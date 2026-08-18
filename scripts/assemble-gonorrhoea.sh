#!/usr/bin/env bash
#
# Backward-compatible wrapper: assemble the Gonorrhoea questionnaire.
# The assembly logic is now disease-agnostic in scripts/assemble-questionnaire.sh.
#
# Publishing to the Forms Server is opt-in: add --upload.
# Assemble every root at once with scripts/assemble.sh (or ./assemble.sh from the repo root).
#
# Usage:  ./scripts/assemble-gonorrhoea.sh [--upload]
set -euo pipefail
exec "$(dirname "$0")/assemble-questionnaire.sh" ChEkmQuestionnaireGonorrhoea "$@"
