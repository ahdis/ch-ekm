// Command-line SDC $assemble using the CSIRO/aehrc reference library (@aehrc/sdc-assemble) —
// the same engine the Smart Forms renderer runs in-app. This replaces the previous flow that
// POSTed to the hosted HAPI $assemble (smartforms.csiro.au). We switched because:
//
//   - HAPI's $assemble requires every questionnaire it processes (root AND every child) to have
//     the item[0].item nesting, i.e. a wrapping group; a groupless leaf sub-questionnaire is
//     rejected with "Root questionnaire does not have a valid item." The reference engine here
//     tolerates a groupless child (getCanonicalUrls returns [] for a child without item[0].item),
//     so our person leaves can stay flat (no wrapping group) and merge directly into the root.
//   - It matches the other two SDC ops, which already run locally via the reference libraries:
//     $populate (@aehrc/sdc-populate, tests/populate/) and $extract (@aehrc/sdc-template-extract,
//     tests/extract/). No server round-trip / upload step needed.
//
// CommonJS on purpose, same reason as the populate/extract wrappers: the ESM build trips Node's
// loader on a `fhirpath` directory import; the CJS build resolves fine.
//
// Usage:
//   node assemble.cjs <rootQuestionnaire.json> <out.json> [resourcesDir]
//
// The child sub-questionnaires are resolved by canonical url from local files in `resourcesDir`
// (default fsh-generated/resources) — no FHIR server required. This engine keeps the root's
// top-level (item[0]) templateExtract extension and drops its contained Bundle; the caller
// (assemble-questionnaire.sh) re-attaches the contained Bundle to the assembled result.

const { readFileSync, writeFileSync, readdirSync } = require('node:fs');
const { join } = require('node:path');
const { assemble } = require('@aehrc/sdc-assemble');

const [, , rootPath, outPath, resourcesDirArg] = process.argv;
if (!rootPath || !outPath) {
  console.error('Usage: node assemble.cjs <rootQuestionnaire.json> <out.json> [resourcesDir]');
  process.exit(2);
}

const resourcesDir = resourcesDirArg || 'fsh-generated/resources';

// Build a canonical-url -> Questionnaire index from the local generated resources, so the
// fetchQuestionnaireCallback can resolve sub-questionnaires offline.
const byUrl = new Map();
for (const file of readdirSync(resourcesDir)) {
  if (!file.startsWith('Questionnaire-') || !file.endsWith('.json')) continue;
  try {
    const q = JSON.parse(readFileSync(join(resourcesDir, file), 'utf8'));
    if (q && q.resourceType === 'Questionnaire' && q.url) {
      byUrl.set(q.url, q);
      if (q.version) byUrl.set(`${q.url}|${q.version}`, q);
    }
  } catch {
    // ignore non-JSON / unparsable files
  }
}

const rootQuestionnaire = JSON.parse(readFileSync(rootPath, 'utf8'));

// The library hands us the canonical with any version pin rewritten from `|x` to `&version=x`
// (see fetchSubquestionnaires). Normalise back and look up locally; return a searchset Bundle
// whose entry[0].resource is the sub-questionnaire (the shape fetchSubquestionnaires expects).
const fetchQuestionnaireCallback = async (canonicalUrl) => {
  let url = String(canonicalUrl);
  const vIdx = url.indexOf('&version=');
  let versioned = null;
  if (vIdx !== -1) {
    versioned = url.slice(0, vIdx) + '|' + url.slice(vIdx + '&version='.length);
    url = url.slice(0, vIdx);
  }
  const q = (versioned && byUrl.get(versioned)) || byUrl.get(url) || null;
  return {
    resourceType: 'Bundle',
    type: 'searchset',
    entry: q ? [{ resource: q }] : []
  };
};

(async () => {
  const parameters = {
    resourceType: 'Parameters',
    parameter: [{ name: 'questionnaire', resource: rootQuestionnaire }]
  };

  const result = await assemble(parameters, fetchQuestionnaireCallback, {});

  let assembled = null;
  let issues = [];

  if (result && result.resourceType === 'OperationOutcome') {
    console.error('Assemble failed (OperationOutcome):');
    for (const i of result.issue || []) {
      console.error(`  - ${i.severity}: ${i.diagnostics || (i.details && i.details.text) || ''}`);
    }
    process.exit(1);
  } else if (result && result.resourceType === 'Parameters') {
    // OutputParameters: parameter[0] name 'return' (Questionnaire), parameter[1] name 'outcome'.
    const ret = (result.parameter || []).find((p) => p.name === 'return');
    const outcome = (result.parameter || []).find((p) => p.name === 'outcome');
    assembled = ret && ret.resource;
    issues = (outcome && outcome.resource && outcome.resource.issue) || [];
  } else if (result && result.resourceType === 'Questionnaire') {
    assembled = result;
  }

  if (!assembled || assembled.resourceType !== 'Questionnaire') {
    console.error('Assemble did not return a Questionnaire.');
    process.exit(1);
  }

  writeFileSync(outPath, JSON.stringify(assembled, null, 2));
  console.error(`OK: wrote ${outPath}` + (issues.length ? `, ${issues.length} issue(s)` : ''));
  for (const i of issues) {
    console.error(`  - ${i.severity}: ${i.diagnostics || (i.details && i.details.text) || ''}`);
  }
})();
