#!/usr/bin/env bash
#
# Pre-populate the assembled invasive pneumococcal disease questionnaire using the SDC REFERENCE
# $populate implementation (@aehrc/sdc-populate) — the same engine Smart Forms runs in-app — via the
# shared local CommonJS wrapper (scripts/populate/populate.cjs). Same pipeline and rationale as
# scripts/populate-mpox.sh and scripts/populate-hepatitisc.sh.
#
# Pipeline:  sushi .  ->  scripts/assemble-invasivepneumococcaldisease.sh  ->  this script
#
# Launch contexts (declared on the modular root, propagated onto the assembled questionnaire):
#   patient   (Patient)          -> %patient    the affected person. This form reports INITIALS
#                                               only (ChEkmCompositionInvasivePneumococcalDisease
#                                               constrains subject to ChEkmPatientInitials), so the
#                                               default is ChEkmPatientInitialsExample — the same
#                                               patient the example Bundle uses
#   user      (PractitionerRole) -> %user       the treating physician's role
#   encounter (Encounter)        -> %encounter  the hospitalisation, read by the three items of the
#                                               "Verlauf" section (ChEkmQuestionnaireHospitalisation)
#
# This form has a "Verlauf" section like Mpox and Hepatitis C, so it needs the encounter context too.
# The organism HAS its own Encounter example (ChEkmEncounterExample-InvasivePneumococcalDisease, in
# the example Bundle), so that is the default here rather than the Mpox one. Passing NO Encounter is
# not useful: the expressions reference %encounter, which would then be unbound.
#
# %user is the treating physician's PractitionerRole. The Practitioner/Organization fields are
# populated via %user.practitioner.resolve() / %user.organization.resolve() — FHIRPath resolve()
# fetches those references over HTTP from a real FHIR server, so this script requires a LOCAL HAPI
# INSTANCE with the example resources loaded:
#
#   ./scripts/start_hapi.sh                                  # HAPI FHIR at http://localhost:8080/fhir
#   ./scripts/load_examples.sh http://localhost:8080/fhir    # ALWAYS pass the base URL — the script
#                                                            # defaults to the REMOTE Forms Server
#
# Usage:
#   ./scripts/populate-invasivepneumococcaldisease.sh [PATIENT_ID] [ROLE_ID] [ENCOUNTER_ID] [FHIR_BASE_URL]
#
# PATIENT_ID     Patient example id in fsh-generated/resources           (default ChEkmPatientInitialsExample)
# ROLE_ID        PractitionerRole example id (treating physician's role) (default ChEkmPractitionerRoleTreatingPhysicianExample)
# ENCOUNTER_ID   Encounter example id (the hospitalisation)              (default ChEkmEncounterExample-InvasivePneumococcalDisease)
# FHIR_BASE_URL  Local HAPI base serving the above (via load_examples.sh) (default http://localhost:8080/fhir)

set -euo pipefail

# Run from the repo root regardless of where the script is invoked from.
cd "$(dirname "$0")/.."

PATIENT_ID="${1:-ChEkmPatientInitialsExample}"
ROLE_ID="${2:-ChEkmPractitionerRoleTreatingPhysicianExample}"
ENCOUNTER_ID="${3:-ChEkmEncounterExample-InvasivePneumococcalDisease}"
FHIR_BASE_URL="${4:-http://localhost:8080/fhir}"
Q="input/resources/Questionnaire-ChEkmQuestionnaireInvasivePneumococcalDiseaseAssembled.json"
PAT="fsh-generated/resources/Patient-$PATIENT_ID.json"
ROLE="fsh-generated/resources/PractitionerRole-$ROLE_ID.json"
ENC="fsh-generated/resources/Encounter-$ENCOUNTER_ID.json"
OUT="fsh-generated/QuestionnaireResponse-ChEkmQuestionnaireInvasivePneumococcalDisease-populated.json"
WRAPPER_DIR="scripts/populate"

[ -f "$Q" ]    || { echo "ERROR: $Q not found. Run scripts/assemble-invasivepneumococcaldisease.sh first."; exit 1; }
[ -f "$PAT" ]  || { echo "ERROR: $PAT not found (run 'sushi .' or pick another PATIENT_ID)."; exit 1; }
[ -f "$ROLE" ] || { echo "ERROR: $ROLE not found (run 'sushi .' or pick another ROLE_ID)."; exit 1; }
[ -f "$ENC" ]  || { echo "ERROR: $ENC not found (run 'sushi .' or pick another ENCOUNTER_ID)."; exit 1; }

if ! curl -sf -o /dev/null "$FHIR_BASE_URL/metadata"; then
  echo "ERROR: no FHIR server reachable at $FHIR_BASE_URL."
  echo "       %user.practitioner.resolve() / %user.organization.resolve() need a live server."
  echo "       Run ./scripts/start_hapi.sh, then ./scripts/load_examples.sh $FHIR_BASE_URL"
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
echo "Encounter:        $ENC  (-> %encounter; the hospitalisation)"
echo

# --- run the SDC reference $populate ------------------------------------------
node "$WRAPPER_DIR/populate.cjs" "$Q" "$PAT" "$ROLE" "$OUT" "$FHIR_BASE_URL" "$ENC"
echo

echo "QuestionnaireResponse written to: $OUT"
COUNT=$(jq '[.. | objects | select(.answer) ] | length' "$OUT")
echo "Pre-filled answers: $COUNT"
jq -r '.. | objects | select(.answer) | "  \(.linkId): \(.answer[0] | (.valueDate // .valueDateTime // .valueString // .valueBoolean // .valueCoding.code // "—"))"' "$OUT"
[ "$COUNT" = "0" ] && echo "(empty — re-run sushi + assemble-invasivepneumococcaldisease.sh so the assembled questionnaire carries the launchContext + initialExpressions)"
exit 0
