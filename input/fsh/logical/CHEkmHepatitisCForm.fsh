Logical: ChEkmHepatitisCPersonForm
Parent: ChEkmPersonForm
Id: ch-ekm-hepatitisc-person-form
Title: "CH EKM Form: HepatitisC - Angaben zur betroffenen Person"
Description: "Logical model for the form section 'Angaben zur betroffenen Person' of the HepatitisC clinical findings report. One element per form item."
Characteristics: #can-be-target

* initialName 0..0
* Name 0..1
* initialFirstName 0..0 
* FirstName 0..1 
* birthDate 1..1 
* nationality 0..1
* postalCodeResidence 0..1 
* country 0..1 
* canton 0..1 
* administrativeGender 1..1
* genderIdentity 0..1 

Logical: ChEkmHepatitisCExpositionForm
Parent: ChEkmExpositionForm
Id: ch-ekm-hepatitisc-exposition-form
Title: "CH EKM Form: HepatitisC - Exposition"
Description: "Logical model for the form section 'Exposition' of the HepatitisC clinical findings report. One element per form item."
Characteristics: #can-be-target

// Wo on the structured level we will not have inland/ausland as separate items (discussed June 1st)
* where 0..1
  * country 0..1 
  * preciseLocation 0..1
  * unknown 0..1

// Wie (Übertragungsweg)
* transmission 0..1 Base "Wie (Übertragungsweg)"
  * sexualContactPartner 0..1 CodeableConcept "Sexualkontakt (Frau, Mann, anderes)" // proposed minimum set of options as of June 1st; to be further discussed, see // to verify that administrative gender is correctly captures here https://docs.google.com/spreadsheets/d/153rbSKx_zNKEO1dNm-AigvTit9cwy3HeVS8MCZTuC7g/edit?gid=509131979#gid=509131979
  * relationshipType 0..1 CodeableConcept "Art der Beziehung (anonymer Partner / bekannter Partner / bezahlter Sex / unbekannt)"
  * otherTransmission 0..1 string "anderer Übertragungsweg (Freitext)"
  * unknown 0..1 boolean "unbekannt"

Mapping: HepatitisCExpositionToExposure
Source: ChEkmHepatitisCExpositionForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-exposure-hepatitisc"
Id: hepatitisc-exposition-to-exposure
Title: "Exposition Form to CH EKM Exposure"
* -> "Observation" "Maps the form section to the ChEkmExposureHepatitisC profile"
* transmission.sexualContactPartner -> "Observation.component[sexualContactPartner].valueCodeableConcept"
* transmission.relationshipType -> "Observation.component[relationshipType].valueCodeableConcept"
* transmission.unknown -> "Observation.component[transmissionRoute]" "unbekannt -> component[transmissionRoute].dataAbsentReason #unknown"
* transmission.otherTransmission -> "Observation.component[transmissionRoute].text" "anderer Übertragungsweg"

