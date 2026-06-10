#!/usr/bin/env bash
#
# Assemble the modular Gonorrhoea questionnaire on a matchbox FHIR server.
#
# Matchbox (https://www.matchbox.health) exposes the SDC Questionnaire/$assemble
# operation. It resolves the `subQuestionnaire` canonicals of a modular questionnaire
# from the Questionnaires stored on the server, so this script:
#   1. uploads (PUT) the three assemble-child sub-questionnaires + the modular root,
#   2. calls Questionnaire/$assemble on the root,
#   3. writes the assembled (flattened) questionnaire to disk.
#
# The assembled output can be loaded into the Smart Forms renderer (../smart-forms).
#
# Usage:
#   ./tests/assemble-gonorrhoea.sh [FHIR_BASE_URL]
#
# Defaults to the ahdis test server. Run `sushi .` first so fsh-generated/ is up to date.

set -euo pipefail

# Run from the repo root regardless of where the script is invoked from.
cd "$(dirname "$0")/.."

BASE="${1:-https://test.ahdis.ch/matchbox/fhir}"
DIR="fsh-generated/resources"
OUT="fsh-generated/Questionnaire-ChEkmQuestionnaireGonorrhoea-assembled.json"
CT="Content-Type: application/fhir+json"
ACCEPT="Accept: application/fhir+json"

ROOT_ID="ChEkmQuestionnaireGonorrhoea"
CHILDREN=(
  "ChEkmQuestionnaireGonorrhoeaPerson"
  "ChEkmQuestionnaireGonorrhoeaManifestation"
  "ChEkmQuestionnaireGonorrhoeaExposition"
)

echo "FHIR base: $BASE"
echo

# --- 1. upload the sub-questionnaires and the root ----------------------------
upload() {
  local id="$1"
  local file="$DIR/Questionnaire-$id.json"
  [ -f "$file" ] || { echo "ERROR: missing $file (run 'sushi .' first)"; exit 1; }
  echo "PUT Questionnaire/$id"
  curl -sS -X PUT "$BASE/Questionnaire/$id" \
    -H "$CT" -H "$ACCEPT" \
    --data-binary "@$file" \
    -o /tmp/ekm-put-$id.json -w "  -> HTTP %{http_code}\n"
}

for id in "${CHILDREN[@]}"; do upload "$id"; done
upload "$ROOT_ID"
echo

# --- 2. call $assemble on the root --------------------------------------------
# SDC-conformant input: Parameters with a `questionnaire` parameter holding the
# modular root resource.
echo "POST Questionnaire/\$assemble"
python3 - "$DIR/Questionnaire-$ROOT_ID.json" > /tmp/ekm-assemble-in.json <<'PY'
import json, sys
root = json.load(open(sys.argv[1]))
json.dump({"resourceType": "Parameters",
           "parameter": [{"name": "questionnaire", "resource": root}]},
          sys.stdout)
PY

HTTP=$(curl -sS -X POST "$BASE/Questionnaire/\$assemble" \
  -H "$CT" -H "$ACCEPT" \
  --data-binary "@/tmp/ekm-assemble-in.json" \
  -o /tmp/ekm-assemble-out.json -w "%{http_code}")
echo "  -> HTTP $HTTP"
echo

# --- 3. report ----------------------------------------------------------------
RTYPE=$(jq -r '.resourceType // "?"' /tmp/ekm-assemble-out.json)
if [ "$RTYPE" = "Questionnaire" ]; then
  cp /tmp/ekm-assemble-out.json "$OUT"
  echo "Assembled questionnaire written to: $OUT"
  echo "Top-level items:"
  jq -r '.item[]? | "  - [\(.type)] \(.linkId): \(.text // "")"' "$OUT"
else
  echo "Assemble did not return a Questionnaire (got: $RTYPE). Server response:"
  jq '.' /tmp/ekm-assemble-out.json || cat /tmp/ekm-assemble-out.json
  exit 1
fi
