// "Impfstatus" (issue #29) -> one resource per ANSWERED form row.
//
// The extraction counterpart of RuleSetQrImmunizationRow: that rule set builds one row of the form,
// this one builds the resource that row extracts to, and both are parameterised by the same
// {suffix} so a disease adds a vaccination type by inserting each of them once more.
//
// THE RESOURCE TYPE DEPENDS ON THE ANSWER. Only "yes" describes a vaccination, so only "yes"
// produces a ChEkmImmunization; "no" and "unknown" are answers to a question and produce a
// ChEkmObservationVaccinationStatus (see Observation.fsh for why). A row that was not answered
// produces nothing at all.
//
// SIX MUTUALLY EXCLUSIVE TEMPLATE INSTANCES PER ROW, of which exactly one is ever emitted - four
// Immunizations and two Observations. This is the obs-6 pattern from forms-summary.md section 8, and
// on the Immunization side it is forced rather than chosen: `Immunization.occurrence[x]` is **1..1**
// and has to be an answered value on some branches and a `data-absent-reason` on others. A single
// template cannot do both - the static content is what makes the cardinality check pass, so
// whichever of the two is static survives into the extracted resource next to the computed one:
//
//   sentinel value + computed data-absent-reason  ->  the sentinel survives on the absent branch
//   static data-absent-reason + computed value    ->  the reason survives on the answered branch
//
// Neither is caught by the validator (R4 has no invariant forbidding a value beside a
// data-absent-reason), so a wrong date would ship silently. Splitting the row makes every instance
// unambiguous: an element is either statically absent or always answered, never both.
//
// The two optional details are independent, so the "yes" branch needs 2 x 2 combinations:
//
//                                     occurrenceDateTime        protocolApplied.doseNumber
//   Immunization
//     ...DatedDosed    yes, both        the answered date         the answered dose count
//     ...DatedNoDose   yes, no dose     the answered date         DAR asked-unknown
//     ...UndatedDosed  yes, no date     DAR asked-unknown         the answered dose count
//     ...UndatedNoDose yes, neither     DAR asked-unknown         DAR asked-unknown
//   Observation                       value[x]
//     ...No            no               sct#373067005 "No"        (no such elements)
//     ...Unknown       unknown          sct#261665006 "Unknown"
//   not answered       -> no resource at all (every gate is empty)
//
// `protocolApplied` is 1..1 on the Immunization and carries `targetDisease`, so a "yes" row is
// directly queryable as "vaccinated against smallpox" rather than only through `vaccineCode`. That
// is why the dose number takes a data-absent-reason instead of the whole element being omitted: R4
// makes `doseNumber[x]` 1..1 inside `protocolApplied`, so keeping targetDisease means the dose must
// be present, valued or absent-with-a-reason. The Observation needs none of this - it has no date
// and no dose count to be absent, which is why its two instances are entirely static.
//
// Making the dose count and the last-dose date mandatory once "yes" is answered would collapse the
// Immunization side to one instance, but it would lose "vaccinated, details unknown" - the likely
// answer for the historical smallpox programme, and the reason the split was chosen instead.
//
// SAME ENGINE CONSTRAINT AS THE ENCOUNTER AND THE CAUSE OF DEATH: each instance sits inside a
// context-gated Bundle entry, so there must be NO templateExtractContext anywhere below that gate
// (see RuleSetEncounterHospitalisation). Every computed part is a plain templateExtractValue reading
// the answers ABSOLUTELY through %resource. Because each instance's gate guarantees the answer it
// reads exists, those directives ALWAYS fire - which is what makes a sentinel next to them safe.
//
// DISEASE-SPECIFIC PARAMETERS, because the FHIRPath cannot read them off the template:
//   {suffix}            the linkId suffix of the row, e.g. Smallpox. Only the variants that READ an
//                       answer need it; the two Observations read none, so they do not take it.
//   {diseaseCode}       / {diseaseDisplay} -> Immunization.protocolApplied.targetDisease, resp. the
//                       Observation's component value: what the row is about
//   {vaccineCode}       / {vaccineDisplay} -> the SNOMED CT vaccine product, used as the
//                       Immunization's vaccineCode fallback when the physician did not name a
//                       product, and as the Observation's component code
//   {vaccineDisplayRaw} the SAME display, passed WITHOUT quotes. A rule set argument arrives with its
//                       FSH quotes attached, so the quoted form cannot be nested inside a FHIRPath
//                       string literal; only a bare-word argument can.
//   {reason}            a data-absent-reason code, passed WITHOUT quotes (e.g. asked-unknown)


// =================================================================================================
// Shared parts. Every instance is composed from these, so the disease-specific values and the
// product logic are written once.
// =================================================================================================

// patient and the fallback product, shared by the four "yes" instances. `vaccineCode` is 1..1 and
// fixed per row to the SNOMED CT vaccine product for that vaccination; the same concept is what the
// Observation of a "no"/"unknown" row puts in `component.code`, so both halves of one form line
// name the vaccination the same way.
RuleSet: RuleSetImmunizationBase(diseaseCode, diseaseDisplay, vaccineCode, vaccineDisplay)
* patient.reference = "Patient/ExtractedPatient"
* protocolApplied.targetDisease = $sct#{diseaseCode} {diseaseDisplay}
* vaccineCode = $sct#{vaccineCode} {vaccineDisplay}

// The product, for the "yes" instances only - the form item is enableWhen-gated on "yes", so on the
// other branches the answer cannot exist and the static fallback above already says the right thing.
// ONE directive, because the open-choice item has three possible outcomes and `vaccineCode` is 1..1:
//   picked from the Swiss vaccine list -> answer is a Coding -> a CodeableConcept holding it
//   typed by hand                      -> answer is a string -> a CodeableConcept holding the
//                                         FALLBACK CODING **and** the typed name in `text`
//   not answered                       -> an empty result DELETES the element, so the expression
//                                         must be total and end with the fallback
//
// EVERY BRANCH BUILDS THE COMPLETE CodeableConcept, and that is not optional. A factory value that
// produces a complete element REPLACES the static one rather than merging into it - the same engine
// behaviour the shared template documents for `%factory.HumanName` on Patient.name[0]. So the typed
// branch cannot rely on the static `vaccineCode` above surviving underneath it: written as a bare
// `withProperty(create(CodeableConcept), 'text', ...)` it extracts to `{text: "Prevenar 13"}` with
// NO coding at all, which contradicts ChEkmImmunization.vaccineCode ("a typed brand name is carried
// in vaccineCode.text" - alongside the SNOMED CT product, not instead of it). Hence the fallback
// Coding is built into the typed branch too.
// (Not reachable from the Mpox round-trip, whose QR picks a brand from the list; the invasive
// pneumococcal disease QR types one, which is what surfaced this.)
RuleSet: RuleSetImmunizationVaccineAnswered(suffix, vaccineCode, vaccineDisplayRaw)
* vaccineCode.extension[+].url = $sdc-templateExtractValue
* vaccineCode.extension[=].valueString = "iif(%resource.descendants().where(linkId='immunizationVaccine{suffix}').answer.value.ofType(Coding).exists(), %factory.CodeableConcept(%resource.descendants().where(linkId='immunizationVaccine{suffix}').answer.value.ofType(Coding).first()), iif(%resource.descendants().where(linkId='immunizationVaccine{suffix}').answer.value.ofType(string).exists(), %factory.withProperty(%factory.CodeableConcept(%factory.Coding('http://snomed.info/sct', '{vaccineCode}', '{vaccineDisplayRaw}')), 'text', %resource.descendants().where(linkId='immunizationVaccine{suffix}').answer.value.ofType(string).first()), %factory.CodeableConcept(%factory.Coding('http://snomed.info/sct', '{vaccineCode}', '{vaccineDisplayRaw}'))))"

// Date of the last dose, answered. PLACEHOLDER DEFAULT - the same idiom as Bundle.timestamp:
// `occurrence[x]` is 1..1 so the template needs a real value to validate, and the directive below
// always fires because the instance's gate requires the answer to exist. The 1900 sentinel therefore
// never survives a real extraction.
RuleSet: RuleSetImmunizationOccurrenceAnswered(suffix)
* occurrenceDateTime = "1900-01-01"
* occurrenceDateTime.extension[+].url = $sdc-templateExtractValue
* occurrenceDateTime.extension[=].valueString = "%resource.descendants().where(linkId='immunizationLastDose{suffix}').answer.value.first()"

// Date of the last dose, absent. A statically declared data-absent-reason and NO directive at all:
// SUSHI accepts a real extension on the primitive as satisfying `occurrence[x] 1..1`, and with
// nothing computed there is nothing that could contradict it.
RuleSet: RuleSetImmunizationOccurrenceAbsent(reason)
* occurrenceDateTime.extension[+].url = $data-absent-reason
* occurrenceDateTime.extension[=].valueCode = #{reason}

// Total number of doses, answered. PLACEHOLDER DEFAULT - the Bundle.timestamp idiom:
// `protocolApplied.doseNumber[x]` is 1..1 within `protocolApplied` so the template needs a real
// value, and the directive always fires because the instance's gate requires the answer to exist.
// positiveInt cannot express "0 doses" - that answer is "no".
RuleSet: RuleSetImmunizationDoseAnswered(suffix)
* protocolApplied.doseNumberPositiveInt = 1
* protocolApplied.doseNumberPositiveInt.extension[+].url = $sdc-templateExtractValue
* protocolApplied.doseNumberPositiveInt.extension[=].valueString = "%resource.descendants().where(linkId='immunizationDoses{suffix}').answer.value.first()"

// Total number of doses, absent - a statically declared data-absent-reason and no directive.
RuleSet: RuleSetImmunizationDoseAbsent(reason)
* protocolApplied.doseNumberPositiveInt.extension[+].url = $data-absent-reason
* protocolApplied.doseNumberPositiveInt.extension[=].valueCode = #{reason}


// =================================================================================================
// The four "yes" row variants.
// =================================================================================================

RuleSet: RuleSetImmunizationDatedDosed(suffix, diseaseCode, diseaseDisplay, vaccineCode, vaccineDisplay, vaccineDisplayRaw)
* insert RuleSetImmunizationBase({diseaseCode}, {diseaseDisplay}, {vaccineCode}, {vaccineDisplay})
* insert RuleSetImmunizationVaccineAnswered({suffix}, {vaccineCode}, {vaccineDisplayRaw})
* status = #completed
* insert RuleSetImmunizationOccurrenceAnswered({suffix})
* insert RuleSetImmunizationDoseAnswered({suffix})

RuleSet: RuleSetImmunizationDatedNoDose(suffix, diseaseCode, diseaseDisplay, vaccineCode, vaccineDisplay, vaccineDisplayRaw)
* insert RuleSetImmunizationBase({diseaseCode}, {diseaseDisplay}, {vaccineCode}, {vaccineDisplay})
* insert RuleSetImmunizationVaccineAnswered({suffix}, {vaccineCode}, {vaccineDisplayRaw})
* status = #completed
* insert RuleSetImmunizationOccurrenceAnswered({suffix})
* insert RuleSetImmunizationDoseAbsent(asked-unknown)

RuleSet: RuleSetImmunizationUndatedDosed(suffix, diseaseCode, diseaseDisplay, vaccineCode, vaccineDisplay, vaccineDisplayRaw)
* insert RuleSetImmunizationBase({diseaseCode}, {diseaseDisplay}, {vaccineCode}, {vaccineDisplay})
* insert RuleSetImmunizationVaccineAnswered({suffix}, {vaccineCode}, {vaccineDisplayRaw})
* status = #completed
* insert RuleSetImmunizationOccurrenceAbsent(asked-unknown)
* insert RuleSetImmunizationDoseAnswered({suffix})

RuleSet: RuleSetImmunizationUndatedNoDose(suffix, diseaseCode, diseaseDisplay, vaccineCode, vaccineDisplay, vaccineDisplayRaw)
* insert RuleSetImmunizationBase({diseaseCode}, {diseaseDisplay}, {vaccineCode}, {vaccineDisplay})
* insert RuleSetImmunizationVaccineAnswered({suffix}, {vaccineCode}, {vaccineDisplayRaw})
* status = #completed
* insert RuleSetImmunizationOccurrenceAbsent(asked-unknown)
* insert RuleSetImmunizationDoseAbsent(asked-unknown)


// =================================================================================================
// "No" and "unknown" -> ChEkmObservationVaccinationStatus, NOT an Immunization.
//
// Neither answer describes a vaccination, so neither can honestly be an Immunization: R4
// `Immunization.status` has no "unknown", and `not-done` asserts that the vaccination did not take
// place. Both are answers, and an answer lives in `Observation.value[x]` - see Observation.fsh.
//
// ENTIRELY STATIC, which is what makes these the two simplest instances in the template: the
// answer, the vaccine product and the target disease are all fixed by the instance's own gate and
// its disease parameters, so there is not one templateExtractValue directive below the gate. No
// sentinel, no data-absent-reason, nothing that could survive into the wrong branch.
//
// The answer is NOT a rule set argument. Its display, "No (qualifier value)" / "Unknown (qualifier
// value)", contains parentheses, and `(` and `)` inside an argument are read by the FSH parser as
// the end of the argument list - the same reason the entry gates below cannot be parameterised. So
// everything except the answer is shared here and each variant writes its own value[x].
// =================================================================================================

RuleSet: RuleSetVaccinationStatusBase(diseaseCode, diseaseDisplay, vaccineCode, vaccineDisplay)
* status = #final
* code = $sct#408864009 "Vaccination status (observable entity)"
* subject.reference = "Patient/ExtractedPatient"
* component.code = $sct#{vaccineCode} {vaccineDisplay}
* component.valueCodeableConcept = $sct#{diseaseCode} {diseaseDisplay}

// "No" - the person was not vaccinated against this disease.
RuleSet: RuleSetVaccinationStatusNo(diseaseCode, diseaseDisplay, vaccineCode, vaccineDisplay)
* insert RuleSetVaccinationStatusBase({diseaseCode}, {diseaseDisplay}, {vaccineCode}, {vaccineDisplay})
* valueCodeableConcept = $sct#373067005 "No (qualifier value)"

// "Unknown" - it is not known whether the person was vaccinated against this disease. The same
// qualifier this IG uses for every other "unknown" that can be carried as a code.
RuleSet: RuleSetVaccinationStatusUnknown(diseaseCode, diseaseDisplay, vaccineCode, vaccineDisplay)
* insert RuleSetVaccinationStatusBase({diseaseCode}, {diseaseDisplay}, {vaccineCode}, {vaccineDisplay})
* valueCodeableConcept = $sct#261665006 "Unknown (qualifier value)"


// =================================================================================================
// The Bundle entries and the section references, one rule set per variant.
//
// The gate cannot be a rule set ARGUMENT: it contains parentheses, and `(`, `)` and `,` all have to
// be backslash-escaped inside an argument, which would turn every expression into an unreadable
// thicket. So each variant carries its own gate and takes only {suffix}. The six gates are mutually
// exclusive and together cover every answered state, so exactly one fires per answered row.
//
// Each gate yields the answered status Coding (a single item) or nothing - no `iif` and no
// empty-collection literal, which matters because a brace pair anywhere in a parameterised rule set,
// comments included, is read by FSH as a parameter reference.
//
// The IDENTITY VALUE on fullUrl is load-bearing: the engine seeds a context-gated entry with a
// shallow spread of its FIRST value, so a value whose path starts at `resource.` would replace the
// whole static resource. See ChEkmDocumentMpoxTemplate.
// =================================================================================================

RuleSet: RuleSetImmunizationEntryDatedDosed(suffix)
* entry[+].extension[0].url = $sdc-templateExtractContext
* entry[=].extension[0].valueString = "%resource.descendants().where(linkId='immunizationStatus{suffix}').answer.value.ofType(Coding).where(code='373066001' and %resource.descendants().where(linkId='immunizationLastDose{suffix}').answer.value.exists() and %resource.descendants().where(linkId='immunizationDoses{suffix}').answer.value.exists())"
* entry[=].fullUrl = "http://test.fhir.ch/r4/Immunization/ExtractedImmunization{suffix}DatedDosed"
* entry[=].fullUrl.extension[0].url = $sdc-templateExtractValue
* entry[=].fullUrl.extension[0].valueString = "'http://test.fhir.ch/r4/Immunization/ExtractedImmunization{suffix}DatedDosed'"
* entry[=].resource = ExtractedImmunization{suffix}DatedDosed

RuleSet: RuleSetImmunizationEntryDatedNoDose(suffix)
* entry[+].extension[0].url = $sdc-templateExtractContext
* entry[=].extension[0].valueString = "%resource.descendants().where(linkId='immunizationStatus{suffix}').answer.value.ofType(Coding).where(code='373066001' and %resource.descendants().where(linkId='immunizationLastDose{suffix}').answer.value.exists() and %resource.descendants().where(linkId='immunizationDoses{suffix}').answer.value.exists().not())"
* entry[=].fullUrl = "http://test.fhir.ch/r4/Immunization/ExtractedImmunization{suffix}DatedNoDose"
* entry[=].fullUrl.extension[0].url = $sdc-templateExtractValue
* entry[=].fullUrl.extension[0].valueString = "'http://test.fhir.ch/r4/Immunization/ExtractedImmunization{suffix}DatedNoDose'"
* entry[=].resource = ExtractedImmunization{suffix}DatedNoDose

RuleSet: RuleSetImmunizationEntryUndatedDosed(suffix)
* entry[+].extension[0].url = $sdc-templateExtractContext
* entry[=].extension[0].valueString = "%resource.descendants().where(linkId='immunizationStatus{suffix}').answer.value.ofType(Coding).where(code='373066001' and %resource.descendants().where(linkId='immunizationLastDose{suffix}').answer.value.exists().not() and %resource.descendants().where(linkId='immunizationDoses{suffix}').answer.value.exists())"
* entry[=].fullUrl = "http://test.fhir.ch/r4/Immunization/ExtractedImmunization{suffix}UndatedDosed"
* entry[=].fullUrl.extension[0].url = $sdc-templateExtractValue
* entry[=].fullUrl.extension[0].valueString = "'http://test.fhir.ch/r4/Immunization/ExtractedImmunization{suffix}UndatedDosed'"
* entry[=].resource = ExtractedImmunization{suffix}UndatedDosed

RuleSet: RuleSetImmunizationEntryUndatedNoDose(suffix)
* entry[+].extension[0].url = $sdc-templateExtractContext
* entry[=].extension[0].valueString = "%resource.descendants().where(linkId='immunizationStatus{suffix}').answer.value.ofType(Coding).where(code='373066001' and %resource.descendants().where(linkId='immunizationLastDose{suffix}').answer.value.exists().not() and %resource.descendants().where(linkId='immunizationDoses{suffix}').answer.value.exists().not())"
* entry[=].fullUrl = "http://test.fhir.ch/r4/Immunization/ExtractedImmunization{suffix}UndatedNoDose"
* entry[=].fullUrl.extension[0].url = $sdc-templateExtractValue
* entry[=].fullUrl.extension[0].valueString = "'http://test.fhir.ch/r4/Immunization/ExtractedImmunization{suffix}UndatedNoDose'"
* entry[=].resource = ExtractedImmunization{suffix}UndatedNoDose

RuleSet: RuleSetVaccinationStatusEntryNo(suffix)
* entry[+].extension[0].url = $sdc-templateExtractContext
* entry[=].extension[0].valueString = "%resource.descendants().where(linkId='immunizationStatus{suffix}').answer.value.ofType(Coding).where(code='373067005')"
* entry[=].fullUrl = "http://test.fhir.ch/r4/Observation/ExtractedVaccinationStatus{suffix}No"
* entry[=].fullUrl.extension[0].url = $sdc-templateExtractValue
* entry[=].fullUrl.extension[0].valueString = "'http://test.fhir.ch/r4/Observation/ExtractedVaccinationStatus{suffix}No'"
* entry[=].resource = ExtractedVaccinationStatus{suffix}No

RuleSet: RuleSetVaccinationStatusEntryUnknown(suffix)
* entry[+].extension[0].url = $sdc-templateExtractContext
* entry[=].extension[0].valueString = "%resource.descendants().where(linkId='immunizationStatus{suffix}').answer.value.ofType(Coding).where(code='261665006')"
* entry[=].fullUrl = "http://test.fhir.ch/r4/Observation/ExtractedVaccinationStatus{suffix}Unknown"
* entry[=].fullUrl.extension[0].url = $sdc-templateExtractValue
* entry[=].fullUrl.extension[0].valueString = "'http://test.fhir.ch/r4/Observation/ExtractedVaccinationStatus{suffix}Unknown'"
* entry[=].resource = ExtractedVaccinationStatus{suffix}Unknown

RuleSet: RuleSetImmunizationEntries(suffix)
* insert RuleSetImmunizationEntryDatedDosed({suffix})
* insert RuleSetImmunizationEntryDatedNoDose({suffix})
* insert RuleSetImmunizationEntryUndatedDosed({suffix})
* insert RuleSetImmunizationEntryUndatedNoDose({suffix})
* insert RuleSetVaccinationStatusEntryNo({suffix})
* insert RuleSetVaccinationStatusEntryUnknown({suffix})


RuleSet: RuleSetImmunizationSectionEntryDatedDosed(suffix)
* section[=].entry[+].reference = "Immunization/ExtractedImmunization{suffix}DatedDosed"
* section[=].entry[=].extension[0].url = $sdc-templateExtractValue
* section[=].entry[=].extension[0].valueString = "%resource.descendants().where(linkId='immunizationStatus{suffix}').answer.value.ofType(Coding).where(code='373066001' and %resource.descendants().where(linkId='immunizationLastDose{suffix}').answer.value.exists() and %resource.descendants().where(linkId='immunizationDoses{suffix}').answer.value.exists()).first().select(%factory.withProperty(%factory.create(Reference), 'reference', 'Immunization/ExtractedImmunization{suffix}DatedDosed'))"

RuleSet: RuleSetImmunizationSectionEntryDatedNoDose(suffix)
* section[=].entry[+].reference = "Immunization/ExtractedImmunization{suffix}DatedNoDose"
* section[=].entry[=].extension[0].url = $sdc-templateExtractValue
* section[=].entry[=].extension[0].valueString = "%resource.descendants().where(linkId='immunizationStatus{suffix}').answer.value.ofType(Coding).where(code='373066001' and %resource.descendants().where(linkId='immunizationLastDose{suffix}').answer.value.exists() and %resource.descendants().where(linkId='immunizationDoses{suffix}').answer.value.exists().not()).first().select(%factory.withProperty(%factory.create(Reference), 'reference', 'Immunization/ExtractedImmunization{suffix}DatedNoDose'))"

RuleSet: RuleSetImmunizationSectionEntryUndatedDosed(suffix)
* section[=].entry[+].reference = "Immunization/ExtractedImmunization{suffix}UndatedDosed"
* section[=].entry[=].extension[0].url = $sdc-templateExtractValue
* section[=].entry[=].extension[0].valueString = "%resource.descendants().where(linkId='immunizationStatus{suffix}').answer.value.ofType(Coding).where(code='373066001' and %resource.descendants().where(linkId='immunizationLastDose{suffix}').answer.value.exists().not() and %resource.descendants().where(linkId='immunizationDoses{suffix}').answer.value.exists()).first().select(%factory.withProperty(%factory.create(Reference), 'reference', 'Immunization/ExtractedImmunization{suffix}UndatedDosed'))"

RuleSet: RuleSetImmunizationSectionEntryUndatedNoDose(suffix)
* section[=].entry[+].reference = "Immunization/ExtractedImmunization{suffix}UndatedNoDose"
* section[=].entry[=].extension[0].url = $sdc-templateExtractValue
* section[=].entry[=].extension[0].valueString = "%resource.descendants().where(linkId='immunizationStatus{suffix}').answer.value.ofType(Coding).where(code='373066001' and %resource.descendants().where(linkId='immunizationLastDose{suffix}').answer.value.exists().not() and %resource.descendants().where(linkId='immunizationDoses{suffix}').answer.value.exists().not()).first().select(%factory.withProperty(%factory.create(Reference), 'reference', 'Immunization/ExtractedImmunization{suffix}UndatedNoDose'))"

RuleSet: RuleSetVaccinationStatusSectionEntryNo(suffix)
* section[=].entry[+].reference = "Observation/ExtractedVaccinationStatus{suffix}No"
* section[=].entry[=].extension[0].url = $sdc-templateExtractValue
* section[=].entry[=].extension[0].valueString = "%resource.descendants().where(linkId='immunizationStatus{suffix}').answer.value.ofType(Coding).where(code='373067005').first().select(%factory.withProperty(%factory.create(Reference), 'reference', 'Observation/ExtractedVaccinationStatus{suffix}No'))"

RuleSet: RuleSetVaccinationStatusSectionEntryUnknown(suffix)
* section[=].entry[+].reference = "Observation/ExtractedVaccinationStatus{suffix}Unknown"
* section[=].entry[=].extension[0].url = $sdc-templateExtractValue
* section[=].entry[=].extension[0].valueString = "%resource.descendants().where(linkId='immunizationStatus{suffix}').answer.value.ofType(Coding).where(code='261665006').first().select(%factory.withProperty(%factory.create(Reference), 'reference', 'Observation/ExtractedVaccinationStatus{suffix}Unknown'))"

RuleSet: RuleSetImmunizationSectionEntries(suffix)
* insert RuleSetImmunizationSectionEntryDatedDosed({suffix})
* insert RuleSetImmunizationSectionEntryDatedNoDose({suffix})
* insert RuleSetImmunizationSectionEntryUndatedDosed({suffix})
* insert RuleSetImmunizationSectionEntryUndatedNoDose({suffix})
* insert RuleSetVaccinationStatusSectionEntryNo({suffix})
* insert RuleSetVaccinationStatusSectionEntryUnknown({suffix})


RuleSet: RuleSetImmunizationSectionMpox
// Composition.section[immunization] - present only when at least one row was answered, because the
// section is 0..1 with `entry` 1..*: an empty section would be invalid, and a section whose entries
// point at Immunizations that were never emitted would dangle. One computed entry per INSTANCE, so
// at most two of the twelve references survive; each carries its instance's gate verbatim, so a
// reference can never outlive the resource it points at.
//
// `section[+]` appends after the sections the caller has already declared, so this rule set has to
// be inserted LAST in the Composition template and stay last.
* section[+].extension[0].url = $sdc-templateExtractContext
* section[=].extension[0].valueString = "%resource.descendants().where(linkId='immunizationStatusSmallpox' or linkId='immunizationStatusMpox').answer.value.first()"
* section[=].title = "Immunization section"
* section[=].code = $loinc#11369-6
* insert RuleSetImmunizationSectionEntries(Smallpox)
* insert RuleSetImmunizationSectionEntries(Mpox)


RuleSet: RuleSetImmunizationSectionInvasivePneumococcalDisease
// Composition.section[immunization] for the invasive pneumococcal disease report - the same shape as
// RuleSetImmunizationSectionMpox, with ONE row instead of two.
//
// Present only when the row was answered, because the section is 0..1 with `entry` 1..*: an empty
// section would be invalid, and a section whose entry points at a resource that was never emitted
// would dangle. One computed entry per INSTANCE, so at most one of the six references survives;
// each carries its instance's gate verbatim, so a reference can never outlive its resource.
//
// The gate is NOT parameterisable and the section rule set therefore not shareable across diseases:
// it has to name the row linkIds of THIS form, and a rule set argument cannot carry the `(`/`)` of
// the expressions below. Two organisms, two four-line rule sets.
//
// `section[+]` appends after the sections the caller has already declared, so this rule set has to
// be inserted LAST in the Composition template and stay last.
* section[+].extension[0].url = $sdc-templateExtractContext
* section[=].extension[0].valueString = "%resource.descendants().where(linkId='immunizationStatusPneumococcal').answer.value.first()"
* section[=].title = "Immunization section"
* section[=].code = $loinc#11369-6
* insert RuleSetImmunizationSectionEntries(Pneumococcal)
