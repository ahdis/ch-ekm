
Instance: ChEkmBundleHepatitisC
InstanceOf: Bundle
Usage: #example
Description: "Example for a CH EKM Bundle: Hepatitis C"
* identifier.system = "urn:ietf:rfc:3986"
* identifier.value = "urn:uuid:1901332d-6012-443f-9690-9291adb234fa"
* type = #document
* timestamp = "2026-01-27T11:30:00+02:00"
* entry[0].fullUrl = "http://test.fhir.ch/r4/Composition/ChEkmCompositionExample-HepatitisC" // Composition
* entry[=].resource = ChEkmCompositionExample-HepatitisC
* entry[+].fullUrl = "http://test.fhir.ch/r4/Patient/ChEkmPatientExample" // Patient
* entry[=].resource = ChEkmPatientExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/PractitionerRole/ChEkmPractitionerRoleTreatingPhysicianExample" // PractitionerRole - Treating Physician
* entry[=].resource = ChEkmPractitionerRoleTreatingPhysicianExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/Practitioner/ChEkmPractitionerTreatingPhysicianExample" // Practitioner - Treating Physician
* entry[=].resource = ChEkmPractitionerTreatingPhysicianExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/Organization/ChEkmOrganizationTreatingPhysicianExample" // Organization - Treating Physician
* entry[=].resource = ChEkmOrganizationTreatingPhysicianExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/ServiceRequest/ChEkmServiceRequestExample-HepatitisC" // ServiceRequest
* entry[=].resource = ChEkmServiceRequestExample-HepatitisC
* entry[+].fullUrl = "http://test.fhir.ch/r4/Organization/ChEkmOrganizationLabExample" // Organization - Lab
* entry[=].resource = ChEkmOrganizationLabExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/Specimen/ChEkmSpecimenExample-HepatitisC" // Specimen
* entry[=].resource = ChEkmSpecimenExample-HepatitisC
* entry[+].fullUrl = "http://test.fhir.ch/r4/Condition/ChEkmConditionExample-HepatitisC" // Condition
* entry[=].resource = ChEkmConditionExample-HepatitisC
* entry[+].fullUrl = "http://test.fhir.ch/r4/Observation/ChEkmObservationExample-HepatitisCVirusAb" // Observation
* entry[=].resource = ChEkmObservationExample-HepatitisCVirusAb
* entry[+].fullUrl = "http://test.fhir.ch/r4/Observation/ChEkmObservationExample-AntiviralTherapy" // Observation
* entry[=].resource = ChEkmObservationExample-AntiviralTherapy
* entry[+].fullUrl = "http://test.fhir.ch/r4/Observation/ChEkmObservationExample-ExposureViralDisease" // Observation
* entry[=].resource = ChEkmObservationExample-ExposureViralDisease
* entry[+].fullUrl = "http://test.fhir.ch/r4/Observation/ChEkmObservationExample-Occupation" // Observation
* entry[=].resource = ChEkmObservationExample-Occupation


Instance: ChEkmCompositionExample-HepatitisC
InstanceOf: ChEkmComposition
Usage: #example
Description: "Example for a CH EKM Composition: Hepatitis C"
* identifier.system = "urn:ietf:rfc:3986"
* identifier.value = "urn:uuid:1301332d-6012-443f-9690-929132b2e155"
* status = #final
* category = $sct#423876004 "Clinical report"
* type = $sct#722143004 "Infectious disease diagnostic study note"
* subject = Reference(ChEkmPatientExample)
* date = "2026-01-27"
* author = Reference(http://test.fhir.ch/r4/PractitionerRole/ChEkmPractitionerRoleTreatingPhysicianExample)
* title = "Meldung zum klinischen Befund Infektionskrankheit"

// Diagnosis section
* section[diagnosis].title = "Diagnosis section"
* section[diagnosis].code = $loinc#29308-4
* section[diagnosis].entry[0] = Reference(ChEkmConditionExample-HepatitisC)

// Laboratory section
* section[laboratory].title = "Laboratory Results section"
* section[laboratory].code = $loinc#30954-2
* section[laboratory].entry[0] = Reference(ChEkmServiceRequestExample-HepatitisC)
* section[laboratory].entry[1] = Reference(ChEkmObservationExample-HepatitisCVirusAb)

// Medication section
* section[medication].title = "Medication section"
* section[medication].code = $loinc#10160-0
* section[medication].entry[0] = Reference(ChEkmObservationExample-AntiviralTherapy)

// Social History section
* section[social-history].title = "Social History section"
* section[social-history].code = $loinc#29762-2
* section[social-history].entry[0] = Reference(ChEkmObservationExample-ExposureViralDisease)
* section[social-history].entry[1] = Reference(ChEkmObservationExample-Occupation)


Instance: ChEkmConditionExample-HepatitisC
InstanceOf: Condition
Usage: #example
Description: "Example for a CH EKM Condition: Hepatitis C"
* subject = Reference(ChEkmPatientExample)
//* category = $condition-category#encounter-diagnosis "Encounter Diagnosis"
* code = $sct#50711007 "Viral hepatitis type C (disorder)"
//* verificationStatus = $sct#410605003 "Confirmed present (qualifier value)"
* onsetDateTime.extension[+].url = "http://hl7.org/fhir/StructureDefinition/data-absent-reason"
* onsetDateTime.extension[=].valueCode = #asked-unknown
* evidence[0].code = $sct#707724006 "Liver enzymes level above reference range"
// * evidence[0].code.text = "Transaminase ≥ 2.5x"
* recorder = Reference(ChEkmPractitionerRoleTreatingPhysicianExample)

Instance: ChEkmObservationExample-HepatitisCVirusAb
InstanceOf: Observation
Usage: #example
Description: "Example for a CH EKM Observation: Hepatitis C virus Ab"
* status = #final
* code = $loinc#16128-1 "Hepatitis C virus Ab [Presence] in Serum"
* subject = Reference(ChEkmPatientExample)
* valueCodeableConcept = $sct#261665006 "Unknown (qualifier value)"

Instance: ChEkmObservationExample-AntiviralTherapy
InstanceOf: Observation
Usage: #example
Description: "Example for a CH EKM Observation: Antiviral Therapy"
* status = #final
* code = $sct#427314002 "Antiviral therapy (procedure)"
* subject = Reference(ChEkmPatientExample)
* valueCodeableConcept = $sct#386053000 "Evaluation procedure (procedure)"


Instance: ChEkmObservationExample-ExposureViralDisease
InstanceOf: Observation
Usage: #example
Description: "Example for a CH EKM Observation: Exposure to Viral Disease"
* extension[+].url = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-ext-exposition-address"
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

Instance: ChEkmObservationExample-Occupation
InstanceOf: Observation
Usage: #example
Description: "Example for a CH EKM Observation: Occupation"
* status = #final
* code = $loinc#21843-8 "History of Usual occupation"
* subject = Reference(ChEkmPatientExample)
* valueString = "Ärztin"



