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
//   node populate.cjs <questionnaire.json> <patient.json> <practitioner.json> <organization.json> <out.json>
//
// Launch contexts (declared on the modular root, propagated onto the assembled questionnaire):
//   patient      (Patient)      -> %patient        passed as `patient`
//   user         (Practitioner) -> %user           passed as `user`
//   organization (Organization) -> %organization   passed via `fhirContext` (SMART App Launch
//                                                   mechanism), resolved by the fetch callback.
//
// The reference populate binds any non-patient/user launchContext from fhirContext by
// resourceType, which is exactly how a real SMART launch would deliver the Organization.

const { readFileSync, writeFileSync } = require('node:fs');
const { populateQuestionnaire } = require('@aehrc/sdc-populate');

const [, , qPath, patPath, practPath, orgPath, outPath] = process.argv;
if (!qPath || !patPath || !practPath || !orgPath || !outPath) {
  console.error(
    'Usage: node populate.cjs <questionnaire.json> <patient.json> <practitioner.json> <organization.json> <out.json>'
  );
  process.exit(2);
}

const questionnaire = JSON.parse(readFileSync(qPath, 'utf8'));
const patient = JSON.parse(readFileSync(patPath, 'utf8'));
const user = JSON.parse(readFileSync(practPath, 'utf8'));
const organization = JSON.parse(readFileSync(orgPath, 'utf8'));

// Resolve fhirContext (and any other) references locally — no FHIR server involved.
const localResources = {
  [`Organization/${organization.id}`]: organization,
  [`Practitioner/${user.id}`]: user,
  [`Patient/${patient.id}`]: patient
};
const fetchResourceCallback = (query) => {
  const ref = String(query).split('?')[0];
  const resource = localResources[ref];
  if (!resource) {
    return Promise.reject(new Error(`No local resource for reference "${query}"`));
  }
  return Promise.resolve(resource);
};

(async () => {
  const { populateSuccess, populateResult } = await populateQuestionnaire({
    questionnaire,
    fetchResourceCallback,
    fetchResourceRequestConfig: {},
    patient,
    user,
    // The Organization is delivered the SMART App Launch way: as a fhirContext entry.
    fhirContext: [
      { role: 'launch', type: 'Organization', reference: `Organization/${organization.id}` }
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
