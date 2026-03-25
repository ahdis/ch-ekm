
Instance: ChEkmPatientVCTExample
InstanceOf: ChEkmPatientVCT
Usage: #example
* identifier[LocalPid].system = "http://fhir.ch/ig/ch-ekm/identifier/vct"
* identifier[LocalPid].type = $v2-0203#MR
* identifier[LocalPid].value = "kste12345"
* name.given.extension[dataabsentreason].valueCode = #unknown
* name.family.extension[dataabsentreason].valueCode = #unknown
* birthDate = "2000-01-01"
* gender = #male
* address[home].use = #home
* address[home].city = "Liebefeld"
* address[home].postalCode = "3097"
* address[home].state = "BE"
* address[home].country = "CH"
* address[home].country.extension[countrycode].valueCoding = urn:iso:std:iso:3166#CH
* extension[citizenship].extension[code].valueCodeableConcept = urn:iso:std:iso:3166#CH


