#!/usr/bin/env bash
#
# Assemble ALL modular CH EKM questionnaires in one go.
#
# Runs `sushi .` once, then calls scripts/assemble-questionnaire.sh --no-sushi for every modular
# ROOT questionnaire found in fsh-generated/resources. Roots are discovered automatically: a
# questionnaire is a root when it carries
#   http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-assemble-expectation
# with valueCode = assemble-root. Adding a new disease questionnaire with that extension is
# therefore enough — no edit here needed.
#
# Per root this produces (see scripts/assemble-questionnaire.sh for the details):
#   input/resources/Questionnaire-<RootId>Assembled.json
#   input/resources/Questionnaire-<RootId>-<lang>.json   (de-CH / fr-CH / it-CH)
#
# Everything is local by default. Publishing to the Forms Server
# (https://smartforms.ahdis.ch/api/fhir) is opt-in with --upload.
#
# Usage (./assemble.sh in the repo root is a thin wrapper around this script):
#   ./scripts/assemble.sh                     # assemble every root, no upload
#   ./scripts/assemble.sh --upload            # ... and publish each one to the Forms Server
#   ./scripts/assemble.sh ChEkmQuestionnaireMpox ChEkmQuestionnaireGonorrhoea   # only these roots
#   PREVIEW_LANG=fr-CH ./scripts/assemble.sh  # build/publish one language only
#   EKM_FHIR_BASE=http://localhost:8080/fhir ./scripts/assemble.sh --upload
#
set -euo pipefail

# Run from the repo root regardless of where the script is invoked from.
cd "$(dirname "$0")/.."

# Flags are forwarded to scripts/assemble-questionnaire.sh; bare words are explicit root ids.
PASSTHRU=()
ROOTS=()
for a in "$@"; do
  case "$a" in
    -*) PASSTHRU+=("$a") ;;
    *)  ROOTS+=("$a") ;;
  esac
done

# sushi once for the whole batch, rather than once per root.
sushi .

DIR="fsh-generated/resources"
EXPECT_URL="http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-assemble-expectation"

if [ ${#ROOTS[@]} -eq 0 ]; then
  while IFS= read -r id; do
    [ -n "$id" ] && ROOTS+=("$id")
  done < <(
    for f in "$DIR"/Questionnaire-*.json; do
      [ -f "$f" ] || continue
      jq -r --arg u "$EXPECT_URL" \
        'select(any(.extension[]?; .url == $u and .valueCode == "assemble-root")) | .id' "$f"
    done | sort
  )
fi

if [ ${#ROOTS[@]} -eq 0 ]; then
  echo "ERROR: no modular root questionnaires found in $DIR"
  echo "  (looked for the assemble-expectation extension with valueCode = assemble-root)"
  exit 1
fi

echo
echo "=============================================================================="
echo "Assembling ${#ROOTS[@]} root questionnaire(s): ${ROOTS[*]}"
echo "=============================================================================="

FAILED=()
for root in "${ROOTS[@]}"; do
  echo
  echo "------------------------------------------------------------------------------"
  echo "$root"
  echo "------------------------------------------------------------------------------"
  scripts/assemble-questionnaire.sh "$root" --no-sushi "${PASSTHRU[@]+"${PASSTHRU[@]}"}" \
    || FAILED+=("$root")
done

echo
echo "=============================================================================="
if [ ${#FAILED[@]} -gt 0 ]; then
  echo "FAILED: ${#FAILED[@]} of ${#ROOTS[@]} root(s)"
  printf '  %s\n' "${FAILED[@]}"
  exit 1
fi
echo "OK: assembled all ${#ROOTS[@]} root questionnaire(s)"
echo "=============================================================================="
