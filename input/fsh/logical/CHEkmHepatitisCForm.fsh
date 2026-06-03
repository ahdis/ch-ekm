Logical: ChEkmHepatitisCPersonForm
Parent: ChEkmPersonForm
Title: "CH EKM Form: HepatitisC - Angaben zur betroffenen Person"
Description: "Logical model for the form section 'Angaben zur betroffenen Person' of the HepatitisC clinical findings report. One element per form item."
Characteristics: #can-be-target

* surnameInitial 0..0
* surname 0..1
* givennameInitial 0..0
* givenname 0..1
* dateOfBirth 1..1
* nationality 0..1
* zipCode 0..1
* city 0..1
* country 0..1
* canton 0..1
* administrativeGender 1..1
* genderIdentity 0..1

Logical: ChEkmHepatitisCExpositionForm
Parent: ChEkmExpositionForm
Title: "CH EKM Form: HepatitisC - Exposition"
Description: "Logical model for the form section 'Exposition' of the HepatitisC clinical findings report. One element per form item."
Characteristics: #can-be-target

// Wo on the structured level we will not have inland/ausland as separate items (discussed June 1st)
* where 0..1
  * country 0..1
  * preciseLocation 0..1
  * unknown 0..1
// Wie (Übertragungsweg)
* transmission 0..1 Base "Transmission route"
  * sexualContactPartner 0..1 CodeableConcept "Sexual contact (female, male, other)" // proposed minimum set of options as of June 1st; to be further discussed, see // to verify that administrative gender is correctly captured here https://docs.google.com/spreadsheets/d/153rbSKx_zNKEO1dNm-AigvTit9cwy3HeVS8MCZTuC7g/edit?gid=509131979#gid=509131979
  * relationshipType 0..1 CodeableConcept "Type of relationship (anonymous partner / known partner / paid sex / unknown)"
  * otherTransmission 0..1 string "Other transmission route (free text)"
  * unknown 0..1 boolean "Unknown"

Mapping: HepatitisCExpositionToExposure
Source: ChEkmHepatitisCExpositionForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-exposure-hepatitisc"
Id: hepatitisc-exposition-to-exposure
Title: "Exposition Form to CH EKM Exposure"
* -> "Observation" "Maps the form section to the ChEkmExposureHepatitisC profile"
* transmission.sexualContactPartner -> "Observation.component[sexualContactPartner].valueCodeableConcept"
* transmission.relationshipType -> "Observation.component[relationshipType].valueCodeableConcept"
* transmission.unknown -> "Observation.component[transmissionRoute]" "unknown -> component[transmissionRoute].dataAbsentReason #unknown"
* transmission.otherTransmission -> "Observation.component[transmissionRoute].text" "other transmission route"
