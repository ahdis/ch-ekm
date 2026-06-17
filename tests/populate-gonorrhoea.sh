#!/usr/bin/env bash
#
# Pre-populate the assembled Gonorrhoea questionnaire with a patient, using the
# Smart Forms (aehrc/CSIRO) SDC $populate service.
#
# Hosted endpoint: https://smartforms.csiro.au/api/fhir/Questionnaire/$populate
# (TypeScript sdc-populate microservice, see ../smart-forms/packages/sdc-populate).
#
# Pipeline:  sushi .  ->  assemble-gonorrhoea.sh  ->  this script
#
# It POSTs the assembled questionnaire + an example Patient (as the `patient` launch
# context) to $populate and writes the returned QuestionnaireResponse to disk. The
# answers come from the items' sdc-questionnaire-initialExpression extensions, which read
# from %patient (declared via the launchContext on the modular root, propagated onto the
# assembled questionnaire).
#
# The resulting QuestionnaireResponse can be handed to the Smart Forms renderer together
# with the questionnaire to show the pre-filled form.
#
# As with $assemble, the service uses express.json() so Content-Type MUST be
# application/json (application/fhir+json arrives empty).
#
# Usage:
#   ./tests/populate-gonorrhoea.sh [PATIENT_ID] [FHIR_BASE_URL]
#
# PATIENT_ID   id of a Patient example in fsh-generated/resources (default ChEkmPatientExample)
# FHIR_BASE_URL default https://smartforms.csiro.au/api/fhir
#
# NOTE: the answers only appear once the assembled questionnaire actually carries the
# launchContext + initialExpressions, i.e. after `sushi .` + `assemble-gonorrhoea.sh` have
# been re-run following the pre-population edits. Until then the QuestionnaireResponse is
# returned empty.

set -euo pipefail

# Run from the repo root regardless of where the script is invoked from.
cd "$(dirname "$0")/.."

PATIENT_ID="${1:-ChEkmPatientExample}"
BASE="${2:-https://smartforms.csiro.au/api/fhir}"
Q="input/resources/Questionnaire-ChEkmQuestionnaireGonorrhoeaAssembled.json"
PAT="fsh-generated/resources/Patient-$PATIENT_ID.json"
OUT="fsh-generated/QuestionnaireResponse-ChEkmQuestionnaireGonorrhoea-populated.json"
CT="Content-Type: application/json"
ACCEPT="Accept: application/json"

[ -f "$Q" ]   || { echo "ERROR: $Q not found. Run tests/assemble-gonorrhoea.sh first."; exit 1; }
[ -f "$PAT" ] || { echo "ERROR: $PAT not found (run 'sushi .' or pick another PATIENT_ID)."; exit 1; }

echo "FHIR base:   $BASE"
echo "Questionnaire: $Q"
echo "Patient:       $PAT"
echo

# --- build $populate input Parameters -----------------------------------------
python3 - "$Q" "$PAT" > /tmp/ekm-populate-in.json <<'PY'
import json, sys
q = json.load(open(sys.argv[1]))
pat = json.load(open(sys.argv[2]))
params = {
    "resourceType": "Parameters",
    "parameter": [
        {"name": "questionnaire", "resource": q},
        {"name": "subject", "valueReference": {"type": "Patient", "reference": "Patient/" + pat["id"]}},
        # local=false: the questionnaire is supplied in the request, not resolved from a server
        {"name": "local", "valueBoolean": False},
        {"name": "context", "part": [
            {"name": "name", "valueString": "patient"},
            {"name": "content", "resource": pat},
        ]},
    ],
}
json.dump(params, sys.stdout)
PY

# --- call $populate -----------------------------------------------------------
echo "POST Questionnaire/\$populate"
HTTP=$(curl -sS -X POST "$BASE/Questionnaire/\$populate" \
  -H "$CT" -H "$ACCEPT" \
  --data-binary "@/tmp/ekm-populate-in.json" \
  -o /tmp/ekm-populate-out.json -w "%{http_code}")
echo "  -> HTTP $HTTP"
echo

# --- extract the QuestionnaireResponse ----------------------------------------
# $populate returns Parameters with a `response` parameter holding the QuestionnaireResponse.
jq -e '.parameter[]? | select(.name=="response") | .resource' /tmp/ekm-populate-out.json > "$OUT" 2>/dev/null || {
  echo "No QuestionnaireResponse returned. Server response:"
  jq '.' /tmp/ekm-populate-out.json || cat /tmp/ekm-populate-out.json
  exit 1
}

echo "QuestionnaireResponse written to: $OUT"
COUNT=$(jq '[.. | objects | select(.answer) ] | length' "$OUT")
echo "Pre-filled answers: $COUNT"
jq -r '.. | objects | select(.answer) | "  \(.linkId): \(.answer[0] | (.valueDate // .valueDateTime // .valueString // .valueBoolean // .valueCoding.code // "—"))"' "$OUT"
[ "$COUNT" = "0" ] && echo "(empty — re-run sushi + assemble-gonorrhoea.sh so the assembled questionnaire carries the launchContext + initialExpressions)"
exit 0
