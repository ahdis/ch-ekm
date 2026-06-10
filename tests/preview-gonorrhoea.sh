#!/usr/bin/env bash
#
# Preview the Gonorrhoea questionnaire in the Smart Forms renderer.
#
# Pipeline:
#   sushi .  ->  tests/assemble-gonorrhoea.sh  ->  this script
#
# The Smart Forms renderer expands `answerValueSet`s against a live terminology
# server, but the CH-specific value sets (bfs-country-codes, ChEkmGenderIdentity,
# ChEkmExposureRelationshipType, ChEkmGonorrhoeaManifestationFormChoice) are not
# resolvable by canonical on a public tx server -> the choice controls show
# "There was an error fetching options from the terminology server".
#
# To avoid that, this script first builds a SELF-CONTAINED preview via
# build-preview-questionnaire.py (every answerValueSet is pre-expanded into inline
# answerOptions using tx.fhir.ch), then serves that file from the demo-renderer-app's
# public/ folder (same-origin, no CORS) and starts its Vite dev server.
#
# Open:  http://localhost:5173/?url=/gonorrhoea-preview.json
#
# Requires the Smart Forms repo checked out next to this one (../smart-forms).

set -euo pipefail

# Run from the repo root regardless of where the script is invoked from.
cd "$(dirname "$0")/.."

ASSEMBLED="fsh-generated/Questionnaire-ChEkmQuestionnaireGonorrhoea-assembled.json"
PREVIEW="fsh-generated/Questionnaire-ChEkmQuestionnaireGonorrhoea-preview.json"
APP_DIR="../smart-forms/apps/demo-renderer-app"
PUBLIC="$APP_DIR/public/gonorrhoea-preview.json"

[ -f "$ASSEMBLED" ] || { echo "ERROR: $ASSEMBLED not found. Run tests/assemble-gonorrhoea.sh first."; exit 1; }
[ -d "$APP_DIR" ]   || { echo "ERROR: $APP_DIR not found (clone aehrc/smart-forms next to this repo)."; exit 1; }

echo "Building self-contained preview (pre-expanding value sets)..."
python3 tests/build-preview-questionnaire.py

echo
echo "Copying preview questionnaire -> $PUBLIC"
cp "$PREVIEW" "$PUBLIC"

if [ ! -d "$APP_DIR/node_modules" ]; then
  echo "Installing demo-renderer-app dependencies (first run)..."
  ( cd "$APP_DIR" && npm install )
fi

echo
echo "Starting Smart Forms demo renderer..."
echo "Open:  http://localhost:5173/?url=/gonorrhoea-preview.json"
echo
exec sh -c "cd '$APP_DIR' && npm run dev"
