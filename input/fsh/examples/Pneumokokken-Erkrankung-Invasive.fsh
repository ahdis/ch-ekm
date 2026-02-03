ValueSet: InvasiveStreptococcusPneumoniaeDiagnosisVS 
Id: invasive-streptococcus-pneumoniae-diagnosis-vs
* http://snomed.info/sct#233604007 "Pneumonia (disorder)"
* http://snomed.info/sct#91302008  "Sepsis (disorder)"
* http://snomed.info/sct#7180009   "Meningitis (disorder)"
* http://snomed.info/sct#160245001 "No current problems or disability (situation)"
* http://snomed.info/sct#3219008   "Disease type AND/OR category unknown (finding)"


Instance: PneumokokkenErkrankungInvasive
InstanceOf: Bundle
Usage: #example
* identifier.system = "urn:ietf:rfc:3986"
* identifier.value = "urn:uuid:1301332d-6012-443f-9690-929132b2e155"
* type = #document
* timestamp = "2026-01-27T11:30:00+02:00"
* entry[0].fullUrl = "urn:uuid:da065461-34df-4e2e-b69f-4181908575d0" // Composition
* entry[=].resource = da065461-34df-4e2e-b69f-4181908575d0
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015655" // Patient
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015655
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015656" // Condition
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015656
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015660" // Encounter
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015660
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015661" // Organization
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015661
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015662" // Specimen
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015662
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015664" // PractitionerRole
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015664
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015670" // PractitionerRole
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015670
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015665" // Practitioner
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015665
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015663" // Organization
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015663
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015671" // Immunization
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015671
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015673" // Immunization
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015673
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015672" // Condition
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015672

Instance: da065461-34df-4e2e-b69f-4181908575d0
InstanceOf: Composition
Usage: #example
* language = #de-CH
* identifier.system = "urn:ietf:rfc:3986"
* identifier.value = "urn:uuid:1301332d-6012-443f-9690-929132b2e155"
* status = #final
* type.coding[0] = $loinc#34782-3 "Infectious disease Note"
* subject = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015655) // Angaben zur betroffenen Person
* subject.type = "Patient"
* date = "2026-01-27T11:30:00+02:00"
* author[+] = Reference(50d5deca-64e9-4a30-8cec-40ac1f015664) // Arzt/Ärztin
* author[=].type = "PractitionerRole"
* title = "Meldung zum klinischen Befund Infektionskrankheit" // ASK here how the process is, do you send this when the lab result is confirmed or also when it's just a suspicion? If so, we have to play with Condition.verificationStatus
* section[+].title = "Diagnose und Manifestation" // Diagnose und Manifestation
* section[=].code = $sct#1269502008 "Diagnosis section"
* section[=].code = $loinc#29308-4 "Diagnosis"
* section[=].entry[0] = Reference(50d5deca-64e9-4a30-8cec-40ac1f015656)
* section[=].entry[0].type = "Condition"
* section[+].title = "Verlauf - Labor" // Laboratory
* section[=].code = $loinc#30954-2  "Relevant diagnostic tests/laboratory data Narrative" 
* section[=].entry[+] = Reference(50d5deca-64e9-4a30-8cec-40ac1f015661) 
* section[=].entry[=].type = "Organization" 
* section[=].entry[+] = Reference(50d5deca-64e9-4a30-8cec-40ac1f015662) 
* section[=].entry[=].type = "Specimen"
* section[+].title = "Verlauf - Hospitalisation" // Hospitalisation
* section[=].code = $loinc#46240-8 "History of hospitalizations+History of outpatient visits Narrative" 
* section[=].entry[+] = Reference(50d5deca-64e9-4a30-8cec-40ac1f015660) 
* section[=].entry[=].type = "Encounter" 
* section[+].title = "Impfstatus vor Krankheitsbeginn" // Impfstatus vor Krankheitsbeginn
* section[=].code = $loinc#11369-6  "History of immunization Narrative" 
* section[=].entry[+] = Reference(50d5deca-64e9-4a30-8cec-40ac1f015671) 
* section[=].entry[=].type = "Immunization" 
* section[=].entry[+] = Reference(50d5deca-64e9-4a30-8cec-40ac1f015673) 
* section[=].entry[=].type = "Immunization" 
* section[+].title = "Risikofaktoren" // Risikofaktoren
* section[=].code = $loinc#46467-7 "Risk factors" 
* section[=].entry[+] = Reference(50d5deca-64e9-4a30-8cec-40ac1f015672) 
* section[=].entry[=].type = "Condition" 


Instance: 50d5deca-64e9-4a30-8cec-40ac1f015655
InstanceOf: Patient
Usage: #example
//AHV-Nummer
//* identifier[+].system = "urn:oid:2.16.756.5.32"
//* identifier[=].value = "7561234567897"
//Initiale Name
* name.family = "M"
//Initiale Vorname
* name.given = "B"
//Geburtsdatum
* birthDate = "2000-01-01"
//Administratives Geschlecht
* gender = #male
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
* address[=].country = "CH"
//Nationalität
* extension[+].url = "http://hl7.org/fhir/StructureDefinition/patient-citizenship"
* extension[=].valueCodeableConcept = urn:iso:std:iso:3166#CH

Instance: 50d5deca-64e9-4a30-8cec-40ac1f015656
InstanceOf: Condition
Usage: #example
* subject = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015655)
//* category = $condition-category#encounter-diagnosis "Encounter Diagnosis"
* code = $sct#406617004 "Invasive Streptococcus pneumoniae disease (disorder)"
//* verificationStatus = $sct#410605003 "Confirmed present (qualifier value)" 
* onsetDateTime = "2026-01-27T00:00:00+02:00"
* evidence[0].code = $sct#91302008 "Sepsis (disorder)"
//* encounter = Reference(50d5deca-64e9-4a30-8cec-40ac1f015660)
//* recorder = Reference(50d5deca-64e9-4a30-8cec-40ac1f015664)


Instance: 50d5deca-64e9-4a30-8cec-40ac1f015660
InstanceOf: Encounter
Usage: #example
//* subject = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015655)
* class = #IMP
* status = #unknown
// Hospitalisation - Eintrittsdatum
* period.start = "2026-01-19T14:00:00+02:00"
// Hospitalisationsgrund - gemeldete Erreger
* reasonReference = Reference(50d5deca-64e9-4a30-8cec-40ac1f015656)

Instance: 50d5deca-64e9-4a30-8cec-40ac1f015661 
InstanceOf: Organization
Usage: #example
// Labor - Name
* name = "Viollier Bern AG"
// Labor - Tel.
* telecom[+].system = #phone
* telecom[=].value = "+41 848 121 121"

Instance: 50d5deca-64e9-4a30-8cec-40ac1f015662
InstanceOf: Specimen
Usage: #example
//* subject = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015655) 
// Labor - Entnahmedatum
* collection.collectedDateTime = "2026-01-27T10:00:00+02:00"
// Labor - Material
* type.coding[0] = $sct#19297000 "Blood specimen (specimen)"

Instance: 50d5deca-64e9-4a30-8cec-40ac1f015664
InstanceOf: PractitionerRole
Usage: #example
* practitioner = Reference(50d5deca-64e9-4a30-8cec-40ac1f015665)
* organization = Reference(50d5deca-64e9-4a30-8cec-40ac1f015663)

Instance: 50d5deca-64e9-4a30-8cec-40ac1f015670
InstanceOf: PractitionerRole
Usage: #example
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

Instance: 50d5deca-64e9-4a30-8cec-40ac1f015671
InstanceOf: Immunization
Usage: #example
* status = #completed
// Impfstatus vor Krankheitsbeginn - Gemäss
// If the input is "Impfauweis or Krankengeschichte" it references to a PractitionerRole with Organization; if the input is "Anamnese" it references to a PractitionerRole without Organizationp PractitionerRole with Practitioner
* extension[+].url = "http://fhir.ch/ig/ch-core/StructureDefinition/ch-ext-author"
* extension[=].valueReference = Reference(50d5deca-64e9-4a30-8cec-40ac1f015670)
// // Impfstatus vor Krankheitsbeginn - mit Impfstoff: Markenname
* vaccineCode = $ch-vacd-swissmedic-cs#60129
* patient = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015655)
* occurrenceDateTime = "2000-03-01T09:12:56+02:00"
// Impfstatus vor Krankheitsbeginn - Pneumokokken
* protocolApplied.targetDisease[+] = $sct#16814004 "Pneumococcal infectious disease"
// Impfstatus vor Krankheitsbeginn - mit X Dosen
* protocolApplied.doseNumberPositiveInt = 1

Instance: 50d5deca-64e9-4a30-8cec-40ac1f015673
InstanceOf: Immunization
Usage: #example
* status = #completed
// Impfstatus vor Krankheitsbeginn - Gemäss
// If the input is "Impfauweis or Krankengeschichte" it references to a PractitionerRole with Organization; if the input is "Anamnese" it references to a PractitionerRole without Organizationp PractitionerRole with Practitioner
* extension[+].url = "http://fhir.ch/ig/ch-core/StructureDefinition/ch-ext-author"
* extension[=].valueReference = Reference(50d5deca-64e9-4a30-8cec-40ac1f015670)
// // Impfstatus vor Krankheitsbeginn - mit Impfstoff: Markenname
* vaccineCode = $ch-vacd-swissmedic-cs#60129
* patient = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015655)
* occurrenceDateTime = "2000-05-01T09:12:56+02:00"
// Impfstatus vor Krankheitsbeginn - Pneumokokken
* protocolApplied.targetDisease[+] = $sct#16814004 "Pneumococcal infectious disease"
// Impfstatus vor Krankheitsbeginn - mit X Dosen
* protocolApplied.doseNumberPositiveInt = 2

// Risikofaktoren
Instance: 50d5deca-64e9-4a30-8cec-40ac1f015672
InstanceOf: Condition
Usage: #example
//* category = $condition-category#problem-list-item "Problem List Item"
* code = $sct#38013005 "Immunosuppression (finding)"
* subject = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015655)
//* recordedDate = "2026-01-27"
//* recorder = Reference(50d5deca-64e9-4a30-8cec-40ac1f015664)
// We can use this two code use in IPS for kein or unknow in Conditions
// $sct#160245001 "No current problems or disability (situation)"
// $sct#3219008 "Disease type AND/OR category unknown (finding)"

// Instance: QuestionnairePneumoInvasive
// InstanceOf: Questionnaire
// Usage: #example
// Title: "Meldung zum klinischen Befund Infektionskrankheit: Pneumokokken-Erkrankung Invasive"
// * status = #active
// * meta.profile = "http://hl7.org/fhir/4.0/StructureDefinition/Questionnaire"
// * extension.url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-preferredTerminologyServer"
// * extension.valueUrl = "http://tx.fhir.org"
// 
// // ---  Angaben zur betroffenen Person ---
// * item[+].linkId = "patient-section"
// * item[=].text = "Angaben zur betroffenen Person"
// * item[=].type = #group
// * item[=].extension[+].url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-itemExtractionContext"
// * item[=].extension[=].valueCode = #Patient
// * item[=].definition = "http://hl7.org/fhir/StructureDefinition/Patient"
// 
// * item[=].item[+].linkId = "p-family"
// * item[=].item[=].definition = "http://hl7.org/fhir/StructureDefinition/Patient#Patient.name.family"
// * item[=].item[=].text = "Initiale Name"
// * item[=].item[=].maxLength = 1
// * item[=].item[=].type = #string
// 
// 
// * item[=].item[+].linkId = "p-given"
// * item[=].item[=].definition = "http://hl7.org/fhir/StructureDefinition/Patient#Patient.name.given"
// * item[=].item[=].text = "Initiale Vorname"
// * item[=].item[=].maxLength = 1
// * item[=].item[=].type = #string 
// 
// * item[=].item[+].linkId = "p-gender"
// * item[=].item[=].definition = "http://hl7.org/fhir/StructureDefinition/Patient#Patient.gender"
// * item[=].item[=].text = "Geschlecht" 
// * item[=].item[=].type = #choice
// * item[=].item[=].answerValueSet = "#administrative-gender"
// 
// * item[=].item[+].linkId = "p-address-city"
// * item[=].item[=].definition = "http://hl7.org/fhir/StructureDefinition/Patient#Patient.address.city"
// * item[=].item[=].text = "Wohnort" 
// * item[=].item[=].type = #string 
// 
// * item[=].item[+].linkId = "p-address-postalCode"
// * item[=].item[=].definition = "http://hl7.org/fhir/StructureDefinition/Patient#Patient.address.postalCode"
// * item[=].item[=].text = "PLZ" 
// * item[=].item[=].type = #string 
// 
// * item[=].item[+].linkId = "p-address-state"
// * item[=].item[=].definition = "http://hl7.org/fhir/StructureDefinition/Patient#Patient.address.state"
// * item[=].item[=].text = "Kanton"
// * item[=].item[=].type = #choice
// * item[=].item[=].answerValueSet = "#cantonabbreviation"
// 
// 
// * item[=].item[+].linkId = "p-address-country"
// * item[=].item[=].definition = "http://hl7.org/fhir/StructureDefinition/Patient#Patient.address.country"
// * item[=].item[=].text = "Land"
// * item[=].item[=].type = #choice
// * item[=].item[=].answerValueSet = "#bfs-country-codes"
// 
// 
// * item[=].item[+].linkId = "p-nationality"
// * item[=].item[=].definition = "http://hl7.org/fhir/StructureDefinition/patient-citizenship#extension.code"
// * item[=].item[=].text = "Nationalität"
// * item[=].item[=].type = #choice
// * item[=].item[=].answerValueSet = "#bfs-country-codes"
// 
// 
// // --- Diagnose und Manifestation ---
// * item[+].linkId = "condition-section"
// * item[=].text = "Diagnose und Manifestation" 
// * item[=].type = #group
// * item[=].extension[+].url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-itemExtractionContext"
// * item[=].extension[=].valueCode = #Condition
// 
// * item[=].item[+].linkId = "c-code"
// * item[=].item[=].definition = "http://hl7.org/fhir/StructureDefinition/Condition#Condition.code"
// * item[=].item[=].text = "Manifestationen" 
// * item[=].item[=].type = #open-choice
// * item[=].item[=].repeats = true
// * item[=].item[=].answerValueSet = "#invasive-streptococcus-pneumoniae-diagnosis-vs"
// 
// * item[=].item[+].linkId = "c-onset-group"
// * item[=].item[=].type = #group
// * item[=].item[=].item[+].linkId = "c-known-onset"
// * item[=].item[=].item[=].definition = "http://hl7.org/fhir/StructureDefinition/Condition#Condition.onsetDateTime"
// * item[=].item[=].item[=].text = "Manifestationsbeginn" 
// * item[=].item[=].item[=].type = #date 
// * item[=].item[=].item[=].enableWhen[0].question = "c-unknown-onset"
// * item[=].item[=].item[=].operator = #!=
// * item[=].item[=].item[=].answerBoolean = true
// 
// * item[=].item[=].item[+].linkId = "c-unknown-onset"
// * item[=].item[=].item[=].type = #boolean
// * item[=].item[=].item[=].text = "Unbekannt"
// 
// // --- Labor ---
// * item[+].linkId = "lab-section"
// * item[=].text = "Labor" 
// * item[=].type = #group
// * item[=].item[+].linkId = "lab-material"
// * item[=].item[=].text = "Material" 
// * item[=].item[=].type = #choice
// 
// 
// * item[+].linkId = "vaccination-section"
// * item[=].text = "Impfstatus vor Krankheitsbeginn" 
// * item[=].type = #group
// * item[=].repeats = true
// * item[=].extension[+].url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-itemExtractionContext"
// * item[=].extension[=].valueCode = #Immunization
// * item[=].item[+].linkId = "v-date"
// * item[=].item[=].definition = "http://hl7.org/fhir/StructureDefinition/Immunization#Immunization.occurrenceDateTime"
// * item[=].item[=].text = "Datum der Dosis" 
// * item[=].item[=].type = #date
// * item[=].item[+].linkId = "v-brand"
// * item[=].item[=].definition = "http://hl7.org/fhir/StructureDefinition/Immunization#Immunization.vaccineCode"
// * item[=].item[=].text = "Markenname" 
// * item[=].item[=].type = #string 
// 
// 
// * item[+].linkId = "outcome-section"
// * item[=].text = "Verlauf / Zustand" 
// * item[=].type = #group
// * item[=].item[+].linkId = "outcome-death"
// * item[=].item[=].text = "Tod" 
// * item[=].item[=].type = #boolean
// 
// * item[=].item[+].linkId = "death-date"
// * item[=].item[=].text = "Todesdatum" 
// * item[=].item[=].type = #date
// * item[=].item[=].enableWhen[0].question = "outcome-death"
// * item[=].item[=].enableWhen[0].operator = #=
// * item[=].item[=].answerBoolean = true
// 
// 
// * item[+].linkId = "risk-factors-section"
// * item[=].text = "Risikofaktoren" 
// * item[=].type = #group
// * item[=].item[+].linkId = "risks"
// * item[=].item[=].text = "Bitte ankreuzen"
// * item[=].item[=].type = #choice
// * item[=].item[=].repeats = true

