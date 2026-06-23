#!/usr/bin/env bash
#
# Pre-populate the assembled Gonorrhoea questionnaire using the SDC REFERENCE $populate
# implementation (@aehrc/sdc-populate) — the same engine Smart Forms runs in-app — via a
# small local CommonJS wrapper (tests/populate/populate.cjs).
#
# Why the reference library and NOT the hosted HAPI $populate
# (https://smartforms.csiro.au/api/fhir/Questionnaire/$populate):
#   * HAPI does not resolve item/group-level `variable` extensions, and lacks the
#     extension(url) FHIRPath shortcut (see forms-summary §10);
#   * the reference library matches what the Smart Forms renderer actually does.
#
# Pipeline:  sushi .  ->  assemble-gonorrhoea.sh  ->  this script
#
# Launch contexts (declared on the modular root, propagated onto the assembled questionnaire):
#   patient (Patient)          -> %patient  passed as `patient`
#   user    (PractitionerRole) -> %user     passed as `user`
#
# %user is the treating physician's PractitionerRole. The Practitioner/Organization fields in
# ChEkmQuestionnaireGonorrhoeaTreatingPhysician are populated via %user.practitioner.resolve()
# and %user.organization.resolve() — FHIRPath resolve() fetches those references over HTTP from a
# real FHIR server, so this script requires a LOCAL HAPI INSTANCE with the example resources
# loaded:
#
#   ./start_hapi.sh      # starts HAPI FHIR at http://localhost:8080/fhir
#   ./load_examples.sh   # PUTs Practitioner/Organization/PractitionerRole/Patient examples into it
#
# The resulting QuestionnaireResponse can be handed to the Smart Forms renderer together with
# the questionnaire to show the pre-filled form.
#
# Usage:
#   ./tests/populate-gonorrhoea.sh [PATIENT_ID] [ROLE_ID] [FHIR_BASE_URL]
#
# PATIENT_ID     Patient example id in fsh-generated/resources           (default ChEkmPatientInitialsExample)
# ROLE_ID        PractitionerRole example id (treating physician's role) (default ChEkmPractitionerRoleTreatingPhysicianExample)
# FHIR_BASE_URL  Local HAPI base serving the above (via load_examples.sh) (default http://localhost:8080/fhir)
#
# NOTE: answers only appear once the assembled questionnaire actually carries the launchContext
# + initialExpressions, i.e. after `sushi .` + `assemble-gonorrhoea.sh` have been re-run following
# any pre-population edits.

set -euo pipefail

# Run from the repo root regardless of where the script is invoked from.
cd "$(dirname "$0")/.."

PATIENT_ID="${1:-ChEkmPatientInitialsExample}"
ROLE_ID="${2:-ChEkmPractitionerRoleTreatingPhysicianExample}"
FHIR_BASE_URL="${3:-http://localhost:8080/fhir}"
Q="input/resources/Questionnaire-ChEkmQuestionnaireGonorrhoeaAssembled.json"
PAT="fsh-generated/resources/Patient-$PATIENT_ID.json"
ROLE="fsh-generated/resources/PractitionerRole-$ROLE_ID.json"
OUT="fsh-generated/QuestionnaireResponse-ChEkmQuestionnaireGonorrhoea-populated.json"
WRAPPER_DIR="tests/populate"

[ -f "$Q" ]    || { echo "ERROR: $Q not found. Run tests/assemble-gonorrhoea.sh first."; exit 1; }
[ -f "$PAT" ]  || { echo "ERROR: $PAT not found (run 'sushi .' or pick another PATIENT_ID)."; exit 1; }
[ -f "$ROLE" ] || { echo "ERROR: $ROLE not found (run 'sushi .' or pick another ROLE_ID)."; exit 1; }

if ! curl -sf -o /dev/null "$FHIR_BASE_URL/metadata"; then
  echo "ERROR: no FHIR server reachable at $FHIR_BASE_URL."
  echo "       %user.practitioner.resolve() / %user.organization.resolve() need a live server."
  echo "       Run ./start_hapi.sh, then ./load_examples.sh $FHIR_BASE_URL"
  exit 1
fi

# Install the wrapper's dependency (@aehrc/sdc-populate) on first run.
if [ ! -d "$WRAPPER_DIR/node_modules/@aehrc/sdc-populate" ]; then
  echo "Installing $WRAPPER_DIR dependencies (@aehrc/sdc-populate)..."
  ( cd "$WRAPPER_DIR" && npm install --silent )
fi

echo "Engine:           @aehrc/sdc-populate (SDC reference, in-process)"
echo "Questionnaire:    $Q"
echo "Patient:          $PAT"
echo "PractitionerRole: $ROLE  (-> %user; practitioner/organization resolved via $FHIR_BASE_URL)"
echo

# --- run the SDC reference $populate ------------------------------------------
node "$WRAPPER_DIR/populate.cjs" "$Q" "$PAT" "$ROLE" "$OUT" "$FHIR_BASE_URL"
echo

echo "QuestionnaireResponse written to: $OUT"
COUNT=$(jq '[.. | objects | select(.answer) ] | length' "$OUT")
echo "Pre-filled answers: $COUNT"
jq -r '.. | objects | select(.answer) | "  \(.linkId): \(.answer[0] | (.valueDate // .valueDateTime // .valueString // .valueBoolean // .valueCoding.code // "—"))"' "$OUT"
[ "$COUNT" = "0" ] && echo "(empty — re-run sushi + assemble-gonorrhoea.sh so the assembled questionnaire carries the launchContext + initialExpressions)"
exit 0
