Logical: ChEkmPersonForm
Parent: Base
Title: "CH EKM Form: Affected Person"
Description: "Logical model for the form section 'Affected person' (German form: 'Angaben zur betroffenen Person'). One element per form item."
Characteristics: #can-be-target

* surnameInitial 0..1 string "Surname (initial)"
* surname 0..1 string "Surname"
* givennameInitial 0..1 string "Given name (initial)"
* givenname 0..1 string "Given name"
* dateOfBirth 1..1 date "Date of birth"
* ahvn13 0..1 string "OASI number (AHVN13 / NAVS13)"
* nationality 0..1 CodeableConcept "Nationality"
* nationality from ChEkmCountryCodes (required)
* zipCode 0..1 string "Zip code"
* city 0..1 string "City"
* country 0..1 CodeableConcept "Country"
* country from ChEkmCountryCodes (required)
* canton 0..1 string "Canton"
* administrativeGender 1..1 CodeableConcept "Administrative sex (female, male)"
* administrativeGender from http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmPatientAdministrativeSex (required)
* genderIdentity 0..1 CodeableConcept "Trans person (no, trans man, trans woman)"
* genderIdentity from ChEkmTransPerson (required)

Mapping: PersonToPatient
Source: ChEkmPersonForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-patient"
Id: person-to-patient
Title: "Person Form to CH EKM Patient"
* -> "Patient" "Maps the form section to the ChEkmPatient profile"
* surnameInitial -> "Patient.name.family" "Initial of the family name"
* surname -> "Patient.name.family" "Family name"
* givennameInitial -> "Patient.name.given" "Initial of the given name"
* givenname -> "Patient.name.given" "Given name"
* dateOfBirth -> "Patient.birthDate"
* ahvn13 -> "Patient.identifier[AHVN13].value" "OASI number Switzerland (system urn:oid:2.16.756.5.32)"
* nationality -> "Patient.extension[citizenship]" "Nationality via patient-citizenship extension"
* zipCode -> "Patient.address[home].postalCode" "Zip code"
* city -> "Patient.address[home].city" "City"
* country -> "Patient.address[home].country"
* canton -> "Patient.address[home].state" "Canton abbreviation"
* administrativeGender -> "Patient.gender" "Administrative gender"
* genderIdentity -> "Patient.extension[genderIdentity]" "Gender identity, for the answers trans man / trans woman; 'no' is a ChEkmObservationTransgenderStatus (see mapping person-to-observation-transgender-status)"

// The "Nein" answer of genderIdentity (issue #35): not a gender identity, so not on the Patient.
Mapping: PersonToObservationTransgenderStatus
Source: ChEkmPersonForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-observation-transgender-status"
Id: person-to-observation-transgender-status
Title: "Person Form to CH EKM Observation Transgender status"
* -> "Observation" "Only for the answer 'no' to genderIdentity"
* genderIdentity -> "Observation.value[x]" "The answer 'no' (sct#373067005); the answers trans man / trans woman are Patient.extension[genderIdentity]"
