
Instance: ChEkmBundleGonorrhoea 
InstanceOf: ChEkmDocumentGonorrhoea
Usage: #example
Description: "Example for a CH EKM Bundle: Invasive Streptococcus Pneumoniae"
* identifier.system = "urn:ietf:rfc:3986"
* identifier.value = "urn:uuid:c376a38a-61b9-4a79-8722-12c75bacf927"
* type = #document
* timestamp = "2026-05-27T11:30:00+02:00"
* entry[0].fullUrl = "http://test.fhir.ch/r4/Composition/ChEkmCompositionExample-Gonorrhoea" // Composition
* entry[=].resource = ChEkmCompositionExample-Gonorrhoea
* entry[+].fullUrl = "http://test.fhir.ch/r4/Patient/ChEkmPatientInitialsExample" // Patient
* entry[=].resource = ChEkmPatientInitialsExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/PractitionerRole/ChEkmPractitionerRoleBrokerExample" // PractitionerRole - Broker
* entry[=].resource = ChEkmPractitionerRoleBrokerExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/Practitioner/ChEkmPractitionerBrokerExample" // Practitioner - Broker
* entry[=].resource = ChEkmPractitionerBrokerExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/Organization/ChEkmOrganizationBrokerExample" // Organization - Broker
* entry[=].resource = ChEkmOrganizationBrokerExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/Condition/ChEkmConditionExample-Gonorrhoea" // Condition
* entry[=].resource = ChEkmConditionExample-Gonorrhoea
* entry[+].fullUrl = "http://test.fhir.ch/r4/Encounter/ChEkmEncounterExample-Gonorrhoea" // Encounter
* entry[=].resource = ChEkmEncounterExample-Gonorrhoea

Instance: ChEkmCompositionExample-Gonorrhoea
InstanceOf: ChEkmCompositionGonorrhoea
Usage: #example
Description: "Example for a CH EKM Composition: Invasive Streptococcus Pneumoniae"
* status = #final
* category = $sct#423876004 "Clinical report"
* type = $sct#722143004 "Infectious disease diagnostic study note"
* subject = Reference(ChEkmPatientInitialsExample) // TODO update if example is available
* date = "2026-05-27" // TODO update if example is available
* author = Reference(ChEkmPractitionerRoleBrokerExample)
* encounter = Reference(ChEkmEncounterExample-Gonorrhoea)
* title = "Meldung zum klinischen Befund Infektionskrankheit"

// Diagnosis Section
* section[diagnosis].title = "Diagnosis section"
* section[diagnosis].code = $loinc#29308-4
* section[diagnosis].entry[0] = Reference(ChEkmConditionExample-Gonorrhoea)

// Laboratory Section

// Hospitalization Section

// Immunization Section

// Risk Factors Section (Direct Entry)


Instance: ChEkmConditionExample-Gonorrhoea
InstanceOf: Condition
Usage: #example
Description: "Example for a CH EKM Condition: Invasive Streptococcus Pneumoniae"
* subject = Reference(ChEkmPatientInitialsExample)
* category = $condition-category#encounter-diagnosis
* code = $sct#15628003 "Gonorrhea (disorder)"
* onsetDateTime.extension[+].url = "http://hl7.org/fhir/StructureDefinition/data-absent-reason"
* onsetDateTime.extension[=].valueCode = #asked-unknown
* evidence.code[0] = $sct#15628003 "Gonorrhea (disorder)"
// * evidence[0].code.text = "Symptomatisch"

Instance: ChEkmEncounterExample-Gonorrhoea
InstanceOf: Encounter
Usage: #example
Description: "Example for a CH EKM Encounter: Invasive Streptococcus Pneumoniae"
* subject = Reference(ChEkmPatientInitialsExample)
* class = #IMP
* status = #unknown
* period.start = "2026-01-19"
* reasonReference = Reference(ChEkmConditionExample-Gonorrhoea)
