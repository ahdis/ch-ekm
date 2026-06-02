Logical: ChEkmGonorrhoeaPersonForm
Parent: ChEkmPersonForm
Id: ch-ekm-gonorrhoea-person-form
Title: "CH EKM Form: Gonorrhoea - Angaben zur betroffenen Person"
Description: "Logical model for the form section 'Angaben zur betroffenen Person' of the Gonorrhoea clinical findings report. One element per form item."
Characteristics: #can-be-target

* initialName 0..1
* Name 0..0 
* initialFirstName 0..1 
* FirstName 0..0 
* birthDate 0..1 
* nationality 0..1
* postalCodeResidence 0..1 
* country 0..1 
* canton 0..1 
* gender 0..1 
// * genderAndIdentity 0..1 string "w (female): female, m (male), trans (MtF): assigned male at birth, with a female or non-binary gender identity, trans (FtM): assigned female at birth, with a male or non-binary gender identity , VGE: variation of sex development (intersex), anderes (other)"
// to verify that administrative gender is correctly captures here https://docs.google.com/spreadsheets/d/153rbSKx_zNKEO1dNm-AigvTit9cwy3HeVS8MCZTuC7g/edit?gid=509131979#gid=509131979
* pregnancy 0..1 
* pregnancy ^short = "open issue"

Logical: ChEkmGonorrhoeaExpositionForm
Parent: ChEkmExpositionForm
Id: ch-ekm-gonorrhoea-exposition-form
Title: "CH EKM Form: Gonorrhoea - Exposition"
Description: "Logical model for the form section 'Exposition' of the Gonorrhoea clinical findings report. One element per form item."
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

Mapping: GonorrhoeaExpositionToExposure
Source: ChEkmGonorrhoeaExpositionForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-exposure-gonorrhoea"
Id: gonorrhoea-exposition-to-exposure
Title: "Exposition Form to CH EKM Exposure"
* -> "Observation" "Maps the form section to the ChEkmExposureGonorrhoea profile"
* transmission -> "Observation.component[transmissionRoute]" "Wie (Übertragungsweg)"
* transmission.sexualContactPartner -> "Observation.component[sexualContactPartner].valueCodeableConcept"
* transmission.relationshipType -> "Observation.component[relationshipType].valueCodeableConcept"
* transmission.unknown -> "Observation.component[transmissionRoute]" "unbekannt -> component[transmissionRoute].dataAbsentReason #unknown"
* transmission.otherTransmission -> "Observation.component[otherTransmission].text" "anderer Übertragungsweg"

