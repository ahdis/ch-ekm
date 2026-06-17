Logical: ChEkmGonorrhoeaForm
Parent: Base
Title: "CH EKM Form: Gonorrhoea"
Description: "Logical model for the form ChEkmGonorrhoeaForm."
Characteristics: #can-be-target

* person 1..1 ChEkmGonorrhoeaPersonForm "Affected person"
* exposition 1..1 ChEkmGonorrhoeaExpositionForm "Exposition"
* manifestation 1..1 ChEkmGonorrhoeaManifestationForm "Diagnosis and manifestation"
* treatingPhysician 1..1 Base "Treating physician"
  * practitioner 1..1 ChEkmTreatingPhysicianPractitionerForm "Practitioner"
  * organization 1..1 ChEkmTreatingPhysicianOrganizationForm "Organization"

Logical: ChEkmGonorrhoeaPersonForm
Parent: ChEkmPersonForm
Title: "CH EKM Form: Gonorrhoea - Angaben zur betroffenen Person"
Description: "Logical model for the form section 'Angaben zur betroffenen Person' of the Gonorrhoea clinical findings report. One element per form item."
Characteristics: #can-be-target

* surnameInitial 1..1
* surname 0..0
* givennameInitial 1..1
* givenname 0..0
* dateOfBirth 1..1
* ahvn13 0..1
* nationality 0..1
* zipCode 0..1
* city 0..1
* country 0..1
* canton 0..1
* administrativeGender 1..1
* genderIdentity 0..1

Logical: ChEkmGonorrhoeaExpositionForm
Parent: ChEkmExpositionForm
Title: "CH EKM Form: Gonorrhoea - Exposition"
Description: "Logical model for the form section 'Exposition' of the Gonorrhoea clinical findings report. One element per form item."
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

Mapping: GonorrhoeaExpositionToExposure
Source: ChEkmGonorrhoeaExpositionForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-exposure-gonorrhoea"
Id: gonorrhoea-exposition-to-exposure
Title: "Exposition Form to CH EKM Exposure"
* -> "Observation" "Maps the form section to the ChEkmExposureGonorrhoea profile"
* transmission.sexualContactPartner -> "Observation.component[sexualContactPartner].valueCodeableConcept"
* transmission.relationshipType -> "Observation.component[relationshipType].valueCodeableConcept"
* transmission.unknown -> "Observation.component[transmissionRoute]" "unknown -> component[transmissionRoute].dataAbsentReason #unknown"
* transmission.otherTransmission -> "Observation.component[transmissionRoute].text" "other transmission route"

Logical: ChEkmGonorrhoeaManifestationForm
Parent: ChEkmManifestationForm
Title: "CH EKM Form: Gonorrhoea - Diagnosis and Manifestation"
Description: "Logical model for the form section 'Diagnosis and Manifestation' of the Gonorrhoea clinical findings report. One element per form item."

* manifestation ^short = "Manifestations (symptomatic / oral / genital / anal / systemic / none / unknown)"
