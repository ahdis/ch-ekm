# Test plan — SDC `$extract` regression suite

Status: **proposal** (nothing implemented yet). Scope: the SDC template-based `$extract`
pipeline (`Questionnaire` + `QuestionnaireResponse` → document `Bundle`).

## Why this needs a suite

The extract engine **fails silently**. A `templateExtractContext` whose FHIRPath returns an
empty collection causes the engine to *drop that array element* — by design, that is how
optional answers are omitted. So a broken reference and an unanswered question are
indistinguishable in the output: both yield a well-formed `Bundle` that passes profile
validation, just with data missing.

Neither of the two checks we run today catches that:

| check | catches | misses |
| --- | --- | --- |
| `sushi .` | FSH syntax, profile violations | anything about FHIRPath strings — they are opaque `valueString`s |
| IG Publisher QA | profile conformance of the *committed* bundles | a Bundle that is valid but missing components |

The `Exposition`→`Exposure` and linkId-prefix renames (issue #25) rewrote 8 FHIRPath
`linkId='…'` references. The only reason we know nothing broke is that the Gonorrhoea
extracted bundle came out **byte-identical** and the Mpox one differed by exactly the one
intended line. That diff *was* the test — it was just run by hand. This plan automates it.

## Prior art: `../smart-forms`

`packages/sdc-template-extract` (the reference engine we run locally) tests itself with Jest,
~1550 lines over 7 files. The relevant one is `tests/extract.test.ts` — pure **golden-file
testing** over fixture triples:

```
tests/resources/questionnaires/QSepsisRisk.ts            ← input Questionnaire (contained template)
tests/resources/questionnaireResponses/QRSepsisRisk.ts   ← input QuestionnaireResponse
tests/resources/extracted/extractedSepsisRisk.ts         ← expected Bundle
```

…asserted with `expect(extracted.entry[i].resource).toEqual(expected.entry[i].resource)`.
Ten scenarios, one per template feature.

Two things do not transfer directly:

- Their fixtures are **hand-written TS constants**. Ours are **SUSHI build artifacts**, so our
  suite must *build* before it asserts (see the stale-template trap below).
- Their tests verify **the engine**. Ours must verify **our template's branch logic** — a
  different target, and the reason a plain golden compare is not sufficient on its own.

## Layer 0 — static lint (no extraction)

Highest value per line, and the direct antidote to the silent-drop failure mode. Runs in
milliseconds, needs no fixtures, and would have caught every possible rename miss in issue #25.

**Rule.** Collect every `linkId='…'` from the template's FHIRPath strings (any
`templateExtractValue` / `templateExtractContext` `valueString`). Collect every `linkId` in the
assembled questionnaire. Flag any **expression** in which *none* of the referenced ids resolve.

**Per-expression, not per-linkId** — this matters. The shared `ExtractedPatient` template
deliberately supports both name modules:

```fhirpath
%factory.HumanName(item.where(linkId='surnameInitial' or linkId='surname').answer.value.first(), …)
```

Mpox assembles the full-name module, so `surnameInitial` is *legitimately* absent; Gonorrhoea
assembles initials, so `surname` is. A naive per-linkId rule reports both as dangling. The
correct rule is "at least one referenced id resolves per expression".

**Baseline today** (both clean):

| form | expressions reading answers | orphaned |
| --- | --- | --- |
| `ChEkmQuestionnaireMpoxAssembled` | 43 | 0 |
| `ChEkmQuestionnaireGonorrhoeaAssembled` | 40 | 0 |

Proposed home: `scripts/lint-extract-links.sh` (or `.mjs`), run over every
`input/resources/Questionnaire-*Assembled.json`. Exit non-zero on any orphan.

Worth adding as a second lint: flag any questionnaire `linkId` that **no** expression reads.
Not always a bug (display-only items, group wrappers), so warn rather than fail — but it is how
you notice a form item that was never wired into extraction at all.

## Layer 1 — golden-file extraction tests

Mirrors smart-forms, with fixtures on disk instead of TS constants.

```
scripts/extract/tests/
  run.mjs                                   ← runner
  cases/
    mpox/exposure-date-known/{qr.json,expected.json}
    mpox/exposure-entry-date-unknown/{qr.json,expected.json}
    mpox/transmission-unknown/{qr.json,expected.json}
    mpox/transmission-other/{qr.json,expected.json}
    gonorrhoea/baseline/{qr.json,expected.json}
```

**Runner steps**

1. `sushi .`
2. **`./scripts/assemble-<disease>.sh --no-upload`** — mandatory, see trap below
3. for each case: `extract(assembled Q, case qr.json)` → compare to `expected.json` with
   `assert.deepStrictEqual`
4. `--update` regenerates the goldens; reviewing the resulting `git diff` is the actual test

**⚠️ The stale-template trap.** `scripts/extract-*.sh` reads the template from
`input/resources/Questionnaire-…Assembled.json`, which embeds a **copy** of the contained
Bundle template. `sushi .` alone does *not* refresh that copy. Editing a ruleset in
`input/fsh/questionnnaire/extract/` and re-running only `sushi .` + `extract-*.sh` silently
tests the **previous** template. This cost a false negative while implementing the
`data-absent-reason` branch — the FSH was already correct. Step 2 is not optional.

**Fixtures stay out of the IG.** Case QRs live under `scripts/` as plain JSON, not FSH. Only
the one canonical QR per disease remains a published IG example; otherwise every test case
becomes a rendered example page.

**Runner choice.** `node:test` + `assert.deepStrictEqual` — zero new dependencies, no config,
appropriate for a repo where JS is tooling rather than product. Jest is the alternative if
mirroring upstream exactly is preferred; `scripts/extract/` already has its own `package.json`.

### Case inventory

Each case pins one branch of the template. All five are already exercised — by hand, with `jq`
— during the issue #25 work; this table is that work made repeatable.

| case | pins | expected output |
| --- | --- | --- |
| `mpox/exposure-date-known` | repeating `manifestation` (3 answers); answered onset; `exposureWhenDate`; transmission fallback (nested `iif`) | 3 × `evidence`; `onsetDateTime`; `effectiveDateTime`; `component[409496000] = 417564009` |
| `mpox/exposure-entry-date-unknown` | `exposureWhenLastEntryDate`; `%factory.Extension` carrier | no `effectiveDateTime` value; `_effectiveDateTime` DAR `asked-unknown`; `component[161097008].valueDateTime` |
| `mpox/transmission-unknown` | `exposureHowUnknown = true` gate | `component[409496000] = 261665006`; no free-text component |
| `mpox/transmission-other` | `exposureHowOtherTransmission` free text | `component[74964007].valueString`; `component[409496000] = 74964007` |
| `gonorrhoea/baseline` | initials name module; onset **data-absent** branch (`manifestationBeginUnknown = true`) | `_onsetDateTime` DAR; `name` from initials |

Coverage gap worth closing later: no case yet asserts the *absence* of `section[social-history]`
when the whole exposure group is unanswered.

## Layer 2 — profile-validate the case outputs

A golden compare proves **stability**, not **correctness**: a wrong-but-consistent template
passes forever. The committed bundles are validated because they live in `input/resources/` and
the IG Publisher picks them up; case outputs would not be.

Batch every case output through the FHIR validator CLI against `ChEkmDocumentMpox` /
`ChEkmDocumentGonorrhoea` in a **single** run (one JVM start ≈ 1 min; per-case would be
unusable). Run in CI and on demand, not on every local edit.

## Intent assertions alongside goldens

A golden diff says *something changed*, not *whether it is right* — and a large diff invites
rubber-stamping. Pair each case with 2–3 explicit assertions capturing the semantics, so an
unrelated template edit that legitimately churns the golden still gets its invariants checked.

For `exposure-entry-date-unknown`:

- exactly one of `effectiveDateTime` (value) / `_effectiveDateTime` (DAR) is present — never both
- `component[161097008]` present **iff** the DAR branch fired
- `component[161097008].valueDateTime` equals the answered `exposureWhenLastEntryDate`

## Sequencing

1. **Layer 0** — standalone, ~40 lines, no fixtures. Lands as its own commit.
2. **Layer 1** — runner + the 5 cases above, goldens generated with `--update` and reviewed.
3. **CI** — `sushi . && lint-extract-links && extract tests` on PR. Layer 2 nightly or on
   release branches.

## Open decisions

- `node:test` vs Jest (recommendation: `node:test`).
- Whether Layer 0 also fails on *unread* questionnaire linkIds, or only warns (recommendation:
  warn).
- Whether goldens live beside the cases (`cases/<name>/expected.json`, as above) or in a
  parallel `expected/` tree mirroring smart-forms' layout.
