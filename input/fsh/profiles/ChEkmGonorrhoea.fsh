Profile: ChEkmDocumentGonorrhoea
Parent: ChEkmDocument
Title: "CH EKM-Document: Clinical findings Gonorrhoea"
Description: "This profile constrains the Bundle resource for the purpose of clinical findings for Gonorrhoea"
* entry[Composition].resource only ChEkmCompositionGonorrhoea

Profile: ChEkmCompositionGonorrhoea
Parent: ChEkmComposition
Title: "CH EKM Composition: Clinical Findings Gonorrhoea"
Description: "This CH EKM base profile constrains the Composition resource for the purpose of clinical findings for Gonorrhoea"
* subject only Reference(ChEkmPatientInitials)
* section[diagnosis].entry[condition] only Reference(ChEkmConditionGonorrhoea)
* section[social-history].entry[exposure-to-infectious-disease] only Reference(ChEkmExposureGonorrhoea)

Profile: ChEkmConditionGonorrhoea
Parent: ChEkmCondition
Title: "CH EKM Condition: Gonorrhoea"
Description: "This CH EKM base profile constrains the Condition resource for the purpose of clinical findings for Gonorrhoea"
* code = $sct#15628003 "Gonorrhea (disorder)"
* evidence.code from ChEkmGonorrhoeaManifestation (required)

Profile: ChEkmExposureGonorrhoea
Parent: ChEkmExposure
Id: ch-ekm-exposure-gonorrhoea
Title: "CH EKM Exposure: Gonorrhoea"
Description: "This CH EKM base profile constrains the Exposure observation for the purpose of clinical findings for Gonorrhoea, adding the transmission route, the sex of the infected sexual contact partner and the type of relationship (Wie / Übertragungsweg)."
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