# AGENTS.md — CH EKM Implementation Guide

Orientation guide for AI agents and developers working on this repository.

## What this project is

**CH EKM (Elektronische klinische Meldung)** is a FHIR R4 Implementation Guide of the
Swiss Federal Office of Public Health (FOPH / BAG), Communicable Diseases Division. It
enables clinicians (or brokers acting on their behalf) to send **clinical findings on
notifiable communicable infectious diseases** to the FOPH electronically.

A report is a **FHIR Document** (a `Bundle` of type `document`) built around a
`Composition`. The IG is organism-specific: a generic CH EKM base layer is specialised
per disease (Gonorrhoea, Hepatitis C, Invasive Streptococcus Pneumoniae, …).

- Package id: `ch.fhir.ig.ch-ekm` · canonical `http://fhir.ch/ig/ch-ekm`
- FHIR version: **4.0.1** · status `draft` · version `0.0.1`
- Dependencies: `ch.fhir.ig.ch-core 6.0.0`, `ch.fhir.ig.ch-term 3.3.x`
- CI build: https://build.fhir.org/ig/ahdis/ch-ekm/branches/master/index.html

This IG uses **two parallel representations** of the report content:

1. **Logical models** (`input/fsh/logical/`) — one element per *form item*, mirroring the
   paper reporting forms (e.g. the Gonorrhoea form). They carry `Mapping` blocks that map
   each form item to the target FHIR profile. These are the **master** for the
   forms/questionnaires work (the paper form may differ slightly from the model).
2. **FHIR profiles** (`input/fsh/profiles/`) — constrain real FHIR resources (`Bundle`,
   `Composition`, `Condition`, `Observation`, `Patient`, …) for the actual wire format.

## Repository layout

| Path | Contents |
| --- | --- |
| `input/fsh/profiles/` | Resource profiles, extensions, invariants |
| `input/fsh/logical/` | Form logical models (one element per form item) + `Mapping` to profiles |
| `input/fsh/terminology/` | `CodeSystem`s and `ValueSet`s (+ a `ConceptMap`) |
| `input/fsh/examples/` | Instance examples, grouped by organism (`Gonorrhoea/`, `HepatitisC/`, `InvasiveStreptococcusPneumoniae/`, `Mpox/`) and shared Patient/Practitioner/Organization examples; the per-disease questionnaire roots and `$extract` templates live here too |
| `input/fsh/questionnnaire/` | Disease-agnostic SDC sub-questionnaires + `RuleSets.fsh`; `extract/` holds the reusable `$extract` rule sets |
| `input/fsh/ALIAS.fsh` | All FSH aliases (code systems, extensions, value sets) |
| `input/pagecontent/` | Narrative IG pages (`index`, `usecase`, `guidance`, `profiles`, `terminology`, `examples`, `changelog`, `extensions`) |
| `input/images-source/` | PlantUML sources for use-case diagrams |
| `scripts/` | Questionnaire tooling (formerly `tests/`): `$assemble` / `$populate` / `$extract` runners, the language-preview builder, `load_examples.sh` |
| `sushi-config.yaml` | SUSHI / IG configuration, menu, dependencies, pages |
| `expansion-params.json` | Terminology expansion params (SNOMED CT Swiss Extension) |
| `gonorrhoea.png` | Scan of the paper Gonorrhoea reporting form (green = sections to be turned into an SDC Questionnaire) |

## Profiles

### Document structure
- **`ChEkmDocument`** (← `CHCoreDocument`) — the report `Bundle`; entry Composition only `ChEkmComposition`.
- **`ChEkmComposition`** (← `CHCoreComposition`) — `status=final`,
  `category = sct#423876004 "Clinical report"`, `type = sct#722143004 "Infectious disease
  diagnostic study note"`. Author is a `ChEkmPractitionerRole` (treating physician *or*
  broker). Sliced `section`: `diagnosis` (1..1), `laboratory`, `medication`, `immunization`,
  `risk-factors`, `social-history`, `cause-death`. There is
  deliberately **no** `hospitalization` section — the hospitalisation is `Composition.encounter`
  → `ChEkmEncounter` and nothing else.
  - `section[diagnosis]` → `ChEkmCondition` (+ optional `QuestionnaireResponse`)
  - `section[laboratory]` → `ChEkmServiceRequest` (+ optional seroconversion Observation)
  - `section[social-history]` → `ChEkmExposure`

### Clinical content
- **`ChEkmCondition`** (← `CHCoreCondition`) — diagnosis + manifestations. `code` (the
  disease), `onsetDateTime` (manifestation begin, with `data-absent-reason` for unknown),
  `evidence` = manifestation.
- **`ChEkmEncounter`** (← `CHCoreEncounter`) — the hospitalisation (Verlauf). Referenced from
  `Composition.encounter` and from the diagnosis `Condition.encounter`. `class = IMP`,
  `period.start` = Eintrittsdatum, Hospitalisationsgrund in `reasonReference` (the diagnosis
  Condition) or `reasonCode`. "Hospitalisation unknown" is the only use of `hospitalization`:
  it then carries nothing but `extension[unknown]` = `data-absent-reason#asked-unknown`;
  "no" produces no Encounter at all.
- **`ChEkmObservationCauseOfDeath`** (← `Observation`) — the cause of death (Verlauf / Zustand).
  `code = loinc#79378-6`, `valueCodeableConcept` = the reported disease, `74964007` "Other" **or
  `261665006` "Unknown"** — all three answers are values, `dataAbsentReason` is `0..0` (issue #28,
  same treatment "unknown" gets in `Encounter.reasonCode`). `focus` → the diagnosis
  Condition when the reported disease is the cause. An Observation rather than a Condition because
  the form asks a closed question and `value[x]` is an answer while `Condition.code` would assert a
  diagnosis; HL7 US VRDR made the same move between STU1 and STU2.
  Referenced from `Composition.section[cause-death]`. The death itself is
  `ChEkmPatient.deceasedDateTime` (with a `data-absent-reason` slice for "died, date unknown"), so
  the fact of death is answerable from the Patient alone.
- **`ChEkmExposure`** (← `Observation`) — the "Exposition" / Exposure (how/where exposed). Mirrors
  HL7 Europe HDR *Infectious Contact*: `category` from `ChEkmExposureClass`,
  `code = EXPAGNT`, `extension[exposureAddress]` for the place (Wo — country as ISO code +
  `iso21090-codedString`, precise location as `city`, or a `data-absent-reason` when reported as
  unknown), `effective[x]` + `component[dateOfEntry]` for the time (Wann).
- **The "Impfstatus" section (issue #29) — one entry per answered form row, but the RESOURCE TYPE
  depends on the answer.** Only `yes` describes a vaccination; `no` and `unknown` are answers to a
  closed question, and R4 `Immunization.status` has no "unknown" (an earlier draft used
  `not-done` + a modifier extension that took the assertion back — removed). Both resource types are
  referenced from `Composition.section[immunization]` (LOINC 11369-6, the section code CH VACD also
  uses), whose `entry` is sliced by profile into `immunization` / `vaccination-status`.
  - **`ChEkmImmunization`** (← `CHCoreImmunization`) — `yes` only, so `status = completed (exactly)`.
    `occurrenceDateTime` = the last dose, `protocolApplied.doseNumberPositiveInt` = the total number
    of doses; both details are optional on the form, so either can be valueless with a
    `data-absent-reason` `#asked-unknown`. `protocolApplied.targetDisease` names the vaccination;
    `vaccineCode` (1..1) is the picked Swiss brand code, else the SNOMED CT vaccine product for that
    target disease. R4 makes `doseNumber[x]` 1..1 inside `protocolApplied`, and `occurrence[x]` 1..1
    at the root, which is why extraction needs four mutually exclusive template instances for the
    2 × 2 combinations of "which detail was answered" — see `RuleSetImmunization.fsh` and
    forms-summary.md §8.
  - **`ChEkmObservationVaccinationStatus`** (← `Observation`) — `no` and `unknown`.
    `code = sct#408864009 "Vaccination status"` (SNOMED has no pre-coordinated vaccination-status
    concept for smallpox or mpox), `value[x]` = `373067005` No or `261665006` Unknown,
    `dataAbsentReason` `0..0` — same treatment "unknown" gets in `ChEkmObservationCauseOfDeath`.
    A single mandatory `component` names the vaccination, entirely in SNOMED CT: `component.code` is
    the vaccine product of the row (the same concept `ChEkmImmunization` uses as its `vaccineCode`
    fallback) and `component.value` the target disease, so both halves of one form line answer
    "which vaccination?" identically. The two Observation template instances are fully static.

### Person / actors
- **`ChEkmPatient`** (← `CHCorePatient`) and four representation variants reflecting the
  privacy rules (see `guidance.md`):
  - `ChEkmPatientInitials` — initials only (name-initials invariant; no address line / telecom)
  - `ChEkmPatientHIV` — masked name + 2-char HIV code extension (`ch-ekm-ext-hiv-code`)
  - `ChEkmPatientVCT` — VCT identifier, masked name
  - `ChEkmPatient` (full name) — for e.g. Hepatitis C
- **`ChEkmPractitionerRole / Practitioner / Organization`** (← CH Core) — treating
  physician and broker roles.
- **`ChEkmServiceRequest` / `ChEkmSpecimen`** — laboratory information.

### Disease specialisations (pattern to follow for new organisms)
For Gonorrhoea (`profiles/ChEkmGonorrhoea.fsh`):
`ChEkmDocumentGonorrhoea` → `ChEkmCompositionGonorrhoea` → constrains
`section[diagnosis]` to `ChEkmConditionGonorrhoea` (fixes `code = sct#15628003`, evidence
bound to `ChEkmGonorrhoeaManifestation`) and `section[social-history]` to
`ChEkmExposureGonorrhoea` (adds sliced components: `transmissionRoute`,
`sexualContactPartner`, `relationshipType`, `otherTransmission`).
HepatitisC and InvasiveStreptococcusPneumoniae follow the same shape.
Mpox additionally constrains `section[immunization]` to `ChEkmImmunizationMpox` (target diseases
fixed to `ChEkmMpoxImmunizationTargetDisease`, smallpox + mpox) and
`ChEkmObservationVaccinationStatusMpox` (the same two target diseases, plus the two vaccine products
in `ChEkmMpoxVaccineProduct` as the component code). Invasive pneumococcal disease does the same for
its single row: `ChEkmImmunizationInvasivePneumococcalDisease` /
`ChEkmObservationVaccinationStatusInvasivePneumococcal`, with
`ChEkmInvasivePneumococcalDiseaseImmunizationTargetDisease` (`sct#16814004`) and
`ChEkmInvasivePneumococcalDiseaseVaccineProduct` (`sct#836398006`).

### Extensions & invariants
- Extensions (`profiles/Extensions.fsh`): `ChEkmExtHivCode`, `ChEkmExtExposureAddress`,
  `ChEkmExtDepartment`. Two template-only carrier lives here too: `SdcTemplateExtractExtension`.
- Invariants (`profiles/Invariants.fsh`): `name-initials`, `ch-ekm-hiv-check`, `ch-ekm-dateTime`.

## Logical models (form models)

Located in `input/fsh/logical/`. Each is a `Logical` with `Characteristics: #can-be-target`
and one element per form item, plus a `Mapping` to the corresponding profile.

- **`ChEkmPersonForm`** → maps to `ChEkmPatient` (Person to Patient).
- **`ChEkmManifestationForm`** → maps to `ChEkmCondition`.
- **`ChEkmExposureForm`** → maps to `ChEkmExposure` (the "Wo"/where part).
- **`ChEkmHospitalisationForm`** → maps to `ChEkmEncounter` (the Verlauf / Hospitalisation part).
- **`ChEkmDeathForm`** → maps to `ChEkmPatient.deceasedDateTime` + `ChEkmObservationCauseOfDeath`
  (the Verlauf / Zustand part).
- **`ChEkmImmunizationForm`** → maps to `ChEkmImmunization` (the `yes` answer) **and** to
  `ChEkmObservationVaccinationStatus` (`no` / `unknown`) — two `Mapping` blocks. Describes ONE row
  of the "Impfstatus" section (target disease, yes/no/unknown, doses, last dose date, product); a
  disease instantiates it once per vaccination type it asks about.
- **`ChEkmTreatingPhysicianForm`** → `Practitioner` + `Organization` form models.
- **`ChEkmLabForm`** → `ChEkmOrganizationLab` (the "Labor" block: the analysing laboratory).
  Disease-agnostic; the sibling of `ChEkmTreatingPhysicianOrganizationForm`, differing only in what
  is mandatory (here: the name alone).
- **`ChEkmLabSpecimenForm`** → `ChEkmSpecimen` (the sample: Entnahmedatum + Material), reached from
  `ChEkmServiceRequest.specimen`. Its own model because only some organisms' forms ask for it.
- **`CHEkmGonorrhoeaForm`** — the disease-level aggregate: `person`, `exposure`,
  `manifestation`, `treatingPhysician`, each refining the generic form models for
  Gonorrhoea (e.g. `surnameInitial 1..1`, `surname 0..0`; adds the Gonorrhoea
  transmission sub-structure `transmission.sexualContactPartner / relationshipType /
  otherTransmission / unknown`).
- **`CHEkmHepatitisCForm`** — Person and Exposure only; there is no disease-level aggregate and no
  `ChEkmHepatitisCManifestationForm` (see TODO.md).

These logical models are the **master** for building the SDC Questionnaires — see
[forms-summary.md](forms-summary.md).

## Terminology

`input/fsh/terminology/`:
- **CodeSystems**: `ChEkmExposureComponent` (internal discriminator codes for Exposure
  components), `ChEkmRelationshipType` (Art der Beziehung), `ChEkmReportedPathogen` (the one
  "reported pathogen" answer shared by the hospitalisation-reason and cause-of-death questions — a
  pointer to the disease this report is about, not a clinical concept).
- **ValueSets**: per-disease manifestation sets (`ChEkmGonorrhoeaManifestation`,
  `ChEkmHepatitisCManifestation`, `ChEkmInvasivePneumococcalDiseaseManifestation`,
  `ChEkmHIVManifestation`, …), `ChEkmExposureClass`, `ChEkmExposureTransmissionRoute`,
  `ChEkmExposureRelationshipType`, `ChEkmBiologicalSex`, `ChEkmGenderIdentity`,
  `ChEkmServiceRequestReason`, `ChEkmOtherNoneUnknown`,
  `ChEkmHepatitisCCourseOfDisease`, `ChEkmYesNoUnknown`, `ChEkmHospitalisationReasonChoice`,
  `ChEkmCauseOfDeathChoice`, `ChEkmMpoxImmunizationTargetDisease`,
  `ChEkmVaccinationStatusNoUnknown`, `ChEkmMpoxVaccineProduct`. The vaccine brand list and the
  target disease list are NOT redefined here — `ChEkmImmunization` reuses the CH VACD value sets that
  `CHCoreImmunization` already binds (`$SwissVaccinesVS`, `$TargetDiseasesVS`, both from ch-term).
- **ConceptMap**: `ChEkmSexToHl7Gender` (biological sex → administrative gender).

**Prefer an external canonical over a local wrapper.** `Specimen.type` and the "Material" form item
both bind DIRECTLY to `http://fhir.ch/ig/ch-elm/ValueSet/ch-elm-results-complete-spec` (alias
`$ch-elm-results-complete-spec`). A local `ChEkmSpecimenType` used to wrap it with nothing but
`include codes from valueset …`; it added no concepts, and the nested include made tx.fhir.ch refuse
`useSupplement` on it with HTTP 422, breaking the questionnaire language previews. A wrapper that
adds no concepts is not worth that.

**"Unknown" has two shapes on the wire, and the target element decides which**: if it can hold a
code, the answer is `sct#261665006` in `value[x]` / `reasonCode` / a component; if it is a `dateTime`
or a plain string (`Address.country`, `Address.city`), the element is left empty and carries
`extension[data-absent-reason] = asked-unknown`. The full rule, the inventory of every "unknown"
in the IG and the one case that still deviates (Hospitalisation yes/no/unknown) are in
forms-summary.md §12.

Note (per `README.md`): the production terminology (ValueSets/CodeSystems) is maintained
by the FOPH on the **ABN environment** and pulled via the ABN API into `input/resources/`.
Terminology expansion uses the SNOMED CT Swiss Extension via `expansion-params.json`.

## Conventions

- **Naming**: profiles/instances are PascalCase `ChEkm…`; ids are kebab-case
  `ch-ekm-…`. (Minor inconsistency in the repo: some files use `CHEkm…` — match the
  surrounding file when editing.)
- **Aliases**: always reuse the aliases in `ALIAS.fsh` (`$sct`, `$loinc`, `$v3-ActClass`,
  `$data-absent-reason`, `$bfs-country-codes`, CH Core canonicals, …). Add new external
  references there rather than inline URLs.
- **Examples**: live under `input/fsh/examples/<Organism>/`; `setMetaProfile: never` is set
  in `sushi-config.yaml`, so examples do **not** auto-stamp `meta.profile`.
- **Unknown / absent data**: modelled with `data-absent-reason` (e.g. unknown
  manifestation begin date, masked names).
- New organism → add: a manifestation `ValueSet`, disease `Document/Composition/Condition
  (/Exposure)` profiles, a `…Form` logical model + mappings, and an example `Bundle`.

## Build & validation

SUSHI compiles `input/fsh/**` → `fsh-generated/resources/`; the HL7 **IG Publisher**
renders the IG into `output/`.

```bash
sushi .                 # compile FSH → fsh-generated/ (syntax + basic checks)
./_genonce.sh           # or _updatePublisher.sh / _genonce.bat — full IG Publisher build

# If the _genonce.sh helper / input-cache/publisher.jar are not set up in the checkout, run the
# jar shipped with the VS Code FHIR Tools extension directly (same build, no download needed):
java -jar "/Users/oegger/.vscode/extensions/yannick-lagger.vscode-fhir-tools-1.5.1/publisher.jar" -ig ig.ini
```

**Validate examples/profiles with the IG Publisher** (the project's preferred validator —
not the matchbox MCP). The Publisher validates all examples against their profiles during
the build; warnings to ignore are listed in `input/ignoreWarnings.txt`. Results land in
`output/qa.html` (and `output/qa.txt`) — check the error count there after a build.

## Use cases

Two reporting scenarios (`input/pagecontent/usecase.md`, diagrams in
`input/images-source/`):
1. **Treating physician** sends directly — `Composition.author` = treating physician.
2. **Broker** sends on behalf of the physician — `Composition.author` = broker,
   `Condition.recorder` = treating physician.

## Forms / SDC Questionnaires

A separate effort builds **SDC Questionnaires** from the logical models, to be rendered in
the **Smart Forms** viewer (`../smart-forms`), using a **modular questionnaire** approach
(reusable sub-questionnaires assembled per disease via `$assemble`). See
[forms-summary.md](forms-summary.md) for the full analysis and build plan.

All questionnaire tooling lives in `scripts/` (renamed from `tests/`) and runs the **SDC
reference libraries locally** — no server round-trip:

```bash
sushi .                                    # FSH -> fsh-generated/
./scripts/assemble.sh                      # sushi + $assemble for EVERY modular root
./scripts/assemble-gonorrhoea.sh           # $assemble  -> input/resources/…Assembled.json
./scripts/populate-gonorrhoea.sh           # $populate  -> pre-filled QuestionnaireResponse
./scripts/populate-mpox.sh                 # $populate, incl. the `encounter` launch context
./scripts/populate-hepatitisc.sh           # $populate, same three launch contexts as Mpox
./scripts/populate-invasivepneumococcaldisease.sh  # $populate, same three launch contexts
./scripts/extract-gonorrhoea.sh            # $extract   -> input/resources/Bundle-…-extracted.json
./scripts/extract-mpox.sh                  # $extract, incl. the conditional Encounter entry
./scripts/extract-hepatitisc.sh            # $extract, the CLOSED state of both conditional entries
./scripts/extract-invasivepneumococcaldisease.sh  # $extract, hospitalisation "nein" + death without a date
```

Four organisms have a modular root today: **Gonorrhoea**, **Mpox**, **Hepatitis C** and **invasive
pneumococcal disease**. `scripts/assemble.sh` discovers them by the
`assemble-expectation = assemble-root` extension, so adding a fifth needs no script change.

Two of them are **starters**: they assemble only the sections whose modules and target profiles
already exist, and everything the paper form asks on top of that is listed, with the blocking
decision for each, in an `OPEN QUESTIONS` block at the bottom of the root's FSH file and in TODO.md.
- **Hepatitis C** (`examples/HepatitisC/ChEkmQuestionnaireHepatitisC.fsh`) — open: Serokonversion,
  antivirale Therapie, Krankheitsverlauf, Impfstatus, Exposition "Wie", and the Labor block's
  "Anlass".
- **Invasive pneumococcal disease**
  (`examples/InvasiveStreptococcusPneumoniae/ChEkmQuestionnaireInvasivePneumococcalDisease.fsh`) —
  open: Risikofaktoren (a section no other organism has), Exposition "Wie", the Labor block's
  "Anlass", and *which* of the two pneumococcal manifestation value sets is authoritative. It is also
  the one form that does NOT ask the gender identity (its CSV has no such row). **Impfstatus is implemented**: one row
  (`Pneumokokkenimpfung`), the same one-row/total-doses model as Mpox, so an answered row extracts to
  exactly one `ChEkmImmunizationInvasivePneumococcalDisease` — note the example Bundle still carries
  the other, one-resource-per-dose shape. Apart from that section it reuses every shared module
  unchanged. NB the naming: the folder is `InvasiveStreptococcusPneumoniae/`, the profiles and
  instances in it are `…InvasivePneumococcalDisease`.

Sub-questionnaires are disease-agnostic and live in `input/fsh/questionnnaire/`; the per-disease
root (`input/fsh/examples/<Organism>/ChEkmQuestionnaire<Organism>.fsh`) assembles the ones its form
needs via the `RuleSetQr…` rule sets in `input/fsh/questionnnaire/RuleSets.fsh`. The **"Impfstatus"** section is modular one level further down: SDC `$assemble` cannot parameterise a
sub-questionnaire, so the reuse lives in the FSH rule sets `RuleSetQrImmunizationRow` (form) and
`RuleSetImmunizationRow` (extraction), each inserted once per vaccination type by a per-disease child
(`examples/Mpox/ChEkmQuestionnaireImmunizationMpox.fsh` — two rows;
`examples/InvasiveStreptococcusPneumoniae/ChEkmQuestionnaireImmunizationInvasivePneumococcalDisease.fsh`
— one). Fixed rows, not a repeating group — see forms-summary.md §8 for why variable cardinality
breaks the single-Bundle-template extraction. **One row = one resource carrying the TOTAL dose
count**, never one resource per dose.
The **"Labor"** section (`RuleSetQrLaboratory` -> `ChEkmQuestionnaireLaboratory`) is a LEVEL-3 child
of the Diagnose section, inserted right after the Manifestationsbeginn; Hepatitis C and invasive
pneumococcal disease assemble it, Gonorrhoea and Mpox do not. Its OPT-IN companion
`RuleSetQrLaboratorySpecimen` -> `ChEkmQuestionnaireLaboratorySpecimen` adds the two sample questions
(Entnahmedatum + Material -> `ChEkmSpecimen`) and is assembled by invasive pneumococcal disease only:
`$assemble` cannot include a child conditionally, so a form that asks more says so with one more
insert rather than by branching inside a shared module. Mpox, Hepatitis C and invasive pneumococcal disease
have the **"Verlauf"** section (`RuleSetQrGroupCourse` + `RuleSetQrHospitalisation` +
`RuleSetQrDeath`); Gonorrhoea has none. That section is also the only one needing a third launch context (`encounter`), which is why
it is inserted separately (`RuleSetQrLaunchContextEncounter`) rather than from the shared header.

The assemble scripts are **local only** by default. Publishing the assembled + per-language
questionnaires to the Forms Server (https://smartforms.ahdis.ch/api/fhir) is opt-in — add
`--upload` (or `EKM_UPLOAD=1`), and point elsewhere with `EKM_FHIR_BASE`.

**Pre-population needs a local HAPI.** `%user` is the treating physician's **PractitionerRole**,
and the Practitioner/Organization fields read `%user.practitioner.resolve()` /
`%user.organization.resolve()`. FHIRPath `resolve()` does a real HTTP fetch, so both
`populate-gonorrhoea.sh` **and** the Smart Forms playground need a server holding the examples:

```bash
./scripts/start_hapi.sh              # HAPI FHIR at http://localhost:8080/fhir  (docker)
# ALWAYS pass the base URL: load_examples.sh defaults to the REMOTE Forms Server
# (https://smartforms.ahdis.ch/api/fhir), not to the local HAPI just started above.
./scripts/load_examples.sh http://localhost:8080/fhir   # PUTs Practitioner/Organization/PractitionerRole/Patient/Condition/Encounter into it
```

In the **playground** (https://smartforms.csiro.au/playground) additionally set *Source FHIR
server* to `http://localhost:8080/fhir` and pick Patient → User → **PractitionerRole**. Selecting
the PractitionerRole is what binds `%user`; picking only a "user" (a `Practitioner`) leaves the
whole treating-physician block empty. See forms-summary.md §10 for why.
