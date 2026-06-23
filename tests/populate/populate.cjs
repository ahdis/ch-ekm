// Command-line SDC $populate using the CSIRO/aehrc reference library (@aehrc/sdc-populate) —
// the same engine Smart Forms runs in-app. This is the SDC reference implementation, NOT the
// hosted HAPI $populate (which does not resolve item-level `variable` extensions and lacks the
// extension(url) FHIRPath shortcut — see forms-summary §10).
//
// CommonJS on purpose: like sdc-template-extract, the library's ESM build does a directory
// import of `fhirpath/fhir-context/r4` that Node's native ESM loader rejects; the CJS build
// (dist/index.cjs) resolves it fine, so we require() it here.
//
// Usage:
//   node populate.cjs <questionnaire.json> <patient.json> <practitionerRole.json> <out.json> [fhirServerUrl]
//
// Launch contexts (declared on the modular root, propagated onto the assembled questionnaire):
//   patient (Patient)         -> %patient  passed as `patient`
//   user    (PractitionerRole)-> %user     delivered via `fhirContext` (NOT the `user` param)
//
// Why fhirContext and not the dedicated `user` parameter: @aehrc/sdc-populate's
// createLaunchContextParam() only binds the named `user` parameter when the launchContext's
// declared type is literally 'Practitioner' (hardcoded check); for any other type (incl. our
// PractitionerRole) it falls through to resolving the resource from `fhirContext`, keyed by
// resourceType, and binds it to %user via the launchContext's `name` regardless. This matches how
// the actual Smart Forms renderer expects it too — see the `resolvedFhirContextReferences` comment
// in packages/smart-forms-renderer/src/stores/smartConfigStore.ts ("keyed by resource type e.g.
// { PractitionerRole: <PractitionerRole> }").
//
// %user is the treating physician's PractitionerRole. The Practitioner and Organization fields
// in ChEkmQuestionnaireGonorrhoeaTreatingPhysician read %user.practitioner.resolve() and
// %user.organization.resolve() respectively — fhirpath.js's resolve() function fetches those
// references over HTTP from `fhirServerUrl` (it does NOT go through our fetchResourceCallback),
// so a reachable FHIR server holding the Practitioner/Organization by id is required. We point it
// at the local HAPI instance (./start_hapi.sh + ./load_examples.sh), defaulting to
// http://localhost:8080/fhir.

const { readFileSync, writeFileSync } = require('node:fs');
const { populateQuestionnaire } = require('@aehrc/sdc-populate');

const [, , qPath, patPath, rolePath, outPath, fhirServerUrlArg] = process.argv;
if (!qPath || !patPath || !rolePath || !outPath) {
  console.error(
    'Usage: node populate.cjs <questionnaire.json> <patient.json> <practitionerRole.json> <out.json> [fhirServerUrl]'
  );
  process.exit(2);
}

const fhirServerUrl = fhirServerUrlArg || process.env.CH_EKM_FHIR_BASE || 'http://localhost:8080/fhir';

const questionnaire = JSON.parse(readFileSync(qPath, 'utf8'));
const patient = JSON.parse(readFileSync(patPath, 'utf8'));
const practitionerRole = JSON.parse(readFileSync(rolePath, 'utf8'));

// Resolves fhirContext references (the PractitionerRole) by fetching from the local HAPI instance.
const fetchResourceCallback = async (query) => {
  const url = `${fhirServerUrl.replace(/\/$/, '')}/${String(query).replace(/^\//, '')}`;
  const res = await fetch(url, { headers: { Accept: 'application/fhir+json' } });
  if (!res.ok) {
    throw new Error(`GET ${url} -> HTTP ${res.status}`);
  }
  return res.json();
};

(async () => {
  const { populateSuccess, populateResult } = await populateQuestionnaire({
    questionnaire,
    fetchResourceCallback,
    fetchResourceRequestConfig: { sourceServerUrl: fhirServerUrl },
    patient,
    fhirContext: [
      { role: 'launch', type: 'PractitionerRole', reference: `PractitionerRole/${practitionerRole.id}` }
    ]
  });

  if (!populateSuccess || !populateResult) {
    console.error('Population failed (populateSuccess=false).');
    process.exit(1);
  }

  writeFileSync(outPath, JSON.stringify(populateResult.populatedResponse, null, 2));

  const issues = (populateResult.issues && populateResult.issues.issue) || [];
  console.error(`OK: wrote ${outPath}` + (issues.length ? `, ${issues.length} issue(s)` : ''));
  for (const i of issues) {
    console.error(`  - ${i.severity}: ${i.diagnostics || (i.details && i.details.text) || ''}`);
  }
})();
