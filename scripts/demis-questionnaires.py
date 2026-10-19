#!/usr/bin/env python3
"""
Download the RKI DEMIS disease-notification Questionnaires and (optionally) publish them to the
Smart Forms Forms Server, for side-by-side demonstration with the CH EKM forms.

DEMIS (the German notification system) ships its forms as plain Questionnaire resources in the
Simplifier package rki.demis.disease (https://simplifier.net/packages/rki.demis.disease): one
DiseaseQuestionsCommon answered by every disease notification plus one DiseaseQuestions<XXX> per
notifiable disease. Their answer ValueSets (https://demis.rki.de/fhir/ValueSet/...) are not served by
any public terminology server, so Smart Forms could not render a single choice item. This script makes
every Questionnaire self-contained instead:

  - each `answerValueSet` canonical is replaced by a CONTAINED ValueSet (`#<id>`) carrying a
    pre-computed `expansion`. Smart Forms reads the codings of a contained ValueSet straight from its
    expansion and never calls a terminology server for it (smart-forms-renderer
    extractContainedValueSets.ts). The expansion is built locally from the package content:
      * enumerated `compose.include.concept`  -> taken as is (DEMIS display, which is German for the
        DEMIS/SNOMED codes; the v3-NullFlavor ones are English in the source and stay so),
        ordered by the `valueset-conceptOrder` extension when every concept carries one;
      * `compose.include.system` without concepts -> every concept of that CodeSystem, looked up in
        rki.demis.disease or in one of its rki.demis.* dependencies (rki.demis.common);
      * `compose.include.valueSet`            -> expanded recursively.
    Filters are not supported; the script stops on one rather than emit an incomplete answer list.
  - answer sets listed in DEMO_SUBSETS are cut down for the demo (today only the 3,851-entry
    geographic region list, cut to Germany + Bundeslaender = 20 entries); the contained ValueSet's
    title and description say so.
  - `title` is prefixed with "DEMIS: " so the Forms Server picker shows where the form comes from.

Everything else (id, url, version, items, enableWhen, initial values) is left untouched, so a
QuestionnaireResponse captured with the demo copy still points at the original DEMIS canonical.

Output: temp/demis/Questionnaire-<id>.json (temp/ is gitignored), the downloaded packages under
temp/demis/packages/.

Publishing is opt-in, as for the CH EKM questionnaires (scripts/assemble-questionnaire.sh): pass
--upload (or EKM_UPLOAD=1); the target is EKM_FHIR_BASE, default https://smartforms.ahdis.ch/api/fhir.
Each Questionnaire is PUT by its DEMIS id. Before writing, the script GETs that id and refuses to
overwrite a resource with a different canonical url, so it never clobbers an unrelated form that
happens to share the id. After writing, it checks the stored copy still holds every contained
ValueSet (HAPI can drop contained resources, see scripts/upload-questionnaire.sh).

Usage:
  python3 scripts/demis-questionnaires.py                    # latest version, build only
  python3 scripts/demis-questionnaires.py --version 3.0.0    # a specific package version
  python3 scripts/demis-questionnaires.py --upload           # ... and publish to the Forms Server
  EKM_FHIR_BASE=http://localhost:8080/fhir python3 scripts/demis-questionnaires.py --upload
"""
import argparse, copy, glob, io, json, os, sys, tarfile, urllib.error, urllib.request, uuid
from datetime import datetime, timezone

# Run from the repo root regardless of where the script is invoked from.
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))

REGISTRY = "https://packages.simplifier.net"
PACKAGE = "rki.demis.disease"
OUT_DIR = "temp/demis"
PKG_DIR = os.path.join(OUT_DIR, "packages")
TITLE_PREFIX = "DEMIS: "
CONCEPT_ORDER = "http://hl7.org/fhir/StructureDefinition/valueset-conceptOrder"
# Only the DEMIS packages are needed to expand the answer ValueSets; the base dependencies
# (hl7.fhir.r4.core, de.basisprofil.r4) define none of them and are large.
DEPENDENCY_PREFIX = "rki.demis."

# DEMO CUTS: answer sets deliberately shortened for the demo copy. answerSetGeographicRegion
# (item placeExposureRegion in DiseaseQuestionsCommon) includes the whole geographicRegion
# CodeSystem: 3,849 codes from continents down to every German Landkreis, ~500 KB inline, as a flat
# drop-down in Smart Forms. The DEMIS portal shows it as a server-backed autocomplete instead
# (DEMIS-fhir-ui-data-model-translation-service). For the demo we keep Germany and its 16
# Bundeslaender plus "Ausland (Land unbekannt)" and the two NullFlavors - 20 entries. The contained
# ValueSet's compose is rewritten to the kept codes and its title/description say so, so the cut is
# visible in the resource and not mistaken for DEMIS content. A listed code missing from the package
# fails the build (the package changed), rather than shrinking the list silently.
DEMO_SUBSETS = {
    "https://demis.rki.de/fhir/ValueSet/answerSetGeographicRegion": {
        "codes": {"21000109"}                                   # Deutschland
                 | {f"130000{n:02d}" for n in range(1, 17)}     # the 16 Bundeslaender
                 | {"31099999", "ASKU", "NASK"},                # Ausland (Land unbekannt), NullFlavors
        "note": "Für die Demo gekürzt auf Deutschland, die 16 Bundesländer, \"Ausland (Land "
                "unbekannt)\" und die NullFlavors; das DEMIS-Original enthält das ganze CodeSystem "
                "geographicRegion (Kontinente bis Landkreise).",
    },
}


def http_json(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers={"Accept": "application/json"})) as r:
        return json.load(r)


def fetch_package(name, version):
    """Download name@version (version None = latest) into PKG_DIR and return (version, folder)."""
    if not version:
        version = http_json(f"{REGISTRY}/{name}")["dist-tags"]["latest"]
    folder = os.path.join(PKG_DIR, f"{name}-{version}")
    if not os.path.isdir(folder):
        print(f"  downloading {name}@{version}")
        with urllib.request.urlopen(f"{REGISTRY}/{name}/{version}") as r:
            data = r.read()
        with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as tar:
            # 'data' filter: no absolute paths, no '..', no links out of the target folder.
            tar.extractall(folder, filter="data")
    else:
        print(f"  cached      {name}@{version}")
    return version, folder


def fetch_with_dependencies(name, version):
    """Return {name: (version, folder)} for the package and its rki.demis.* dependencies."""
    seen = {}
    todo = [(name, version)]
    while todo:
        n, v = todo.pop()
        if n in seen:
            continue
        seen[n] = fetch_package(n, v)
        manifest = json.load(open(os.path.join(seen[n][1], "package", "package.json")))
        for dn, dv in (manifest.get("dependencies") or {}).items():
            if dn.startswith(DEPENDENCY_PREFIX):
                todo.append((dn, dv))
    return seen


def load_resources(folders):
    """Index every resource of the packages (package/ and package/examples/) by type and url."""
    questionnaires, valuesets, codesystems = [], {}, {}
    for folder in folders:
        for f in sorted(glob.glob(os.path.join(folder, "package", "**", "*.json"), recursive=True)):
            try:
                res = json.load(open(f, encoding="utf-8"))
            except (json.JSONDecodeError, UnicodeDecodeError):
                continue
            rt = res.get("resourceType") if isinstance(res, dict) else None
            if rt == "Questionnaire" and folder == folders[0]:
                questionnaires.append(res)
            elif rt == "ValueSet" and res.get("url"):
                valuesets.setdefault(res["url"], res)
            elif rt == "CodeSystem" and res.get("url"):
                codesystems.setdefault(res["url"], res)
    return questionnaires, valuesets, codesystems


def flatten_concepts(concepts):
    for c in concepts or []:
        yield c
        yield from flatten_concepts(c.get("concept"))


def concept_order(c):
    for e in c.get("extension", []):
        if e.get("url") == CONCEPT_ORDER:
            return e.get("valueInteger")
    return None


class Expander:
    def __init__(self, valuesets, codesystems):
        self.valuesets, self.codesystems = valuesets, codesystems

    def contains(self, canonical, stack=()):
        url = canonical.split("|")[0]
        if url in stack:
            raise ValueError(f"circular ValueSet include: {' -> '.join(stack + (url,))}")
        vs = self.valuesets.get(url)
        if vs is None:
            raise ValueError(f"ValueSet {canonical} not found in the packages")
        compose = vs.get("compose") or {}
        # valueset-conceptOrder numbers the concepts across ALL includes of the ValueSet (e.g. the
        # DEMIS codes 300/400, the NullFlavor ones 999/1000), so sort the whole list. Concepts
        # without an order (a whole CodeSystem, a nested ValueSet) stay right after whatever the
        # includes before them ordered: a region CodeSystem followed by the NullFlavors 999/1000
        # keeps the NullFlavors at the end, not on top.
        result, running_max = [], float("-inf")
        for inc in compose.get("include", []):
            for e in self._include(inc, url, stack + (url,)):
                if e["_order"] is None:
                    e["_sort"] = (running_max, 1, len(result))
                else:
                    e["_sort"] = (e["_order"], 0, len(result))
                    running_max = max(running_max, e["_order"])
                result.append(e)
        excluded = {(e["system"], e["code"])
                    for exc in compose.get("exclude", []) for e in self._include(exc, url, stack + (url,))}
        result.sort(key=lambda e: e["_sort"])
        seen, out = set(), []
        for entry in result:
            key = (entry["system"], entry["code"])
            if key not in excluded and key not in seen:
                seen.add(key)
                out.append({k: v for k, v in entry.items() if k not in ("_order", "_sort")})
        return out

    def _include(self, inc, vs_url, stack):
        if inc.get("filter"):
            raise ValueError(f"{vs_url}: compose filters are not supported ({inc['filter']})")
        entries = []
        system, version = inc.get("system"), inc.get("version")
        if system:
            if inc.get("concept"):
                concepts = inc["concept"]
            else:
                cs = self.codesystems.get(system)
                if cs is None:
                    raise ValueError(f"{vs_url}: includes all of {system}, which is not in the packages")
                version = version or cs.get("version")
                concepts = list(flatten_concepts(cs.get("concept")))
            for c in concepts:
                e = {"system": system}
                if version:
                    e["version"] = version
                e["code"] = c["code"]
                if c.get("display"):
                    e["display"] = c["display"]
                e["_order"] = concept_order(c) if inc.get("concept") else None
                entries.append(e)
        for nested in inc.get("valueSet", []):
            nested_entries = [{**e, "_order": None} for e in self.contains(nested, stack)]
            if system:  # include = intersection of the system part and the nested value sets
                keep = {(e["system"], e["code"]) for e in nested_entries}
                entries = [e for e in entries if (e["system"], e["code"]) in keep]
            else:
                entries += nested_entries
        return entries

    def contained_valueset(self, canonical, timestamp):
        url = canonical.split("|")[0]
        vs = copy.deepcopy(self.valuesets[url])
        vs.pop("text", None)
        vs.pop("meta", None)
        contains = self.contains(canonical)
        if url in DEMO_SUBSETS:
            contains = apply_demo_subset(vs, contains, DEMO_SUBSETS[url])
        vs["expansion"] = {
            "identifier": f"urn:uuid:{uuid.uuid4()}",
            "timestamp": timestamp,
            "total": len(contains),
            "contains": contains,
        }
        return vs


def apply_demo_subset(vs, contains, subset):
    """Cut an expansion down to subset['codes'] (keeping its order) and make the ValueSet say so."""
    kept = [e for e in contains if e["code"] in subset["codes"]]
    missing = subset["codes"] - {e["code"] for e in kept}
    if missing:
        raise ValueError(f"{vs['url']}: demo subset codes not in the expansion: {sorted(missing)}")
    # The compose must describe what the expansion holds, so enumerate the kept codes.
    includes = {}
    for e in kept:
        inc = includes.setdefault((e["system"], e.get("version")), {"system": e["system"]})
        if e.get("version"):
            inc["version"] = e["version"]
        inc.setdefault("concept", []).append({k: e[k] for k in ("code", "display") if k in e})
    vs["compose"] = {"include": list(includes.values())}
    vs["title"] = f"{vs.get('title') or vs.get('name')} (Demo, gekürzt)"
    vs["description"] = f"{vs.get('description', '')} {subset['note']}".strip()
    return kept


def walk_items(items):
    for it in items or []:
        yield it
        yield from walk_items(it.get("item"))


def convert(q, expander, timestamp):
    """Return the self-contained demo copy of a DEMIS Questionnaire (input is left untouched)."""
    q = copy.deepcopy(q)
    q.pop("text", None)
    q.pop("meta", None)
    title = q.get("title") or q.get("name") or q["id"]
    if not title.startswith(TITLE_PREFIX):
        q["title"] = TITLE_PREFIX + title

    contained = {r["id"]: r for r in q.get("contained", []) if r.get("id")}
    by_canonical = {}
    for it in walk_items(q.get("item")):
        canonical = it.get("answerValueSet")
        if not canonical or canonical.startswith("#"):
            continue
        if canonical not in by_canonical:
            vs = expander.contained_valueset(canonical, timestamp)
            cid = vs["id"]
            n = 2
            while cid in contained:  # contained ids must be unique within the Questionnaire
                cid = f"{vs['id']}-{n}"
                n += 1
            vs["id"] = cid
            contained[cid] = vs
            by_canonical[canonical] = cid
        it["answerValueSet"] = "#" + by_canonical[canonical]
    if contained:
        q["contained"] = list(contained.values())
        # Put `contained` where the FHIR JSON serialisation has it, so the files diff cleanly.
        head = ["resourceType", "id", "meta", "implicitRules", "language", "text", "contained"]
        q = {**{k: q[k] for k in head if k in q}, **{k: v for k, v in q.items() if k not in head}}
    return q, len(by_canonical)


def request(method, url, body=None):
    data = json.dumps(body, ensure_ascii=False).encode("utf-8") if body is not None else None
    req = urllib.request.Request(url, data=data, method=method, headers={
        "Accept": "application/json", "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req) as r:
            return r.status, json.load(r)
    except urllib.error.HTTPError as e:
        try:
            return e.code, json.load(e)
        except Exception:
            return e.code, None


def upload(q, base):
    """PUT one Questionnaire by id; return an error message, or None on success."""
    target = f"{base}/Questionnaire/{q['id']}"
    status, existing = request("GET", target)
    if status == 200 and existing and existing.get("url") != q["url"]:
        return (f"{target} already holds a different Questionnaire ({existing.get('url')}); "
                "not overwritten")
    status, stored = request("PUT", target, q)
    if status not in (200, 201) or not stored or stored.get("resourceType") != "Questionnaire":
        issue = (stored or {}).get("issue", [{}])[0].get("diagnostics", "")
        return f"PUT {target} -> HTTP {status} {issue}"
    sent, kept = len(q.get("contained", [])), len(stored.get("contained", []))
    if kept != sent:
        return f"server stored {kept} of {sent} contained ValueSets for {q['id']}"
    return None


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--version", help=f"{PACKAGE} version (default: latest on {REGISTRY})")
    ap.add_argument("--upload", action="store_true", help="publish to the Forms Server")
    args = ap.parse_args()
    do_upload = args.upload or os.environ.get("EKM_UPLOAD") == "1"
    if os.environ.get("EKM_UPLOAD") == "0":
        do_upload = False
    base = os.environ.get("EKM_FHIR_BASE", "https://smartforms.ahdis.ch/api/fhir").rstrip("/")

    os.makedirs(PKG_DIR, exist_ok=True)
    print(f"Fetching {PACKAGE} and its {DEPENDENCY_PREFIX}* dependencies from {REGISTRY}")
    packages = fetch_with_dependencies(PACKAGE, args.version)
    version = packages[PACKAGE][0]
    folders = [packages[PACKAGE][1]] + [f for n, (_, f) in packages.items() if n != PACKAGE]
    questionnaires, valuesets, codesystems = load_resources(folders)
    print(f"  {len(questionnaires)} Questionnaires, {len(valuesets)} ValueSets, "
          f"{len(codesystems)} CodeSystems")
    if not questionnaires:
        sys.exit(f"ERROR: no Questionnaire found in {PACKAGE}@{version}")

    expander = Expander(valuesets, codesystems)
    timestamp = datetime.now(timezone.utc).replace(microsecond=0).isoformat()
    for old in glob.glob(os.path.join(OUT_DIR, "Questionnaire-*.json")):
        os.remove(old)  # a Questionnaire dropped from the package must not linger
    print(f"\nBuilding self-contained copies in {OUT_DIR}/")
    built, failed = [], []
    for q in sorted(questionnaires, key=lambda r: r["id"]):
        try:
            out, n_vs = convert(q, expander, timestamp)
        except ValueError as e:
            failed.append((q["id"], str(e)))
            print(f"  FAILED {q['id']}: {e}")
            continue
        path = os.path.join(OUT_DIR, f"Questionnaire-{out['id']}.json")
        with open(path, "w", encoding="utf-8") as f:
            json.dump(out, f, ensure_ascii=False, indent=2)
            f.write("\n")
        built.append(out)
        print(f"  {out['id']:<34} {n_vs:>3} ValueSet(s) embedded  {out['title']}")

    if failed:
        print(f"\nERROR: {len(failed)} Questionnaire(s) could not be built — none were uploaded.")
        sys.exit(1)

    if not do_upload:
        print(f"\nBuilt {len(built)} Questionnaire(s) from {PACKAGE}@{version}. "
              "Not published (upload is opt-in).")
        print("  Publish with:  python3 scripts/demis-questionnaires.py --upload")
        return

    print(f"\nPublishing {len(built)} Questionnaire(s) to {base}")
    errors = []
    for q in built:
        err = upload(q, base)
        print(f"  {'FAILED' if err else 'ok    '} Questionnaire/{q['id']}" + (f": {err}" if err else ""))
        if err:
            errors.append(err)
    print()
    if errors:
        print(f"ERROR: {len(errors)} of {len(built)} upload(s) failed.")
        sys.exit(1)
    print(f"Published {len(built)} DEMIS Questionnaire(s) ({PACKAGE}@{version}).")
    # The renderer is the host root of a Forms Server (…/api/fhir), see scripts/upload-questionnaire.sh.
    if base.endswith("/api/fhir"):
        print(f"Open one in the hosted renderer, e.g.:\n"
              f"  {base[:-len('/api/fhir')]}/?questionnaireUrl={built[0]['url']}")


if __name__ == "__main__":
    main()
