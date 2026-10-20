#!/usr/bin/env bash
#
# Upload CH EKM questionnaires to the Smart Forms Forms Server, so they show up in the hosted
# renderer's questionnaire picker. Disease-agnostic: pass the modular ROOT id, or one file.
#
# The Forms Server holds only the per-language previews (<RootId>-de-CH / -fr-CH / -it-CH): they
# render without a terminology server and are what a clinician picks. The assembled questionnaire
# (<RootId>Assembled) stays in the IG — passing a root id publishes its language previews, not it.
#
# Default Forms Server: https://smartforms.ahdis.ch/api/fhir (HAPI 8.8.0 patched, R4 —
# image hapi-fhir:8.8.0-pr8260-pr8371, built from https://github.com/ahdis/hapi-fhir/tree/v8.8.0-pr8260-pr8371).
# The renderer web app is the host root (https://smartforms.ahdis.ch/), NOT a FHIR server —
# do not PUT there. Same split as the CSIRO deployment (smartforms.csiro.au/api/fhir).
#
# Pipeline:  sushi .  ->  assemble-questionnaire.sh <RootId>  ->  this script
#
# It PUTs each questionnaire by id, so the form is self-contained on the server (the modular
# sub-questionnaires are already merged in by $assemble). PUT is an upsert by id, so re-running
# updates the existing resource instead of creating duplicates.
#
# The artifact is uploaded VERBATIM — the contained SDC extraction template and every
# templateExtract directive go up exactly as authored, so the server copy and the file in
# input/resources/ are the same resource.
#
# Stock HAPI cannot store that: it rejects the contained template outright
# (https://github.com/hapifhir/hapi-fhir/issues/8238, fix PR #8260 still unmerged) and silently drops
# extensions on repeating primitives that SUSHI leaves unpadded
# (https://github.com/hapifhir/hapi-fhir/issues/8370, fixed in 8.14.0; https://github.com/FHIR/sushi/issues/1631).
# smartforms.ahdis.ch runs a HAPI patched with both fixes. Any other server — or that one rebuilt
# without the patches — can fail either way, which is why the upload is checked against the artifact
# at the end rather than trusted on its status code — see forms-summary.md §9.
#
# As with the other Smart Forms scripts, send Content-Type application/json.
#
# Usage:
#   ./scripts/upload-questionnaire.sh <RootQuestionnaireId|QUESTIONNAIRE_JSON> [FHIR_BASE_URL]
#   ./scripts/upload-questionnaire.sh ChEkmQuestionnaireGonorrhoea      # its three language previews
#   PREVIEW_LANG=de-CH ./scripts/upload-questionnaire.sh ChEkmQuestionnaireMpox
#   ./scripts/upload-questionnaire.sh input/resources/Questionnaire-ChEkmQuestionnaireMpox-fr-CH.json
#
set -euo pipefail

# Run from the repo root regardless of where the script is invoked from.
cd "$(dirname "$0")/.."

TARGET="${1:?usage: upload-questionnaire.sh <RootQuestionnaireId|QUESTIONNAIRE_JSON> [FHIR_BASE_URL]}"
BASE="${2:-https://smartforms.ahdis.ch/api/fhir}"
CT="Content-Type: application/json"
ACCEPT="Accept: application/json"

# A modular root id stands for its language previews (PREVIEW_LANG overrides the three Swiss
# languages, as in build-lang-questionnaire.py); each one is uploaded by a call with its file.
if [ ! -f "$TARGET" ]; then
  for lang in ${PREVIEW_LANG:-de-CH fr-CH it-CH}; do
    f="input/resources/Questionnaire-${TARGET}-${lang}.json"
    [ -f "$f" ] || { echo "ERROR: $f not found. Run scripts/assemble-questionnaire.sh ${TARGET} first."; exit 1; }
    scripts/upload-questionnaire.sh "$f" "$BASE"
    echo
  done
  exit 0
fi
Q="$TARGET"

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
