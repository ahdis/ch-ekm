#!/usr/bin/env bash
#
# Pre-populate the assembled Gonorrhoea questionnaire using the SDC REFERENCE $populate
# implementation (@aehrc/sdc-populate) — the same engine Smart Forms runs in-app — via a
# small local CommonJS wrapper (tests/populate/populate.cjs). This is run in-process; no
# FHIR server is involved (resources are resolved from local files).
#
# Why the reference library and NOT the hosted HAPI $populate
# (https://smartforms.csiro.au/api/fhir/Questionnaire/$populate):
#   * HAPI does not resolve item/group-level `variable` extensions, and lacks the
#     extension(url) FHIRPath shortcut (see forms-summary §10);
#   * the reference library matches what the Smart Forms renderer actually does, including
#     resolving non-patient/user launch contexts from the SMART App Launch `fhirContext`.
#
# Pipeline:  sushi .  ->  assemble-gonorrhoea.sh  ->  this script
#
# Launch contexts (declared on the modular root, propagated onto the assembled questionnaire):
#   patient      (Patient)      -> %patient        passed as `patient`
#   user         (Practitioner) -> %user           passed as `user`
#   organization (Organization) -> %organization   passed via `fhirContext` (SMART App Launch)
#
# The resulting QuestionnaireResponse can be handed to the Smart Forms renderer together with
# the questionnaire to show the pre-filled form.
#
# Usage:
#   ./tests/populate-gonorrhoea.sh [PATIENT_ID] [PRACT_ID] [ORG_ID]
#
# PATIENT_ID  Patient example id in fsh-generated/resources      (default ChEkmPatientExample)
# PRACT_ID    Practitioner example id (treating physician)       (default ChEkmPractitionerTreatingPhysicianExample)
# ORG_ID      Organization example id (sending organization)     (default ChEkmOrganizationTreatingPhysicianExample)
#
# NOTE: answers only appear once the assembled questionnaire actually carries the launchContexts
# + initialExpressions, i.e. after `sushi .` + `assemble-gonorrhoea.sh` have been re-run following
# any pre-population edits.

set -euo pipefail

# Run from the repo root regardless of where the script is invoked from.
cd "$(dirname "$0")/.."

PATIENT_ID="${1:-ChEkmPatientExample}"
PRACT_ID="${2:-ChEkmPractitionerTreatingPhysicianExample}"
ORG_ID="${3:-ChEkmOrganizationTreatingPhysicianExample}"
Q="input/resources/Questionnaire-ChEkmQuestionnaireGonorrhoeaAssembled.json"
PAT="fsh-generated/resources/Patient-$PATIENT_ID.json"
PRACT="fsh-generated/resources/Practitioner-$PRACT_ID.json"
ORG="fsh-generated/resources/Organization-$ORG_ID.json"
OUT="fsh-generated/QuestionnaireResponse-ChEkmQuestionnaireGonorrhoea-populated.json"
WRAPPER_DIR="tests/populate"

[ -f "$Q" ]     || { echo "ERROR: $Q not found. Run tests/assemble-gonorrhoea.sh first."; exit 1; }
[ -f "$PAT" ]   || { echo "ERROR: $PAT not found (run 'sushi .' or pick another PATIENT_ID)."; exit 1; }
[ -f "$PRACT" ] || { echo "ERROR: $PRACT not found (run 'sushi .' or pick another PRACT_ID)."; exit 1; }
[ -f "$ORG" ]   || { echo "ERROR: $ORG not found (run 'sushi .' or pick another ORG_ID)."; exit 1; }

# Install the wrapper's dependency (@aehrc/sdc-populate) on first run.
if [ ! -d "$WRAPPER_DIR/node_modules/@aehrc/sdc-populate" ]; then
  echo "Installing $WRAPPER_DIR dependencies (@aehrc/sdc-populate)..."
  ( cd "$WRAPPER_DIR" && npm install --silent )
fi

echo "Engine:        @aehrc/sdc-populate (SDC reference, in-process)"
echo "Questionnaire: $Q"
echo "Patient:       $PAT"
echo "Practitioner:  $PRACT  (-> %user)"
echo "Organization:  $ORG  (-> %organization, via fhirContext)"
echo

# --- run the SDC reference $populate ------------------------------------------
node "$WRAPPER_DIR/populate.cjs" "$Q" "$PAT" "$PRACT" "$ORG" "$OUT"
echo

echo "QuestionnaireResponse written to: $OUT"
COUNT=$(jq '[.. | objects | select(.answer) ] | length' "$OUT")
echo "Pre-filled answers: $COUNT"
jq -r '.. | objects | select(.answer) | "  \(.linkId): \(.answer[0] | (.valueDate // .valueDateTime // .valueString // .valueBoolean // .valueCoding.code // "—"))"' "$OUT"
[ "$COUNT" = "0" ] && echo "(empty — re-run sushi + assemble-gonorrhoea.sh so the assembled questionnaire carries the launchContexts + initialExpressions)"
exit 0
