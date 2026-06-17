Logical: ChEkmPersonForm
Parent: Base
Title: "CH EKM Form: Angaben zur betroffenen Person"
Description: "Logical model for the form section 'Angaben zur betroffenen Person' One element per form item."
Characteristics: #can-be-target

* surnameInitial 0..1 string "Surname (initial)"
* surname 0..1 string "Surname"
* givennameInitial 0..1 string "Given name (initial)"
* givenname 0..1 string "Given name"
* dateOfBirth 1..1 date "Date of birth"
* nationality 0..1 CodeableConcept "Nationality"
* nationality from ChEkmCountryCodes (required)
* zipCode 0..1 string "Zip code"
* city 0..1 string "City"
* country 0..1 CodeableConcept "Country"
* country from ChEkmCountryCodes (required)
* canton 0..1 string "Canton"
* administrativeGender 1..1 CodeableConcept "Gender (male, female, other)"
* administrativeGender from http://hl7.org/fhir/ValueSet/administrative-gender (required)
* genderIdentity 0..1 CodeableConcept "Gender identity (affiliation with the transgender community)"
* genderIdentity from ChEkmGenderIdentity (required)

Mapping: PersonToPatient
Source: ChEkmPersonForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-patient"
Id: person-to-patient
Title: "Person Form to CH EKM Patient Initials"
* -> "Patient" "Maps the form section to the ChEkmPatientInitials profile"
* surnameInitial -> "Patient.name.family" "Initial of the family name"
* surname -> "Patient.name.family" "Family name"
* givennameInitial -> "Patient.name.given" "Initial of the given name"
* givenname -> "Patient.name.given" "Given name"
* dateOfBirth -> "Patient.birthDate"
* nationality -> "Patient.extension[citizenship]" "Nationality via patient-citizenship extension"
* zipCode -> "Patient.address[home].postalCode" "Zip code"
* city -> "Patient.address[home].city" "City"
* country -> "Patient.address[home].country"
* canton -> "Patient.address[home].state" "Canton abbreviation"
* administrativeGender -> "Patient.gender" "Administrative gender"
* genderIdentity -> "Patient.extension[genderIdentity]" "Gender identity"
