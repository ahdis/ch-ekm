Instance: ChEkmPatientExample
InstanceOf: ChEkmPatient
Usage: #example
* identifier[EPR-SPID] 0..0
* identifier[LocalPid] 0..0
* identifier[insuranceCardNumber] 0..0
* identifier[AHVN13].system = "urn:oid:2.16.756.5.32"
* identifier[AHVN13].value = "7561234567897"
* name.family = "Muster"
* name.given = "Beispielin"
* birthDate = "2000-01-01"
* extension[genderIdentity].extension[value].valueCodeableConcept = $sct#446151000124109 "Male gender Identity"
* extension[biologicalSexAtBirth].extension[type].valueCodeableConcept = $loinc#76689-9 "Sex Assigned At Birth"
* extension[biologicalSexAtBirth].extension[value].valueCodeableConcept = $sct#248153007 "Male (finding)"
* gender = #male
* address[home].use = #home
* address[home].line = "Tannenstrasse 10a"
* address[home].line.extension[0].url = $iso21090-ADXP-streetName
* address[home].line.extension[=].valueString = "Tannenstrasse"
* address[home].line.extension[+].url = $iso21090-ADXP-houseNumber
* address[home].line.extension[=].valueString = "10a"
* address[home].city = "Liebefeld"
* address[home].postalCode = "3097"
* address[home].state = "BE"
* address[home].country = "CH"
* address[home].country.extension[countrycode].valueCoding = urn:iso:std:iso:3166#CH
* extension[citizenship].extension[code].valueCodeableConcept = urn:iso:std:iso:3166#CH
* telecom[phone].system = #phone
* telecom[phone].value = "+41 79 222 33 44"
