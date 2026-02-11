Profile: ChEkmComposition
Parent: Composition
Id: ch-ekm-composition
Title: "CH EKM Composition: Clinical Findings of Communicable Infectious Diseases Report"
Description: "This CH EKM base profile constrains the Composition resource for the purpose of clinical findings of communicable infectious diseases reports."

* status = #final
* type = $loinc#34782-3
* date 1..
* subject 1..
* subject only Reference(Patient)
* author ..1
* author only Reference(PractitionerRole)
* encounter ..1
* encounter only Reference(Encounter)

* section 2.. 
  * ^slicing.discriminator.type = #value
  * ^slicing.discriminator.path = "code"
  * ^slicing.rules = #closed

* section contains
    diagnosis 1..1 and
    laboratory 1..1 and
    hospitalization 0..1 and
    medication 0..1 and
    immunization 0..1 and
    risk-factors 0..1 and
    social-history 0..1 and
    cause-death 0..1 

// "Diagnosis"
* section[diagnosis].code = $loinc#29308-4
* section[diagnosis].entry 1..1
* section[diagnosis].entry only Reference(Condition)


// "Relevant diagnostic tests/laboratory data Narrative"
* section[laboratory].code = $loinc#30954-2
* section[laboratory].entry 1..1
* section[laboratory].entry only Reference(ServiceRequest)

// "History of hospitalizations+History of outpatient visits Narrative"
* section[hospitalization].code = $loinc#46240-8
* section[hospitalization].entry 1..1
* section[hospitalization].entry only Reference(Encounter)

// "History of immunization Narrative"
* section[immunization].code = $loinc#11369-6 
* section[immunization].entry 1..*
* section[immunization].entry only Reference(Immunization)

// "History of medication use Narrative"
* section[medication].code = $loinc#10160-0
* section[medication].entry 1..1
* section[medication].entry only Reference(Observation)

// "Risk Factors"
* section[risk-factors].code = $loinc#46467-7 
* section[risk-factors].entry 1..*
* section[risk-factors].entry only Reference(Condition)

// "Social history Narrative"
* section[social-history].code = $loinc#29762-2 
* section[social-history].section 2..2 
  * ^slicing.discriminator.type = #profile
  * ^slicing.discriminator.path = "$this"
  * ^slicing.rules = #closed
* section[social-history].section contains
    exposure-to-infectious-disease 1..1 and
    occupation 1..1
* section[social-history].section[exposure-to-infectious-disease].entry 1..1
* section[social-history].section[exposure-to-infectious-disease].entry only Reference(Observation)
* section[social-history].section[occupation].entry 1..1
* section[social-history].section[occupation].entry only Reference(Observation)

// "Cause of death"
* section[cause-death].code = $loinc#79378-6 
* section[cause-death].entry 1..*
* section[cause-death].entry only Reference(Condition)
