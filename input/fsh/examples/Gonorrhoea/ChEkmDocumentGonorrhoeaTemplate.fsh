// ---------------------------------------------------------------------------
// Condition (ChEkmCondition) — fixed disease code; manifestation -> evidence.code;
// manifestation begin date -> onset (omitted when "unbekannt" is ticked)
// ---------------------------------------------------------------------------
Instance: ExtractedConditionGonorrhoea
InstanceOf: ChEkmConditionGonorrhoea
// Usage: #inline
* code = $sct#15628003 "Gonorrhea (disorder)"
* category = $condition-category#encounter-diagnosis
* subject.reference = "Patient/ExtractedPatient"
* recorder.reference = "PractitionerRole/ExtractedTreatingPractitionerRole"

* insert RuleSetOnsetDateManifestationBeginUnknown

* insert RuleSetEvidenceManifestation
* evidence[0].code[0].coding[0] = $sct#15628003 "Gonorrhea (disorder)"


// ---------------------------------------------------------------------------
// Exposure (ChEkmExposureGonorrhoea) — fixed component codes; sex & relationship from `transmission`
// ---------------------------------------------------------------------------
Instance: ExtractedExposureGonorrhoea
InstanceOf: ChEkmExposureGonorrhoea
// Usage: #inline
* status = #final
* category = $v3-ActClass#AEXPOS "acquisition exposure"
* code = $v3-ParticipationType#EXPAGNT "Exposure Agent"
* subject.reference = "Patient/ExtractedPatient"
* insert RuleSetComponentExposure
// ---------------------------------------------------------------------------
// Composition (ChEkmCompositionGonorrhoea) — static structure, references the entries above,
// author = Broker, date taken from QR.authored
// ---------------------------------------------------------------------------
Instance: ExtractedCompositionGonorrhoea
InstanceOf: ChEkmCompositionGonorrhoea
//Usage: #inline
* status = #final
* type = $sct#722143004 "Infectious disease diagnostic study note"
* category = $sct#423876004 "Clinical report"
* subject.reference = "Patient/ExtractedPatient"
* date.extension[+].url = $sdc-templateExtractValue
* date.extension[=].valueString = "%resource.authored"
* author.reference = "PractitionerRole/ExtractedTreatingPractitionerRole"
* title = "Meldung zum klinischen Befund Infektionskrankheit"
* section[0].title = "Diagnosis section"
* section[0].code = $loinc#29308-4
* section[0].entry.reference = "Condition/ExtractedConditionGonorrhoea"
* section[1].title = "Social history section"
* section[1].code = $loinc#29762-2
* section[1].entry.reference = "Observation/ExtractedExposureGonorrhoea"

// ---------------------------------------------------------------------------
// The Bundle template itself (ChEkmDocumentGonorrhoea shape)
// ---------------------------------------------------------------------------
Instance: ChEkmDocumentGonorrhoeaTemplate
InstanceOf: ChEkmDocumentGonorrhoea
Usage: #example
Title: "CH EKM $extract template: Gonorrhoea document Bundle"
Description: "SDC template-based extraction template. Shaped like ChEkmDocumentGonorrhoea; the per-report fields carry sdc-questionnaire-templateExtractValue/-Context FHIRPath expressions that read a Gonorrhoea QuestionnaireResponse. Used by tests/extract-gonorrhoea.sh; not a normal example."
// * meta.profile = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-document-gonorrhoea"
* type = #document
* identifier.system = "urn:ietf:rfc:3986"
* identifier.value = "urn:uuid:c376a38a-61b9-4a79-8722-12c75bacf927"
// PLACEHOLDER DEFAULT — replaced at extraction. A document Bundle must have a timestamp value
// (bdl-10: timestamp.hasValue()), so the template needs a real value to be valid; the
// templateExtractValue below overwrites it with the QuestionnaireResponse's authored time at
// extraction. This 1900 sentinel never survives a real extraction.
* timestamp = "1900-01-01T00:00:00Z"
* timestamp.extension[+].url = $sdc-templateExtractValue
* timestamp.extension[=].valueString = "%resource.authored"
* entry[+].fullUrl = "http://test.fhir.ch/r4/Composition/ExtractedCompositionGonorrhoea"
* entry[=].resource = ExtractedCompositionGonorrhoea
* entry[+].fullUrl = "http://test.fhir.ch/r4/Patient/ExtractedPatient"
* entry[=].resource = ExtractedPatient
* entry[+].fullUrl = "http://test.fhir.ch/r4/Condition/ExtractedConditionGonorrhoea"
* entry[=].resource = ExtractedConditionGonorrhoea
* entry[+].fullUrl = "http://test.fhir.ch/r4/Observation/ExtractedExposureGonorrhoea"
* entry[=].resource = ExtractedExposureGonorrhoea
* entry[+].fullUrl = "http://test.fhir.ch/r4/PractitionerRole/ExtractedTreatingPractitionerRole"
* entry[=].resource = ExtractedTreatingPractitionerRole
* entry[+].fullUrl = "http://test.fhir.ch/r4/Practitioner/ExtractedTreatingPractitioner"
* entry[=].resource = ExtractedTreatingPractitioner
* entry[+].fullUrl = "http://test.fhir.ch/r4/Organization/ExtractedTreatingOrganization"
* entry[=].resource = ExtractedTreatingOrganization