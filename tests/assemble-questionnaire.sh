#!/usr/bin/env bash
#
# Assemble a modular CH EKM questionnaire using the Smart Forms (aehrc/CSIRO) SDC reference
# $assemble library, run LOCALLY in-process. Disease-agnostic: pass the modular ROOT id.
#
# Engine: @aehrc/sdc-assemble via tests/assemble/assemble.cjs — the same reference engine the
# Smart Forms renderer runs in-app, and a sibling of the $populate / $extract wrappers we already
# run locally (tests/populate/, tests/extract/). We moved OFF the hosted HAPI $assemble
# (smartforms.csiro.au) because HAPI requires every questionnaire it processes (root and every
# child) to carry the item[0].item group nesting and rejects a groupless leaf sub-questionnaire
# with "Root questionnaire does not have a valid item." The reference engine tolerates groupless
# leaves, so our person leaves can stay flat and merge directly into the root's group.
#
# The child sub-questionnaires are resolved by canonical url from local fsh-generated/resources
# (no FHIR server, no upload step).
#
# Usage:
#   ./tests/assemble-questionnaire.sh <RootQuestionnaireId>
#   ./tests/assemble-questionnaire.sh ChEkmQuestionnaireGonorrhoea
#   ./tests/assemble-questionnaire.sh ChEkmQuestionnaireMpox
#
set -euo pipefail

# Run from the repo root regardless of where the script is invoked from.
cd "$(dirname "$0")/.."

ROOT_ID="${1:-}"
if [ -z "$ROOT_ID" ]; then
  echo "ERROR: missing root questionnaire id."
  echo "Usage: $0 <RootQuestionnaireId>   (e.g. ChEkmQuestionnaireGonorrhoea)"
  exit 2
fi

# run `sushi .` first to ensure fsh-generated/ is up to date, then assemble locally.
sushi .

DIR="fsh-generated/resources"
ROOT_FILE="$DIR/Questionnaire-$ROOT_ID.json"
[ -f "$ROOT_FILE" ] || { echo "ERROR: missing $ROOT_FILE (run 'sushi .' first / check the id)"; exit 1; }

# The assembled (flattened) questionnaire is published as a predefined IG resource in
# input/resources/ (must be listed under path-resource in sushi-config.yaml). It is given
# a distinct id/url so it does not collide with the modular root example.
ASSEMBLED_ID="${ROOT_ID}Assembled"
OUT="input/resources/Questionnaire-$ASSEMBLED_ID.json"
# Human-readable disease label, derived from the root id (ChEkmQuestionnaire<Disease>).
DISEASE="${ROOT_ID#ChEkmQuestionnaire}"
SCRIPT_URL="https://github.com/ahdis/ch-ekm/blob/master/tests/assemble-questionnaire.sh"
WRAPPER="tests/assemble/assemble.cjs"
[ -f "$WRAPPER" ] || { echo "ERROR: missing $WRAPPER"; exit 1; }
[ -d "tests/assemble/node_modules" ] || { echo "ERROR: run 'npm install' in tests/assemble first"; exit 1; }

echo "Engine:  @aehrc/sdc-assemble (local, $WRAPPER)"
echo "Root:    $ROOT_ID  (disease: $DISEASE)"
echo

# --- 1. assemble --------------------------------------------------------------
# The @aehrc/sdc-assemble reference engine preserves the top-level (item[0]) templateExtract
# extension and drops the contained Bundle regardless, so we feed it the root as-is. Step 2
# re-attaches the contained Bundle (from the root file) and idempotently re-affirms the
# extension + extr-template profile on the assembled result.
TE_URL="http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-templateExtract"

echo "Assembling (Questionnaire/\$assemble)"
node "$WRAPPER" "$ROOT_FILE" /tmp/ekm-assemble-out.json "$DIR"
echo

# --- 2. publish as an IG resource ---------------------------------------------
RTYPE=$(jq -r '.resourceType // "?"' /tmp/ekm-assemble-out.json)
if [ "$RTYPE" != "Questionnaire" ]; then
  echo "Assemble did not return a Questionnaire (got: $RTYPE). Output:"
  jq '.' /tmp/ekm-assemble-out.json || cat /tmp/ekm-assemble-out.json
  exit 1
fi

mkdir -p "$(dirname "$OUT")"
# Give the flattened result a distinct identity (the assembler returns it with the root's
# id/url, which would collide with the modular root example in the IG).
python3 - /tmp/ekm-assemble-out.json "$ASSEMBLED_ID" "$ROOT_FILE" "$TE_URL" "$DISEASE" "$SCRIPT_URL" > "$OUT" <<'PY'
import json, sys
q = json.load(open(sys.argv[1]))
new_id = sys.argv[2]
root = json.load(open(sys.argv[3]))
te_url = sys.argv[4]
disease = sys.argv[5]
script_url = sys.argv[6]
q["id"] = new_id
q["url"] = "http://fhir.ch/ig/ch-ekm/Questionnaire/" + new_id
q["name"] = new_id
q["version"] = "0.0.1"
q["title"] = f"CH EKM Questionnaire: {disease} (assembled)"

# Re-affirm the SDC template-based extraction wiring on the assembled result:
#  - the contained Bundle template (dropped by $assemble, so re-attached from the root),
#  - the sdc-questionnaire-templateExtract extension on the top form group (kept by $assemble;
#    added here only if missing),
#  - the extr-template profile claim.
# (The renderer needs all three on the assembled questionnaire to offer $extract.)
extr_template = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-extr-template"
if root.get("contained"):
    q["contained"] = root["contained"]
te_ext = None
for it in root.get("item", []):
    for e in it.get("extension", []) or []:
        if e.get("url") == te_url:
            te_ext = e
            break
if te_ext and q.get("item"):
    top = q["item"][0]
    top.setdefault("extension", [])
    if not any(e.get("url") == te_url for e in top["extension"]):
        top["extension"].append(te_ext)
# Only claim the extr-template profile if a template was actually re-attached; a template-less
# modular root (e.g. the standalone Person questionnaire) must not claim it, or the IG Publisher
# errors on the unsatisfied `contained 1..*` requirement.
if root.get("contained"):
    profiles = q.setdefault("meta", {}).setdefault("profile", [])
    if extr_template not in profiles:
        profiles.append(extr_template)
# Provenance + "do not edit" guard (FHIR-valid; survives regeneration since it is set here)
q.setdefault("meta", {})["source"] = script_url
q["description"] = (
    "GENERATED FILE — do not edit by hand. Assembled from the modular questionnaire "
    f"{root.get('id', '')} and its sub-questionnaires via Questionnaire/$assemble "
    "(tests/assemble-questionnaire.sh). Re-run that script after changing any child "
    "questionnaire to keep this resource in sync."
)

# The $assemble engine may emit empty arrays (e.g. "contained": [], item[0] "extension": []).
# FHIR forbids empty arrays, so the IG Publisher errors on them — prune them (depth-first).
def prune(x):
    if isinstance(x, dict):
        out = {}
        for k, v in x.items():
            pv = prune(v)
            if isinstance(pv, (list, dict)) and len(pv) == 0:
                continue
            out[k] = pv
        return out
    if isinstance(x, list):
        return [prune(v) for v in x]
    return x

json.dump(prune(q), sys.stdout, indent=2, ensure_ascii=False)
PY

echo "Assembled questionnaire written to: $OUT"
echo "Items:"
jq -r '.. | objects | select(.linkId) | "  [\(.type)] \(.linkId): \(.text // "")"' "$OUT"

# --- 3. build the pre-expanded, per-language preview questionnaires ------------
# Bake the answerValueSet expansions into inline answerOptions (one file per Swiss language)
# so the assembled questionnaire renders offline in the Smart Forms preview.
echo
echo "Building per-language preview questionnaires"
python3 tests/build-lang-questionnaire.py "$ASSEMBLED_ID"
