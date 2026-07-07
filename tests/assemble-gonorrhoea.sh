#!/usr/bin/env bash
#
# Backward-compatible wrapper: assemble the Gonorrhoea questionnaire.
# The assembly logic is now disease-agnostic in tests/assemble-questionnaire.sh.
#
# Usage:  ./tests/assemble-gonorrhoea.sh [FHIR_BASE_URL]
set -euo pipefail
exec "$(dirname "$0")/assemble-questionnaire.sh" ChEkmQuestionnaireGonorrhoea "$@"
