// SDC template-based $extract template for the invasive pneumococcal disease report.
//
// Shaped like ChEkmDocumentInvasivePneumococcalDisease. Everything generic — Patient, treating
// Practitioner / Organization / PractitionerRole — is reused verbatim from the shared template
// (input/fsh/questionnnaire/extract/ChEkmDocumentTemplate.fsh); everything conditional reuses the
// same rule sets Mpox and Hepatitis C do. Read the header of that file first: it documents the
// idioms (context-gating, %factory, the "conditional entries LAST" rule) that this file relies on.
//
// STARTER SCOPE, mirroring the questionnaire root: no section[risk-factors] — it is optional in
// ChEkmComposition, so the extracted document is valid without it. See OPEN QUESTIONS #3 in
// ChEkmQuestionnaireInvasivePneumococcalDisease.fsh. section[immunization] (issue #29, one row) and
// section[laboratory] (the analysing laboratory) ARE produced.
//
// Run:  ./scripts/extract-invasivepneumococcaldisease.sh

// ---------------------------------------------------------------------------
// Condition (ChEkmConditionInvasivePneumococcalDisease) — fixed disease code; manifestation ->
// evidence.code; manifestation begin date -> onset (data-absent-reason when "unknown" is ticked)
// ---------------------------------------------------------------------------
Instance: ExtractedConditionInvasivePneumococcalDisease
InstanceOf: ChEkmConditionInvasivePneumococcalDisease
Usage: #inline
* code = $sct#406617004 "Invasive Streptococcus pneumoniae disease (disorder)"
* category = $condition-category#encounter-diagnosis
* subject.reference = "Patient/ExtractedPatient"
* recorder.reference = "PractitionerRole/ExtractedTreatingPractitionerRole"
// Hospitalisation: reference the Encounter, gated on there being one (see RuleSetEncounterReference)
* insert RuleSetEncounterReference(encounter, ExtractedEncounterInvasivePneumococcalDisease)
* insert RuleSetOnsetDateManifestationBeginUnknown
* insert RuleSetEvidenceManifestation
// PLACEHOLDER DEFAULT — replaced at extraction by the answered manifestation Coding(s).
// `evidence.code` has a required binding to ChEkmInvasivePneumococcalDiseaseManifestation, so the
// TEMPLATE needs a member of that value set to validate standalone.
* evidence[0].code[0].coding[0] = $sct#91302008 "Sepsis (disorder)"

// ---------------------------------------------------------------------------
// Exposure — the BASE ChEkmExposure, not a disease-specific profile: there is no
// ChEkmExposureInvasivePneumococcalDisease (see OPEN QUESTIONS #5 in the questionnaire root), and
// the base profile is exactly what ChEkmComposition's section[social-history] requires. Only "Wo"
// and "Wann" are extracted, because only those two questions are in the form; the "Wie" components
// that Gonorrhoea/Mpox add (RuleSetComponentExposure) are deliberately absent.
// ---------------------------------------------------------------------------
Instance: ExtractedExposureInvasivePneumococcalDisease
InstanceOf: ChEkmExposure
Usage: #inline
* status = #final
* category = $v3-ActClass#AEXPOS "acquisition exposure"
* code = $v3-ParticipationType#EXPAGNT "Exposure Agent"
* subject.reference = "Patient/ExtractedPatient"
// Wann — effectiveDateTime plus component[dateOfEntry].
* insert RuleSetEffectiveExposureWhen
// Wo — only touches the `extension` array, independent of the component indices above.
* insert RuleSetExposureWhere

// ---------------------------------------------------------------------------
// Encounter (ChEkmEncounter) — the hospitalisation. Emitted only when the Hospitalisation question
// was answered "yes" or "unknown"; the Bundle entry below carries that gate.
// ---------------------------------------------------------------------------
Instance: ExtractedEncounterInvasivePneumococcalDisease
InstanceOf: ChEkmEncounter
Usage: #inline
* insert RuleSetEncounterHospitalisation(ExtractedConditionInvasivePneumococcalDisease)

// ---------------------------------------------------------------------------
// Cause of death (ChEkmObservationCauseOfDeath) — the "Zustand" half of the Verlauf section.
// Emitted only when the person died AND a cause was answered; the Bundle entry below carries that
// gate. The death itself and its date are on ExtractedPatient.deceasedDateTime
// (RuleSetPatientDeceased in the shared template).
//
// The "reported pathogen" answer writes sct#406617004, the SAME code the diagnosis Condition above
// fixes — the CSV proposes the broader sct#16814004 "Pneumococcal infectious disease" instead; see
// OPEN QUESTIONS #8 in the questionnaire root.
// ---------------------------------------------------------------------------
Instance: ExtractedCauseOfDeathInvasivePneumococcalDisease
InstanceOf: ChEkmObservationCauseOfDeath
Usage: #inline
* insert RuleSetObservationCauseOfDeath(406617004, Invasive Streptococcus pneumoniae disease (disorder\), ExtractedConditionInvasivePneumococcalDisease)

// ---------------------------------------------------------------------------
// "Impfstatus" (issue #29) — SIX MUTUALLY EXCLUSIVE INSTANCES FOR THE ONE FORM ROW, of which
// exactly one is ever emitted; the Bundle entry gates below decide which. Four Immunizations for
// the 2 x 2 combinations of "was a last-dose date given" x "was a dose count given", and two
// Observations for the "no" / "unknown" answers, which are not vaccinations. The full reasoning is
// in questionnnaire/extract/RuleSetImmunization.fsh; Mpox instantiates the same six rule sets twice.
//
// ONE ROW, TOTAL DOSES: doseNumberPositiveInt is the TOTAL number of doses and occurrenceDateTime
// the date of the LAST one, so an answered row produces exactly ONE Immunization — not one per dose
// as the example Bundle carries. See ChEkmImmunizationInvasivePneumococcalDisease.
//
// The disease parameters, identical on all six: target disease sct#16814004 "Pneumococcal
// infectious disease", fallback product sct#836398006 "Streptococcus pneumoniae antigen-containing
// vaccine product". The display is passed twice, quoted and unquoted — a rule-set argument keeps its
// FSH quotes, so only a bare-word argument can be nested inside a FHIRPath string literal.
// ---------------------------------------------------------------------------
Instance: ExtractedImmunizationPneumococcalDatedDosed
InstanceOf: ChEkmImmunizationInvasivePneumococcalDisease
Usage: #inline
* insert RuleSetImmunizationDatedDosed(Pneumococcal, 16814004, "Pneumococcal infectious disease", 836398006, "Streptococcus pneumoniae antigen-containing vaccine product", Streptococcus pneumoniae antigen-containing vaccine product)

Instance: ExtractedImmunizationPneumococcalDatedNoDose
InstanceOf: ChEkmImmunizationInvasivePneumococcalDisease
Usage: #inline
* insert RuleSetImmunizationDatedNoDose(Pneumococcal, 16814004, "Pneumococcal infectious disease", 836398006, "Streptococcus pneumoniae antigen-containing vaccine product", Streptococcus pneumoniae antigen-containing vaccine product)

Instance: ExtractedImmunizationPneumococcalUndatedDosed
InstanceOf: ChEkmImmunizationInvasivePneumococcalDisease
Usage: #inline
* insert RuleSetImmunizationUndatedDosed(Pneumococcal, 16814004, "Pneumococcal infectious disease", 836398006, "Streptococcus pneumoniae antigen-containing vaccine product", Streptococcus pneumoniae antigen-containing vaccine product)

Instance: ExtractedImmunizationPneumococcalUndatedNoDose
InstanceOf: ChEkmImmunizationInvasivePneumococcalDisease
Usage: #inline
* insert RuleSetImmunizationUndatedNoDose(Pneumococcal, 16814004, "Pneumococcal infectious disease", 836398006, "Streptococcus pneumoniae antigen-containing vaccine product", Streptococcus pneumoniae antigen-containing vaccine product)

Instance: ExtractedVaccinationStatusPneumococcalNo
InstanceOf: ChEkmObservationVaccinationStatusInvasivePneumococcalDisease
Usage: #inline
* insert RuleSetVaccinationStatusNo(16814004, "Pneumococcal infectious disease", 836398006, "Streptococcus pneumoniae antigen-containing vaccine product")

Instance: ExtractedVaccinationStatusPneumococcalUnknown
InstanceOf: ChEkmObservationVaccinationStatusInvasivePneumococcalDisease
Usage: #inline
* insert RuleSetVaccinationStatusUnknown(16814004, "Pneumococcal infectious disease", 836398006, "Streptococcus pneumoniae antigen-containing vaccine product")

// ---------------------------------------------------------------------------
// Composition (ChEkmCompositionInvasivePneumococcalDisease) — static structure, references the
// entries above, author = the treating physician's PractitionerRole, date taken from QR.authored.
// ---------------------------------------------------------------------------
Instance: ExtractedCompositionInvasivePneumococcalDisease
InstanceOf: ChEkmCompositionInvasivePneumococcalDisease
Usage: #inline
* status = #final
* type = $sct#722143004 "Infectious disease diagnostic study note"
* category = $sct#423876004 "Clinical report"
* subject.reference = "Patient/ExtractedPatient"
// Hospitalisation: the one place the Encounter is referenced from the Composition.
* insert RuleSetEncounterReference(encounter, ExtractedEncounterInvasivePneumococcalDisease)
* date.extension[+].url = $sdc-templateExtractValue
* date.extension[=].valueString = "%resource.authored"
* author.reference = "PractitionerRole/ExtractedTreatingPractitionerRole"
* title = "Meldung zum klinischen Befund Invasive Pneumokokkenerkrankung"
* section[0].title = "Diagnosis section"
* section[0].code = $loinc#29308-4
* section[0].entry.reference = "Condition/ExtractedConditionInvasivePneumococcalDisease"
* section[1].title = "Social history section"
* section[1].code = $loinc#29762-2
* section[1].entry.reference = "Observation/ExtractedExposureInvasivePneumococcalDisease"
// Labor — UNGATED (labName is a required form item), so it is declared before the gated sections.
* insert RuleSetLaboratorySection
// Cause of death — gated, and therefore LAST (a gated array element that is not re-inserted shifts
// every later element; see RuleSetCauseOfDeathSection).
* insert RuleSetCauseOfDeathSection(ExtractedCauseOfDeathInvasivePneumococcalDisease)
// Impfstatus — likewise gated, so it stays after the cause-of-death section and nothing may follow it.
* insert RuleSetImmunizationSectionInvasivePneumococcalDisease

// ---------------------------------------------------------------------------
// The Bundle template itself (ChEkmDocumentInvasivePneumococcalDisease shape)
// ---------------------------------------------------------------------------
Instance: ChEkmDocumentInvasivePneumococcalDiseaseTemplate
InstanceOf: ChEkmDocumentInvasivePneumococcalDisease
Usage: #example
Title: "CH EKM $extract template: invasive pneumococcal disease document Bundle"
Description: "SDC template-based extraction template. Shaped like ChEkmDocumentInvasivePneumococcalDisease; the per-report fields carry sdc-questionnaire-templateExtractValue/-Context FHIRPath expressions that read an invasive pneumococcal disease QuestionnaireResponse. Used by scripts/extract-invasivepneumococcaldisease.sh; not a normal example."
// meta.profile names the disease profile, so a validator picks it up from the extracted document (and
// from the transaction entry) without being told which profile to use. Explicit because
// sushi-config sets `setMetaProfile: never`.
* meta.profile = Canonical(ChEkmDocumentInvasivePneumococcalDisease)
* type = #document
* identifier.system = "urn:ietf:rfc:3986"
// PLACEHOLDER DEFAULT — replaced at extraction by the allocated %documentBundleId, the UUID the
// DocumentReference (ChEkmDocumentReferenceTemplate) uses as masterIdentifier, so every extracted
// report gets its own identifier. A document Bundle must have one (bdl-9), hence the default.
* identifier.value = "urn:uuid:9d4c1b02-3f77-4f56-9e21-5a8c6e0b74d1"
* identifier.value.extension[+].url = $sdc-templateExtractValue
* identifier.value.extension[=].valueString = "'urn:uuid:' + %documentBundleId"
// PLACEHOLDER DEFAULT — replaced at extraction. A document Bundle must have a timestamp value
// (bdl-10), so the template needs a real one to validate; this 1900 sentinel never survives.
* timestamp = "1900-01-01T00:00:00Z"
* timestamp.extension[+].url = $sdc-templateExtractValue
* timestamp.extension[=].valueString = "%resource.authored"
* entry[+].fullUrl = "http://test.fhir.ch/r4/Composition/ExtractedCompositionInvasivePneumococcalDisease"
* entry[=].resource = ExtractedCompositionInvasivePneumococcalDisease
* entry[+].fullUrl = "http://test.fhir.ch/r4/Patient/ExtractedPatient"
* entry[=].resource = ExtractedPatient
* entry[+].fullUrl = "http://test.fhir.ch/r4/Condition/ExtractedConditionInvasivePneumococcalDisease"
* entry[=].resource = ExtractedConditionInvasivePneumococcalDisease
* entry[+].fullUrl = "http://test.fhir.ch/r4/Observation/ExtractedExposureInvasivePneumococcalDisease"
* entry[=].resource = ExtractedExposureInvasivePneumococcalDisease
* entry[+].fullUrl = "http://test.fhir.ch/r4/PractitionerRole/ExtractedTreatingPractitionerRole"
* entry[=].resource = ExtractedTreatingPractitionerRole
* entry[+].fullUrl = "http://test.fhir.ch/r4/Practitioner/ExtractedTreatingPractitioner"
* entry[=].resource = ExtractedTreatingPractitioner
* entry[+].fullUrl = "http://test.fhir.ch/r4/Organization/ExtractedTreatingOrganization"
* entry[=].resource = ExtractedTreatingOrganization

// Labor — the ServiceRequest carrying the analysing laboratory. Ungated, hence before the
// conditional entries below.
* insert RuleSetLaboratoryEntries

// --- CONDITIONAL ENTRIES, LAST ON PURPOSE -------------------------------------------------------
// The engine deletes a context-gated array element from the template and re-inserts it once per
// context result; a STATIC entry placed after a gated one is corrupted as soon as the gate does not
// fire. All conditional entries therefore sit at the end. See ChEkmDocumentMpoxTemplate.fsh for the
// full explanation, including why `fullUrl` needs an identity templateExtractValue.

// The sample (Entnahmedatum / Material) — emitted when either question was answered.
* insert RuleSetLaboratorySpecimenEntry

// Hospitalisation Encounter — answered "no" (or unanswered) -> empty context -> no Encounter, and
// the two references to it (Composition.encounter, Condition.encounter) carry the same test, so
// they disappear with it.
* entry[+].extension[0].url = $sdc-templateExtractContext
* entry[=].extension[0].valueString = "iif(%resource.descendants().where(linkId='hospitalisationStatus').answer.value.ofType(Coding).where(system='http://snomed.info/sct' and (code='373066001' or code='261665006')).exists(), true, {})"
* entry[=].fullUrl = "http://test.fhir.ch/r4/Encounter/ExtractedEncounterInvasivePneumococcalDisease"
// IDENTITY VALUE, AND IT IS LOAD-BEARING — see ChEkmDocumentMpoxTemplate.fsh.
* entry[=].fullUrl.extension[0].url = $sdc-templateExtractValue
* entry[=].fullUrl.extension[0].valueString = "'http://test.fhir.ch/r4/Encounter/ExtractedEncounterInvasivePneumococcalDisease'"
* entry[=].resource = ExtractedEncounterInvasivePneumococcalDisease

// Cause of death Observation — gated on "the person died AND a cause was answered", for all three
// answers ("unknown" is a value, issue #28).
* entry[+].extension[0].url = $sdc-templateExtractContext
* entry[=].extension[0].valueString = "iif(%resource.descendants().where(linkId='deceased').answer.value.first() = true and %resource.descendants().where(linkId='deathCause').answer.value.exists(), true, {})"
* entry[=].fullUrl = "http://test.fhir.ch/r4/Observation/ExtractedCauseOfDeathInvasivePneumococcalDisease"
// IDENTITY VALUE, LOAD-BEARING — see above.
* entry[=].fullUrl.extension[0].url = $sdc-templateExtractValue
* entry[=].fullUrl.extension[0].valueString = "'http://test.fhir.ch/r4/Observation/ExtractedCauseOfDeathInvasivePneumococcalDisease'"
* entry[=].resource = ExtractedCauseOfDeathInvasivePneumococcalDisease

// Impfstatus — the six mutually exclusive instances of the one form row. Their gates are spelled out
// in RuleSetImmunization.fsh (they cannot be rule-set arguments: the expressions contain parentheses).
// At most ONE of the six fires per report; an unanswered row emits nothing at all.
* insert RuleSetImmunizationEntries(Pneumococcal)
