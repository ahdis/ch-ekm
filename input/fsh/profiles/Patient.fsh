Profile: ChEkmPatient
Parent: CHCorePatient
Id: ch-ekm-patient
Title: "CH EKM Patient"
Description: "This CH EKM base profile constrains the Patient resource for the purpose of Clinical Findings of Communicable Infectious Diseases Reports."

* extension[citizenship] ..1 MS 
* extension[placeOfBirth] ..1  
* extension contains $individual-genderIdentity named genderIdentity 0..1 MS
* extension[genderIdentity].extension[value].valueCodeableConcept from $gender-identity (required)
* extension contains $individual-recordedSexOrGender named biologicalSexAtBirth ..1 
* extension[biologicalSexAtBirth].extension[type].valueCodeableConcept = $loinc#76689-9 "Sex Assigned At Birth"
* extension[biologicalSexAtBirth].extension[value].valueCodeableConcept from $biological-sex (required)
* extension contains $individual-recordedSexOrGender named biologicalSex ..1 
* extension[biologicalSex].extension[type].valueCodeableConcept = $loinc#46098-0 "Sex"
* extension[biologicalSex].extension[value].valueCodeableConcept from $biological-sex (required)
* identifier ..1 MS
* identifier[AHVN13] ..1 MS
* identifier[AHVN13] ^short = "OASI Number Switzerland"
* name 1..1
* name ^short = "Whether the personal data is transmitted by using initials or full name is described under 'Guidance - Personal Data (Patient Name)'"
* name.family 1..
* name.given 1..1
* gender 1..
* gender ^short = "Administrative gender" 
* obeys ch-ekm-gender-sync
* birthDate 1..
* birthDate obeys ch-ekm-dateTime
* address ..1 MS
* address ^slicing.discriminator[0].type = #value
* address ^slicing.discriminator[=].path = "use"
* address ^slicing.rules = #open
* address contains home ..1 MS
* address[home] ^short = "Residential address"
* address[home].use 1..
* address[home].use = #home
* address[home].line ..1 
* address[home].line.extension[streetName].valueString ..1 
* address[home].line.extension[houseNumber].valueString ..1 
* address[home].postalCode MS
* address[home].city MS
* address[home].state MS 
* address[home].state ^short = "sub-unit of country. canton-abbreviation is expected for a Swiss or Liechtenstein address." // kein Binding notwendig: constraint ch-addr-2 = For a Swiss address, a canton abbreviation from the value set 'eCH-0007 Canton Abbreviation' must be used.
* address[home].country MS
* address[home].country.extension[countrycode] 1.. 
* address[home].country.extension[countrycode].valueCoding from $bfs-country-codes (required)
* telecom[phone] ..1


Profile: ChEkmPatientInitials
Parent: ChEkmPatient
Id: ch-ekm-patient-initials
Title: "CH Ekm Patient Initials"
Description: "Patient representation via Initials"
* name obeys name-initials
* address[home].line ..0
* telecom ..0

