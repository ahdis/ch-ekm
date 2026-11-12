Profile: ChEkmDocumentMpox
Parent: ChEkmDocument
Id: ch-ekm-document-mpox
Title: "CH EKM-Document: Clinical findings Mpox"
Description: "This profile constrains the Bundle resource for the purpose of clinical findings for Mpox"
* entry[Composition].resource only ChEkmCompositionMpox

Profile: ChEkmCompositionMpox
Parent: ChEkmComposition
Id: ch-ekm-composition-mpox
Title: "CH EKM Composition: Clinical Findings Mpox"
Description: "This CH EKM base profile constrains the Composition resource for the purpose of clinical findings for Mpox"
* subject only Reference(ChEkmPatient)
* section[diagnosis].entry[condition] only Reference(ChEkmConditionMpox)
// The answers to the form questions without a FHIR target (today the close contact after the onset
// of the manifestation, issue #43). Although that question is asked in the Exposition section, the
// response sits in the SAME slot as for Hepatitis C: a document carries ONE disease-specific response,
// holding the disease-specific questions of every section, so a consumer always finds it in
// section[diagnosis]. Optional, as the question is: 0..1 from the base ChEkmComposition.
* section[diagnosis].entry[questionnaire-response] only Reference(ChEkmQuestionnaireResponseDiseaseSpecificMpox)
* section[social-history].entry[exposure-to-infectious-disease] only Reference(ChEkmExposureMpox)
* section[immunization].entry[immunization] only Reference(ChEkmImmunizationMpox)
* section[immunization].entry[vaccination-status] only Reference(ChEkmObservationVaccinationStatusMpox)

Profile: ChEkmConditionMpox
Parent: ChEkmCondition
Id: ch-ekm-condition-mpox
Title: "CH EKM Condition: Mpox"
Description: "This CH EKM base profile constrains the Condition resource for the purpose of clinical findings for Mpox"
* code = $sct#359814004 "Mpox"
* evidence.code from ChEkmMpoxManifestation (required)

Profile: ChEkmExposureMpox
Parent: ChEkmExposure
Id: ch-ekm-exposure-mpox
Title: "CH EKM Exposure: Mpox"
Description: "TODO: This CH EKM base profile constrains the Exposure observation for the purpose of clinical findings for Mpox, adding the transmission route, the sex of the infected sexual contact partner, the type of relationship, the other routes of transmission through contact (as medical / nursing staff, in the household) and the contact with a laboratory-confirmed mpox case (Wie / Übertragungsweg)."
* component ^slicing.discriminator.type = #pattern
* component ^slicing.discriminator.path = "code"
* component ^slicing.rules = #open
* component contains
    transmissionRoute 0..1 MS and
    sexualContactPartner 0..1 MS and
    relationshipType 0..1 MS and
    otherTransmission 0..1 MS

// Wie - transmission route
* component[transmissionRoute].code = $sct#409496000 "Mode of transmission (observable entity)"
* component[transmissionRoute].value[x] only CodeableConcept
* component[transmissionRoute].valueCodeableConcept from ChEkmExposureTransmissionRoute (required)

// Wie - sex/gender of the infected sexual contact partner
* component[sexualContactPartner].code = ChEkmExposureComponent#sexual-contact-partner
* component[sexualContactPartner].value[x] only CodeableConcept
* component[sexualContactPartner].valueCodeableConcept from ChEkmExposureSexualContactPartner (required)

// Anderer Übertragungsweg - other transmission route (free text)
* component[otherTransmission].code =  $sct#74964007 "Other (qualifier value)"
* component[otherTransmission].value[x] only string

// Art der Beziehung - type of relationship to the sexual contact partner
* component[relationshipType].code = $sct#228465009 "Sexual relationship details (observable entity)"
* component[relationshipType].value[x] only CodeableConcept
* component[relationshipType].valueCodeableConcept from ChEkmExposureRelationshipType (required)

// The contact questions of the Mpox "Wie" (issue #44) — sliced on the base ChEkmExposure, asked by
// the Mpox form, hence MustSupport here.
* component[contactRoute] MS
* component[confirmedCaseContact] MS
// Impfstatus (https://github.com/ahdis/ch-ekm/issues/29). The Mpox form asks about TWO
// vaccination types, so this profile does two things the base ChEkmImmunization cannot: it fixes
// which target diseases may appear, and it constrains the fallback product code to the SNOMED CT
// vaccine products for those two — the concepts extraction writes when the physician did not pick
// a brand from the Swiss vaccine list.
//
// Both fallbacks are in the CH VACD SNOMED CT vaccine value set:
//   Pockenimpfung      sct#1290624003 Vaccine product containing Variola virus antigen
//   Affenpockenimpfung sct#1293025000 Vaccine product containing only modified Vaccinia virus
//                                     Ankara antigen  (MVA-BN, i.e. Jynneos / Imvanex)
// Note that MVA-BN is licensed against BOTH smallpox and mpox; it is `targetDisease`, not the
// product, that separates the two form rows.
Profile: ChEkmImmunizationMpox
Parent: ChEkmImmunization
Id: ch-ekm-immunization-mpox
Title: "CH EKM Immunization: Mpox"
Description: "This CH EKM profile constrains the Immunization resource for the 'Impfstatus' section of the Mpox report: one resource per vaccination type asked about (smallpox vaccination, mpox vaccination)."
* protocolApplied.targetDisease from ChEkmMpoxImmunizationTargetDisease (required)

// The "no" / "unknown" counterpart of ChEkmImmunizationMpox: same two form rows, same two
// vaccine products, same two target diseases — only the answer differs, and with it the resource
// type. Fixing both ends of the component keeps the two halves of one form line consistent:
//   Pockenimpfung       component.code  sct#1290624003 Variola virus antigen-containing vaccine
//                       component.value sct#67924001   Smallpox
//   Affenpockenimpfung  component.code  sct#1293025000 modified Vaccinia virus Ankara (MVA-BN)
//                       component.value sct#359814004  Mpox
// The same product / target disease pair the "yes" row puts in Immunization.vaccineCode and
// Immunization.protocolApplied.targetDisease, so both halves answer "which vaccination?" the same
// way. MVA-BN is licensed against BOTH smallpox and mpox; it is the target disease, not the
// product, that separates the two rows.
Profile: ChEkmObservationVaccinationStatusMpox
Parent: ChEkmObservationVaccinationStatus
Id: ch-ekm-observation-vaccination-status-mpox
Title: "CH EKM Observation: Vaccination status Mpox"
Description: "This CH EKM profile constrains the Observation resource for the 'no' and 'unknown' answers of the 'Impfstatus' (vaccination status) section of the Mpox report: one resource per vaccination type asked about (smallpox vaccination, mpox vaccination) that the person did not receive or where it is not known."
* component.code from ChEkmMpoxVaccineProduct (required)
* component.valueCodeableConcept from ChEkmMpoxImmunizationTargetDisease (required)

// The QuestionnaireResponse the Mpox document carries: the answers to the form questions that have no
// FHIR target, and ONLY those — the response to the disease-specific questionnaire
// ChEkmQuestionnaireMpoxDiseaseSpecificAssembled. Same construction as
// ChEkmQuestionnaireResponseDiseaseSpecificHepatitisC (read its comment): `questionnaire` stays 0..1
// and unfixed, and the invariant is guarded on `questionnaire.hasValue()`, because the $extract
// template has to conform to this profile while it names no questionnaire yet. No answer is required:
// the question is optional on the form, and a report that leaves it empty carries no response.
Profile: ChEkmQuestionnaireResponseDiseaseSpecificMpox
Parent: QuestionnaireResponse
Id: ch-ekm-questionnaireresponse-mpox-diseasespecific
Title: "CH EKM Questionnaire Response: Disease-specific questions - Mpox"
Description: "This CH EKM base profile constrains the QuestionnaireResponse resource carried in the Mpox document: the answers to the form questions that have no FHIR target (close contact with other persons after the onset of the manifestation, with a remark). It is the response to the disease-specific questionnaire ChEkmQuestionnaireMpoxDiseaseSpecificAssembled, or to its language variant matching the form that was filled in. It is carried in the document only when one of these questions was answered."
* obeys ch-ekm-qr-mpox-questionnaire
* questionnaire ^short = "The disease-specific Mpox questionnaire this is a response to (ChEkmQuestionnaireMpoxDiseaseSpecificAssembled or its -de-CH / -fr-CH / -it-CH variant, as the form that was filled in). Present on every real response; absent only in the $extract template."
* status ^short = "A response carried in a final document is expected to be 'completed'"
