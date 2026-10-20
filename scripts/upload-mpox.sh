#!/usr/bin/env bash
#
# Upload the Mpox language previews to the Forms Server.
# The upload logic is disease-agnostic in scripts/upload-questionnaire.sh (see that script's
# header for what is stripped and why).
#
# Usage:  ./scripts/upload-mpox.sh [FHIR_BASE_URL]
set -euo pipefail
exec "$(dirname "$0")/upload-questionnaire.sh" ChEkmQuestionnaireMpox "$@"
