Profile: ChEkmPatient
Parent: Patient
Id: ch-ekm-patient
Title: "CH EKM Patient"
Description: "This CH EKM base profile constrains the Patient resource for the purpose of ..."
* . ^short = "CH EKM Patient"

* identifier ..1 MS
* identifier[AHVN13] ..1 MS
* identifier[AHVN13] ^short = "OASI Number Switzerland"

* name 1..1
* name ^short = "Whether the personal data is transmitted by using initials, full name or a special combination is described under 'Guidance - Personal Data (Patient Name)'"
* name.family 1..
//* name.family ^short = "masked when using HIV/VCT-extensions (see IG guidance)."
//* name.given ^maxLength = 100
* name.given 1..1
//* name.given ^short = "masked when using HIV/VCT-extensions (see IG guidance)."
//* name.given ^maxLength = 100

* gender 1..

* birthDate 1..
* birthDate obeys ch-elm-dateTime


* address ..1 MS
* address ^slicing.discriminator[0].type = #value
* address ^slicing.discriminator[=].path = "use"
* address ^slicing.rules = #open
* address contains home ..1 MS
* address[home] ^short = "Residential address"
* address[home].use 1..
* address[home].use = #home
* address[home].line ..1
* address[home].line.extension[streetName].valueString ^maxLength = 100
* address[home].line.extension[houseNumber].valueString ^maxLength = 10
* address[home].postalCode MS
* address[home].postalCode ^maxLength = 10
* address[home].city MS
* address[home].city ^maxLength = 50
* address[home].state MS 
* address[home].state ^short = "sub-unit of country. canton-abbreviation is expected for a Swiss or Liechtenstein address." // kein Binding notwendig: constraint ch-addr-2 = For a Swiss address, a canton abbreviation from the value set 'eCH-0007 Canton Abbreviation' must be used.
* address[home].country MS
* address[home].country.extension contains $country-deprecated named country-deprecated 0..1
// * address[home].country.extension[countrycode] 1.. // we have to support the deprecated extension for backwards compatibility too
* address[home].country.extension[countrycode].valueCoding from $bfs-country-codes (required)


Profile: ChElmPatientHIV
Parent: ChElmPatient
Title: "CH ELM Patient HIV"
Description: "Patient representation for HIV"
* . ^short = "CH ELM Patient HIV"
* name.extension[vctcode] ..0 
* name.extension[hivcode] 1..
* name.family.extension[dataabsentreason] 1..
* name.family.extension[dataabsentreason].valueCode = #masked
* name.given.extension[dataabsentreason] 1..
* name.given.extension[dataabsentreason].valueCode = #masked
* address[home].line ..0
* telecom ..0

Profile: ChElmPatientInitials
Parent: ChElmPatient
Title: "CH ELM Patient Initials"
Description: "Patient representation via Initials"
* name obeys name-initials
* address[home].line ..0
* telecom ..0

Invariant: name-initials
Description: "a name with initials"
Severity: #error
Expression: "given.exists() and given.first().exists() and (''+given.first()).length() = 1 and family.exists() and (''+family).length() = 1"


Invariant: ch-elm-dateTime
Description: "At least the format YYYY-MM-DD is required."
Severity: #error
Expression: "$this.toString().length() >= 10"