
Instance: ChEkmBundleInvasiveStreptococcusPneumoniae 
InstanceOf: Bundle
Usage: #example
Description: "Example for a CH EKM Bundle: Invasive Streptococcus Pneumoniae"
* identifier.system = "urn:ietf:rfc:3986"
* identifier.value = "urn:uuid:1301332d-6012-443f-9690-929132b2e155"
* type = #document
* timestamp = "2026-01-27T11:30:00+02:00"
* entry[0].fullUrl = "urn:uuid:da065461-34df-4e2e-b69f-4181908575d0" // Composition
* entry[=].resource = da065461-34df-4e2e-b69f-4181908575d0
* entry[+].fullUrl = "http://test.fhir.ch/r4/Patient/ChEkmPatientInitialsExample" // Patient
* entry[=].resource = ChEkmPatientInitialsExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/Organization/ChEkmOrganizationAuthorExample" // Organization - Author
* entry[=].resource = ChEkmOrganizationAuthorExample
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f025656" // Condition
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f025656
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015660" // Encounter
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015660
* entry[+].fullUrl = "http://test.fhir.ch/r4/ServiceRequest/ChEkmServiceRequestExample-InvasiveStreptococcusPneumoniae" // ServiceRequest
* entry[=].resource = ChEkmServiceRequestExample-InvasiveStreptococcusPneumoniae
* entry[+].fullUrl = "http://test.fhir.ch/r4/Specimen/ChEkmSpecimenExample-InvasiveStreptococcusPneumoniae" // Specimen
* entry[=].resource = ChEkmSpecimenExample-InvasiveStreptococcusPneumoniae
* entry[+].fullUrl = "http://test.fhir.ch/r4/Organization/ChEkmOrganizationLabExample" // Organization - Lab
* entry[=].resource = ChEkmOrganizationLabExample
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015671" // Immunization
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015671
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015673" // Immunization
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015673
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015672" // Condition
* entry[=].resource = 50d5deca-64e9-4a30-8cec-40ac1f015672
* entry[+].fullUrl = "urn:uuid:50d5deca-64e9-4a30-8cec-80ac1f015672" // Condition
* entry[=].resource = 50d5deca-64e9-4a30-8cec-80ac1f015672




Instance: da065461-34df-4e2e-b69f-4181908575d0
InstanceOf: ChEkmComposition
Usage: #example
* status = #final
* type = $loinc#34782-3 "Infectious disease Note"
* subject = Reference(http://test.fhir.ch/r4/Patient/ChEkmPatientInitialsExample)
* date = "2026-01-27"
* author = Reference(http://test.fhir.ch/r4/Organization/ChEkmOrganizationAuthorExample) 
* encounter = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015660)
* title = "Meldung zum klinischen Befund Infektionskrankheit" 

// Diagnosis Section
* section[diagnosis].title = "Diagnosis section" 
* section[diagnosis].code = $loinc#29308-4
* section[diagnosis].entry[0] = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f025656)

// Laboratory Section
* section[laboratory].title = "Laboratory section" 
* section[laboratory].code = $loinc#30954-2
* section[laboratory].entry[0] = Reference(http://test.fhir.ch/r4/ServiceRequest/ChEkmServiceRequestExample-InvasiveStreptococcusPneumoniae) 

// Hospitalization Section
* section[hospitalization].title = "Hospitalisation section" 
* section[hospitalization].code = $loinc#46240-8
* section[hospitalization].entry[0] = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015660) 

// Immunization Section
* section[immunization].title = "Immunization section"
* section[immunization].code = $loinc#11369-6
* section[immunization].entry[0] = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015671) 
* section[immunization].entry[1] = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015673) 

// Risk Factors Section (Direct Entry)
* section[risk-factors].title = "Risk factors section"
* section[risk-factors].code = $loinc#46467-7
* section[risk-factors].entry[0] = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015672)


Instance: 50d5deca-64e9-4a30-8cec-40ac1f025656
InstanceOf: Condition
Usage: #example
* subject = Reference(http://test.fhir.ch/r4/Patient/ChEkmPatientInitialsExample)
* category = $condition-category#encounter-diagnosis 
* code = $sct#406617004 "Invasive Streptococcus pneumoniae disease (disorder)"
//* verificationStatus = $sct#410605003 "Confirmed present (qualifier value)" 
* onsetDateTime = "2026-01-27"
* evidence[0].detail = Reference (urn:uuid:50d5deca-64e9-4a30-8cec-80ac1f015672)
//* encounter = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f015660)



Instance: 50d5deca-64e9-4a30-8cec-40ac1f015660
InstanceOf: Encounter
Usage: #example
* subject = Reference(http://test.fhir.ch/r4/Patient/ChEkmPatientInitialsExample)
* class = #IMP
* status = #unknown
* period.start = "2026-01-19"
* reasonReference = Reference(urn:uuid:50d5deca-64e9-4a30-8cec-40ac1f025656)



Instance: 50d5deca-64e9-4a30-8cec-40ac1f015671
InstanceOf: Immunization
Usage: #example
* status = #completed
* vaccineCode = $ch-vacd-swissmedic-cs#60129
* patient = Reference(http://test.fhir.ch/r4/Patient/ChEkmPatientInitialsExample)
* occurrenceDateTime = "2000-03-01"
* protocolApplied.targetDisease[+] = $sct#16814004 "Pneumococcal infectious disease"
* protocolApplied.doseNumberPositiveInt = 1

Instance: 50d5deca-64e9-4a30-8cec-40ac1f015673
InstanceOf: Immunization
Usage: #example
* status = #completed
* vaccineCode = $ch-vacd-swissmedic-cs#60129
* patient = Reference(http://test.fhir.ch/r4/Patient/ChEkmPatientInitialsExample)
* occurrenceDateTime = "2000-05-01"
* protocolApplied.targetDisease[+] = $sct#16814004 "Pneumococcal infectious disease"
* protocolApplied.doseNumberPositiveInt = 2


Instance: 50d5deca-64e9-4a30-8cec-40ac1f015672
InstanceOf: Condition
Usage: #example
* category = $condition-category#problem-list-item 
* code = $sct#38013005 "Immunosuppression (finding)"
* subject = Reference(http://test.fhir.ch/r4/Patient/ChEkmPatientInitialsExample)

Instance: 50d5deca-64e9-4a30-8cec-80ac1f015672
InstanceOf: Condition
Usage: #example
* category = $condition-category#problem-list-item 
* code = $sct#91302008 "Sepsis (disorder)"
* subject = Reference(http://test.fhir.ch/r4/Patient/ChEkmPatientInitialsExample)






// Instance: QuestionnairePneumoInvasive
// InstanceOf: Questionnaire
// Usage: #example
// Title: "Meldung zum klinischen Befund Infektionskrankheit: Pneumokokken-Erkrankung Invasive"
// * status = #active
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

