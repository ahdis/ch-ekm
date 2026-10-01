// Command-line SDC template-based $extract using the CSIRO/aehrc reference library
// (@aehrc/sdc-template-extract) — the same engine Smart Forms runs in-app.
//
// CommonJS on purpose: the library's ESM build does a directory import of
// `fhirpath/fhir-context/r4` which Node's native ESM loader rejects (works only under a
// bundler). The CJS build (dist/index.cjs) resolves it fine, so we require() it here.
//
// Usage:
//   node extract.cjs <questionnaire.json> <questionnaireResponse.json> <out.json> [<transaction-out.json>]
//
// The Questionnaire must already carry the extraction template — i.e. the Bundle template as a
// `contained` resource + a sdc-questionnaire-templateExtract extension (ChEkmQuestionnaireGonorrhoea
// is authored that way in FSH). This is exactly what a renderer such as Smart Forms needs in order
// to offer $extract, so the CLI uses the questionnaire as-is rather than injecting anything.
//
// The reference engine returns a `transaction` Bundle (Profile: ChEkmExtractTransaction) with two
// entries: the document Bundle and the DocumentReference that links it to the launch patient
// (ChEkmDocumentReferenceTemplate). <out.json> receives the document alone (unwrapped), the optional
// <transaction-out.json> the whole transaction — what Smart Forms would POST back to the server.
//
// STABLE IDS. The engine allocates %documentBundleId (sdc-questionnaire-extractAllocateId) and the
// DocumentReference's fullUrl as fresh random UUIDs, so every run would rewrite the IG examples. This
// CLI replaces both with UUIDs derived from the QuestionnaireResponse id (name-based, SHA-1), and sets
// the transaction's id (from its file name) and timestamp (= authored). Same QR in, same files out;
// the links between the two entries are kept because every occurrence of a UUID is replaced.

const { createHash } = require('node:crypto');
const { readFileSync, writeFileSync } = require('node:fs');
const { basename } = require('node:path');
const { inAppExtract, extractResultIsOperationOutcome } = require('@aehrc/sdc-template-extract');

const [, , qPath, qrPath, outPath, txOutPath] = process.argv;
if (!qPath || !qrPath || !outPath) {
  console.error('Usage: node extract.cjs <questionnaire.json> <questionnaireResponse.json> <out.json> [<transaction-out.json>]');
  process.exit(2);
}

// Name-based (version 5 layout) UUID from a string.
function stableUuid(name) {
  const h = createHash('sha1').update(name).digest('hex');
  const variant = ((parseInt(h[16], 16) & 0x3) | 0x8).toString(16);
  return `${h.slice(0, 8)}-${h.slice(8, 12)}-5${h.slice(13, 16)}-${variant}${h.slice(17, 20)}-${h.slice(20, 32)}`;
}

function stabilise(transactionBundle, qr) {
  const seed = `ch-ekm/${qr.id || basename(qrPath)}`;
  let json = JSON.stringify(transactionBundle);
  for (const entry of transactionBundle.entry || []) {
    const m = /^urn:uuid:(.+)$/.exec(entry.fullUrl || '');
    if (!m) continue;
    const kind = entry.resource && entry.resource.resourceType;
    json = json.split(m[1]).join(stableUuid(`${seed}/${kind}`));
  }
  const stable = JSON.parse(json);
  if (txOutPath) stable.id = basename(txOutPath, '.json').replace(/^Bundle-/, '');
  if (qr.authored) stable.timestamp = qr.authored;
  return stable;
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

  const transactionBundle = stabilise(extractResult.extractedBundle, questionnaireResponse);

  // Unwrap the document Bundle from the outer transaction Bundle.
  const documentEntry = (transactionBundle.entry || []).find((e) => e.resource && e.resource.resourceType === 'Bundle');
  const documentBundle = documentEntry ? documentEntry.resource : transactionBundle;

  writeFileSync(outPath, JSON.stringify(documentBundle, null, 2));
  if (txOutPath) {
    writeFileSync(txOutPath, JSON.stringify(transactionBundle, null, 2));
    console.error(
      `OK: wrote ${txOutPath} (Bundle.type=${transactionBundle.type}, entries=` +
        (transactionBundle.entry || []).map((e) => `${e.request.method} ${e.request.url}`).join(', ') + ')'
    );
  }

  const issues = (extractResult.issues && extractResult.issues.issue) || [];
  console.error(
    `OK: wrote ${outPath} (Bundle.type=${documentBundle.type}, entries=${(documentBundle.entry || []).length})` +
      (issues.length ? `, ${issues.length} warning(s)` : '')
  );
  for (const i of issues) {
    console.error(`  - ${i.severity}: ${i.diagnostics || (i.details && i.details.text) || ''}`);
  }
})();
