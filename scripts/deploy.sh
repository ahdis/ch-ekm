#!/usr/bin/env bash
#
# Bring the Smart Forms test environment (../smart-forms/ARCHITECTURE.md) up to the current sources:
#   1. scripts/assemble.sh --upload   sushi + $assemble every modular root, publish the forms to the
#                                     Forms Server (https://smartforms.ahdis.ch/api/fhir, EKM_FHIR_BASE)
#   2. IG Publisher                   builds output/, incl. output/package.tgz with the assembled
#                                     questionnaires of step 1
#   3. scripts/upload-matchbox.sh     replaces the CH EKM package on the matchbox that validates the
#                                     extracted documents (https://test.ahdis.ch/matchboxv3/fhir, MATCHBOX_BASE)
#
# The Publisher's QA counts are printed but do not stop the run: the upload goes ahead as long as the
# Publisher finished and wrote a new package.tgz. Check output/qa.html for the details.
#
# The Publisher jar is the first of: $PUBLISHER_JAR, input-cache/publisher.jar, the one shipped with
# the VS Code FHIR Tools extension.
#
# Usage:
#   ./scripts/deploy.sh
#   PREVIEW_LANG=de-CH ./scripts/deploy.sh                          # publish one language only
#   MATCHBOX_BASE=http://localhost:8080/matchboxv3/fhir ./scripts/deploy.sh
#
set -euo pipefail

# Run from the repo root regardless of where the script is invoked from.
cd "$(dirname "$0")/.."

JAR="${PUBLISHER_JAR:-}"
if [ -z "$JAR" ] && [ -f input-cache/publisher.jar ]; then
  JAR=input-cache/publisher.jar
fi
if [ -z "$JAR" ]; then
  JAR=$(ls -d "$HOME"/.vscode/extensions/yannick-lagger.vscode-fhir-tools-*/publisher.jar 2>/dev/null | tail -1 || true)
fi
if [ -z "$JAR" ] || [ ! -f "$JAR" ]; then
  echo "ERROR: no IG Publisher jar found — set PUBLISHER_JAR"
  exit 1
fi

step() {
  echo
  echo "=============================================================================="
  echo "$1"
  echo "=============================================================================="
}

step "1/3 Assemble the questionnaires and publish them to the Forms Server"
scripts/assemble.sh --upload

step "2/3 IG Publisher ($JAR)"
# A package.tgz older than this marker is left over from an earlier build and must not be uploaded.
MARKER=$(mktemp)
trap 'rm -f "$MARKER"' EXIT
java -jar "$JAR" -ig ig.ini
if [ ! output/package.tgz -nt "$MARKER" ]; then
  echo "ERROR: the IG Publisher did not write a new output/package.tgz"
  exit 1
fi
jq -r '"QA: \(.errs) errors, \(.warnings) warnings, \(.hints) hints — see output/qa.html"' output/qa.json

step "3/3 Upload the package to matchbox"
scripts/upload-matchbox.sh output/package.tgz
