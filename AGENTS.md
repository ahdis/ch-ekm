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
| `input/fsh/examples/` | Instance examples, grouped by organism (`Gonorrhoea/`, `HepatitisC/`, `InvasiveStreptococcusPneumoniae/`) and shared Patient/Practitioner/Organization examples |
| `input/fsh/ALIAS.fsh` | All FSH aliases (code systems, extensions, value sets) |
| `input/pagecontent/` | Narrative IG pages (`index`, `usecase`, `guidance`, `profiles`, `terminology`, `examples`, `changelog`, `extensions`) |
| `input/images-source/` | PlantUML sources for use-case diagrams |
| `sushi-config.yaml` | SUSHI / IG configuration, menu, dependencies, pages |
| `expansion-params.json` | Terminology expansion params (SNOMED CT Swiss Extension) |
| `gonorrhoea.png` | Scan of the paper Gonorrhoea reporting form (green = sections to be turned into an SDC Questionnaire) |

## Profiles

### Document structure
- **`ChEkmDocument`** (← `CHCoreDocument`) — the report `Bundle`; entry Composition only `ChEkmComposition`.
- **`ChEkmComposition`** (← `CHCoreComposition`) — `status=final`,
  `category = sct#423876004 "Clinical report"`, `type = sct#722143004 "Infectious disease
  diagnostic study note"`. Author is a `ChEkmPractitionerRole` (treating physician *or*
  broker). Sliced `section`: `diagnosis` (1..1), `laboratory`, `hospitalization`,
  `medication`, `immunization`, `risk-factors`, `social-history`, `cause-death`.
  - `section[diagnosis]` → `ChEkmCondition` (+ optional `QuestionnaireResponse`)
  - `section[laboratory]` → `ChEkmServiceRequest` (+ optional seroconversion Observation)
  - `section[social-history]` → `ChEkmExposure`

### Clinical content
- **`ChEkmCondition`** (← `CHCoreCondition`) — diagnosis + manifestations. `code` (the
  disease), `onsetDateTime` (manifestation begin, with `data-absent-reason` for unknown),
  `evidence` = manifestation.
- **`ChEkmExposure`** (← `Observation`) — the "Exposition" (how/where exposed). Mirrors
  HL7 Europe HDR *Infectious Contact*: `category` from `ChEkmExposureClass`,
  `code = EXPAGNT`, `extension[expositionAddress]` for the place (Wo).

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

### Extensions & invariants
- Extensions (`profiles/Extensions.fsh`): `ChEkmExtHivCode`, `ChEkmExtExpositionAddress`,
  `ChEkmExtDepartment`.
- Invariants (`profiles/Invariants.fsh`): `name-initials`, `ch-ekm-hiv-check`,
  `ch-ekm-dateTime`.

## Logical models (form models)

Located in `input/fsh/logical/`. Each is a `Logical` with `Characteristics: #can-be-target`
and one element per form item, plus a `Mapping` to the corresponding profile.

- **`ChEkmPersonForm`** → maps to `ChEkmPatient` (Person to Patient).
- **`ChEkmManifestationForm`** → maps to `ChEkmCondition`.
- **`ChEkmExpositionForm`** → maps to `ChEkmExposure` (the "Wo"/where part).
- **`ChEkmTreatingPhysicianForm`** → `Practitioner` + `Organization` form models.
- **`CHEkmGonorrhoeaForm`** — the disease-level aggregate: `person`, `exposition`,
  `manifestation`, `treatingPhysician`, each refining the generic form models for
  Gonorrhoea (e.g. `surnameInitial 1..1`, `surname 0..0`; adds the Gonorrhoea
  transmission sub-structure `transmission.sexualContactPartner / relationshipType /
  otherTransmission / unknown`).
- **`CHEkmHepatitisCForm`** — analogous for Hepatitis C.

These logical models are the **master** for building the SDC Questionnaires — see
[forms-summary.md](forms-summary.md).

## Terminology

`input/fsh/terminology/`:
- **CodeSystems**: `ChEkmExposureComponent` (internal discriminator codes for Exposure
  components), `ChEkmRelationshipType` (Art der Beziehung).
- **ValueSets**: per-disease manifestation sets (`ChEkmGonorrhoeaManifestation`,
  `ChEkmHepatitisCManifestation`, `ChEkmInvasivePneumococcalDiseaseManifestation`,
  `ChEkmHIVManifestation`, …), `ChEkmExposureClass`, `ChEkmExposureTransmissionRoute`,
  `ChEkmExposureRelationshipType`, `ChEkmBiologicalSex`, `ChEkmGenderIdentity`,
  `ChEkmServiceRequestReason`, `ChEkmSpecimenType`, `ChEkmOtherNoneUnknown`,
  `ChEkmHepatitisCCourseOfDisease`.
- **ConceptMap**: `ChEkmSexToHl7Gender` (biological sex → administrative gender).

Note (per `README.md`): the production terminology (ValueSets/CodeSystems) is maintained
by the FOPH on the **ABN environment**; `tests/updateterminolgy.sh` pulls them via the ABN
API into `input/resources/`. Terminology expansion uses the SNOMED CT Swiss Extension via
`expansion-params.json`.

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
```

**Validate examples/profiles with the IG Publisher** (the project's preferred validator —
not the matchbox MCP). The Publisher validates all examples against their profiles during
the build; warnings to ignore are listed in `input/ignoreWarnings.txt`.

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
</content>
</invoke>
