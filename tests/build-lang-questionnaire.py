#!/usr/bin/env python3
"""
Build a self-contained PREVIEW of an assembled CH EKM questionnaire (disease-agnostic).

The Smart Forms renderer expands `answerValueSet`s against a live terminology
server. The CH-specific value sets (bfs-country-codes, ChEkm*) are not resolvable
by canonical on a public tx, so for a dependency-free local preview we pre-expand
every value set and replace `answerValueSet` with inline `answerOption`s.

Item LABELS carry the English default in `item.text` plus de-CH/fr-CH/it-CH variants as
http://hl7.org/fhir/StructureDefinition/translation extensions (under `_text`). We bake the
target-language label into `item.text` for the preview (see localize_text), the same way the
answerOption displays are baked in.

Expansion strategy (terminology server: tx.fhir.ch, which hosts ch-term + SNOMED CH):
  - Every value set is expanded via POST with `displayLanguage` (default de-CH) and all local
    fsh-generated CodeSystems supplied as `tx-resource` (so their de/fr/it designations, and any
    `content=supplement` CodeSystem, are available to tx.fhir.ch).
  - ch-ekm value sets  -> the local ValueSet is supplied inline as the `valueSet` parameter;
    everything else     -> the canonical is passed as the `url` parameter.
  - Language supplements (e.g. ChEkmAdministrativeGenderLanguageSupplement, which adds de/fr/it to
    the external administrative-gender code system) are NOT auto-applied by tx — they must be
    activated with `useSupplement`. The script expands once to discover the systems in the value
    set, then re-expands with `useSupplement` for any local supplement whose base system is present.
    This bakes the localized option labels into the inline `answerOption` displays.

Usage:  python3 tests/build-lang-questionnaire.py [AssembledIdOrPath]
          - no arg          -> ChEkmQuestionnaireGonorrhoeaAssembled (default)
          - an id           -> e.g. ChEkmQuestionnaireMpoxAssembled
          - a path to *.json
        By default a preview is built for every Swiss language (de-CH, fr-CH, it-CH).
        Set PREVIEW_LANG=fr-CH to build just one language.
Output: input/resources/Questionnaire-<Base>-<LANG>.json  (one file per language)
"""
import json, os, sys, urllib.request, urllib.parse, glob

# Run from the repo root regardless of where the script is invoked from.
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))

# Target display language(s) for the baked-in option labels. By default we build all three
# Swiss languages; set PREVIEW_LANG to build just one (e.g. PREVIEW_LANG=fr-CH).
LANGS = [os.environ["PREVIEW_LANG"]] if os.environ.get("PREVIEW_LANG") else ["de-CH", "fr-CH", "it-CH"]
LANG = LANGS[0]  # display language of the current build; reassigned per language in main()
TX = "https://tx.fhir.ch/r4"
RES = "fsh-generated/resources"

# Which assembled questionnaire to preview: positional arg is either an id
# (e.g. ChEkmQuestionnaireMpoxAssembled) or a path to the assembled Questionnaire JSON.
# Defaults to the Gonorrhoea assembled questionnaire.
_arg = sys.argv[1] if len(sys.argv) > 1 else "ChEkmQuestionnaireGonorrhoeaAssembled"
if _arg.endswith(".json") or "/" in _arg:
    SRC = _arg
    _base = os.path.basename(_arg)[:-len(".json")]
    ASSEMBLED_ID = _base[len("Questionnaire-"):] if _base.startswith("Questionnaire-") else _base
else:
    ASSEMBLED_ID = _arg
    SRC = f"input/resources/Questionnaire-{ASSEMBLED_ID}.json"

# Distinct identity for the preview so it does not collide with the assembled questionnaire's
# id/url when the IG Publisher scans input/resources. Derived from the assembled id (strip a
# trailing "Assembled"): ChEkmQuestionnaireMpoxAssembled -> ChEkmQuestionnaireMpox-<LANG>.
BASE_ID = ASSEMBLED_ID[:-len("Assembled")] if ASSEMBLED_ID.endswith("Assembled") else ASSEMBLED_ID
HEADERS = {"Content-Type": "application/fhir+json", "Accept": "application/fhir+json"}


def preview_identity(lang):
    """Per-language preview identity: (preview_id, url, name, out_path)."""
    preview_id = f"{BASE_ID}-{lang}"
    return (
        preview_id,
        f"http://fhir.ch/ig/ch-ekm/Questionnaire/{preview_id}",
        f"{BASE_ID}" + lang.replace("-", ""),  # FHIR name: no hyphens
        f"input/resources/Questionnaire-{preview_id}.json",
    )

# Preload local CodeSystems so internal-code value sets (and language supplements) can be
# supplied to tx as `tx-resource`.
LOCAL_CODESYSTEMS = [json.load(open(f)) for f in glob.glob(f"{RES}/CodeSystem-*.json")]

# Preload local ValueSets too: a value set may `include codes from valueset <local VS>`
# (e.g. ChEkmMpoxManifestation includes ChEkmOtherNoneUnknown). tx.fhir.ch has no copy of
# those, so without supplying them as `tx-resource` the $expand fails with HTTP 422
# ("Unable to find included value set ...").
LOCAL_VALUESETS = [json.load(open(f)) for f in glob.glob(f"{RES}/ValueSet-*.json")]

# Local language supplements as (base_system_without_version, supplement_canonical) pairs.
# A supplement is only applied (via useSupplement) when its base system appears in the value set.
LOCAL_SUPPLEMENTS = [
    (cs["supplements"].split("|", 1)[0], cs["url"])
    for cs in LOCAL_CODESYSTEMS
    if cs.get("content") == "supplement" and cs.get("supplements") and cs.get("url")
]

# Supplement designations keyed by (base_system, code, language). tx does NOT apply supplement
# designations to post-coordinated SNOMED expressions (e.g. "271807003:363698007=66019005") — for
# those it returns the source-language concept.display. We override the baked display client-side
# from the supplement so an expression option is localized like every pre-coordinated code.
SUPPLEMENT_DESIGNATIONS = {}
for _cs in LOCAL_CODESYSTEMS:
    if _cs.get("content") == "supplement" and _cs.get("supplements"):
        _base = _cs["supplements"].split("|", 1)[0]
        for _concept in _cs.get("concept", []):
            for _d in _concept.get("designation", []):
                if _d.get("language") and _d.get("value"):
                    SUPPLEMENT_DESIGNATIONS[(_base, _concept["code"], _d["language"])] = _d["value"]


def post(url, body):
    req = urllib.request.Request(url, data=json.dumps(body).encode(), headers=HEADERS, method="POST")
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.load(r)


# Value sets live either in fsh-generated (FSH-authored) or input/resources (predefined,
# e.g. ValueSet-ChEkmCountryCodes.json), so search both.
VS_DIRS = [RES, "input/resources"]


def local_valueset_file(canonical):
    name = canonical.rsplit("/", 1)[-1]                      # ChEkmGenderIdentity
    for d in VS_DIRS:
        for cand in (f"{d}/ValueSet-{name}.json", f"{d}/ValueSet-ch-ekm-{name}.json"):
            if os.path.exists(cand):
                return cand
    # fall back: match by .url inside the files
    for d in VS_DIRS:
        for f in glob.glob(f"{d}/ValueSet-*.json"):
            try:
                if json.load(open(f)).get("url") == canonical:
                    return f
            except Exception:
                pass
    return None


def expand(canonical):
    """Return list of answerOption (with displayLanguage-localized displays) for a value set."""
    is_chekm = "fhir.ch/ig/ch-ekm/ValueSet" in canonical
    vs_resource = None
    if is_chekm:
        vsfile = local_valueset_file(canonical)
        if not vsfile:
            raise RuntimeError(f"no local ValueSet for {canonical}")
        vs_resource = json.load(open(vsfile))

    def do_expand(display_language, use_supplement_urls):
        param = [{"name": "valueSet", "resource": vs_resource}] if is_chekm \
            else [{"name": "url", "valueUri": canonical}]
        if display_language:
            param.append({"name": "displayLanguage", "valueCode": display_language})
        param += [{"name": "tx-resource", "resource": cs} for cs in LOCAL_CODESYSTEMS]
        param += [{"name": "tx-resource", "resource": vs} for vs in LOCAL_VALUESETS]
        param += [{"name": "useSupplement", "valueCanonical": u} for u in use_supplement_urls]
        vs = post(f"{TX}/ValueSet/$expand", {"resourceType": "Parameters", "parameter": param})
        if vs.get("resourceType") != "ValueSet":
            raise RuntimeError(f"expand failed for {canonical}: {vs.get('issue')}")
        return vs

    # Base pass (no displayLanguage): default displays + the code systems present in the value set.
    base = do_expand(None, [])
    base_display = {(c["system"], c["code"]): c.get("display")
                    for c in base.get("expansion", {}).get("contains", [])}
    systems = {s for s, _ in base_display}

    # Localized pass: displayLanguage + any local language supplement whose base system is present
    # (a supplement is not auto-applied — it must be activated with useSupplement).
    applicable = [url for sys_base, url in LOCAL_SUPPLEMENTS if sys_base in systems]
    localized = do_expand(LANG, applicable)

    # Merge: prefer the localized display, fall back to the default display (e.g. eCH-7 cantons
    # have no de-CH designation, so displayLanguage returns no display for them).
    out = []
    for c in localized.get("expansion", {}).get("contains", []):
        coding = {"system": c["system"], "code": c["code"]}
        display = c.get("display") or base_display.get((c["system"], c["code"]))
        # Post-coordinated expressions do not get the supplement designation from tx; override
        # from the local supplement so the expression option is localized (see SUPPLEMENT_DESIGNATIONS).
        if ":" in c["code"]:
            supp = SUPPLEMENT_DESIGNATIONS.get((c["system"], c["code"], LANG))
            if supp:
                display = supp
        if display:
            coding["display"] = display
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


def localize_text(it):
    """Bake the LANG label into item.text from its `translation` extensions.

    Item labels carry the English default in `text` plus de-CH/fr-CH/it-CH variants as
    http://.../translation extensions under `_text` (FHIR primitive-element extension). The
    Smart Forms preview has no live label-translation step, so we replace `text` with the
    LANG content and drop `_text` (same 'bake it in' approach as the answerOption expansion)."""
    ext = it.get("_text")
    if not ext:
        return
    for e in ext.get("extension", []):
        if e.get("url", "").endswith("/translation"):
            sub = {x.get("url"): x for x in e.get("extension", [])}
            if sub.get("lang", {}).get("valueCode") == LANG:
                content = sub.get("content", {}).get("valueString")
                if content:
                    it["text"] = content
    it.pop("_text", None)


def walk(item):
    for it in item:
        localize_text(it)
        if "answerValueSet" in it:
            canonical = it.pop("answerValueSet")
            opts = expand(canonical)
            it["answerOption"] = opts
            downgrade_autocomplete(it)
            print(f"  {it['linkId']}: {len(opts)} options  <- {canonical}")
        if "item" in it:
            walk(it["item"])


def main():
    global LANG
    if not os.path.exists(SRC):
        sys.exit(f"ERROR: {SRC} not found. Run tests/assemble-questionnaire.sh <RootId> first.")
    for LANG in LANGS:
        preview_id, preview_url, preview_name, out = preview_identity(LANG)
        # Reload the source for each language: walk() mutates the questionnaire in place
        # (pops answerValueSet, injects answerOption), so each build needs a fresh copy.
        q = json.load(open(SRC))
        print(f"\n[{LANG}] Expanding answerValueSets via {TX} ...")
        walk(q.get("item", []))
        # Re-identify as a distinct preview resource (avoid id/url collision with the assembled one).
        q["id"] = preview_id
        q["url"] = preview_url
        q["name"] = preview_name
        q["title"] = q.get("title", "") + f" (preview {LANG}, pre-expanded)"
        q["language"] = LANG
        json.dump(q, open(out, "w"), indent=2, ensure_ascii=False)
        print(f"Wrote {out}  (id: {preview_id})")


if __name__ == "__main__":
    main()
