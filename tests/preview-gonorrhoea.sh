#!/usr/bin/env bash
#
# Preview the Gonorrhoea questionnaire in the Smart Forms renderer.
#
# Pipeline:
#   sushi .  ->  tests/assemble-questionnaire.sh ChEkmQuestionnaireGonorrhoea  ->  this script
#
# The Smart Forms renderer expands `answerValueSet`s against a live terminology
# server, but the CH-specific value sets (bfs-country-codes, ChEkmGenderIdentity,
# ChEkmExposureRelationshipType, ChEkmGonorrhoeaManifestationFormChoice) are not
# resolvable by canonical on a public tx server -> the choice controls show
# "There was an error fetching options from the terminology server".
#
# To avoid that, this script first builds a SELF-CONTAINED preview via
# build-lang-questionnaire.py (every answerValueSet is pre-expanded into inline
# answerOptions using tx.fhir.ch), then serves that file from the demo-renderer-app's
# public/ folder (same-origin, no CORS) and starts its Vite dev server.
#
# Language: defaults to de-CH; set PREVIEW_LANG=fr-CH (or it-CH) to preview another.
#
# Open:  http://localhost:5173/?url=/gonorrhoea-preview.json
#
# Requires the Smart Forms repo checked out next to this one (../smart-forms).

set -euo pipefail

# Run from the repo root regardless of where the script is invoked from.
cd "$(dirname "$0")/.."

PREVIEW_LANG="${PREVIEW_LANG:-de-CH}"
ASSEMBLED_ID="ChEkmQuestionnaireGonorrhoeaAssembled"
ASSEMBLED="input/resources/Questionnaire-$ASSEMBLED_ID.json"
PREVIEW="input/resources/Questionnaire-ChEkmQuestionnaireGonorrhoea-$PREVIEW_LANG.json"
APP_DIR="../smart-forms/apps/demo-renderer-app"
PUBLIC="$APP_DIR/public/gonorrhoea-preview.json"

[ -f "$ASSEMBLED" ] || { echo "ERROR: $ASSEMBLED not found. Run 'tests/assemble-questionnaire.sh ChEkmQuestionnaireGonorrhoea' first."; exit 1; }
[ -d "$APP_DIR" ]   || { echo "ERROR: $APP_DIR not found (clone aehrc/smart-forms next to this repo)."; exit 1; }

echo "Building self-contained preview ($PREVIEW_LANG, pre-expanding value sets)..."
PREVIEW_LANG="$PREVIEW_LANG" python3 tests/build-lang-questionnaire.py "$ASSEMBLED_ID"

echo
echo "Copying preview questionnaire -> $PUBLIC"
cp "$PREVIEW" "$PUBLIC"

# Optional: if a populated QuestionnaireResponse exists (from tests/populate-gonorrhoea.sh),
# serve it too so the renderer shows the form pre-filled via the app's `?response=` loader.
POPULATED="fsh-generated/QuestionnaireResponse-ChEkmQuestionnaireGonorrhoea-populated.json"
OPEN_URL="http://localhost:5173/?url=/gonorrhoea-preview.json"
if [ -f "$POPULATED" ]; then
  echo "Copying populated QuestionnaireResponse -> $APP_DIR/public/gonorrhoea-populated.json"
  cp "$POPULATED" "$APP_DIR/public/gonorrhoea-populated.json"
  OPEN_URL="$OPEN_URL&response=/gonorrhoea-populated.json"
fi

if [ ! -d "$APP_DIR/node_modules" ]; then
  echo "Installing demo-renderer-app dependencies (first run)..."
  ( cd "$APP_DIR" && npm install )
fi

echo
echo "Starting Smart Forms demo renderer..."
echo "Open:  $OPEN_URL"
echo
exec sh -c "cd '$APP_DIR' && npm run dev"
