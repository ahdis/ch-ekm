// Command-line SDC template-based $extract using the CSIRO/aehrc reference library
// (@aehrc/sdc-template-extract) — the same engine Smart Forms runs in-app.
//
// CommonJS on purpose: the library's ESM build does a directory import of
// `fhirpath/fhir-context/r4` which Node's native ESM loader rejects (works only under a
// bundler). The CJS build (dist/index.cjs) resolves it fine, so we require() it here.
//
// Usage:
//   node extract.cjs <questionnaire.json> <questionnaireResponse.json> <out.json>
//
// The Questionnaire must already carry the extraction template — i.e. the Bundle template as a
// `contained` resource + a sdc-questionnaire-templateExtract extension (ChEkmQuestionnaireGonorrhoea
// is authored that way in FSH). This is exactly what a renderer such as Smart Forms needs in order
// to offer $extract, so the CLI uses the questionnaire as-is rather than injecting anything.
//
// The reference engine always returns a `transaction` Bundle wrapping the extracted resource(s).
// Because our template is a single document Bundle, the document we want is entry[0].resource —
// we unwrap it and write that out.

const { readFileSync, writeFileSync } = require('node:fs');
const { inAppExtract, extractResultIsOperationOutcome } = require('@aehrc/sdc-template-extract');

const [, , qPath, qrPath, outPath] = process.argv;
if (!qPath || !qrPath || !outPath) {
  console.error('Usage: node extract.cjs <questionnaire.json> <questionnaireResponse.json> <out.json>');
  process.exit(2);
}

const questionnaire = JSON.parse(readFileSync(qPath, 'utf8'));
const questionnaireResponse = JSON.parse(readFileSync(qrPath, 'utf8'));

(async () => {
  const { extractSuccess, extractResult } = await inAppExtract(questionnaireResponse, questionnaire, null);

  if (!extractSuccess || extractResultIsOperationOutcome(extractResult)) {
    console.error('Extraction failed / returned an OperationOutcome:');
    console.error(JSON.stringify(extractResult, null, 2));
    process.exit(1);
  }

  const transactionBundle = extractResult.extractedBundle;

  // Unwrap the single document Bundle from the outer transaction Bundle.
  const first = transactionBundle.entry && transactionBundle.entry[0] && transactionBundle.entry[0].resource;
  const documentBundle = first && first.resourceType === 'Bundle' ? first : transactionBundle;

  writeFileSync(outPath, JSON.stringify(documentBundle, null, 2));

  const issues = (extractResult.issues && extractResult.issues.issue) || [];
  console.error(
    `OK: wrote ${outPath} (Bundle.type=${documentBundle.type}, entries=${(documentBundle.entry || []).length})` +
      (issues.length ? `, ${issues.length} warning(s)` : '')
  );
  for (const i of issues) {
    console.error(`  - ${i.severity}: ${i.diagnostics || (i.details && i.details.text) || ''}`);
  }
})();
