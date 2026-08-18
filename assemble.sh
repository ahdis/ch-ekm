#!/usr/bin/env bash
#
# Convenience wrapper: assemble ALL modular CH EKM questionnaires from the repo root.
# The logic lives with the rest of the tooling in scripts/assemble.sh — see that script's
# header for what it does and which flags it takes.
#
# Usage:  ./assemble.sh [--upload] [RootQuestionnaireId ...]
set -euo pipefail
exec "$(dirname "$0")/scripts/assemble.sh" "$@"
