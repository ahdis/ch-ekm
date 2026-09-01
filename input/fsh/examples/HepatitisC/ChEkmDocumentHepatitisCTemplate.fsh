// SDC template-based $extract template for the Hepatitis C report.
//
// Shaped like ChEkmDocumentHepatitisC. Everything generic — Patient, treating Practitioner /
// Organization / PractitionerRole — is reused verbatim from the shared template
// (input/fsh/questionnnaire/extract/ChEkmDocumentTemplate.fsh); everything conditional reuses the
// same rule sets Mpox does. Read the header of that file first: it documents the idioms
// (context-gating, %factory, the "conditional entries LAST" rule) that this file relies on.
//
// Run:  ./scripts/extract-hepatitisc.sh

// ---------------------------------------------------------------------------
// Condition (ChEkmConditionHepatitisC) — fixed disease code; manifestation -> evidence.code;
// manifestation begin date -> onset (data-absent-reason when "unknown" is ticked)
// ---------------------------------------------------------------------------
Instance: ExtractedConditionHepatitisC
InstanceOf: ChEkmConditionHepatitisC
Usage: #inline
* code = $sct#50711007 "Viral hepatitis type C (disorder)"
* category = $condition-category#encounter-diagnosis
* subject.reference = "Patient/ExtractedPatient"
* recorder.reference = "PractitionerRole/ExtractedTreatingPractitionerRole"
// Hospitalisation: reference the Encounter, gated on there being one (see RuleSetEncounterReference)
* insert RuleSetEncounterReference(encounter, ExtractedEncounterHepatitisC)
* insert RuleSetOnsetDateManifestationBeginUnknown
* insert RuleSetEvidenceManifestation
// PLACEHOLDER DEFAULT — replaced at extraction by the answered manifestation Coding(s).
// `evidence.code` has a required binding to ChEkmHepatitisCManifestation, so the TEMPLATE needs a
// member of that value set to validate standalone.
* evidence[0].code[0].coding[0] = $sct#18165001 "Jaundice"

// ---------------------------------------------------------------------------
// Exposure — the BASE ChEkmExposure, not a disease-specific profile: there is no
// ChEkmExposureHepatitisC (see OPEN QUESTIONS #2 in ChEkmQuestionnaireHepatitisC.fsh), and the base
// profile is exactly what ChEkmComposition's section[social-history] requires. Only "Wo" and "Wann"
// are extracted, because only those two questions are in the form; the "Wie" components that
// Gonorrhoea/Mpox add (RuleSetComponentExposure) are deliberately absent.
// ---------------------------------------------------------------------------
Instance: ExtractedExposureHepatitisC
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
Instance: ExtractedEncounterHepatitisC
InstanceOf: ChEkmEncounter
Usage: #inline
* insert RuleSetEncounterHospitalisation(ExtractedConditionHepatitisC)

// ---------------------------------------------------------------------------
// Cause of death (ChEkmObservationCauseOfDeath) — the "Zustand" half of the Verlauf section.
// Emitted only when the person died AND a cause was answered; the Bundle entry below carries that
// gate. The death itself and its date are on ExtractedPatient.deceasedDateTime
// (RuleSetPatientDeceased in the shared template).
// ---------------------------------------------------------------------------
Instance: ExtractedCauseOfDeathHepatitisC
InstanceOf: ChEkmObservationCauseOfDeath
Usage: #inline
* insert RuleSetObservationCauseOfDeath(50711007, Viral hepatitis type C (disorder\), ExtractedConditionHepatitisC)

// ---------------------------------------------------------------------------
// Composition (ChEkmCompositionHepatitisC) — static structure, references the entries above,
// author = the treating physician's PractitionerRole, date taken from QR.authored.
//
// NOT emitted (see OPEN QUESTIONS in ChEkmQuestionnaireHepatitisC.fsh): section[laboratory] (#4),
// section[medication] (#6), section[immunization] (#8), and
// section[diagnosis].entry[questionnaire-response] for the Krankheitsverlauf (#7). All four are
// optional in ChEkmComposition / ChEkmCompositionHepatitisC, so the extracted document is valid
// without them.
// ---------------------------------------------------------------------------
Instance: ExtractedCompositionHepatitisC
InstanceOf: ChEkmCompositionHepatitisC
Usage: #inline
* status = #final
* type = $sct#722143004 "Infectious disease diagnostic study note"
* category = $sct#423876004 "Clinical report"
* subject.reference = "Patient/ExtractedPatient"
// Hospitalisation: the one place the Encounter is referenced from the Composition.
* insert RuleSetEncounterReference(encounter, ExtractedEncounterHepatitisC)
* date.extension[+].url = $sdc-templateExtractValue
* date.extension[=].valueString = "%resource.authored"
* author.reference = "PractitionerRole/ExtractedTreatingPractitionerRole"
* title = "Meldung zum klinischen Befund Hepatitis C"
* section[0].title = "Diagnosis section"
* section[0].code = $loinc#29308-4
* section[0].entry.reference = "Condition/ExtractedConditionHepatitisC"
* section[1].title = "Social history section"
* section[1].code = $loinc#29762-2
* section[1].entry.reference = "Observation/ExtractedExposureHepatitisC"
// Cause of death — gated, and therefore LAST (a gated array element that is not re-inserted shifts
// every later element; see RuleSetCauseOfDeathSection).
* insert RuleSetCauseOfDeathSection(ExtractedCauseOfDeathHepatitisC)

// ---------------------------------------------------------------------------
// The Bundle template itself (ChEkmDocumentHepatitisC shape)
// ---------------------------------------------------------------------------
Instance: ChEkmDocumentHepatitisCTemplate
InstanceOf: ChEkmDocumentHepatitisC
Usage: #example
Title: "CH EKM $extract template: Hepatitis C document Bundle"
Description: "SDC template-based extraction template. Shaped like ChEkmDocumentHepatitisC; the per-report fields carry sdc-questionnaire-templateExtractValue/-Context FHIRPath expressions that read a Hepatitis C QuestionnaireResponse. Used by scripts/extract-hepatitisc.sh; not a normal example."
* type = #document
* identifier.system = "urn:ietf:rfc:3986"
* identifier.value = "urn:uuid:2b4f6f16-4c8a-4a1c-9c0e-7a1f2d3b5c88"
// PLACEHOLDER DEFAULT — replaced at extraction. A document Bundle must have a timestamp value
// (bdl-10), so the template needs a real one to validate; this 1900 sentinel never survives.
* timestamp = "1900-01-01T00:00:00Z"
* timestamp.extension[+].url = $sdc-templateExtractValue
* timestamp.extension[=].valueString = "%resource.authored"
* entry[+].fullUrl = "http://test.fhir.ch/r4/Composition/ExtractedCompositionHepatitisC"
* entry[=].resource = ExtractedCompositionHepatitisC
* entry[+].fullUrl = "http://test.fhir.ch/r4/Patient/ExtractedPatient"
* entry[=].resource = ExtractedPatient
* entry[+].fullUrl = "http://test.fhir.ch/r4/Condition/ExtractedConditionHepatitisC"
* entry[=].resource = ExtractedConditionHepatitisC
* entry[+].fullUrl = "http://test.fhir.ch/r4/Observation/ExtractedExposureHepatitisC"
* entry[=].resource = ExtractedExposureHepatitisC
* entry[+].fullUrl = "http://test.fhir.ch/r4/PractitionerRole/ExtractedTreatingPractitionerRole"
* entry[=].resource = ExtractedTreatingPractitionerRole
* entry[+].fullUrl = "http://test.fhir.ch/r4/Practitioner/ExtractedTreatingPractitioner"
* entry[=].resource = ExtractedTreatingPractitioner
* entry[+].fullUrl = "http://test.fhir.ch/r4/Organization/ExtractedTreatingOrganization"
* entry[=].resource = ExtractedTreatingOrganization

// --- CONDITIONAL ENTRIES, LAST ON PURPOSE -------------------------------------------------------
// The engine deletes a context-gated array element from the template and re-inserts it once per
// context result; a STATIC entry placed after a gated one is corrupted as soon as the gate does not
// fire. All conditional entries therefore sit at the end. See ChEkmDocumentMpoxTemplate.fsh for the
// full explanation, including why `fullUrl` needs an identity templateExtractValue.

// Hospitalisation Encounter — answered "no" (or unanswered) -> empty context -> no Encounter, and
// the two references to it (Composition.encounter, Condition.encounter) carry the same test, so
// they disappear with it.
* entry[+].extension[0].url = $sdc-templateExtractContext
* entry[=].extension[0].valueString = "iif(%resource.descendants().where(linkId='hospitalisationStatus').answer.value.ofType(Coding).where(system='http://snomed.info/sct' and (code='373066001' or code='261665006')).exists(), true, {})"
* entry[=].fullUrl = "http://test.fhir.ch/r4/Encounter/ExtractedEncounterHepatitisC"
// IDENTITY VALUE, AND IT IS LOAD-BEARING — see ChEkmDocumentMpoxTemplate.fsh.
* entry[=].fullUrl.extension[0].url = $sdc-templateExtractValue
* entry[=].fullUrl.extension[0].valueString = "'http://test.fhir.ch/r4/Encounter/ExtractedEncounterHepatitisC'"
* entry[=].resource = ExtractedEncounterHepatitisC

// Cause of death Observation — gated on "the person died AND a cause was answered", for all three
// answers ("unknown" is a value, issue #28).
* entry[+].extension[0].url = $sdc-templateExtractContext
* entry[=].extension[0].valueString = "iif(%resource.descendants().where(linkId='deceased').answer.value.first() = true and %resource.descendants().where(linkId='deathCause').answer.value.exists(), true, {})"
* entry[=].fullUrl = "http://test.fhir.ch/r4/Observation/ExtractedCauseOfDeathHepatitisC"
// IDENTITY VALUE, LOAD-BEARING — see above.
* entry[=].fullUrl.extension[0].url = $sdc-templateExtractValue
* entry[=].fullUrl.extension[0].valueString = "'http://test.fhir.ch/r4/Observation/ExtractedCauseOfDeathHepatitisC'"
* entry[=].resource = ExtractedCauseOfDeathHepatitisC
