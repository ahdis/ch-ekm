Logical: ChEkmPersonForm
Parent: Base
Id: ch-ekm-person-form
Title: "CH EKM Form: Angaben zur betroffenen Person"
Description: "Logical model for the form section 'Angaben zur betroffenen Person' One element per form item."
Characteristics: #can-be-target

* initialName 0..1 string "Initiale Name"
* Name 0..1 string "Name"
* initialFirstName 0..1 string "Initiale Vorname"
* FirstName 0..1 string "Vorname"
* birthDate 1..1 date "Geburtsdatum"
* nationality 0..1 CodeableConcept "Nationalität"
* nationality from $bfs-country-codes (required)
* postalCodeResidence 0..1 string "PLZ/Wohnort"
* country 0..1 CodeableConcept "Land"
* country from $bfs-country-codes (required)
* canton 0..1 string "Kanton"
* administrativeGender 1..1 CodeableConcept "Gender (Mann, Frau, anderes)"
* administrativeGender from http://hl7.org/fhir/ValueSet/administrative-gender (required)
* genderIdentity 0..1 CodeableConcept "Zugehörigkeit zur Transgender-Community"
* genderIdentity from ChEkmGenderIdentity (required)

Mapping: PersonToPatient
Source: ChEkmPersonForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-patient"
Id: person-to-patient
Title: "Person Form to CH EKM Patient Initials"
* -> "Patient" "Maps the form section to the ChEkmPatientInitials profile"
* initialName -> "Patient.name.family" "Initial of the family name"
* Name -> "Patient.name.family" "Initial of the family name"
* initialFirstName -> "Patient.name.given" "Initial of the given name"
* FirstName -> "Patient.name.given" "Given name"
* birthDate -> "Patient.birthDate"
* nationality -> "Patient.extension[citizenship]" "Nationality via patient-citizenship extension"
* postalCodeResidence -> "Patient.address[home].postalCode" "PLZ; the 'Wohnort' part maps to Patient.address[home].city"
* country -> "Patient.address[home].country"
* canton -> "Patient.address[home].state" "Canton abbreviation"
* administrativeGender -> "Patient.gender" "Administrative gender"
* genderIdentity -> "Patient.extension[genderIdentity]" "Gender identity"