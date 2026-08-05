#!/usr/bin/env bash
#
# Backward-compatible wrapper: assemble the Mpox questionnaire.
# The assembly logic is now disease-agnostic in scripts/assemble-questionnaire.sh.
#
# Usage:  ./scripts/assemble-mpox.sh [FHIR_BASE_URL]
set -euo pipefail
exec "$(dirname "$0")/assemble-questionnaire.sh" ChEkmQuestionnaireMpox "$@"
