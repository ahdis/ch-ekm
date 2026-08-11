#!/usr/bin/env bash
#
# Upload an assembled CH EKM questionnaire to the Smart Forms Forms Server, so it shows up in the
# hosted renderer's questionnaire picker. Disease-agnostic: pass the modular ROOT id.
#
# Default Forms Server: https://smartforms.ahdis.ch/api/fhir (Blaze 1.10.1, R4).
# The renderer web app is the host root (https://smartforms.ahdis.ch/), NOT a FHIR server —
# do not PUT there. Same split as the CSIRO deployment (smartforms.csiro.au/api/fhir).
#
# Pipeline:  sushi .  ->  assemble-questionnaire.sh <RootId>  ->  this script
#
# It PUTs the assembled (flattened) questionnaire by id so the form is self-contained on the
# server (the modular sub-questionnaires are already merged in by $assemble). PUT is an upsert by
# id, so re-running updates the existing resource instead of creating duplicates.
#
# The artifact is uploaded VERBATIM — the contained SDC extraction template and every
# templateExtract directive go up exactly as authored, so the server copy and the file in
# input/resources/ are the same resource. Blaze stores what it is given and returns it unchanged.
#
# Not every server manages that. HAPI rejects the contained template outright
# (https://github.com/hapifhir/hapi-fhir/issues/8238) and silently drops extensions on repeating
# primitives that SUSHI leaves unpadded (https://github.com/FHIR/sushi/issues/1631). That is why
# smartforms.ahdis.ch runs Blaze, and why the upload is checked against the artifact at the end
# rather than trusted on its status code — see forms-summary.md §9.
#
# As with the other Smart Forms scripts, send Content-Type application/json.
#
# Usage:
#   ./scripts/upload-questionnaire.sh <RootQuestionnaireId|QUESTIONNAIRE_JSON> [FHIR_BASE_URL]
#   ./scripts/upload-questionnaire.sh ChEkmQuestionnaireGonorrhoea
#   ./scripts/upload-questionnaire.sh ChEkmQuestionnaireMpox
#
set -euo pipefail

# Run from the repo root regardless of where the script is invoked from.
cd "$(dirname "$0")/.."

TARGET="${1:?usage: upload-questionnaire.sh <RootQuestionnaireId|QUESTIONNAIRE_JSON> [FHIR_BASE_URL]}"
BASE="${2:-https://smartforms.ahdis.ch/api/fhir}"
CT="Content-Type: application/json"
ACCEPT="Accept: application/json"

# Accept either a path to the assembled json or a modular root questionnaire id.
if [ -f "$TARGET" ]; then
  Q="$TARGET"
else
  Q="input/resources/Questionnaire-${TARGET}Assembled.json"
fi
[ -f "$Q" ] || { echo "ERROR: $Q not found. Run scripts/assemble-questionnaire.sh ${TARGET} first."; exit 1; }

ID=$(jq -r '.id // empty' "$Q")
[ -n "$ID" ] || { echo "ERROR: $Q has no id."; exit 1; }

OUT="$(mktemp -t ekm-upload-out)"
trap 'rm -f "$OUT"' EXIT

SENT=$(jq '[.. | objects | select(.url? // "" | endswith("templateExtractValue"))] | length' "$Q")

echo "FHIR base:     $BASE"
echo "Questionnaire: $Q (id: $ID)"
echo "  contained:   $(jq '(.contained // []) | length' "$Q") resource(s) — extraction template sent verbatim"
echo "  sending:     $SENT templateExtractValue directive(s)"
echo

echo "PUT Questionnaire/$ID"
HTTP=$(curl -sS -X PUT "$BASE/Questionnaire/$ID" \
  -H "$CT" -H "$ACCEPT" \
  --data-binary "@$Q" \
  -o "$OUT" -w "%{http_code}")
echo "  -> HTTP $HTTP"
echo

RTYPE=$(jq -r '.resourceType // "?"' "$OUT")
if [ "$RTYPE" != "Questionnaire" ]; then
  echo "Upload failed (server returned: $RTYPE). Server response:"
  jq '.' "$OUT" || cat "$OUT"
  exit 1
fi

URL=$(jq -r '.url' "$OUT")

# A server can drop extensions without reporting an error (HAPI does, see header), so verify the
# stored copy against the artifact instead of trusting the 200/201.
STORED=$(jq '[.. | objects | select(.url? // "" | endswith("templateExtractValue"))] | length' "$OUT")
echo "Uploaded. The questionnaire is now available on the Forms Server:"
echo "  $BASE/Questionnaire/$ID"
echo "  canonical: $URL"
echo "  contained on server: $(jq '(.contained // []) | length' "$OUT") resource(s)"
if [ "$STORED" = "$SENT" ]; then
  echo "  directives: $STORED/$SENT templateExtractValue preserved"
else
  echo "  WARNING: server stored $STORED of $SENT templateExtractValue directives — $((SENT - STORED)) silently dropped."
fi
if diff <(jq -S 'del(.meta)' "$Q") <(jq -S 'del(.meta)' "$OUT") >/dev/null 2>&1; then
  echo "  round-trip: identical to $Q"
else
  echo "  NOTE: the stored copy differs from $Q (beyond .meta) — diff them to see what the server changed."
fi
echo
echo "Open it in the hosted renderer:"
echo "  ${BASE%/api/fhir}/?questionnaireUrl=$URL"
