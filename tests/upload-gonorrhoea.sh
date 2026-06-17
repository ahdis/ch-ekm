#!/usr/bin/env bash
#
# Upload the assembled Gonorrhoea questionnaire to the Smart Forms Forms Server, so it
# shows up in the hosted renderer's questionnaire picker (https://smartforms.csiro.au).
#
# Forms Server endpoint: https://smartforms.csiro.au/api/fhir/Questionnaire
# (the HAPI storage server the renderer lists/loads questionnaires from — the same
# /api/fhir base the assemble/populate scripts use. NB: https://smartforms.csiro.au/fhir
# is the renderer web app, not a FHIR server, so do not PUT there.)
#
# Pipeline:  sushi .  ->  assemble-gonorrhoea.sh  ->  this script
#
# It PUTs the assembled (flattened) questionnaire by id so the form is self-contained on
# the server (the modular sub-questionnaires are already merged in by $assemble). Use PUT
# (upsert by id) so re-running the script updates the existing resource instead of creating
# duplicates.
#
# The contained SDC extraction template (Bundle + templateExtract wiring) is stripped before
# upload: it uses a data-absent-reason extension that carries both sub-extensions and a value,
# which HAPI's strict parser rejects (HAPI-1811, "must not have both a value and other
# contained extensions"). The renderer does not need it to render/populate the form — it is
# only used by $extract — so the server copy drops it.
#
# As with the other Smart Forms scripts, send Content-Type application/json.
#
# Usage:
#   ./tests/upload-gonorrhoea.sh [QUESTIONNAIRE_JSON] [FHIR_BASE_URL]
#
# QUESTIONNAIRE_JSON  questionnaire to upload (default: the assembled questionnaire)
# FHIR_BASE_URL       Forms Server base (default https://smartforms.csiro.au/api/fhir)

set -euo pipefail

# Run from the repo root regardless of where the script is invoked from.
cd "$(dirname "$0")/.."

Q="${1:-input/resources/Questionnaire-ChEkmQuestionnaireGonorrhoeaAssembled.json}"
BASE="${2:-https://smartforms.csiro.au/api/fhir}"
CT="Content-Type: application/json"
ACCEPT="Accept: application/json"

[ -f "$Q" ] || { echo "ERROR: $Q not found. Run tests/assemble-gonorrhoea.sh first."; exit 1; }

ID=$(jq -r '.id' "$Q")
[ "$ID" != "null" ] && [ -n "$ID" ] || { echo "ERROR: $Q has no id."; exit 1; }

# Strip the contained extraction template (see header) so HAPI accepts the resource.
# meta.profile claiming sdc-questionnaire-extr-template is dropped too, since the template
# it refers to is gone.
BODY="/tmp/ekm-upload-in.json"
jq 'del(.contained)
    | (.meta.profile) |= (if . then map(select(endswith("sdc-questionnaire-extr-template") | not)) else . end)
    | if (.meta.profile // []) == [] then del(.meta.profile) else . end' "$Q" > "$BODY"

echo "FHIR base:     $BASE"
echo "Questionnaire: $Q (id: $ID)"
echo "  (contained extraction template stripped for upload)"
echo

echo "PUT Questionnaire/$ID"
HTTP=$(curl -sS -X PUT "$BASE/Questionnaire/$ID" \
  -H "$CT" -H "$ACCEPT" \
  --data-binary "@$BODY" \
  -o /tmp/ekm-upload-out.json -w "%{http_code}")
echo "  -> HTTP $HTTP"
echo

RTYPE=$(jq -r '.resourceType // "?"' /tmp/ekm-upload-out.json)
if [ "$RTYPE" != "Questionnaire" ]; then
  echo "Upload failed (server returned: $RTYPE). Server response:"
  jq '.' /tmp/ekm-upload-out.json || cat /tmp/ekm-upload-out.json
  exit 1
fi

URL=$(jq -r '.url' /tmp/ekm-upload-out.json)
echo "Uploaded. The questionnaire is now available on the Forms Server:"
echo "  $BASE/Questionnaire/$ID"
echo "  canonical: $URL"
echo
echo "Open it in the hosted renderer:"
echo "  https://smartforms.csiro.au/?questionnaireUrl=$URL"
