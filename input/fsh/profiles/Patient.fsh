Profile: CHEkmHumanName
Parent: CHCoreHumanName
Id: ch-ekm-humanname
Title: "Human Name"
Description: "Name with extensions for data-absent-reason"
* extension ^slicing.discriminator.type = #value
* extension ^slicing.discriminator.path = "url"
* extension ^slicing.rules = #open
* extension contains ChEkmExtHivCode named hivcode 0..1
* family.extension contains $data-absent-reason named dataabsentreason 0..1
* given.extension contains $data-absent-reason named dataabsentreason 0..1


Profile: ChEkmPatient
Parent: CHCorePatient
Id: ch-ekm-patient
Title: "CH EKM Patient"
Description: "This CH EKM base profile constrains the Patient resource for the purpose of Clinical Findings of Communicable Infectious Diseases Reports."
* extension ^slicing.discriminator[0].type = #value
* extension ^slicing.discriminator[0].path = "url"
* extension ^slicing.discriminator[1].type = #profile
* extension ^slicing.discriminator[1].path = "$this"
* extension ^slicing.rules = #open

* extension[placeOfBirth] ..1  
* extension[citizenship] ..1 MS 
* extension contains $individual-genderIdentity named genderIdentity 0..1 
* extension[genderIdentity].extension[value].valueCodeableConcept from $gender-identity (required)
* extension contains $individual-recordedSexOrGender named biologicalSexAtBirth 0..1 
* extension[biologicalSexAtBirth].extension[type].valueCodeableConcept = $loinc#76689-9 "Sex Assigned At Birth"
* extension[biologicalSexAtBirth].extension[value].valueCodeableConcept from $biological-sex (required)
* extension contains $individual-recordedSexOrGender named biologicalSex 0..1 
* extension[biologicalSex].extension[type].valueCodeableConcept = $loinc#46098-0 "Sex"
* identifier MS
* identifier[AHVN13] ..1 MS
* identifier[AHVN13] ^short = "OASI Number Switzerland"
* identifier[EPR-SPID] 0..0
* identifier[insuranceCardNumber] 0..0
* name 1..1
* name only CHEkmHumanName
* name ^short = "Whether the personal data is transmitted by using initials or full name is described under 'Guidance - Personal Data (Patient Name)'"
* name.family 1..
* name.given 1..1
* gender 1..
* gender ^short = "Administrative gender" 
* birthDate 1..
* birthDate.extension contains $data-absent-reason named dataabsentreason 0..1
* address ..1 MS
* address ^slicing.discriminator[0].type = #value
* address ^slicing.discriminator[=].path = "use"
* address ^slicing.rules = #open
* address contains home ..1 MS
* address[home] ^short = "Residential address"
* address[home].use 1..
* address[home].use = #home
* address[home].line ..1 MS
* address[home].postalCode MS
* address[home].city MS
* address[home].state MS 
* address[home].state ^short = "sub-unit of country. canton-abbreviation is expected for a Swiss or Liechtenstein address." // kein Binding notwendig: constraint ch-addr-2 = For a Swiss address, a canton abbreviation from the value set 'eCH-0007 Canton Abbreviation' must be used.
* address[home].country MS
* address[home].country.extension[countrycode] 1.. 
* address[home].country.extension[countrycode].valueCoding from $bfs-country-codes (required)
* telecom[phone] ..1 MS



Profile: ChEkmPatientInitials
Parent: ChEkmPatient
Id: ch-ekm-patient-initials
Title: "CH Ekm Patient Initials"
Description: "Patient representation via Initials"
* name obeys name-initials
* extension[genderIdentity] 0..0
* extension[biologicalSexAtBirth] 0..0
* extension[biologicalSex] 0..0
* address[home].line ..0
* telecom ..0


Profile: ChEkmPatientHIV
Parent: ChEkmPatient
Title: "CH EKM Patient HIV"
Description: "Patient representation for HIV"
* . ^short = "CH EKM Patient HIV"
* extension[genderIdentity] 0..0
* extension[biologicalSexAtBirth] 0..0
* extension[biologicalSex] 0..0
* name.extension[hivcode] 1..
* name.family.extension[dataabsentreason] 1..
* name.family.extension[dataabsentreason].valueCode = #masked
* name.given.extension[dataabsentreason] 1..
* name.given.extension[dataabsentreason].valueCode = #masked
* address[home].line ..0
* telecom ..0

Profile: ChEkmPatientVCT
Parent: ChEkmPatient
Title: "CH EKM Patient VCT"
Description: "Patient representation via a VCT Code"
* . ^short = "CH EKM Patient VCT"
* identifier[AHVN13] 0..0
* extension[genderIdentity] 0..0
* extension[biologicalSexAtBirth] 0..0
* extension[biologicalSex] 0..0
* identifier[LocalPid] 1..1
* identifier[LocalPid] only VCTIdentifier
* identifier[LocalPid] ^short = "VCT identifier"
* identifier[LocalPid] ^patternIdentifier.system = "http://fhir.ch/ig/ch-ekm/identifier/vct"
* name.family.extension[dataabsentreason] 1..
* name.family.extension[dataabsentreason].valueCode = #masked
* name.given.extension[dataabsentreason] 1..
* name.given.extension[dataabsentreason].valueCode = #masked
* address[home].line ..0
* telecom ..0


