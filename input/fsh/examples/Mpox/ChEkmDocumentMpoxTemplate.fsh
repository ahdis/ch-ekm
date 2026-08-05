// ---------------------------------------------------------------------------
// Condition (ChEkmCondition) — fixed disease code; manifestation -> evidence.code;
// manifestation begin date -> onset (omitted when "unbekannt" is ticked)
// ---------------------------------------------------------------------------
Instance: ExtractedConditionMpox
InstanceOf: ChEkmConditionMpox
// Usage: #inline
// code already fixed by the profile (ChEkmConditionMpox) to Mpox (disorder)
* category = $condition-category#encounter-diagnosis
* subject.reference = "Patient/ExtractedPatient"
* recorder.reference = "PractitionerRole/ExtractedTreatingPractitionerRole"
* insert RuleSetOnsetDateManifestationBeginUnknown
* insert RuleSetEvidenceManifestation
* evidence[0].code[0].coding[0] = $sct#95324001 "Skin lesion (disorder)"

// ---------------------------------------------------------------------------
// Exposure (ChEkmExposureMpox) — fixed component codes; sex & relationship from `transmission`
// ---------------------------------------------------------------------------
Instance: ExtractedExposureMpox
InstanceOf: ChEkmExposureMpox
// Usage: #inline
* status = #final
* category = $v3-ActClass#AEXPOS "acquisition exposure"
* code = $v3-ParticipationType#EXPAGNT "Exposure Agent"
* subject.reference = "Patient/ExtractedPatient"
* insert RuleSetComponentExposure

// ---------------------------------------------------------------------------
// Composition (ChEkmCompositionMpox) — static structure, references the entries above,
// author = Broker, date taken from QR.authored
// ---------------------------------------------------------------------------
Instance: ExtractedCompositionMpox
InstanceOf: ChEkmCompositionMpox
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
* section[0].entry.reference = "Condition/ExtractedConditionMpox"
* section[1].title = "Social history section"
* section[1].code = $loinc#29762-2
* section[1].entry.reference = "Observation/ExtractedExposureMpox"

// ---------------------------------------------------------------------------
// The Bundle template itself (ChEkmDocumentMpox shape)
// ---------------------------------------------------------------------------
Instance: ChEkmDocumentMpoxTemplate
InstanceOf: ChEkmDocumentMpox
Usage: #example
Title: "CH EKM $extract template: Mpox document Bundle"
Description: "SDC template-based extraction template. Shaped like ChEkmDocumentMpox; the per-report fields carry sdc-questionnaire-templateExtractValue/-Context FHIRPath expressions that read a Mpox QuestionnaireResponse. Used by tests/extract-gonorrhoea.sh; not a normal example."
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
* entry[+].fullUrl = "http://test.fhir.ch/r4/Composition/ExtractedCompositionMpox"
* entry[=].resource = ExtractedCompositionMpox
* entry[+].fullUrl = "http://test.fhir.ch/r4/Patient/ExtractedPatient"
* entry[=].resource = ExtractedPatient
* entry[+].fullUrl = "http://test.fhir.ch/r4/Condition/ExtractedConditionMpox"
* entry[=].resource = ExtractedConditionMpox
* entry[+].fullUrl = "http://test.fhir.ch/r4/Observation/ExtractedExposureMpox"
* entry[=].resource = ExtractedExposureMpox
* entry[+].fullUrl = "http://test.fhir.ch/r4/PractitionerRole/ExtractedTreatingPractitionerRole"
* entry[=].resource = ExtractedTreatingPractitionerRole
* entry[+].fullUrl = "http://test.fhir.ch/r4/Practitioner/ExtractedTreatingPractitioner"
* entry[=].resource = ExtractedTreatingPractitioner
* entry[+].fullUrl = "http://test.fhir.ch/r4/Organization/ExtractedTreatingOrganization"
* entry[=].resource = ExtractedTreatingOrganization