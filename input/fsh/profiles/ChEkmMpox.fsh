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
* section[social-history].entry[exposure-to-infectious-disease] only Reference(ChEkmExposureMpox)

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
Description: "TODO: This CH EKM base profile constrains the Exposure observation for the purpose of clinical findings for Mpox, adding the transmission route, the sex of the infected sexual contact partner and the type of relationship (Wie / Übertragungsweg)."
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
* component[sexualContactPartner].valueCodeableConcept from http://hl7.org/fhir/ValueSet/administrative-gender (required)

// Anderer Übertragungsweg - other transmission route (free text)
* component[otherTransmission].code =  $sct#74964007 "Other (qualifier value)"
* component[otherTransmission].value[x] only string

// Art der Beziehung - type of relationship to the sexual contact partner
* component[relationshipType].code = $sct#228465009 "Sexual relationship details (observable entity)"
* component[relationshipType].value[x] only CodeableConcept
* component[relationshipType].valueCodeableConcept from ChEkmExposureRelationshipType (required)