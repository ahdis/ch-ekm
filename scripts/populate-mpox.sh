#!/usr/bin/env bash
#
# Pre-populate the assembled Mpox questionnaire using the SDC REFERENCE $populate implementation
# (@aehrc/sdc-populate) — the same engine Smart Forms runs in-app — via the shared local CommonJS
# wrapper (scripts/populate/populate.cjs). Same pipeline and same rationale as
# scripts/populate-gonorrhoea.sh; what is Mpox-specific is the THIRD launch context.
#
# Pipeline:  sushi .  ->  scripts/assemble-mpox.sh  ->  this script
#
# Launch contexts (declared on the modular root, propagated onto the assembled questionnaire):
#   patient   (Patient)          -> %patient    the affected person; Mpox reports the FULL name, so
#                                               the default is ChEkmPatientExample and not the
#                                               initials-only patient Gonorrhoea populates from
#   user      (PractitionerRole) -> %user       the treating physician's role
#   encounter (Encounter)        -> %encounter  the hospitalisation, read by the three items of the
#                                               "Verlauf" section (ChEkmQuestionnaireHospitalisation)
#
# The encounter context is what makes the Hospitalisation group pre-fill:
#   hospitalisationStatus        <- "ja", or "unbekannt" when the Encounter's `hospitalization`
#                                   element carries a data-absent-reason
#   hospitalisationReason        <- `reported-pathogen` when the Encounter has a reasonReference,
#                                   otherwise the recorded reasonCode
#   hospitalisationAdmissionDate <- period.start
# Pass a different ENCOUNTER_ID to exercise the other branches. Passing NO Encounter is not useful
# for this form: the expressions reference %encounter, which is then unbound.
#
# %user is the treating physician's PractitionerRole. The Practitioner/Organization fields are
# populated via %user.practitioner.resolve() / %user.organization.resolve() — FHIRPath resolve()
# fetches those references over HTTP from a real FHIR server, so this script requires a LOCAL HAPI
# INSTANCE with the example resources loaded:
#
#   ./scripts/start_hapi.sh      # starts HAPI FHIR at http://localhost:8080/fhir
#   ./scripts/load_examples.sh   # PUTs Practitioner/Organization/PractitionerRole/Patient examples into it
#
# Usage:
#   ./scripts/populate-mpox.sh [PATIENT_ID] [ROLE_ID] [ENCOUNTER_ID] [FHIR_BASE_URL]
#
# PATIENT_ID     Patient example id in fsh-generated/resources           (default ChEkmPatientExample)
# ROLE_ID        PractitionerRole example id (treating physician's role) (default ChEkmPractitionerRoleTreatingPhysicianExample)
# ENCOUNTER_ID   Encounter example id (the hospitalisation)              (default ChEkmEncounterMpoxExample)
# FHIR_BASE_URL  Local HAPI base serving the above (via load_examples.sh) (default http://localhost:8080/fhir)

set -euo pipefail

# Run from the repo root regardless of where the script is invoked from.
cd "$(dirname "$0")/.."

PATIENT_ID="${1:-ChEkmPatientExample}"
ROLE_ID="${2:-ChEkmPractitionerRoleTreatingPhysicianExample}"
ENCOUNTER_ID="${3:-ChEkmEncounterMpoxExample}"
FHIR_BASE_URL="${4:-http://localhost:8080/fhir}"
Q="input/resources/Questionnaire-ChEkmQuestionnaireMpoxAssembled.json"
PAT="fsh-generated/resources/Patient-$PATIENT_ID.json"
ROLE="fsh-generated/resources/PractitionerRole-$ROLE_ID.json"
ENC="fsh-generated/resources/Encounter-$ENCOUNTER_ID.json"
OUT="fsh-generated/QuestionnaireResponse-ChEkmQuestionnaireMpox-populated.json"
WRAPPER_DIR="scripts/populate"

[ -f "$Q" ]    || { echo "ERROR: $Q not found. Run scripts/assemble-mpox.sh first."; exit 1; }
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
[ "$COUNT" = "0" ] && echo "(empty — re-run sushi + assemble-mpox.sh so the assembled questionnaire carries the launchContext + initialExpressions)"
exit 0
