Profile: ChEkmDocumentInvasivePneumococcalDisease
Parent: ChEkmDocument
Id: ch-ekm-document-invasivepneumococcaldisease
Title: "CH EKM-Document: Clinical findings Invasive Pneumococcal Disease"
Description: "This profile constrains the Bundle resource for the purpose of clinical findings for Invasive Pneumococcal Disease."
* entry[Composition].resource only ChEkmCompositionInvasivePneumococcalDisease

Profile: ChEkmCompositionInvasivePneumococcalDisease
Parent: ChEkmComposition
Id: ch-ekm-composition-invasivepneumococcaldisease
Title: "CH EKM Composition: Clinical Findings Invasive Pneumococcal Disease"
Description: "This CH EKM base profile constrains the Composition resource for the purpose of clinical findings for Invasive Pneumococcal Disease."
* subject only Reference(ChEkmPatientInitials)
* section[diagnosis].entry[condition] only Reference(ChEkmConditionInvasivePneumococcalDisease)
* section[immunization].entry[immunization] only Reference(ChEkmImmunizationInvasivePneumococcalDisease)
* section[immunization].entry[vaccination-status] only Reference(ChEkmObservationVaccinationStatusInvasivePneumococcalDisease)

Profile: ChEkmConditionInvasivePneumococcalDisease
Parent: ChEkmCondition
Id: ch-ekm-condition-invasivepneumococcaldisease
Title: "CH EKM Condition: Invasive Pneumococcal Disease"
Description: "This CH EKM base profile constrains the Condition resource for the purpose of clinical findings for Invasive Pneumococcal Disease."
* code = $sct#406617004 "Invasive Streptococcus pneumoniae disease (disorder)"
* evidence.code from ChEkmInvasivePneumococcalDiseaseManifestation (required)

// Impfstatus (https://github.com/ahdis/ch-ekm/issues/29). The invasive pneumococcal disease form
// asks about ONE vaccination type, so this profile does the same two things ChEkmImmunizationMpox
// does for its two rows: it fixes which target disease may appear, and it constrains the fallback
// product code to the SNOMED CT vaccine product for it - the concept extraction writes when the
// physician did not pick a brand from the Swiss vaccine list.
//
//   Pneumokokkenimpfung  targetDisease sct#16814004  Pneumococcal infectious disease
//                        fallback      sct#836398006 Streptococcus pneumoniae antigen-containing
//                                                    vaccine product
//
// ONE ROW, ONE RESOURCE, WITH THE TOTAL DOSE COUNT. `protocolApplied.doseNumberPositiveInt` is the
// TOTAL number of doses of the series, and `occurrenceDateTime` the date of the LAST dose - the
// shape the base ChEkmImmunization documents and the form asks for. The example Bundle
// ChEkmBundleInvasiveStreptococcusPneumoniae instead carries one Immunization PER DOSE
// (doseNumber 1 and 2, two occurrence dates), which is the CH VACD vaccination-record shape; the
// FORM does not produce that, because a variable number of resources cannot come out of the single
// Bundle template that drives $extract (forms-summary.md section 8). The two representations are not
// in conflict on the wire - both are valid ChEkmImmunizations - but a report produced by this
// questionnaire always has exactly one.
//
// ONE ROW, SO NO "Pneumokokken 13-valent vs. 23-valent" DISTINCTION either: the conjugate and the
// polysaccharide vaccines share the row, and the brand (Prevenar 13, Pneumovax 23, ...) is what
// separates them, in vaccineCode.
Profile: ChEkmImmunizationInvasivePneumococcalDisease
Parent: ChEkmImmunization
Id: ch-ekm-immunization-invasivepneumococcaldisease
Title: "CH EKM Immunization: Invasive pneumococcal disease"
Description: "This CH EKM profile constrains the Immunization resource for the 'Impfstatus' section of the invasive pneumococcal disease report: one resource for the single vaccination type asked about (pneumococcal vaccination), carrying the TOTAL number of doses and the date of the last dose."
* protocolApplied.targetDisease from ChEkmInvasivePneumococcalDiseaseImmunizationTargetDisease (required)

// The "no" / "unknown" counterpart of ChEkmImmunizationInvasivePneumococcalDisease: same form row,
// same vaccine product, same target disease - only the answer differs, and with it the resource
// type (issue #29). Fixing both ends of the component keeps the two halves of the one form line
// consistent:
//   Pneumokokkenimpfung  component.code  sct#836398006 Streptococcus pneumoniae antigen-containing
//                                                      vaccine product
//                        component.value sct#16814004  Pneumococcal infectious disease
// The same product / target disease pair the "yes" row puts in Immunization.vaccineCode and
// Immunization.protocolApplied.targetDisease, so both halves answer "which vaccination?" the same way.
Profile: ChEkmObservationVaccinationStatusInvasivePneumococcalDisease
Parent: ChEkmObservationVaccinationStatus
// NB the id drops the "disease" suffix the other ids in this file carry: the full
// `…-invasivepneumococcaldisease` form is 65 characters and a FHIR id may be at most 64.
Id: ch-ekm-observation-vaccination-status-invasivepneumococcal
Title: "CH EKM Observation: Vaccination status invasive pneumococcal disease"
Description: "This CH EKM profile constrains the Observation resource for the 'no' and 'unknown' answers of the 'Impfstatus' (vaccination status) section of the invasive pneumococcal disease report: the single vaccination type asked about (pneumococcal vaccination) that the person did not receive or where it is not known."
* component.code from ChEkmInvasivePneumococcalDiseaseVaccineProduct (required)
* component.valueCodeableConcept from ChEkmInvasivePneumococcalDiseaseImmunizationTargetDisease (required)
