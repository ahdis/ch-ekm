# forms-summary.md — SDC Questionnaires for CH EKM

Analysis of the **Smart Forms** project (`../smart-forms`) and a plan for building the
CH EKM reporting forms as **modular FHIR SDC Questionnaires**, starting with Gonorrhoea.

---

## 1. The viewer: Smart Forms (CSIRO)

Smart Forms (`../smart-forms`) is an open-source, React/TypeScript reference
implementation of the HL7 **Structured Data Capture (SDC)** IG, FHIR **R4**. We use it as
the renderer for the CH EKM forms.

What it gives us:
- **Renderer library** `@aehrc/smart-forms-renderer` (npm) — embeds a `Questionnaire` →
  interactive form → `QuestionnaireResponse` in any React app.
- **Hosted app/playground**: https://smartforms.csiro.au (load local questionnaires
  un-launched) and a **Storybook** of every supported item type / SDC behaviour.
- **Docs**: `../smart-forms/documentation/docs/` (also https://smartforms.csiro.au/docs).
- **SDC operation microservices** (each a TS package + an Express service + Docker image):
  | Operation | Package | Service | Purpose |
  | --- | --- | --- | --- |
  | `$assemble` | `packages/sdc-assemble` | `services/assemble-express` | merge a **modular** questionnaire + its sub-questionnaires into one |
  | `$populate` | `packages/sdc-populate` | `services/populate-express` | pre-fill answers from FHIR data |
  | `$extract`  | `packages/sdc-template-extract` | *(in-app library)* | turn a `QuestionnaireResponse` back into FHIR resources via **template-based** extraction (see §8) |

> **`extract-express` is *not* what we use.** That service implements the *StructureMap-based*
> `$extract` (it only proxies to an external `StructureMap/$transform`) and is **deprecated**
> (unmaintained after 2025‑07‑01). Template-based extraction lives in the
> `@aehrc/sdc-template-extract` npm library (`inAppExtract()` / `extract()`), which Smart Forms
> runs in-app — there is no hosted `$extract` endpoint.

Hosted endpoints (for prototyping):
- Assemble: `https://smartforms.csiro.au/api/fhir/Questionnaire/$assemble` — **no longer used
  by our build** (see the switch below); kept here as a reference/fallback endpoint.

> **`/api/fhir` is the FHIR server, `/fhir` is the web app.** The HAPI Forms Server the
> renderer reads from (and that `$assemble`/`$populate` live on) is at
> **`https://smartforms.csiro.au/api/fhir`**. The bare **`https://smartforms.csiro.au/fhir`**
> path is the **renderer single-page app** (served from S3/CloudFront) — a `PUT` there
> returns the SPA's `index.html` with HTTP 200, not a FHIR response. Always upload to
> `/api/fhir` (see §9).
>
> **The deployed endpoint is HAPI, not the TS microservices.** `/api/fhir/metadata` reports
> **HAPI FHIR Server 8.10.0**, so the hosted `$assemble`/`$populate` are HAPI's operations, not
> the `sdc-assemble`/`sdc-populate` Express services in the table above (those are the *reference*
> implementations / what Smart Forms runs in-app). This matters for both `$assemble` (see next)
> and `$populate` FHIRPath support (see §10).

**We assemble LOCALLY with the SDC reference library `@aehrc/sdc-assemble`** (via
`tests/assemble/assemble.cjs`, wrapped by `tests/assemble-gonorrhoea.sh`) — the same engine the
Smart Forms renderer runs in-app, and a sibling of the local `$populate` / `$extract` wrappers
(`tests/populate/`, `tests/extract/`; all CJS for the same `fhirpath` directory-import reason,
§8/§10). The wrapper builds a `canonical → Questionnaire` index from `fsh-generated/resources` and
supplies it through the library's `fetchQuestionnaireCallback` (returning a searchset `Bundle`
whose `entry[0].resource` is the child), so **no FHIR server and no upload step are needed**.

> **Why we moved off the hosted HAPI `$assemble` (2026-07).** HAPI requires **every**
> questionnaire it processes — the root **and every child** — to carry the `item[0].item` group
> nesting; a **groupless leaf** sub-questionnaire (top-level items not wrapped in a group) is
> rejected with `HTTP 400 — "Root questionnaire does not have a valid item."` The `@aehrc/sdc-assemble`
> reference engine is more lenient: `getCanonicalUrls` returns `[]` (no error) for a child without
> `item[0].item`, so a groupless leaf just contributes its items directly. We rely on this so the
> **person leaves stay flat** (no wrapping group) and merge into one flat group in the assembled
> form. Trade-off: the committed assembled artifact is produced offline by the reference engine
> rather than the hosted server (equivalent output, and it is the engine the renderer uses anyway).
>
> **Recursion fix (patch-package).** Stock `@aehrc/sdc-assemble` has a bug: in `assembleQuestionnaire`
> the recursive result is discarded (`for (let subquestionnaire of subquestionnaires) { … subquestionnaire = assembled }`
> reassigns the loop variable, not the array element), so a child that is itself modular is spliced in
> **un-assembled** — nested/recursive modular never flattens. We fix it with a one-line change
> (index loop → `subquestionnaires[i] = assembled`), applied to `dist/index.cjs` + `dist/index.js`
> via **patch-package** (`tests/assemble/patches/@aehrc+sdc-assemble+2.0.2.patch`, replayed by the
> `postinstall` hook). With the patch, **nested/recursive `subQuestionnaire` works per spec** — a
> disease root can reference an aggregator (e.g. `ChEkmQuestionnaireGonorrhoeaPerson`) that itself
> references leaf children, and it flattens fully (see §4).
>
> **Upstreamed** as aehrc/smart-forms PR **[#1998](https://github.com/aehrc/smart-forms/pull/1998)**
> (same one-line fix + a strengthened `assemble.test.ts` regression test that fails on `main`). Once
> it ships in a released `@aehrc/sdc-assemble`, bump the version and drop the local patch.
>
> **Requirement that still holds at each level:** within any one questionnaire the `subQuestionnaire`
> placeholders must be **direct children of `item[0]`** (`item[0].item[x]`) — `getCanonicalUrls` reads
> `parentQuestionnaire.item[0].item` and does not descend into deeper groups. And `propagateProperties`
> replaces `item[0].item` **by position**, so `item[0].item` should be **all placeholders**: real
> (non-placeholder) content interleaved *before* a placeholder misaligns the indices (real content
> only survives if it comes after all placeholders). All our modular roots keep `item[0].item`
> all-placeholders, so this is a non-issue in practice.

> **matchbox / hosted HAPI as fallbacks.** matchbox (`test.ahdis.ch/matchbox/fhir`) and the hosted
> HAPI both implement `Questionnaire/$assemble` and accept a nested-group root (matchbox wants
> `Content-Type: application/fhir+json` + an SDC `Parameters{questionnaire}` body; the CSIRO Express
> service wants `application/json` + a bare/wrapped `Questionnaire`). Both share HAPI's stricter
> group requirement above, so neither assembles our groupless leaves — use the local engine.

### Supported building blocks (relevant to us)
- **Item types**: `group`, `display`, `string`, `text`, `boolean`, `date`, `dateTime`,
  `integer`, `decimal`, `choice`, `open-choice`, `quantity`, `reference`, `attachment`,
  `url`, `time` (one `.mdx` per type under `documentation/docs/components/`).
- **Answer sources**: `answerOption` (inline) or `answerValueSet` (canonical → expanded by
  a terminology server). Our value sets already exist in `input/fsh/terminology/`.
- **itemControl** extension: `drop-down`, `radio-button`, `check-box`, `autocomplete`.
  `choiceOrientation` controls horizontal/vertical layout.
- **Behaviour**: `enableWhen` / `enableBehavior` (conditional display, e.g. show a free-text
  field only when "andere/other" is chosen, or grey out a date when "unbekannt" is ticked),
  `required`, `repeats`, `readOnly`, `initial`.
- **SDC extensions** (per component docs): `enableWhenExpression`, `calculatedExpression`,
  `answerExpression`, `answerOptionsToggleExpression`, `hidden`, `preferredTerminologyServer`.
- **Pre-population** (`docs/sdc/population.mdx`): expression-based via `launchContext`,
  `x-fhir-query` `variable`, `itemPopulationContext`, `initialExpression`,
  `calculatedExpression`. Useful later to pre-fill patient data from the CIS.

---

## 2. Modular questionnaires & `$assemble`

This is the mechanism for the "modular questionnaire, assemble the final one" goal.

**Concept** (SDC *Modular Questionnaire*,
http://hl7.org/fhir/uv/sdc/modular.html):

- A **sub-questionnaire** is a normal, standalone, reusable `Questionnaire` that declares
  itself assemblable with the **assemble-expectation** extension:
  ```json
  {
    "url": "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-assemble-expectation",
    "valueCode": "assemble-child"
  }
  ```
- A **root / modular** `Questionnaire` carries
  `meta.profile = http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-modular`
  and, wherever a sub-questionnaire's content should appear, a placeholder **`display`
  item** with the **subQuestionnaire** extension pointing at the child's canonical url
  (optionally `|version`):
  ```json
  {
    "linkId": "person",
    "type": "display",
    "text": "Sub-questionnaire ... not available. Unable to display all questions.",
    "extension": [{
      "url": "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-subQuestionnaire",
      "valueCanonical": "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnairePerson|0.0.1"
    }]
  }
  ```
- Calling **`$assemble`** on the root replaces each placeholder with the child's `item`s
  (and merges contained resources, extensions, launchContexts), producing one flat
  **assembled** questionnaire that Smart Forms renders. The assembler fetches children via
  a `fetchQuestionnaireCallback` (our local wrapper resolves them from `fsh-generated/resources`;
  see §1), checks for duplicate `linkId`s / `enableWhen` collisions, and propagates properties —
  including a child's questionnaire-level `variable` (e.g. the Person `homeOrFirstAddress` address
  variable is moved onto the assembled form group, staying in scope for `zipCode`/`city`/`canton`).

Reference behaviour is in `packages/sdc-assemble/src/test/assemble.test.ts` and
`fetchSubquestionnaires.test.ts` — good fixtures to copy when shaping our resources. Engine notes
(see §1 for detail): within each questionnaire, placeholders must be **direct children of `item[0]`**
and `item[0].item` should be **all placeholders** (positional replacement); **nested/recursive**
modular now flattens correctly thanks to our patch-package fix of the reference engine's discarded
recursion.

**Why modular for CH EKM**: the report sections (Person, Manifestation, Exposition,
Treating physician, Laboratory) recur across organisms. Each becomes a reusable
sub-questionnaire; each disease's root questionnaire assembles the subset it needs (plus
disease-specific value-set bindings).

---

## 3. logical models, not the paper form

| Logical model | Target profile |
| --- | --- |
| `ChEkmGonorrhoeaPersonForm` (← `ChEkmPersonForm`) | `ChEkmPatientInitials` |
| `ChEkmGonorrhoeaManifestationForm` (← `ChEkmManifestationForm`) | `ChEkmConditionGonorrhoea` |
| `ChEkmGonorrhoeaExpositionForm.transmission` (← `ChEkmExpositionForm`) | `ChEkmExposureGonorrhoea` |
| `ChEkmTreatingPhysicianPractitionerForm` | `ChEkmPractitionerTreatingPhysician` |
| `ChEkmTreatingPhysicianOrganizationForm` | `ChEkmOrganizationTreatingPhysician` |

### Field-by-field mapping (Gonorrhoea green sections)

**Person** (`ChEkmGonorrhoeaPersonForm`):
| Item | linkId | type | Binding / note |
| --- | --- | --- | --- |
| Initiale Name | `surnameInitial` | string | required (1..1) |
| Initiale Vorname | `givennameInitial` | string | required (1..1) |
| Geburtsdatum | `dateOfBirth` | date | required |
| Nationalität | `nationality` | choice | `ChEkmCountryCodes` |
| PLZ/Wohnort | `zipCode`, `city` | string | |
| Land | `country` | choice | `ChEkmCountryCodes` |
| Kanton | `canton` | string (or choice eCH-0007) | |
| Gender | `administrativeGender` | choice | `administrative-gender` |
| (trans …) | `genderIdentity` | choice | `ChEkmGenderIdentity` |

**Manifestation** (`ChEkmGonorrhoeaManifestationForm`):
| Item | linkId | type | Binding / note |
| --- | --- | --- | --- |
| Manifestationen | `manifestation` | choice, single, radio | `ChEkmGonorrhoeaManifestationFormChoice` (2 options) |
| Manifestationsbeginn – Datum | `manifestationBeginDate` | dateTime | |
| Manifestationsbeginn – unbekannt | `manifestationBeginUnknown` | boolean | disables the date |

> **Decision (2026-06-09) — Manifestationen reduced to 2 options.** The form shows only
> **symptomatic / asymptomatic** (radio, single-select), not the broad SNOMED list.
> A dedicated 2-concept form value set **`ChEkmGonorrhoeaManifestationFormChoice`** was
> added (`$sct#264931009 "Symptomatic (qualifier value)"` and
> `$sct#84387000 "Asymptomatic (finding)"`); `264931009` was also added to the broad
> clinical `ChEkmGonorrhoeaManifestation` so the form codes are a true **subset** of the
> profile's `Condition.evidence.code` binding. Because the form answer is itself a valid
> `evidence.code`, **no ConceptMap is required** — it is an identity pass-through. The
> previous free-text `manifestationOther` item was removed (no "other" option in scope).
>
> **Open:** the example [`ChEkmConditionExample-Gonorrhoea`](input/fsh/examples/Gonorrhoea/ChEkmBundleGonorrhoea.fsh)
> still uses `evidence.code = $sct#15628003` (the disease code) rather than `264931009`
> for "symptomatic". Left unchanged pending decision (semantics: `264931009` is the
> cleaner manifestation/evidence code, distinct from `Condition.code`).

**Transmission / Wie** (`ChEkmGonorrhoeaExpositionForm.transmission`):
| Item | linkId | type | Binding / note |
| --- | --- | --- | --- |
| Sexualkontakt – Geschlecht | `sexualContactPartner` | choice | `administrative-gender` |
| Art der Beziehung | `relationshipType` | choice | `ChEkmExposureRelationshipType` |
| anderer Übertragungsweg | `otherTransmission` | string | |
| unbekannt | `unknown` | boolean | |

**Treating Physician** (`ChEkmQuestionnaireGonorrhoeaTreatingPhysician`, two sub-groups). linkIds are
prefixed `physician*` / `org*` so they stay unique across the assembled form (the Person section
already uses `zipCode`/`city`; `$assemble` rejects duplicate linkIds). All items are `string`.
Pre-population reads a single `%user` launch context — the treating physician's
**PractitionerRole** — and resolves its `practitioner`/`organization` references; see §10.

| Sub-group | Item | linkId | card. | initialExpression source |
| --- | --- | --- | --- | --- |
| Practitioner | Vorname | `physicianGivenname` | 1..1 | `%user.practitioner.resolve().name.first().given.first()` |
| Practitioner | Name | `physicianSurname` | 1..1 | `%user.practitioner.resolve().name.first().family` |
| Practitioner | Adresse | `physicianStreetLine` | 0..1 | `%user.practitioner.resolve().address.where(use='work').combine(…).first().line.first()` |
| Practitioner | PLZ | `physicianZipCode` | 1..1 | …`.first().postalCode` |
| Practitioner | Ort | `physicianCity` | 1..1 | …`.first().city` |
| Practitioner | Telefon | `physicianPhone` | 1..1 | `%user.practitioner.resolve().telecom.where(system='phone').value.first()` |
| Practitioner | E-Mail | `physicianEmail` | 0..1 | `%user.practitioner.resolve().telecom.where(system='email').value.first()` |
| Practitioner | GLN | `physicianGln` | 0..1 | `%user.practitioner.resolve().identifier.where(system='urn:oid:2.51.1.3').value.first()` |
| Organization | Name | `orgName` | 1..1 | `%user.organization.resolve().name` |
| Organization | Abteilung | `orgDepartment` | 0..1 | `%user.organization.resolve().extension.where(url='…/ch-ekm-ext-department').valueString` |
| Organization | Adresse | `orgStreetLine` | 0..1 | `%user.organization.resolve().address.first().line.first()` |
| Organization | PLZ | `orgZipCode` | 1..1 | `%user.organization.resolve().address.first().postalCode` |
| Organization | Ort | `orgCity` | 1..1 | `%user.organization.resolve().address.first().city` |
| Organization | Telefon | `orgPhone` | 1..1 | `%user.organization.resolve().telecom.where(system='phone').value.first()` |
| Organization | E-Mail | `orgEmail` | 0..1 | `%user.organization.resolve().telecom.where(system='email').value.first()` |
| Organization | BUR (BER) | `orgBer` | 0..1 | `%user.organization.resolve().identifier.where(system='urn:oid:2.16.756.5.45').value.first()` |
| Organization | GLN | `orgGln` | 0..1 | `%user.organization.resolve().identifier.where(system='urn:oid:2.51.1.3').value.first()` |

---

## 4. Proposed modular structure for CH EKM

Reusable **sub-questionnaires** (one per report section, generic where possible):

```
ChEkmQuestionnairePerson            (assemble-child)  ← ChEkmPersonForm
ChEkmQuestionnaireManifestation     (assemble-child)  ← ChEkmManifestationForm
ChEkmQuestionnaireExposition        (assemble-child)  ← ChEkmExpositionForm
ChEkmQuestionnaireTreatingPhysician (assemble-child)  ← ChEkmTreatingPhysician{Practitioner,Organization}Form
```

> For Gonorrhoea these are realised as disease-specific children
> `ChEkmQuestionnaireGonorrhoea{Manifestation,Exposition,TreatingPhysician}` (option (a)).
> The TreatingPhysician child holds two sub-groups (Practitioner + Organization, §3) and is built.

> **Person is split into three generic LEAF sub-questionnaires (2026-07):**
> `ChEkmQuestionnairePersonInitials` (surname/given initials), `ChEkmQuestionnairePersonGeneral`
> (birth date, AHVN13, nationality, address, canton, administrative gender — carries the
> questionnaire-level `homeOrFirstAddress` variable) and `ChEkmQuestionnairePersonGenderIdentity`.
> Each leaf's items are **top-level (no wrapping group)**, so on assembly they merge into their
> referencing group as one flat block.
>
> These three leaves are gathered by **`ChEkmQuestionnaireGonorrhoeaPerson`** — an aggregator with
> one `person` group whose three children are `subQuestionnaire` placeholders to the leaves. It is
> `assemble-root-or-child`: the disease root **`ChEkmQuestionnaireGonorrhoea` references it as a
> single `person` placeholder** and the engine **recurses** (root → aggregator → three leaves),
> producing one flat `person` group of all fields — this depends on the recursion patch in §1.
> The aggregator also assembles **standalone** for reuse. (We do not commit a separate
> `…GonorrhoeaPersonAssembled.json`; assemble it on demand.) Groupless leaves + nested recursion are
> both why we assemble with the local (patched) `@aehrc/sdc-assemble` reference engine, not hosted
> HAPI (§1).

Disease-specific bindings (manifestation value set, relationship types) differ per organism.
Two options:
- **(a) Disease-specific children** — e.g. `ChEkmQuestionnaireManifestationGonorrhoea` that
  binds `manifestation` to `ChEkmGonorrhoeaManifestation`. Simplest, fully self-contained.
- **(b) Generic children + override** — keep children generic and override the
  `answerValueSet` in the root. More reuse, more complex. Recommend **(a)** to start.

**Root / modular** questionnaire assembling the Gonorrhoea green sections:

```
ChEkmQuestionnaireGonorrhoea  (meta.profile = sdc-questionnaire-modular)
  ├─ display → subQuestionnaire ChEkmQuestionnaireGonorrhoeaPerson
  ├─ display → subQuestionnaire ChEkmQuestionnaireGonorrhoeaManifestation
  ├─ display → subQuestionnaire ChEkmQuestionnaireGonorrhoeaExposition
  └─ display → subQuestionnaire ChEkmQuestionnaireGonorrhoeaTreatingPhysician
```

`$assemble` → `ChEkmQuestionnaireGonorrhoea-assembled` → render in Smart Forms.

### Authoring approach
- Author the Questionnaires as **FSH `Instance`s** (`InstanceOf: Questionnaire`,
  `Usage: #example` or `#definition`) under `input/fsh/examples/<Organism>/`, following the
  existing pattern in
  `examples/HepatitisC/ChEkmQuestionnaireHepatitisCCourseOfDisease.fsh`.
- Link each questionnaire `item` back to its logical-model element with **`item.definition`**
  = `<logical-model-canonical>#<path>` (e.g.
  `http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmPersonForm#ChEkmPersonForm.dateOfBirth`)
  to keep model ↔ form traceability and enable `$extract` later.
- Reuse existing **`answerValueSet`** canonicals from `input/fsh/terminology/`.
- Use **`enableWhen`** for the "unbekannt"/"andere" toggles (e.g. disable
  `manifestationBeginDate` when `manifestationBeginUnknown = true`; show
  `manifestationOther` when `manifestation` includes the "other" code).

### Minimal FSH skeleton (illustrative — Person sub-questionnaire)
```fsh
Instance: ChEkmQuestionnairePerson
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Angaben zur betroffenen Person"
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnairePerson"
* version = "0.0.1"
* status = #active
* extension[+].url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-assemble-expectation"
* extension[=].valueCode = #assemble-child

* item[+].linkId = "surnameInitial"
* item[=].text = "Initiale Name"
* item[=].type = #string
* item[=].required = true
// ... givennameInitial, dateOfBirth, nationality (choice → bfs-country-codes), ...
```

### Root modular questionnaire (illustrative)
```fsh
Instance: ChEkmQuestionnaireGonorrhoea
InstanceOf: Questionnaire
Usage: #example
Title: "CH EKM Questionnaire: Gonorrhoea (modular)"
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoea"
* meta.profile = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-modular"
* status = #active

// Top-level group; subQuestionnaire placeholders nested one level under it
// (item[0].item[x]) — required by the reference assembler.
* item[+].linkId = "gonorrhoea-form"
* item[=].type = #group
* item[=].text = "Meldung zum klinischen Befund: Gonorrhoea"

* item[=].item[+].linkId = "person"
* item[=].item[=].type = #display
* item[=].item[=].text = "Angaben zur betroffenen Person"
* item[=].item[=].extension[+].url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-subQuestionnaire"
* item[=].item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnairePerson"
// + manifestation + exposition placeholders (siblings under the group)
```

---

## 5. Suggested workflow

1. Build the **sub-questionnaires** as FSH instances (Person, Manifestation, Exposition),
   binding to existing value sets and `item.definition` → logical model.
2. Build the **root modular** `ChEkmQuestionnaireGonorrhoea`.
3. `sushi .` to compile, then **validate with the IG Publisher** (not matchbox MCP).
4. Run **`tests/assemble-gonorrhoea.sh`** → runs the **local** `@aehrc/sdc-assemble` reference
   engine (`tests/assemble/assemble.cjs`; `cd tests/assemble && npm install` once) and writes the
   assembled questionnaire to `input/resources/` (see note below); check for duplicate `linkId`s.
   No FHIR server / upload needed (see §1).
5. Run **`tests/preview-gonorrhoea.sh`** to pre-expand the value sets and render in
   **Smart Forms** (un-launched, local).
6. `$populate` pre-fill via `tests/populate-gonorrhoea.sh` — runs the **SDC reference**
   `@aehrc/sdc-populate` in-process (not hosted HAPI), feeding `%patient`/`%user` and
   `%organization` (the last via SMART `fhirContext`). See §10.
7. **`$extract`** the filled `QuestionnaireResponse` into a `ChEkmDocumentGonorrhoea` Bundle
   via `tests/extract-gonorrhoea.sh` — see §8.

### The assembled questionnaire is a generated, committed artifact
`tests/assemble-gonorrhoea.sh` writes
**`input/resources/Questionnaire-ChEkmQuestionnaireGonorrhoeaAssembled.json`** — a
predefined IG resource (already covered by `path-resource: input/resources` in
`sushi-config.yaml`, picked up automatically by SUSHI / the IG Publisher). It is given a
distinct `id`/`url`/`name` (`…GonorrhoeaAssembled`) so it does not collide with the modular
root example, and carries a *"GENERATED FILE — do not edit by hand"* `description` plus a
`meta.source` pointing at the script.

> ⚠️ **It does not regenerate during `sushi`.** Whenever a child sub-questionnaire (or the
> modular root) changes, **re-run `tests/assemble-gonorrhoea.sh`** to refresh the committed
> assembled resource, otherwise the published artifact drifts out of sync. The render-only
> `…-preview.json` (built by `tests/build-lang-questionnaire.py` from the assembled
> resource) stays in `fsh-generated/` and is **not** part of the IG.

---

## 6. Open questions

Still open:
1. **Disease-specific vs. generic children** (§4 (a)/(b)) — recommend (a) to start.
2. **Language**: forms are German (form labels). Single-language now, or FR/IT later?
   > **Finding (Smart Forms has no multilingual support — verified in the renderer source).**
   > - **Labels are not localized.** `getItemTextToDisplay()`
   >   (`packages/smart-forms-renderer/src/utils/itemTextToDisplay.ts`) returns `qItem.text`
   >   verbatim and does **not** read the FHIR `translation` extension on `_text`/`_prefix` — so
   >   authoring de/fr/it via `translation` extensions will **not** switch languages, and there is
   >   no display-language selector for form content.
   > - **The renderer's own UI strings are hardcoded English** (no `i18next`/`react-intl` in the
   >   package; e.g. `useDateValidation.tsx` returns literal `"Input is an invalid date."`).
   > - **Only terminology is language-aware:** `displayLanguage` exists solely as an
   >   `x-fhir-query`/`$expand` parameter, localizing **answer-option displays** from the tx server,
   >   not labels or UI.
   >
   > Practical options for CH-EKM: **(a)** one assembled questionnaire per language (parallel `text`
   > values, serve the right one) — most reliable today; **(b)** contribute i18n upstream (teach
   > `getItemTextToDisplay` the `translation` extension + add a display-language setting, and i18n the
   > UI strings); **(c)** localize only coded answers now via the tx `displayLanguage`. The
   > `translation`-extension route is **not** an option until the renderer supports it.
3. **Questionnaire `Usage`**: `#definition` (canonical artifacts) vs. `#example` — likely
   `#definition` for the reusable children so they publish as artifacts.
4. **Canton & nationality** rendering: `Kanton` as free string or eCH-0007 choice;
   `nationality`/`country` likely autocomplete (large `bfs-country-codes`).
5. **TODO (deferred) — inline a `subQuestionnaire` group directly in the modular root.** We would
   like to drop the separate aggregator `ChEkmQuestionnaireGonorrhoeaPerson` and instead put its
   `person` group (with the three person `subQuestionnaire` placeholders inside it) **directly** in
   `ChEkmQuestionnaireGonorrhoea`. **This does not work today**, even with our recursion patch
   (§1/§2) — verified empirically: the `person` group is dropped and its placeholders never resolve.
   Two *further* `@aehrc/sdc-assemble` limitations remain (the patch only fixed recursion into a
   modular **child** — a separate sub-questionnaire):
   - `getCanonicalUrls` scans only `item[0].item` and does **not descend** into a nested group, so
     placeholders inside a `person` group are never discovered; and
   - `propagateProperties` replaces `item[0].item` **by position** assuming every entry is a
     placeholder, so a real (non-placeholder) group interleaved among placeholders is clobbered.

   Fixing this needs recursive placeholder **discovery** + **match-based** (not positional)
   replacement — a bigger, riskier divergence from upstream. **For now we accept the limitation**
   and keep the aggregator pattern (root → `ChEkmQuestionnaireGonorrhoeaPerson` → three leaves),
   which already yields the single `person` group we want. Revisit if/when upstream supports
   arbitrary-depth `subQuestionnaire` placement (would extend PR
   [#1998](https://github.com/aehrc/smart-forms/pull/1998)).

---

## 7. Terminology expansion (preview vs. production)

A `choice` item sources its options either from inline `answerOption`s or, more commonly
here, from an `answerValueSet` canonical. At render time the Smart Forms renderer resolves
each `answerValueSet` by calling **`ValueSet/$expand`** on its configured **terminology
server** (default: the CSIRO/ontoserver tx). This has two consequences for CH EKM.

### The problem
- The renderer's default tx can expand **standard** HL7/SNOMED value sets (e.g.
  `administrative-gender`) but **not** the CH-specific ones — `bfs-country-codes`
  (ch-term), `ChEkmGenderIdentity`, `ChEkmExposureRelationshipType`,
  `ChEkmGonorrhoeaManifestationFormChoice` (ch-ekm). For those it shows
  *"There was an error fetching options from the terminology server"* and the control is
  empty.
- A public Swiss tx, **`tx.fhir.ch`**, *can* expand the ch-term + SNOMED-CH content, but it
  does not know our **ch-ekm** canonicals, so the renderer still can't resolve the
  ekm-defined sets by URL. But we can run it on localhost and provide the package direct, see ../tx2.fhir..ch

### Two questionnaire variants
The build therefore produces two artifacts (see `tests/`):

| Artifact | Value sets | Use |
| --- | --- | --- |
| `…-assembled.json` | `answerValueSet` references (unchanged) | **Production** / spec-conformant. Render against a tx that hosts the CH value sets (ch-term + SNOMED CH + the ch-ekm package). |
| `…-preview.json` | every `answerValueSet` **pre-expanded** into inline `answerOption`s | **Render-only** local preview in Smart Forms — fully self-contained, needs **no** live tx. |

### How the preview is built (`tests/build-lang-questionnaire.py`)
Walks the assembled questionnaire and, for each item with an `answerValueSet`, expands it
against **`tx.fhir.ch`** and replaces it with the resulting `answerOption`s. Every value set is
expanded via **`POST ValueSet/$expand`** with **`displayLanguage`** (default `de-CH`; override
with `PREVIEW_LANG=fr-CH`) and **all** local `CodeSystem-*.json` supplied as **`tx-resource`**
parameters (so internal codes *and* `content=supplement` language supplements are available):
- **ch-ekm value sets** — the local `ValueSet` (from `fsh-generated/resources` **or**
  `input/resources`, e.g. predefined `ValueSet-ChEkmCountryCodes.json`) is passed inline as the
  `valueSet` parameter; **everything else** passes the canonical as the `url` parameter.
- **Localized labels (two-pass)** — a base pass (no `displayLanguage`) gives the default displays
  and the code systems present; a localized pass re-expands with `displayLanguage` **and**
  `useSupplement` for any local supplement whose base system is present (tx does **not** auto-apply
  supplements — see *Expansion with language supplements* below). Displays merge: localized → base
  → code. This bakes German labels in for admin-gender (via the supplement),
  relationship/exposure (inline CS designations) and countries (`bfs-country-codes` designations);
  SNOMED codes without a de-CH designation on tx (genderIdentity, manifestation) stay English, and
  the eCH-7 cantons (no display in the expansion) fall back to their abbreviation.
- **`autocomplete` → `drop-down` downgrade**: an item rendered with the `autocomplete`
  itemControl only works with a *live* `answerValueSet` (server type-ahead); with inline
  options it renders nothing. So the script downgrades `autocomplete` to `drop-down`
  **only for the items it inlines** (in practice `nationality`/`country`). The production
  `…-assembled.json` keeps `autocomplete`, which is the correct UX against a real tx.

### Current expansion result (Gonorrhoea)
| Item | Value set | Options |
| --- | --- | --- |
| `nationality`, `country` | `ChEkmCountryCodes` (ch-ekm) | 195 (→ drop-down in preview) |
| `administrativeGender`, `sexualContactPartner` | `administrative-gender` | 4 |
| `genderIdentity` | `ChEkmGenderIdentity` | 1 |
| `relationshipType` | `ChEkmExposureRelationshipType` | 4 |
| `manifestation` | `ChEkmGonorrhoeaManifestationFormChoice` | 2 |

> **Country dedup — `ChEkmCountryCodes`.** Raw `bfs-country-codes` expands to **391** entries
> because the ISO 3166 system carries both the alpha-2 (`CH`) and alpha-3 (`CHE`) code for each
> country under the same display ("Schweiz"), so every country appeared **twice** in the dropdown.
>  **Simplification (current):** We bind the **form** items to a new ch-ekm value set **`ChEkmCountryCodes`** that uses only alpha-2 letter codes.
>


### Implication for production
For a real deployment the renderer (or the system consuming the questionnaire) must point
at a terminology server that hosts **all** required content — ch-term, SNOMED CH (Swiss
extension, see `expansion-params.json`), and the **ch-ekm package** (so the ekm value sets
resolve by canonical). The pre-expanded preview is a convenience for visual QA only and is
**not** the artifact to publish.

### Expansion with language supplements (de/fr/it)

To localize **answer-option labels**, the translations live in terminology, not the questionnaire:
- **inline designations** on a ch-ekm code system (e.g. `ch-ekm-relationship-type`,
  `ch-ekm-exposure-component` carry de-CH/fr-CH/it-CH `designation`s), and
- **CodeSystem supplements** for *external* code systems we don't own (in
  `input/fsh/terminology/CodeSystemSupplements.fsh`):
  - `ChEkmAdministrativeGenderLanguageSupplement` (`supplements=http://hl7.org/fhir/administrative-gender`)
    — de/fr/it for HL7 administrative-gender.
  - `ChEkmSnomedLanguageSupplement` (`supplements=http://snomed.info/sct`) — de/fr/it for the
    explicitly listed `$sct#…` codes across all the value sets in `ValueSet.fsh` (29 concepts). These
    translations are **DRAFT** (best-effort, flagged in the file) and must be validated against the
    official SNOMED CT Swiss extension before production; where a SNOMED CH designation exists it wins.

`ValueSet/$expand` then returns the localized display when called with `displayLanguage=de-CH`.

The preview build applies these **automatically**: it discovers the code systems present in each
value set and activates any local `content=supplement` whose base system matches (so adding a new
supplement, or a new SNOMED-bound disease form, needs **no per-item wiring** — see *How the preview
is built*). Verified for Gonorrhoea: `manifestation` → Symptomatisch/Asymptomatisch, `genderIdentity`
→ "Identifiziert sich als Transgender", both via `ChEkmSnomedLanguageSupplement`.

**Two non-obvious tx behaviours (learned the hard way):**

1. **Supplements are NOT auto-applied — you must pass `useSupplement` (or supply the supplement
   inline as `tx-resource`).** `…/$expand?url=…administrative-gender&displayLanguage=de-CH` alone
   returns English; adding `&useSupplement=<supplement-canonical>` returns "männlich/weiblich/…".
   (Inline designations on a CS *are* applied automatically by `displayLanguage`; separate
   `content=supplement` resources are not.)

2. **A version-pinned `supplements` element breaks `useSupplement` by reference on FHIRsmith.**
   Symptom: `useSupplement=…ch-ekm-administrative-gender-language-supplement` →
   `[not-found] Required supplement not found`, even though the supplement is loaded and queryable
   (`GET /CodeSystem?url=…` finds it, `$lookup` on its own codes works) — while the equivalent call
   for `ch-allergyintolerance`'s supplement works. The only material difference: the working
   supplement's `supplements` is **un-versioned** (`…/allergy-intolerance-category`), ours was
   **pinned** (`…/administrative-gender|4.0.1`). Now it is pinned-none.
   

   > Inline `tx-resource` (POST) is unaffected by the pin — the supplement applies correctly when
   > supplied in the request body regardless. That is what the preview build relies on, so it works
   > against tx.fhir.ch even though the published package's `supplements` is pinned.

---

## 8. Template-based `$extract` — QuestionnaireResponse → CH EKM document Bundle

The filled `QuestionnaireResponse` is turned back into a `ChEkmDocumentGonorrhoea` Bundle with
**SDC template-based extraction** (http://hl7.org/fhir/uv/sdc/extraction.html#template-based-extraction).
No mapping language: the mapping is expressed as a **template resource** carrying FHIRPath
expressions, evaluated by the `@aehrc/sdc-template-extract` library (the same engine Smart Forms
runs in-app — there is no hosted `$extract` endpoint; cf. §1).

### One Bundle template (not four resource templates)
We use a **single Bundle template** shaped exactly like the target document Bundle, rather than
one template per resource. For Gonorrhoea's fixed cardinality (one Patient, one Condition, one
Exposure) this is the cleaner choice:
- **cross-references just work** — the Composition → Patient/Condition/Observation references and
  the entry `fullUrl`s are authored statically inside the one template, so nothing has to be
  re-wired after extraction (the reference engine does *not* rewrite inter-template `#id`
  references to generated fullUrls);
- **the document shape is authored, not reconstructed** — `type=document`, `meta.profile`,
  identifier, sections and the static Broker resources sit in the template verbatim.

The engine always wraps output in an outer **`transaction`** Bundle, so the document we want is
`entry[0].resource` — `tests/extract/extract.cjs` unwraps it.

> A single Bundle template is a poor fit only when a section can **repeat with variable
> cardinality** (→ N entries): the per-instance loop applies to the whole template, not to one
> `entry`. If that ever arises (e.g. multiple manifestations), split that one resource back out
> into its own child template; the rest can stay in the Bundle.

### How the mapping is expressed (FSH)
Authored in **`input/fsh/examples/Gonorrhoea/ChEkmDocumentGonorrhoeaTemplate.fsh`** (FSH, not
hand-written JSON), as `#inline` instances assembled into the Bundle template:
- **primitive value** → `sdc-questionnaire-templateExtractValue` on the element (FSH `x.extension`
  ⇒ the `_x` sibling), e.g. `birthDate` ⇐ `%resource.descendants().where(linkId='dateOfBirth').answer.value`.
  `%resource` is the QuestionnaireResponse; `.descendants()` finds the answer regardless of group nesting.
- **Coding / CodeableConcept** → `templateExtractContext` on the CodeableConcept (sets the
  `answer.value` scope) + `templateExtractValue` `ofType(Coding)` on `coding[0]`
  (e.g. `evidence.code` ⇐ the `manifestation` answer; the exposure component values).
- **array primitive** (e.g. `name.given`) → put a `templateExtractContext` on the parent element
  so values map into `given[*]` (a standalone value path mis-targets the `_given` sibling).
- **conditionals** → an empty FHIRPath result omits the field. `Condition.onsetDateTime` uses
  `iif(... manifestationBeginUnknown = true, {}, manifestationBeginDate)` so onset is **omitted**
  when "unbekannt" is ticked. (Per the SDC spec note, conditionals/loops are *just* empty/multi
  FHIRPath results — verified implemented in the reference engine.)
- **static system metadata** (Broker `PractitionerRole`/`Practitioner`/`Organization`) is reused
  verbatim from the existing examples — it is supplied by the transmitting system, not the form.

### Treating physician — `recorder` → PractitionerRole → Practitioner + Organization
The `treatingPhysician` section (§3) extracts into three resources the template fully owns:
`GonExtractTreatingPractitionerRole` (static refs to the other two), `GonExtractTreatingPractitioner`
(`ChEkmPractitionerTreatingPhysician`), `GonExtractTreatingOrganization`
(`ChEkmOrganizationTreatingPhysician`). `Condition.recorder` is a **static** reference to the role,
so the consumer navigation `Condition.recorder.practitioner / .organization` resolves. Idioms used:
- **array primitives** (`name.given`, `address.line`) → `templateExtractContext` on the **parent**
  (`name[0]` / `address[0]`) scoped to the group (e.g. `…where(linkId='treatingPhysicianPractitioner')`)
  + relative `item.where(linkId=…).answer.value` paths (a standalone value path mis-targets the `_x`
  sibling). Single-valued siblings (`postalCode`, `city`, `family`) take `.first()`.
- **optional fields** (`identifier[GLN]`/`[BER]`, `telecom[email]`) → **whole-element** context-gated
  on the answer (same as the Patient AHVN13 identifier): omitted when blank, and the static `system`
  survives when answered.
- **department** (`ch-ekm-ext-department`, a **simple `valueString` extension**) → gated by a context
  **sub-extension on the extension itself**; empty ⇒ the whole extension is omitted, answered ⇒
  `{url, valueString}`. This is safe (unlike the §8 complex-extension caveat) precisely because the
  payload is a *value*, not a sibling sub-extension, so the sibling-strip bug does not apply.

Verified (all fields answered): the extracted Practitioner/Organization carry the right
identifiers, name (`given`/`family`), `work` address, phone+email, and a clean department extension;
0 extraction warnings.

### The link lives on the questionnaire (required for the renderer)
For a renderer to offer `$extract`, the **questionnaire it loads** must carry the template. So
the modular root **`ChEkmQuestionnaireGonorrhoea`** (FSH source of truth) declares:
- `meta.profile = .../sdc-questionnaire-extr-template` (Extractable Questionnaire – Template),
- the Bundle template as `contained[0]`,
- `sdc-questionnaire-templateExtract` → `#ChEkmDocumentGonorrhoeaTemplate` on the `gonorrhoea-form` group.

`$assemble` does not propagate these (and can choke on them), so
**`tests/assemble-gonorrhoea.sh`** strips them from the assembler input and **re-attaches** all
three onto the assembled artifact — the one the renderer actually loads. (It re-adds the
`extr-template` profile claim only when a template was actually present, so the template-less
standalone Person assembly stays valid.)

### Running it
```
sushi .                          # compiles the template + the test QuestionnaireResponse
tests/assemble-gonorrhoea.sh     # re-attaches the template onto the assembled questionnaire
tests/extract-gonorrhoea.sh      # runs $extract -> fsh-generated/Bundle-ChEkmDocumentGonorrhoea-extracted.json
```
`tests/extract-gonorrhoea.sh` defaults to the **assembled** questionnaire (demo parity with the
renderer) and uses **`input/fsh/examples/Gonorrhoea/ChEkmQuestionnaireResponseGonorrhoea.fsh`** —
a QuestionnaireResponse reconstructed from `ChEkmBundleGonorrhoea` — as test input. The CLI
(`tests/extract/`, a tiny CommonJS wrapper on `@aehrc/sdc-template-extract`; CJS because the
library's ESM build trips Node's loader on a `fhirpath` directory import) uses the questionnaire
**as-is**, exactly like Smart Forms.

### Result and known deviations
Produces a `type=document` Bundle (Composition, Patient, Condition, Observation, Broker ×3, and the
treating-physician PractitionerRole + Practitioner + Organization — 10 entries), 0 extraction
warnings, all template extensions stripped. One intentional difference from the
hand-written `ChEkmBundleGonorrhoea`: `evidence.code` = `$sct#264931009` ("Symptomatic", the form
code per the §3 decision) rather than the disease code `15628003`. The `onsetDateTime` /
data-absent handling (next) matches the example bundle.

### Conditional `data-absent-reason` on `onsetDateTime` (manifestationBeginUnknown)
The "unbekannt" toggle maps to the example bundle's representation:
- **known** → `onsetDateTime` = the answered date;
- **unbekannt** → no value, `onsetDateTime.extension[data-absent-reason] = asked-unknown`.

This is done with a **context-gated extension**: a `templateExtractContext`
(`…manifestationBeginUnknown… answer.value.where($this = true)`) that is non-empty only when the
box is ticked, so the whole data-absent extension is emitted only then (empty context → element
excluded); the `valueCode` is set by a `templateExtractValue` inside that context scope.

> **Two non-obvious engine gotchas (worth knowing for any primitive + data-absent mapping):**
> 1. **Order matters.** The data-absent (context-gated) extension MUST come **before** the plain
>    `onsetDateTime` value `templateExtractValue` in the `_onsetDateTime.extension` array. With the
>    reverse order the engine's array index-bookkeeping fails to delete the gated extension in the
>    "known" case and splits the `valueCode` into a stray entry. (Gated-first works for both cases.)
> 2. FHIRPath *can* navigate the `_onsetDateTime` primitive-extension element (fhirpath.js maps it),
>    so context gating under a primitive does work — it was only the ordering above that tripped it.

### Context-gating to omit an element entirely — works for plain complex types, NOT for complex extensions
To drop a whole element when an answer is blank, put a `templateExtractContext` (scoped to the
answer) **on the element itself**: empty context → the element is excluded. This works cleanly for a
plain complex type whose other fields are **normal elements**, e.g. `Patient.identifier[AHVN13]`:

```
* identifier[0].extension[0].url = templateExtractContext   // = …where(linkId='ahvn13').answer.value
* identifier[0].system = "urn:oid:2.16.756.5.32"            // static, survives the strip
* identifier[0].value.extension[0] = templateExtractValue ($this)   // value on the _value sibling
```

When `ahvn13` is blank the entire identifier (incl. the static `system`) is omitted.

**It does NOT work for a complex extension** (e.g. `patient-citizenship`) whose payload is a required
**sub-extension** (`code`). There the gating context must be a *sibling* of `code` in the same
`extension` array, and the engine's array index-bookkeeping (gotcha 1 above) **corrupts the sibling
when it strips the context** — the answered output loses `code`'s `url` (`{valueCodeableConcept:…}`
with no `"url":"code"`), regardless of sibling order. So complex extensions keep the **value-level**
gate (context on the inner `valueCodeableConcept`): correct when answered, but the parent is **not**
pruned when unanswered — it emits an empty `{url: patient-citizenship, extension:[{url: code}]}`
shell. Acceptable because the form normally answers nationality; revisit if the engine fixes the
sibling-strip bug. (`genderIdentity` has the identical shape and the same caveat.)

### Emitting a FIXED Coding / CodeableConcept — use the FHIRPath Type Factory (`%factory`)
When a template field must carry a **constant** coded value not present in any answer (e.g. the
Gonorrhoea exposition `component[transmissionRoute]` = `$sct#261665006 "Unknown (qualifier value)"`,
emitted only when the boolean `unknown` is ticked), you cannot assemble it field-by-field:

- **fhirpath.js has no object/complex literals** — `{system:…, code:…}`, `Coding{…}`, `select({…})`
  all fail to parse; a value expression can only return a **primitive** (or pass through an existing
  node, e.g. `ofType(Coding)` on a coded answer).
- **Field-by-field fails two ways** (confirmed in `sdc-template-extract`): *multiple* value-paths
  under one Coding get **deepmerge-concatenated** (→ `coding: [{system},{code},{display}]`, and the
  static `component.code` duplicated); a *single* value-path under `valueCodeableConcept`
  **shallow-overwrites** the whole element (`{...static, ...value}`), dropping the static
  `system`/`display`.

The clean solution is the **FHIR Type Factory API** (`%factory`,
https://hl7.org/fhir/fhirpath.html#factory), implemented in **fhirpath.js ≥ 4.11** and available
because the extract engine evaluates with the r4 model loaded:

```
%factory.Coding(system, code, display [, version])
%factory.CodeableConcept(codingCollection [, text])
```

Use **one** `templateExtractValue` on `coding[0]` whose expression is `%factory.Coding(...)`. It
returns a *complete* Coding in a single result, so the engine places it whole (no concat, no
overwrite of siblings) — exactly like the `ofType(Coding)` idiom but for a constant. The element is
still gated by a `templateExtractContext` on the component (`…unknown… = true`); the value-path both
materialises the deleted element and supplies the full Coding, while the static `component.code`
survives (different key from the shallow-merged `valueCodeableConcept`). Verified: ticking `unknown`
yields `component[transmissionRoute].valueCodeableConcept.coding[0] = {system, code, display}`,
unticked omits the component.

### Conditional gating with `iif` — negation and the Boolean-criterion trap
Two recurring patterns when gating a templated element (empty context → element omitted):

- **Negating a boolean answer must cover the absent case.** A naïve
  `…answer.value.where($this != true)` only matches an explicit `false` and stays **empty** when the
  answer is unanswered — so the element wrongly stays omitted for "not selected". And you cannot wrap
  in `.not()`, because a boolean result (`true`/`false`) is *always* non-empty, so the context never
  gates. Use `iif` returning empty only for the true case:
  `iif(%resource.descendants().where(linkId='unknown').answer.value = true, {}, true)` — emits for
  `false` **and** absent (criterion empty → `iif` falls to the otherwise branch), omits only for
  `true`. (The returned `true` is just a non-empty sentinel to materialise the element; a constant
  `%factory.Coding(...)` value-path ignores the context scope.) Chain `iif`s for fallbacks, e.g.
  *emit sexualContactPartner only when not-unknown and no otherTransmission*:
  `iif(…unknown…value = true, {}, iif(…otherTransmission…value.exists(), {}, …sexualContactPartner…value))`.

- **An `iif` criterion must be a Boolean — a bare path is NOT "truthy".** `iif(…otherTransmission…answer.value, {}, X)`
  with a *string* answer does **not** treat the present string as true; FHIRPath only honours a Boolean
  criterion, so a non-boolean falls through to the **else** branch (the component fires even when the
  value is present). Wrap presence checks in `.exists()` (or `.empty()`, `= true`, …). The asymmetry to
  remember: a bare path is fine as an `iif` **value** branch (empty path → field omitted), but as a
  **criterion** it must be Boolean.

> ⚠️ The template artifacts (`ChEkmDocumentGonorrhoeaTemplate` and the modular root's contained
> copy) will surface **IG Publisher validation warnings** — expected, since the template's
> resources intentionally lack values and carry `templateExtract` extensions.

---

## 9. Uploading the questionnaire to the hosted Forms Server

**`tests/upload-gonorrhoea.sh`** PUTs the assembled questionnaire to the Smart Forms HAPI
Forms Server so it shows up in the hosted renderer's picker, without launching:

```
sushi .
tests/assemble-gonorrhoea.sh
tests/upload-gonorrhoea.sh           # PUT Questionnaire/<id> -> /api/fhir
```

- Target base defaults to **`https://smartforms.csiro.au/api/fhir`** — the *FHIR server*,
  not the `/fhir` web app (see §1). Both the base and the questionnaire file are overridable.
- Uses **PUT by id** (upsert) so re-runs update the existing resource instead of creating
  duplicates; **`Content-Type: application/json`** as with the other Smart Forms scripts.
- After upload it prints the canonical and a ready-to-open renderer link
  (`https://smartforms.csiro.au/?questionnaireUrl=<canonical>`).

### Open issue — `$extract` is **not** possible on the hosted server (HAPI rejects the template)
The server-side copy has the **contained extraction template stripped before upload**, because
HAPI's strict parser **rejects** the assembled questionnaire as-is:

```
HTTP 400  HAPI-1811: Extension (URL='…/data-absent-reason') must not have both a value
          and other contained extensions
```

The offending node is the conditional `data-absent-reason` on `Condition._onsetDateTime` in the
contained Bundle template (§8): it carries both sub-extensions (`templateExtractContext`) **and**
a value (`_valueCode`), which the SDC template-extract pattern does deliberately but HAPI reads as
violating the R4 "value xor sub-extensions" rule. The renderer does not need the template to
render/populate — only `$extract` does — so the script `del(.contained)` (and drops the
`sdc-questionnaire-extr-template` `meta.profile` claim) and uploads the rest, which HAPI accepts
(HTTP 201).

**Consequence:** the questionnaire loaded from the hosted server **cannot offer template-based
`$extract`** (its template is gone). Use the full local artifact
(`input/resources/Questionnaire-ChEkmQuestionnaireGonorrhoeaAssembled.json`, template intact) with
`tests/extract-gonorrhoea.sh` for extraction. To make hosted `$extract` work, the
`data-absent-reason` extension in `ChEkmDocumentGonorrhoeaTemplate.fsh` would need restructuring so
HAPI accepts it (unresolved — the current shape is what the §8 reference engine needs).

---

## 10. Pre-population (`$populate`) — engine choice, launch contexts, FHIRPath gotchas

Pre-population is wired with `sdc-questionnaire-initialExpression` (text/fhirpath) on the items,
reading from launch-context variables (`%patient`, `%user`) declared via the modular root's
`launchContext` extensions and propagated onto the assembled questionnaire.

### Engine: the SDC reference library (in-process), NOT hosted HAPI
`tests/populate-gonorrhoea.sh` runs the **SDC reference `$populate`** (`@aehrc/sdc-populate`, the
same engine Smart Forms runs in-app) through a small local CommonJS wrapper
**`tests/populate/populate.cjs`** (mirrors `tests/extract/`; CJS for the same `fhirpath` directory-import
reason — §8). We **switched off the hosted HAPI `Questionnaire/$populate`** (smartforms.csiro.au,
HAPI 8.10.0 per §1) because:

- **HAPI does not resolve item/group-level `variable` extensions.** The Person section's
  `zipCode`/`city`/`country`/`canton` read a `person`-group `variable` (`%homeOrFirstAddress` =
  `%patient.address.where(use='home').combine(%patient.address).first()`); on HAPI these came back
  **empty even though the Patient has an address** (no error). The reference engine resolves them.
  Two ways to cope: keep the group `variable` (works on the reference engine, what the renderer
  uses) **or** inline the full path per item (portable across both engines). The treating-physician
  Practitioner/Organization fields inline the path (`%user.practitioner.resolve().…`,
  `%user.organization.resolve().…`) for the same reason; the Person section keeps its group
  `variable`.
- It matches what the **Smart Forms renderer** actually does.

> The HAPI-specific gotchas below are kept because a *deployed* host may still use HAPI; the
> initialExpressions are written to work on both engines.

### `%user` is a PractitionerRole, delivered via `fhirContext` — Organization is derived via `resolve()`
The modular root declares **two** launch contexts (propagated onto the assembled questionnaire):

| `launchContext` name | type | variable | how the test feeds it | SMART launch delivery |
| --- | --- | --- | --- | --- |
| `patient` | Patient | `%patient` | `patient` param | top-level launch context |
| `user` | **PractitionerRole** | `%user` (treating physician's role) | **`fhirContext`** entry (see below — NOT the `user` param) | token-response `fhirContext` (or `fhirUser` resolved to one) |

**First attempt vs. current design.** The first version declared a *third*, custom launch context
(`organization`, via a new CodeSystem `ChEkmLaunchContext`) delivered through SMART App Launch's
**`fhirContext`** (token-response mechanism,
https://build.fhir.org/ig/HL7/smart-app-launch/scopes-and-launch-context.html#fhircontext-exp) —
spec-justified since SDC's launchContext value set (`patient|encounter|location|user|study`) has no
Organization code and is extensible, but it meant wiring (and keeping in sync) two separate resources
for "the physician" and "their organization", plus a bespoke CodeSystem.

The current design instead types `%user` as a **PractitionerRole** — which is also what a real SMART
launch commonly hands back as `fhirUser`/`user` for clinical users — and lets the Practitioner and
Organization fields **resolve** `PractitionerRole.practitioner` / `PractitionerRole.organization`
themselves (`%user.practitioner.resolve()…`, `%user.organization.resolve()…`, see §3). One launch
context instead of two; the Organization can never drift from the physician's actual affiliation; no
custom CodeSystem.

**Gotcha: the PractitionerRole must still go through `fhirContext`, not the engine's `user`
parameter.** `@aehrc/sdc-populate`'s `createLaunchContextParam()` only binds its dedicated `user`
input to `%user` when the launchContext's declared type is **literally `Practitioner`** (hardcoded
check; confirmed in `inAppPopulation/utils/inputParameters.ts`, and the demo app's own copy is even
marked `// FIXME need to eventually extend this to other resources`). For any other declared type —
our `PractitionerRole` — that path is skipped, and `%user` is instead populated from a **`fhirContext`
entry**, looked up by `resourceType` (`resolvedFhirContextReferences[resourceType]`) but bound to the
FHIRPath variable under the launchContext's **`name`** (`user`). This is exactly the pattern documented
in the real renderer's `packages/smart-forms-renderer/src/stores/smartConfigStore.ts` (comment:
*"resolvedFhirContextReferences, keyed by resource type e.g. `{ "PractitionerRole": <PractitionerRole> }`"*)
— so it is not a workaround specific to our test harness. `tests/populate/populate.cjs` therefore
passes `fhirContext: [{ role: 'launch', type: 'PractitionerRole', reference: 'PractitionerRole/<id>' }]`
and nothing on `user`; `fetchResourceCallback` resolves that reference (fetched from the local HAPI
instance), and `%user` ends up bound to the PractitionerRole exactly as the renderer would deliver it.

**The trade-off: `resolve()` needs a real, reachable FHIR server — it bypasses `fetchResourceCallback`
entirely.** Confirmed by reading the reference engine source: FHIRPath's `resolve()` is implemented
natively in `fhirpath.js` (`additional.js engine.resolveFn` → `requestResourceByUrl`), which does a
plain HTTP `fetch` against `<fhirServerUrl>/<type>/<id>` using `ctx.processedVars.fhirServerUrl`. That
value comes from `fetchResourceRequestConfig.sourceServerUrl`, which `@aehrc/sdc-populate` threads
into **every** FHIRPath evaluation (questionnaire-level `variable`s, `initialExpression`s,
`itemPopulationContext` — see `createFhirPathContext.ts` / `evaluateExpressions.ts`). It does **not**
go through the library's own `fetchResourceCallback` hook (that hook only resolves `fhirContext`
entries and reference/batch-context launch parameters — the old Organization-via-`fhirContext`
mechanism). Consequences:
- **In production** (Smart Forms, real SMART launch): `sourceServerUrl` is set to the launch `iss`
  (see `apps/demo-renderer-app/src/components/PrePopButton.tsx`), a FHIR server the app already has
  token-scoped read access to — so `resolve()` just works, no extra wiring.
- **In our offline CLI test**: there is no FHIR server unless we run one. `tests/populate.cjs` now
  takes a `fhirServerUrl` (default `http://localhost:8080/fhir`) and passes it as
  `fetchResourceRequestConfig.sourceServerUrl`; `tests/populate-gonorrhoea.sh` requires the **local
  HAPI instance** to be running first:
  ```
  ./start_hapi.sh      # HAPI FHIR at http://localhost:8080/fhir
  ./load_examples.sh   # PUTs Practitioner/Organization/PractitionerRole/Patient examples into it
  ```
  `load_examples.sh` loads the resources in dependency order (Practitioner, Organization, then the
  `ChEkmPractitionerRoleTreatingPhysicianExample` that references both) so `resolve()` can find them
  by relative reference.

### FHIRPath gotchas (HAPI-specific, but the expressions satisfy both engines)
Two non-obvious rules emerged getting `nationality` and `genderIdentity` (both read from Patient
**extensions**) to populate against HAPI:

- **Use `extension.where(url = 'xyz')`, NOT the `extension('xyz')` shortcut.** HAPI's FHIRPath
  engine does **not** implement the `extension(url)` shortcut function. With `%patient.extension('…
  patient-citizenship')…` the answer comes back **empty** (no error); rewriting to
  `%patient.extension.where(url = '…patient-citizenship')…` populates it. (Both forms are
  equivalent and both work in fhirpath.js with the R4 model — this is HAPI-specific.) The
  `nationality` / `genderIdentity` initialExpressions in `ChEkmQuestionnaireGonorrhoeaPerson.fsh`
  use the `.where(url=)` form for this reason; the organization `department` extension is read the
  same way.
- **Use the explicit typed accessor `.valueCodeableConcept`, not polymorphic `.value`.** The
  polymorphic `value` accessor only resolves when the FHIR model is loaded; `.valueCodeableConcept`
  works with or without it, so it is the safer choice in an initialExpression.

Putting both together, the working pattern for "read a CodeableConcept out of a (possibly nested)
extension" is:

```
%patient.extension.where(url = '<outer-extension-url>').extension.where(url = '<sub-name>').valueCodeableConcept.coding.first()
```

---

## 11. Item validation — `regex` vs. `targetConstraint` (Smart Forms reads targetConstraint at the ROOT only)

Two ways to validate an answer in these forms; the choice is forced by what the renderer reads.

**`regex` extension (`http://hl7.org/fhir/StructureDefinition/regex`) — genuinely item-scoped.**
Smart Forms reads it directly off the item (`getRegexString` in
`packages/smart-forms-renderer/src/utils/extensions.ts`, applied in `validate.ts`) and surfaces
inline validation. It even unwraps a `matches('…')` wrapper, but a bare pattern works too. Use it
for pure **format/length** checks. Example — `ahvn13` (OASI / AHVN13) in
`ChEkmQuestionnaireGonorrhoeaPerson.fsh` carries `regex = "^756[0-9]{10}$"` (+ `maxLength = 13`),
mirroring the ch-core `ahvn13-length` invariant. A regex **cannot** express the AHV digit-check
(`ahvn13-digit-check`) — that, and the length invariant, are still enforced by the IG Publisher on
the extracted Patient; the form regex is only a UX guard.

**`targetConstraint` (`…/sdc-questionnaire-targetConstraint`) — must live on the modular ROOT.**
Per the SDC extension definition its `Context` is `Questionnaire` **and** `Questionnaire.item`, so an
item-level targetConstraint is spec-valid. **But Smart Forms ignores it on items** —
`extractTargetConstraints()`
(`packages/smart-forms-renderer/src/utils/questionnaireStoreUtils/extractTargetConstraint.ts`) only
iterates `questionnaire.extension` and **never recurses into `questionnaire.item[*].extension`**. An
item-level targetConstraint is silently dropped (no error, no validation). So a targetConstraint must
sit on the **root** and bind to its item via the `location` FHIRPath (e.g.
`Questionnaire.descendants().where(linkId='dateOfBirth')`), which `readTargetConstraintLocationLinkIds`
resolves back to a linkId for *where* the error renders — the constraint still *lives* at the root.
This is exactly how the `dateOfBirthRange` constraint in `ChEkmQuestionnaireGonorrhoea.fsh` is
authored. (`$assemble` keeps the modular root's extensions, drops a child's root extensions — §10 —
which is another reason root-level placement is the working pattern.)

**Rule of thumb:** item-local format/length → **`regex`** on the item; cross-field or
expression/range validation, or anything needing a German `human` message → **`targetConstraint` on
the root** with a `location`.
