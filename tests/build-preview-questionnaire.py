#!/usr/bin/env python3
"""
Build a self-contained PREVIEW of the assembled Gonorrhoea questionnaire.

The Smart Forms renderer expands `answerValueSet`s against a live terminology
server. The CH-specific value sets (bfs-country-codes, ChEkm*) are not resolvable
by canonical on a public tx, so for a dependency-free local preview we pre-expand
every value set and replace `answerValueSet` with inline `answerOption`s.

Expansion strategy (terminology server: tx.fhir.ch, which hosts ch-term + SNOMED CH):
  - ch-ekm value sets  -> POST $expand with the local fsh-generated ValueSet inline,
                          supplying all local CodeSystems as `tx-resource`.
  - everything else     -> GET $expand?url=<canonical>.

Usage:  python3 tests/build-preview-questionnaire.py
Output: fsh-generated/Questionnaire-ChEkmQuestionnaireGonorrhoea-preview.json
"""
import json, os, sys, urllib.request, urllib.parse, glob

# Run from the repo root regardless of where the script is invoked from.
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))

TX = "https://tx.fhir.ch/r4"
RES = "fsh-generated/resources"
SRC = "fsh-generated/Questionnaire-ChEkmQuestionnaireGonorrhoea-assembled.json"
OUT = "fsh-generated/Questionnaire-ChEkmQuestionnaireGonorrhoea-preview.json"
HEADERS = {"Content-Type": "application/fhir+json", "Accept": "application/fhir+json"}

# Preload local CodeSystems so internal-code value sets can be expanded by tx.
LOCAL_CODESYSTEMS = [json.load(open(f)) for f in glob.glob(f"{RES}/CodeSystem-*.json")]


def post(url, body):
    req = urllib.request.Request(url, data=json.dumps(body).encode(), headers=HEADERS, method="POST")
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.load(r)


def get(url):
    req = urllib.request.Request(url, headers=HEADERS, method="GET")
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.load(r)


def local_valueset_file(canonical):
    name = canonical.rsplit("/", 1)[-1]                      # ChEkmGenderIdentity
    for cand in (f"{RES}/ValueSet-{name}.json", f"{RES}/ValueSet-ch-ekm-{name}.json"):
        if os.path.exists(cand):
            return cand
    # fall back: match by .url inside the files
    for f in glob.glob(f"{RES}/ValueSet-*.json"):
        try:
            if json.load(open(f)).get("url") == canonical:
                return f
        except Exception:
            pass
    return None


def expand(canonical):
    """Return list of answerOption from a value set canonical."""
    if "fhir.ch/ig/ch-ekm/ValueSet" in canonical:
        vsfile = local_valueset_file(canonical)
        if not vsfile:
            raise RuntimeError(f"no local ValueSet for {canonical}")
        params = {"resourceType": "Parameters",
                  "parameter": [{"name": "valueSet", "resource": json.load(open(vsfile))}]
                  + [{"name": "tx-resource", "resource": cs} for cs in LOCAL_CODESYSTEMS]}
        vs = post(f"{TX}/ValueSet/$expand", params)
    else:
        vs = get(f"{TX}/ValueSet/$expand?url={urllib.parse.quote(canonical, safe='')}")
    if vs.get("resourceType") != "ValueSet":
        raise RuntimeError(f"expand failed for {canonical}: {vs.get('issue')}")
    out = []
    for c in vs.get("expansion", {}).get("contains", []):
        coding = {"system": c["system"], "code": c["code"]}
        if c.get("display"):
            coding["display"] = c["display"]
        out.append({"valueCoding": coding})
    return out


def downgrade_autocomplete(it):
    """Smart Forms 'autocomplete' needs a live answerValueSet (server type-ahead);
    with inline answerOptions the control renders nothing. Fall back to 'drop-down'."""
    for ext in it.get("extension", []):
        if "itemControl" in ext.get("url", ""):
            for coding in ext.get("valueCodeableConcept", {}).get("coding", []):
                if coding.get("code") == "autocomplete":
                    coding["code"] = "drop-down"
                    coding.pop("display", None)


def walk(item):
    for it in item:
        if "answerValueSet" in it:
            canonical = it.pop("answerValueSet")
            opts = expand(canonical)
            it["answerOption"] = opts
            downgrade_autocomplete(it)
            print(f"  {it['linkId']}: {len(opts)} options  <- {canonical}")
        if "item" in it:
            walk(it["item"])


def main():
    if not os.path.exists(SRC):
        sys.exit(f"ERROR: {SRC} not found. Run tests/assemble-gonorrhoea.sh first.")
    q = json.load(open(SRC))
    print(f"Expanding answerValueSets via {TX} ...")
    walk(q.get("item", []))
    q["title"] = q.get("title", "") + " (preview, pre-expanded)"
    json.dump(q, open(OUT, "w"), indent=2, ensure_ascii=False)
    print(f"\nWrote {OUT}")


if __name__ == "__main__":
    main()
