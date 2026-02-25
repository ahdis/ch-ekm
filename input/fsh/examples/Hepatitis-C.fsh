
Instance: HepatitisC
InstanceOf: Bundle
Usage: #example
* type = #document
* timestamp = "2026-01-27T11:30:00+02:00"
* entry[0].fullUrl = "urn:uuid:da065461-34df-4e2e-b69f-4181908575d1" // Composition
* entry[=].resource = da065461-34df-4e2e-b69f-4181908575d1
* entry[+].fullUrl = "http://test.fhir.ch/r4/Patient/ChEkmPatientExample" // Patient
* entry[=].resource = ChEkmPatientExample
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
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015680
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015664" // PractitionerRole
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015664
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015665" // Practitioner
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015665
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015663" // Organization
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015663
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-5a30-8cec-40ac1f015661" // Organization
* entry[=].resource = 50d5deca-64e9-5a30-8cec-40ac1f015661



Instance: da065461-34df-4e2e-b69f-4181908575d1
InstanceOf: ChEkmComposition
Usage: #example
* identifier.system = "urn:ietf:rfc:3986"
* identifier.value = "urn:uuid:1301332d-6012-443f-9690-929132b2e155"
* status = #final
* type.coding[0] = $loinc#34782-3 "Infectious disease Note"
* subject = Reference(ChEkmPatientExample) // Angaben zur betroffenen Person
* subject.type = "Patient"
* date = "2026-01-27"
* author[+] = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015664) // Arzt/Ärztin
* author[=].type = "PractitionerRole"
* title = "Meldung zum klinischen Befund Infektionskrankheit" // ASK here how the process is, do you send this when the lab result is confirmed or also when it's just a suspicion? If so, we have to play with Condition.verificationStatus
* section[+].title = "Diagnosis section"
* section[=].code = $loinc#29308-4 "Diagnosis"
* section[=].entry[0] = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015656)
* section[=].entry[0].type = "Condition"
* section[+].title = "Laboratory Results section" 
* section[=].code = $loinc#30954-2  "Relevant diagnostic tests/laboratory data Narrative" 
* section[=].entry[+] = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015680) 
* section[=].entry[=].type = "ServiceRequest" 
* section[+].title = "Medication section" 
* section[=].code = $loinc#10160-0 	"History of medication use Narrative"
* section[=].entry[+] = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015790) 
* section[=].entry[=].type = "Observation" 
* section[+].title = "Social History section"
* section[=].code = $loinc#29762-2 "Social history Narrative"
* section[=].section[+].entry[+] = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f016790) 
* section[=].section[=].entry[=].type = "Observation"
* section[=].section[+].entry[+] = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015791) 
* section[=].section[=].entry[=].type = "Observation" 


Instance: 50d5deca-64e9-4a30-8cec-40ac1f015656
InstanceOf: Condition
Usage: #example
* subject = Reference(ChEkmPatientExample)
//* category = $condition-category#encounter-diagnosis "Encounter Diagnosis"
* code = $sct#50711007 "Viral hepatitis type C (disorder)"
//* verificationStatus = $sct#410605003 "Confirmed present (qualifier value)" 
* onsetDateTime.extension[+].url = "http://hl7.org/fhir/StructureDefinition/data-absent-reason"
* onsetDateTime.extension[=].valueCode = #asked-unknown
* evidence[0].detail = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-80bc1f015672)
* evidence[1].detail = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-80cc1f015672)
* evidence[2].detail = Reference (urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015690)
//* recorder = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015664)


Instance: 50d5deca-64e9-4a30-8cec-40ac1f015690
InstanceOf: Observation
Usage: #example
* status = #final
* code = $loinc#16128-1 "Hepatitis C virus Ab [Presence] in Serum"
* subject = Reference(ChEkmPatientExample)
* valueCodeableConcept = $sct#261665006 "Unknown (qualifier value)"

Instance: 50d5deca-64e9-4a30-8cec-40ac1f015790
InstanceOf: Observation
Usage: #example
* status = #final
* code = $sct#427314002 "Antiviral therapy (procedure)"
* subject = Reference(ChEkmPatientExample)
* valueCodeableConcept = $sct#386053000 "Evaluation procedure (procedure)"


Instance: 50d5deca-64e9-4a30-8cec-40ac1f016790
InstanceOf: Observation
Usage: #example
* extension[+].url = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-exposition-address"
* extension[=].valueAddress.country = "Nepal"
//* extension[=].valueAddress.extension[+].url = "http://hl7.org/fhir/StructureDefinition/iso21090-SC-coding"
//* extension[=].valueAddress.extension[=].valueCoding = urn:iso:std:iso:3166#CH
* status = #final
* category = $v3-ActClass#AEXPOS "acquisition exposure"
* code = $sct#150781000119103 "Exposure to viral disease (event)"
* valueCodeableConcept = $sct#223366009 "Healthcare professional (occupation)"
* effectivePeriod.start = "2025-12-01"
* effectivePeriod.end = "2025-12-01"
* subject = Reference(ChEkmPatientExample)
* component.code = $v3-ParticipationType#EXPAGNT "Exposure Agent"
* component.valueCodeableConcept = $sct#62944002 "Hepatitis C virus (organism)"
* component.code = $v3-ParticipationType#LOC "Location"
* component.valueCodeableConcept = $sct#276030007 "Travel abroad (finding)"
* component.code = $v3-ParticipationType#PART "Participant"
* component.valueCodeableConcept = $sct#261665006 "Unknown (qualifier value)"

Instance: 50d5deca-64e9-4a30-8cec-40ac1f015791
InstanceOf: Observation
Usage: #example
* status = #final
* code = $loinc#21843-8 "History of Usual occupation"
* subject = Reference(ChEkmPatientExample)
* valueString = "Ärztin"


Instance: 50d5deca-64e9-4a30-8cec-40ac1f015680
InstanceOf: ServiceRequest
Usage: #example
* intent = #order
* status = #unknown
* reasonCode =  $sct#713883003 "Screening due" 
* subject = Reference(ChEkmPatientExample)
* performer = Reference(urn:uuid:50d5deca-64e9-5a30-8cec-40ac1f015661)

Instance: 50d5deca-64e9-5a30-8cec-40ac1f015661 
InstanceOf: Organization
Usage: #example
* name = "Viollier Bern AG"
* telecom[+].system = #phone
* telecom[=].value = "+41 848 121 121"

Instance: 50d5deca-64e9-4a30-8cec-40ac1f015664
InstanceOf: PractitionerRole
Usage: #example
* practitioner = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015665)
* organization = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015663)


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

Instance: 50d5deca-64e9-4a30-8cec-80bc1f015672
InstanceOf: Condition
Usage: #example
* code =  $sct#235866006 "Acute hepatitis C (disorder)"
* subject = Reference(ChEkmPatientExample)


Instance: 50d5deca-64e9-4a30-8cec-80cc1f015672
InstanceOf: Observation
Usage: #example
* status = #final
* code = $sct#166642001 "Elevated transaminases (finding)"
* code.text = "Transaminase ≥ 2.5x"
* subject = Reference(ChEkmPatientExample)





