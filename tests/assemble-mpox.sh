#!/usr/bin/env bash
#
# Backward-compatible wrapper: assemble the Mpox questionnaire.
# The assembly logic is now disease-agnostic in tests/assemble-questionnaire.sh.
#
# Usage:  ./tests/assemble-mpox.sh [FHIR_BASE_URL]
set -euo pipefail
exec "$(dirname "$0")/assemble-questionnaire.sh" ChEkmQuestionnaireMpox "$@"
