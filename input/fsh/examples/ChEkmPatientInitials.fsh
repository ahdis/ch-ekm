Instance: ChEkmPatientInitialsExample
InstanceOf: ChEkmPatientInitials
Usage: #example
Description: "Example for a CH EKM Patient: Initials"
* identifier[AHVN13].system = "urn:oid:2.16.756.5.32"
* identifier[AHVN13].value = "7561234567897"
* name.family = "M"
* name.given = "B"
* birthDate = "2000-01-01"
* gender = #male
* address[home].use = #home
* address[home].city = "Liebefeld"
* address[home].postalCode = "3097"
* address[home].state = "BE"
* address[home].country = "CH"
* address[home].country.extension[countrycode].valueCoding = urn:iso:std:iso:3166#CH
* extension[citizenship].extension[code].valueCodeableConcept = urn:iso:std:iso:3166#CH
* extension[placeOfBirth].valueAddress.country = "NL"
* extension[placeOfBirth].valueAddress.country.extension[countrycode].valueCoding = urn:iso:std:iso:3166#NL



// A person from Liechtenstein: no AHV number, identified by the IDN instead (issue #45, cf. CH ELM
// Pat-007). The form pre-populates its one "AHV / IDN (FL)" field from it.
Instance: ChEkmPatientInitialsLiechtensteinExample
InstanceOf: ChEkmPatientInitials
Usage: #example
Description: "Example for a CH EKM Patient: Initials, from Liechtenstein with the IDN as identifier"
* identifier[IDN].system = "urn:oid:2.16.438.10.20.10.10.1.2.1"
* identifier[IDN].value = "1234567890123"
* name.family = "M"
* name.given = "B"
* birthDate = "2000-01-01"
* gender = #male
* address[home].use = #home
* address[home].city = "Vaduz"
* address[home].postalCode = "9490"
* address[home].country = "LI"
* address[home].country.extension[countrycode].valueCoding = urn:iso:std:iso:3166#LI
* extension[citizenship].extension[code].valueCodeableConcept = urn:iso:std:iso:3166#LI
