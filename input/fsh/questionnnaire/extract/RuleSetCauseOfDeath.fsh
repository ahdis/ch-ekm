RuleSet: RuleSetPatientDeceased
// "Zustand" (death), the Patient half -> Patient.deceasedDateTime. Three form answers, three shapes:
//
//   deceased not ticked        -> no deceasedDateTime at all: no death is reported.
//   deceased + a date          -> deceasedDateTime = the date.
//   deceased, no date          -> deceasedDateTime with NO value, carrying
//                                 extension[data-absent-reason] = asked-unknown. The death is still
//                                 asserted; only its date is missing.
//
// One element carries both facts (presence = died, value = when), so a consumer never has to check
// two places to learn whether somebody died. That is also why `deceasedBoolean` is not used at all:
// ChEkmPatient restricts deceased[x] to dateTime.
//
// extension[0] builds the WHOLE data-absent-reason extension at extraction via the FHIR Type Factory
// on the ch-ekm SdcTemplateExtractExtension carrier — it cannot be pre-declared as
// data-absent-reason in the template (a to-be-computed valueCode leaves the extension valueless =>
// fails ext-1, and the templateExtractContext sub-extension is not allowed by the
// data-absent-reason profile). Identical idiom to RuleSetOnsetDateManifestationBeginUnknown.
//
// ORDER MATTERS: the context-gated carrier MUST come before the plain value extension. The reference
// engine's array index bookkeeping mis-handles the reverse order. See forms-summary.md §8.
//
// The `iif` criteria are Boolean on purpose (`= true`, `.exists().not()`), never a bare path — a
// non-Boolean criterion silently falls through to the else branch (forms-summary §8). FHIRPath
// three-valued logic then does the rest: with the question unanswered, `{} and true` is `{}`, so the
// criterion is empty and the else branch wins, which is exactly "no death reported".
//
// NB: this rule set is inserted into the SHARED ExtractedPatient, so it also runs for organisms
// whose form has no "Verlauf" section (Gonorrhoea). There the two linkIds simply do not exist, every
// expression is empty, and no deceasedDateTime is emitted.
* deceasedDateTime.extension[0].url = $sdc-templateExtractExtension
* deceasedDateTime.extension[0].extension[0].url = $sdc-templateExtractContext
* deceasedDateTime.extension[0].extension[0].valueString = "iif(%resource.descendants().where(linkId='deceased').answer.value.first() = true and %resource.descendants().where(linkId='deathDate').answer.value.exists().not(), true, {})"
* deceasedDateTime.extension[0].extension[1].url = $sdc-templateExtractValue
* deceasedDateTime.extension[0].extension[1].valueString = "%factory.Extension('http://hl7.org/fhir/StructureDefinition/data-absent-reason', %factory.code('asked-unknown'))"
* deceasedDateTime.extension[1].url = $sdc-templateExtractValue
* deceasedDateTime.extension[1].valueString = "iif(%resource.descendants().where(linkId='deceased').answer.value.first() = true, %resource.descendants().where(linkId='deathDate').answer.value.first(), {})"


// =================================================================================================
// "Zustand" (death), the cause half -> ChEkmObservationCauseOfDeath.
//
//   reported pathogen   -> valueCodeableConcept = the disease code of this report,
//                          plus focus -> the diagnosis Condition
//   other (74964007)    -> valueCodeableConcept = that qualifier, verbatim. No focus.
//   unknown (261665006) -> no value; dataAbsentReason = asked-unknown.
//   not answered / alive-> no Observation at all (the Bundle entry gates handle that).
//
// TWO TEMPLATE INSTANCES FOR ONE CLINICAL RESOURCE, AND THAT IS FORCED BY obs-6.
// `obs-6` is "dataAbsentReason SHALL only be present if Observation.value[x] is not present". A
// single template instance would have to carry BOTH carriers — `valueCodeableConcept` holding the
// value directive and `dataAbsentReason` holding the unknown directive — and although only one of
// them ever survives extraction, the TEMPLATE itself is validated by the IG Publisher as a real
// Observation and fails obs-6 (it also drags the containing Composition out of conformance, so the
// Bundle's `entry:Composition` slice stops matching). The carrier idiom used elsewhere cannot help
// here: it works for extensions, and `dataAbsentReason` is an element.
//
// So the two branches are two template instances with mutually exclusive Bundle-entry gates — only
// ever one materialises, and each is a valid Observation on its own. The Composition's
// section[cause-death] entry points at whichever one fired (see RuleSetCauseOfDeathSection).
//
// The alternative — expressing "unknown" as a data-absent-reason EXTENSION on value[x], the way this
// repo does for onsetDateTime and the exposure address — would keep one instance, but a consumer of
// an Observation looks for `dataAbsentReason`, and that element is the reason an Observation was
// chosen over a Condition in the first place (see ChEkmObservationCauseOfDeath).
//
// SAME ENGINE CONSTRAINT AS THE ENCOUNTER: both instances sit inside context-gated Bundle entries,
// so there must be NO templateExtractContext anywhere below those gates. Every conditional part is a
// plain templateExtractValue reading the answers ABSOLUTELY through %resource and ending in
// `.first().select(%factory.…)`; `select()` on an empty collection returns empty, so "not
// applicable" and "no element emitted" are the same thing. See RuleSetEncounterHospitalisation.
//
// DISEASE-SPECIFIC: the reported-pathogen branch writes the disease code and the focus names this
// document's diagnosis Condition. Both are spelled out for Mpox, exactly as
// RuleSetEncounterHospitalisation names `Condition/ExtractedCondition`. A second organism needs its
// own copy — the FHIRPath cannot read the code off the template.
// =================================================================================================

RuleSet: RuleSetObservationCauseOfDeathCommon
* status = #final
* code = $loinc#79378-6 "Cause of death"
* subject.reference = "Patient/ExtractedPatient"

RuleSet: RuleSetObservationCauseOfDeathValue
* insert RuleSetObservationCauseOfDeathCommon
// The cause. ONE value directive, because only the FIRST templateExtractValue in an extension array
// is read by the engine — the two answer kinds have to be branched inside a single expression:
//   reported pathogen -> the Mpox code, built by the factory (the form answer is the local
//                        discriminator code, which must NOT reach the wire)
//   other             -> the answered SNOMED qualifier, passed through unchanged
// "unknown" never reaches this instance; its entry gate excludes it.
* valueCodeableConcept.extension[+].url = $sdc-templateExtractValue
* valueCodeableConcept.extension[=].valueString = "iif(%resource.descendants().where(linkId='deathCause').answer.value.ofType(Coding).where(system='http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-reported-pathogen' and code='reported-pathogen').exists(), %factory.CodeableConcept(%factory.Coding('http://snomed.info/sct', '359814004', 'Mpox')), %resource.descendants().where(linkId='deathCause').answer.value.ofType(Coding).where(system='http://snomed.info/sct' and code='74964007').first().select(%factory.CodeableConcept($this)))"
// "The cause of death is the disease this report is about" — made machine-checkable by pointing at
// the diagnosis Condition instead of leaving a consumer to compare codes.
//
// PLACEHOLDER DEFAULT — replaced at extraction (same idiom as Encounter.reasonReference): a
// Reference carrying nothing but a templateExtractValue makes the TEMPLATE flag "a Reference without
// an actual reference or identifier should have a display". The engine deletes the whole `focus[0]`
// element when it strips the artifacts, before the clean template is taken, so this never survives.
* focus[0].reference = "Condition/ExtractedCondition"
* focus[0].extension[+].url = $sdc-templateExtractValue
* focus[0].extension[=].valueString = "%resource.descendants().where(linkId='deathCause').answer.value.ofType(Coding).where(system='http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-reported-pathogen' and code='reported-pathogen').first().select(%factory.withProperty(%factory.create(Reference), 'reference', 'Condition/ExtractedCondition'))"

RuleSet: RuleSetObservationCauseOfDeathUnknown
* insert RuleSetObservationCauseOfDeathCommon
// The cause was reported as unknown. Note the code system: DataAbsentReason the CODE SYSTEM
// (terminology.hl7.org/CodeSystem/data-absent-reason) for this CodeableConcept, not the
// data-absent-reason EXTENSION url used on primitives elsewhere in these templates.
// The value is a constant, but it still goes through `.select()` on the answer so that the element —
// and with it the only content of this instance — is omitted if the gate ever lets something else
// through.
* dataAbsentReason.extension[+].url = $sdc-templateExtractValue
* dataAbsentReason.extension[=].valueString = "%resource.descendants().where(linkId='deathCause').answer.value.ofType(Coding).where(system='http://snomed.info/sct' and code='261665006').first().select(%factory.CodeableConcept(%factory.Coding('http://terminology.hl7.org/CodeSystem/data-absent-reason', 'asked-unknown', 'Asked But Unknown')))"

RuleSet: RuleSetCauseOfDeathSection
// Composition.section[cause-death] — present only when the person died AND a cause was answered,
// because the section is 0..1 with `entry` 1..1: an empty section would be invalid, and a section
// whose entry points at an Observation that was never emitted would dangle.
//
// `section[+]` appends after the sections the caller has already declared, so this rule set has to
// be inserted LAST in the Composition template — and the section must stay last, since a gated array
// element that is not re-inserted shifts everything after it (same rule as for the Bundle entries).
//
// The gate needs at least ONE value path to fire at all: `evaluateAndInsertIntoPath` loops over the
// context's valuePathMap, so a context with no values inserts nothing. Here that value is `entry` —
// the reference to whichever of the two cause-of-death instances fired, which has to be computed
// anyway. `title` and `code` stay static and survive, because the engine seeds a context-gated array
// element with a SHALLOW spread, `{...staticSection, ...firstValue}`, and a value at depth 1
// overwrites only its own key. (A value nested deeper WOULD clobber its whole top-level key — that
// is why a gated Bundle entry, whose values live under `resource.…`, needs the identity value on
// `fullUrl` in ChEkmDocumentMpoxTemplate. A section does not.)
* section[+].extension[0].url = $sdc-templateExtractContext
* section[=].extension[0].valueString = "iif(%resource.descendants().where(linkId='deceased').answer.value.first() = true and %resource.descendants().where(linkId='deathCause').answer.value.exists(), true, {})"
* section[=].title = "Cause of death section"
* section[=].code = $loinc#79378-6
* section[=].entry[0].reference = "Observation/ExtractedCauseOfDeath"
* section[=].entry[0].extension[0].url = $sdc-templateExtractValue
* section[=].entry[0].extension[0].valueString = "iif(%resource.descendants().where(linkId='deathCause').answer.value.ofType(Coding).where(system='http://snomed.info/sct' and code='261665006').exists(), %factory.withProperty(%factory.create(Reference), 'reference', 'Observation/ExtractedCauseOfDeathUnknown'), %factory.withProperty(%factory.create(Reference), 'reference', 'Observation/ExtractedCauseOfDeath'))"
