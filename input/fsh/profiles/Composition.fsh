Profile: ChEkmDocument
Parent: CHCoreDocument
Id: ch-ekm-document
Title: "CH EKM-Document: Clinical findings of Communicable Infectious Diseases Report "
Description: "This profile constrains the Bundle resource for the purpose of clinical findings of communicable infectious diseases reports."
* . ^short = "CH EKM Document: Clinical findings report"

* entry[Composition].resource only ChEkmComposition

Profile: ChEkmComposition
Parent: CHCoreComposition
Id: ch-ekm-composition
Title: "CH EKM Composition: Clinical Findings of Communicable Infectious Diseases Report"
Description: "This CH EKM base profile constrains the Composition resource for the purpose of clinical findings of communicable infectious diseases reports."

* status = #final
* category = $sct#423876004 "Clinical report"
* type = $sct#722143004 "Infectious disease diagnostic study note"
* date 1..
* subject 1..
* subject only Reference(ChEkmPatient)
* author 1..
* author only Reference(ChEkmPractitionerRole)
* author ^short = "Author of the report. This can be either the treating physician or a private service provider (so-called broker) who transmits the report to the reporting system of the Federal Office of Public Health on behalf of the treating physician."
* encounter ..1
* encounter only Reference(CHCoreEncounter)

* section 1..*
  * ^slicing.discriminator.type = #value
  * ^slicing.discriminator.path = "code"
  * ^slicing.rules = #open 

* section contains
    diagnosis 1..1 and
    laboratory 0..1 and
    hospitalization 0..1 and
    medication 0..1 and
    immunization 0..1 and
    risk-factors 0..1 and
    social-history 0..1 and
    cause-death 0..1 

// "Diagnosis"
* section[diagnosis].code = $loinc#29308-4
* section[diagnosis].entry ^slicing.discriminator.type = #profile
* section[diagnosis].entry ^slicing.discriminator.path = "$this.resolve()"
* section[diagnosis].entry ^slicing.rules = #open
* section[diagnosis].entry contains
    condition 1..1 and
    questionnaire-response 0..1
* section[diagnosis].entry[condition] only Reference(ChEkmCondition)
* section[diagnosis].entry[questionnaire-response] only Reference(QuestionnaireResponse)


// "Relevant diagnostic tests/laboratory data Narrative"
* section[laboratory].code = $loinc#30954-2
* section[laboratory].entry ^slicing.discriminator.type = #profile
* section[laboratory].entry ^slicing.discriminator.path = "$this.resolve()"
* section[laboratory].entry ^slicing.rules = #open 
* section[laboratory].entry contains
    lab-order 1..1 and
    seroconversion 0..1
* section[laboratory].entry[lab-order] only Reference(ChEkmServiceRequest)
* section[laboratory].entry[seroconversion] only Reference(Observation)

// "History of hospitalizations+History of outpatient visits Narrative"
* section[hospitalization].code = $loinc#46240-8
* section[hospitalization].entry 1..1
* section[hospitalization].entry only Reference(CHCoreEncounter)

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
* section[social-history].entry ^slicing.discriminator.type = #profile
* section[social-history].entry ^slicing.discriminator.path = "$this.resolve()"
* section[social-history].entry ^slicing.rules = #open 
* section[social-history].entry contains
    exposure-to-infectious-disease 1..*
//     and
//    occupation 1..1
* section[social-history].entry[exposure-to-infectious-disease] only Reference(Observation)
// * section[social-history].section[occupation].entry 1..1
// * section[social-history].section[occupation].entry only Reference(Observation)
// this doest not work we need ot make the slicing different

// "Cause of death"
* section[cause-death].code = $loinc#79378-6 
* section[cause-death].entry 1..*
* section[cause-death].entry only Reference(Condition)
