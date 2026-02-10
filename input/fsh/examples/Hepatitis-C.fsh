
Instance: HepatitisC
InstanceOf: Bundle
Usage: #example
* identifier.system = "urn:ietf:rfc:3986"
* identifier.value = "urn:uuid:1301332d-6012-443f-9690-929132b2e156"
* type = #document
* timestamp = "2026-01-27T11:30:00+02:00"
* entry[0].fullUrl = "urn:uuid:da065461-34df-4e2e-b69f-4181908575d1" // Composition
* entry[=].resource = da065461-34df-4e2e-b69f-4181908575d1
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015655" // Patient
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015655
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015656" // Condition
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015656
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015690" // Observation
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015690
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015790" // Observation
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015790 
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f016790" // Observation
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f016790 
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015791" // Observation
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015791
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015680" // ServiceRequest
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015662
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015664" // PractitionerRole
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015664
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015665" // Practitioner
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015665
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015663" // Organization
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015663


Instance: da065461-34df-4e2e-b69f-4181908575d1
InstanceOf: Composition
Usage: #example
* language = #de-CH
* identifier.system = "urn:ietf:rfc:3986"
* identifier.value = "urn:uuid:1301332d-6012-443f-9690-929132b2e155"
* status = #final
* type.coding[0] = $loinc#34782-3 "Infectious disease Note"
* subject = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015655) // Angaben zur betroffenen Person
* subject.type = "Patient"
* date = "2026-01-27"
* author[+] = Reference(50d5deca-64e9-4a30-8cec-40ac1f015664) // Arzt/Ärztin
* author[=].type = "PractitionerRole"
* title = "Meldung zum klinischen Befund Infektionskrankheit" // ASK here how the process is, do you send this when the lab result is confirmed or also when it's just a suspicion? If so, we have to play with Condition.verificationStatus
* section[+].title = "Diagnosis section"
* section[=].code = $sct#1269502008 "Diagnosis section"
* section[=].code = $loinc#29308-4 "Diagnosis"
* section[=].entry[0] = Reference(50d5deca-64e9-4a30-8cec-40ac1f015656)
* section[=].entry[0].type = "Condition"
* section[+].title = "Laboratory Results section" 
* section[=].code = $loinc#30954-2  "Relevant diagnostic tests/laboratory data Narrative" 
* section[=].entry[+] = Reference(50d5deca-64e9-4a30-8cec-40ac1f015680) 
* section[=].entry[=].type = "ServiceRequest" 
* section[+].title = "Medication section" 
* section[=].code = $loinc#10160-0 	"History of medication use Narrative"
* section[=].entry[+] = Reference(50d5deca-64e9-4a30-8cec-40ac1f015790) 
* section[=].entry[=].type = "Observation" 
* section[+].title = "Social History section"
* section[=].code = $loinc#29762-2 "Social history Narrative"
* section[=].section[+].entry[+] = Reference(50d5deca-64e9-4a30-8cec-40ac1f016790) 
* section[=].section[=].entry[=].type = "Observation"
* section[=].section[+].entry[+] = Reference(50d5deca-64e9-4a30-8cec-40ac1f015791) 
* section[=].section[=].entry[=].type = "Observation" 


Instance: 50d5deca-64e9-4a30-8cec-40ac1f015655
InstanceOf: Patient
Usage: #example
//AHV-Nummer
* identifier[+].system = "urn:oid:2.16.756.5.32"
* identifier[=].value = "7561234567897"
//Initiale Name
* name.family = "Muster"
//Initiale Vorname
* name.given = "Beispielin"
//Geburtsdatum
* birthDate = "2000-01-01"
// Geschlecht
* extension[+].url = "http://hl7.org/fhir/StructureDefinition/individual-genderIdentity"
* extension[=].extension[0].url = "value"
* extension[=].extension[=].valueCodeableConcept = $sct#446141000124107 "Identifies as female gender (finding)"
* extension[+].url = "http://hl7.org/fhir/StructureDefinition/individual-recordedSexOrGender"
* extension[=].extension[0].url = "value"
* extension[=].extension[=].valueCodeableConcept = #male 
* extension[=].extension[+].url = "type"
* extension[=].extension[=].valueCodeableConcept = $loinc#76689-9 "Sex Assigned At Birth"
//* gender = #male
//Adresse (Strasse + Hausnumme + Ort)
//* address[home].use = #home
//* address[home].line = "Tannenstrasse 10a"
//* address[home].line.extension[0].url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName"
//* address[home].line.extension[=].valueString = "Tannenstrasse"
//* address[home].line.extension[+].url = "http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber"
//* address[home].line.extension[=].valueString = "10a"
* address[+].city = "Liebefeld"
//PLZ/Wohnort
* address[=].postalCode = "3097"
//Kanton
* address[=].state = "BE"
//Land
* address[=].country = "Schweiz"
* address[=].country.extension[+].url = "http://hl7.org/fhir/StructureDefinition/iso21090-SC-coding"
* address[=].country.extension[=].valueCoding = urn:iso:std:iso:3166#CH
//Nationalität
* extension[+].url = "http://hl7.org/fhir/StructureDefinition/patient-citizenship"
* extension[=].valueCodeableConcept = urn:iso:std:iso:3166#CH
// Herkunftsland
* extension[0].url = "http://hl7.org/fhir/StructureDefinition/patient-birthPlace"
* extension[=].valueAddress.country = "Niederlande"
* address[=].country.extension[+].url = "http://hl7.org/fhir/StructureDefinition/iso21090-SC-coding"
* address[=].country.extension[=].valueCoding = urn:iso:std:iso:3166#NL

Instance: 50d5deca-64e9-4a30-8cec-40ac1f015656
InstanceOf: Condition
Usage: #example
* subject = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015655)
//* category = $condition-category#encounter-diagnosis "Encounter Diagnosis"
* code = $sct#50711007 "Viral hepatitis type C (disorder)"
//* verificationStatus = $sct#410605003 "Confirmed present (qualifier value)" 
* onsetDateTime.extension[+].url = "http://hl7.org/fhir/StructureDefinition/data-absent-reason"
* onsetDateTime.extension[=].valueCode = #asked-unknown
* evidence[0].code = $sct#235866006 "Acute hepatitis C (disorder)"
* evidence[1].code = $sct#166642001 "Elevated transaminases (finding)"
* evidence[1].code.text = "Transaminase ≥ 2.5x"
* evidence[2].detail = Reference (50d5deca-64e9-4a30-8cec-40ac1f015690)
//* recorder = Reference(50d5deca-64e9-4a30-8cec-40ac1f015664)


Instance: 50d5deca-64e9-4a30-8cec-40ac1f015690
InstanceOf: Observation
Usage: #example
* status = #final
* code = $loinc#16128-1 "Hepatitis C virus Ab [Presence] in Serum"
* subject = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015655)
* valueCodeableConcept = $sct#61665006 "Unknown (qualifier value)"

Instance: 50d5deca-64e9-4a30-8cec-40ac1f015790
InstanceOf: Observation
Usage: #example
* status = #final
* code = $loinc#427314002 "Antiviral therapy (procedure)"
* subject = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015655)
* valueCodeableConcept = $sct#386053000 "Evaluation procedure (procedure)"


Instance: 50d5deca-64e9-4a30-8cec-40ac1f016790
InstanceOf: Observation
Usage: #example
* extension[+].url = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-exposition-address"
* extension[=].valueAddress.country = "Nepal"
* extension[=].valueAddress.extension[+].url = "http://hl7.org/fhir/StructureDefinition/iso21090-SC-coding"
* extension[=].valueAddress.extension[=].valueCoding = urn:iso:std:iso:3166#CH
* status = #final
* category = $v3-ActClass#AEXPOS "acquisition exposure"
* code = $sct#150781000119103 "Exposure to viral disease (event)"
* valueCodeableConcept = $sct#223366009 "Healthcare professional (occupation)"
* effectivePeriod.start = "2025-12-01"
* effectivePeriod.end = "2025-12-01"
* subject = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015655)
* component.code = $v3-ParticipationType#EXPAGNT "Exposure Agent"
* component.valueCodeableConcept = $sct#62944002 "Hepatitis C virus (organism)"
* component.code = $v3-ParticipationType#LOC "Location"
* component.valueCodeableConcept = $sct#276030007 "Travel abroad (finding)"
* component.code = $v3-ParticipationType#PART "Participant"
* component.valueCodeableConcept = $sct#61665006 "Unknown (qualifier value)"

Instance: 50d5deca-64e9-4a30-8cec-40ac1f015791
InstanceOf: Observation
Usage: #example
* status = #final
* code = $loinc#21843-8 "History of Usual occupation"
* subject = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015655)
* valueString = "Ärztin"


Instance: 50d5deca-64e9-4a30-8cec-40ac1f015680
InstanceOf: ServiceRequest
Usage: #example
* intent = #order
* status = #unknown
* reasonCode =  $sct#71112000 "Screening due" 
* subject = Reference(50d5deca-64e9-4a30-8cec-40ac1f015655)


Instance: 50d5deca-64e9-4a30-8cec-40ac1f015664
InstanceOf: PractitionerRole
Usage: #example
* practitioner = Reference(50d5deca-64e9-4a30-8cec-40ac1f015665)
* organization = Reference(50d5deca-64e9-4a30-8cec-40ac1f015663)


Instance: 50d5deca-64e9-4a30-8cec-40ac1f015665
InstanceOf: Practitioner
Usage: #example
// Arzt/Ärztin - Name
* name.family = "Giacometti"
* name.given = "Monika"
// Arzt/Ärztin - Tel.
* telecom[+].system = #email
* telecom[=].value = "m.giacometti@ks-abc.ch"
// Arzt/Ärztin - E-Mail
* telecom[+].system = #phone
* telecom[=].value = "+41 79 111 44 55"

Instance: 50d5deca-64e9-4a30-8cec-40ac1f015663
InstanceOf: Organization
Usage: #example
// Arzt/Ärztin - Addresse
* address.line = "Aortastrasse 22"
* address.city = "Bern"
* address.postalCode = "3000"



