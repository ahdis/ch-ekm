#!/usr/bin/env bash
#
# Backward-compatible wrapper: upload the assembled Gonorrhoea questionnaire to the Forms Server.
# The upload logic is now disease-agnostic in scripts/upload-questionnaire.sh (see that script's
# header for what is stripped and why).
#
# Usage:  ./scripts/upload-gonorrhoea.sh [FHIR_BASE_URL]
set -euo pipefail
exec "$(dirname "$0")/upload-questionnaire.sh" ChEkmQuestionnaireGonorrhoea "$@"
