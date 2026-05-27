
Instance: ChEkmBundleInvasivePneumococcalDisease 
InstanceOf: ChEkmDocumentInvasivePneumococcalDisease
Usage: #example
Description: "Example for a CH EKM Bundle: Invasive Streptococcus Pneumoniae"
* identifier.system = "urn:ietf:rfc:3986"
* identifier.value = "urn:uuid:1301332d-6012-443f-9690-929132b2e155"
* type = #document
* timestamp = "2026-01-27T11:30:00+02:00"
* entry[0].fullUrl = "http://test.fhir.ch/r4/Composition/ChEkmCompositionExample-InvasivePneumococcalDisease" // Composition
* entry[=].resource = ChEkmCompositionExample-InvasivePneumococcalDisease
* entry[+].fullUrl = "http://test.fhir.ch/r4/Patient/ChEkmPatientInitialsExample" // Patient
* entry[=].resource = ChEkmPatientInitialsExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/PractitionerRole/ChEkmPractitionerRoleBrokerExample" // PractitionerRole - Broker
* entry[=].resource = ChEkmPractitionerRoleBrokerExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/Practitioner/ChEkmPractitionerBrokerExample" // Practitioner - Broker
* entry[=].resource = ChEkmPractitionerBrokerExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/Organization/ChEkmOrganizationBrokerExample" // Organization - Broker
* entry[=].resource = ChEkmOrganizationBrokerExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/Condition/ChEkmConditionExample-InvasivePneumococcalDisease" // Condition
* entry[=].resource = ChEkmConditionExample-InvasivePneumococcalDisease
* entry[+].fullUrl = "http://test.fhir.ch/r4/Encounter/ChEkmEncounterExample-InvasivePneumococcalDisease" // Encounter
* entry[=].resource = ChEkmEncounterExample-InvasivePneumococcalDisease
* entry[+].fullUrl = "http://test.fhir.ch/r4/ServiceRequest/ChEkmServiceRequestExampleInvasivePneumococcalDisease" // ServiceRequest
* entry[=].resource = ChEkmServiceRequestExampleInvasivePneumococcalDisease
* entry[+].fullUrl = "http://test.fhir.ch/r4/Specimen/ChEkmSpecimenExampleInvasivePneumococcalDisease" // Specimen
* entry[=].resource = ChEkmSpecimenExampleInvasivePneumococcalDisease
* entry[+].fullUrl = "http://test.fhir.ch/r4/Organization/ChEkmOrganizationLabExample" // Organization - Lab
* entry[=].resource = ChEkmOrganizationLabExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/Immunization/ChEkmImmunizationExample-Pneumococcal1" // Immunization
* entry[=].resource = ChEkmImmunizationExample-Pneumococcal1
* entry[+].fullUrl = "http://test.fhir.ch/r4/Immunization/ChEkmImmunizationExample-Pneumococcal2" // Immunization
* entry[=].resource = ChEkmImmunizationExample-Pneumococcal2
* entry[+].fullUrl = "http://test.fhir.ch/r4/Condition/ChEkmConditionExample-Immunosuppression" // Condition
* entry[=].resource = ChEkmConditionExample-Immunosuppression

Instance: ChEkmCompositionExample-InvasivePneumococcalDisease
InstanceOf: ChEkmCompositionInvasivePneumococcalDisease
Usage: #example
Description: "Example for a CH EKM Composition: Invasive Streptococcus Pneumoniae"
* status = #final
* category = $sct#423876004 "Clinical report"
* type = $sct#722143004 "Infectious disease diagnostic study note"
* subject = Reference(ChEkmPatientInitialsExample)
* date = "2026-01-27"
* author = Reference(ChEkmPractitionerRoleBrokerExample)
* encounter = Reference(ChEkmEncounterExample-InvasivePneumococcalDisease)
* title = "Meldung zum klinischen Befund Infektionskrankheit"

// Diagnosis Section
* section[diagnosis].title = "Diagnosis section"
* section[diagnosis].code = $loinc#29308-4
* section[diagnosis].entry[0] = Reference(ChEkmConditionExample-InvasivePneumococcalDisease)

// Laboratory Section
* section[laboratory].title = "Laboratory section"
* section[laboratory].code = $loinc#30954-2
* section[laboratory].entry[0] = Reference(ChEkmServiceRequestExampleInvasivePneumococcalDisease)

// Hospitalization Section
* section[hospitalization].title = "Hospitalisation section"
* section[hospitalization].code = $loinc#46240-8
* section[hospitalization].entry[0] = Reference(ChEkmEncounterExample-InvasivePneumococcalDisease)

// Immunization Section
* section[immunization].title = "Immunization section"
* section[immunization].code = $loinc#11369-6
* section[immunization].entry[0] = Reference(ChEkmImmunizationExample-Pneumococcal1)
* section[immunization].entry[1] = Reference(ChEkmImmunizationExample-Pneumococcal2)

// Risk Factors Section (Direct Entry)
* section[risk-factors].title = "Risk factors section"
* section[risk-factors].code = $loinc#46467-7
* section[risk-factors].entry[0] = Reference(ChEkmConditionExample-Immunosuppression)


Instance: ChEkmConditionExample-InvasivePneumococcalDisease
InstanceOf: Condition
Usage: #example
Description: "Example for a CH EKM Condition: Invasive Streptococcus Pneumoniae"
* subject = Reference(ChEkmPatientInitialsExample)
* category = $condition-category#encounter-diagnosis
* code = $sct#406617004 "Invasive Streptococcus pneumoniae disease (disorder)"
//* verificationStatus = $sct#410605003 "Confirmed present (qualifier value)"
* onsetDateTime = "2026-01-27"
* evidence[0].code = $sct#91302008 "Sepsis (disorder)"

Instance: ChEkmEncounterExample-InvasivePneumococcalDisease
InstanceOf: Encounter
Usage: #example
Description: "Example for a CH EKM Encounter: Invasive Streptococcus Pneumoniae"
* subject = Reference(ChEkmPatientInitialsExample)
* class = #IMP
* status = #unknown
* period.start = "2026-01-19"
* reasonReference = Reference(ChEkmConditionExample-InvasivePneumococcalDisease)

Instance: ChEkmImmunizationExample-Pneumococcal1
InstanceOf: Immunization
Usage: #example
Description: "Example for a CH EKM Immunization: Pneumococcal Dose 1"
* status = #completed
* vaccineCode = $ch-vacd-swissmedic-cs#60129
* patient = Reference(ChEkmPatientInitialsExample)
* occurrenceDateTime = "2000-03-01"
* protocolApplied.targetDisease[+] = $sct#16814004 "Pneumococcal infectious disease"
* protocolApplied.doseNumberPositiveInt = 1

Instance: ChEkmImmunizationExample-Pneumococcal2
InstanceOf: Immunization
Usage: #example
Description: "Example for a CH EKM Immunization: Pneumococcal Dose 2"
* status = #completed
* vaccineCode = $ch-vacd-swissmedic-cs#60129
* patient = Reference(ChEkmPatientInitialsExample)
* occurrenceDateTime = "2000-05-01"
* protocolApplied.targetDisease[+] = $sct#16814004 "Pneumococcal infectious disease"
* protocolApplied.doseNumberPositiveInt = 2


Instance: ChEkmConditionExample-Immunosuppression
InstanceOf: Condition
Usage: #example
Description: "Example for a CH EKM Condition: Immunosuppression"
* category = $condition-category#problem-list-item
* code = $sct#38013005 "Immunosuppression (finding)"
* subject = Reference(ChEkmPatientInitialsExample)


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

