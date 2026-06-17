#!/usr/bin/env bash
#
# Assemble the modular Gonorrhoea questionnaire using the Smart Forms (aehrc/CSIRO)
# SDC $assemble service.
#
# Hosted endpoint: https://smartforms.csiro.au/api/fhir/Questionnaire/$assemble
# (TypeScript sdc-assemble microservice, see ../smart-forms/packages/sdc-assemble).
#
# The service resolves the `subQuestionnaire` canonicals from the Questionnaires stored
# on its own FHIR server, so this script:
#   1. uploads (PUT) the three assemble-child sub-questionnaires + the modular root,
#   2. POSTs the modular root to Questionnaire/$assemble,
#   3. writes the assembled (flattened) questionnaire to disk.
#
# Two server-specific details (learned the hard way):
#   * Content-Type MUST be application/json — the Express service uses express.json(),
#     which does not parse application/fhir+json, so a fhir+json body arrives empty and
#     yields "Parameters provided is invalid against the $assemble specification".
#   * The root's subQuestionnaire placeholders must be nested under a top-level group
#     (item[0].item[x]); the reference assembler reads parentQuestionnaire.item[0].item.
#     ChEkmQuestionnaireGonorrhoea is structured that way.
#
# The service accepts either a bare Questionnaire body (wrapped automatically) or an
# SDC Parameters{questionnaire} body; this script POSTs the bare Questionnaire.
#
# Usage:
#   ./tests/assemble-gonorrhoea.sh [FHIR_BASE_URL]
#
# Defaults to the hosted Smart Forms server. Run `sushi .` first so fsh-generated/ is
# up to date.
#
# Matchbox note: matchbox (https://test.ahdis.ch/matchbox/fhir) also implements
# Questionnaire/$assemble and accepts the same nested-group root, but expects
# Content-Type application/fhir+json and a Parameters{questionnaire} body.

set -euo pipefail

# Run from the repo root regardless of where the script is invoked from.
cd "$(dirname "$0")/.."

# run `sushi .` first to ensure fsh-generated/ is up to date, then this script to upload the

sushi .

BASE="${1:-https://smartforms.csiro.au/api/fhir}"
DIR="fsh-generated/resources"
# The assembled (flattened) questionnaire is published as a predefined IG resource in
# input/resources/ (already listed under path-resource in sushi-config.yaml). It is given
# a distinct id/url so it does not collide with the modular root example.
ASSEMBLED_ID="ChEkmQuestionnaireGonorrhoeaAssembled"
OUT="input/resources/Questionnaire-$ASSEMBLED_ID.json"
CT="Content-Type: application/json"
ACCEPT="Accept: application/json"

ROOT_ID="ChEkmQuestionnaireGonorrhoea"
CHILDREN=(
  "ChEkmQuestionnaireGonorrhoeaPerson"
  "ChEkmQuestionnaireGonorrhoeaManifestation"
  "ChEkmQuestionnaireGonorrhoeaExposition"
)

echo "FHIR base: $BASE"
echo

# --- 1. upload the sub-questionnaires and the root ----------------------------
upload() {
  local id="$1"
  local file="$DIR/Questionnaire-$id.json"
  [ -f "$file" ] || { echo "ERROR: missing $file (run 'sushi .' first)"; exit 1; }
  echo "PUT Questionnaire/$id"
  curl -sS -X PUT "$BASE/Questionnaire/$id" \
    -H "$CT" -H "$ACCEPT" \
    --data-binary "@$file" \
    -o /tmp/ekm-put-$id.json -w "  -> HTTP %{http_code}\n"
}

for id in "${CHILDREN[@]}"; do upload "$id"; done
upload "$ROOT_ID"
echo

# --- 2. call $assemble on the root --------------------------------------------
# The extraction template (contained Bundle + sdc-questionnaire-templateExtract) is not needed
# for assembly and the assembler does not propagate it, so strip it from the POST body and
# re-attach it to the result in step 3.
TE_URL="http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-templateExtract"
python3 - "$DIR/Questionnaire-$ROOT_ID.json" "$TE_URL" > /tmp/ekm-assemble-root.json <<'PY'
import json, sys
q = json.load(open(sys.argv[1]))
te_url = sys.argv[2]
q.pop("contained", None)
def strip(items):
    for it in items or []:
        if "extension" in it:
            it["extension"] = [e for e in it["extension"] if e.get("url") != te_url]
            if not it["extension"]:
                del it["extension"]
        strip(it.get("item"))
strip(q.get("item"))
json.dump(q, sys.stdout)
PY

echo "POST Questionnaire/\$assemble"
HTTP=$(curl -sS -X POST "$BASE/Questionnaire/\$assemble" \
  -H "$CT" -H "$ACCEPT" \
  --data-binary "@/tmp/ekm-assemble-root.json" \
  -o /tmp/ekm-assemble-out.json -w "%{http_code}")
echo "  -> HTTP $HTTP"
echo

# --- 3. publish as an IG resource ---------------------------------------------
RTYPE=$(jq -r '.resourceType // "?"' /tmp/ekm-assemble-out.json)
if [ "$RTYPE" != "Questionnaire" ]; then
  echo "Assemble did not return a Questionnaire (got: $RTYPE). Server response:"
  jq '.' /tmp/ekm-assemble-out.json || cat /tmp/ekm-assemble-out.json
  exit 1
fi

mkdir -p "$(dirname "$OUT")"
# Give the flattened result a distinct identity (the server returns it with the root's
# id/url, which would collide with the modular root example in the IG).
python3 - /tmp/ekm-assemble-out.json "$ASSEMBLED_ID" "$DIR/Questionnaire-$ROOT_ID.json" "$TE_URL" > "$OUT" <<'PY'
import json, sys
q = json.load(open(sys.argv[1]))
new_id = sys.argv[2]
root = json.load(open(sys.argv[3]))
te_url = sys.argv[4]
q["id"] = new_id
q["url"] = "http://fhir.ch/ig/ch-ekm/Questionnaire/" + new_id
q["name"] = new_id
q["version"] = "0.0.1"
q["title"] = "CH EKM Questionnaire: Gonorrhoea (assembled)"

# Re-attach the SDC template-based extraction wiring stripped before $assemble:
#  - the contained Bundle template,
#  - the sdc-questionnaire-templateExtract extension on the top form group,
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
profiles = q.setdefault("meta", {}).setdefault("profile", [])
if extr_template not in profiles:
    profiles.append(extr_template)
# Provenance + "do not edit" guard (FHIR-valid; survives regeneration since it is set here)
q.setdefault("meta", {})["source"] = \
    "https://github.com/ahdis/ch-ekm/blob/master/tests/assemble-gonorrhoea.sh"
q["description"] = (
    "GENERATED FILE — do not edit by hand. Assembled from the modular questionnaire "
    "ChEkmQuestionnaireGonorrhoea and its sub-questionnaires via Questionnaire/$assemble "
    "(tests/assemble-gonorrhoea.sh). Re-run that script after changing any child "
    "questionnaire to keep this resource in sync."
)

# The $assemble service emits empty arrays (e.g. "contained": [], item[0] "extension": []).
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
