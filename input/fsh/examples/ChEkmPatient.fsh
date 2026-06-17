Instance: ChEkmPatientExample
InstanceOf: ChEkmPatient
Usage: #example
Description: "Example for a CH EKM Patient: Full Name"
* identifier[AHVN13].system = "urn:oid:2.16.756.5.32"
* identifier[AHVN13].value = "7561234567897"
* name.family = "Muster"
* name.given = "Beispielin"
* birthDate = "2000-01-01"
* gender = #male
* address[home].use = #home
* address[home].line = "Tannenstrasse 10a"
* address[home].city = "Liebefeld"
* address[home].postalCode = "3097"
* address[home].state = "BE"
* address[home].country = "CH"
* address[home].country.extension[countrycode].valueCoding = urn:iso:std:iso:3166#CH
* extension[citizenship].extension[code].valueCodeableConcept = urn:iso:std:iso:3166#CH
* extension[genderIdentity].extension[value].valueCodeableConcept = $sct#1384187000 "Identifies as transgender (finding)"
* telecom[phone].system = #phone
* telecom[phone].value = "+41 79 222 33 44"
