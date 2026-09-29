// Logical model for the invasive pneumococcal disease (invasive Streptococcus pneumoniae) clinical
// findings report — the master for ChEkmQuestionnaireInvasivePneumococcalDisease.
//
// Source: "Meldung zum klinischen Befund Infektionskrankheit - Pneumokokkenerkrankung.csv", the rows
// marked with an X. Only the sections where this form differs from the generic models get their own
// sub-form (Person, Manifestation, the one Impfstatus row); Labor, Verlauf, Exposition and the
// treating physician reuse the generic models unchanged, exactly as the questionnaire reuses the
// shared sub-questionnaires.
//
// NOT MODELLED, because the form item has no agreed answer list or FHIR target yet (see TODO.md,
// "Invasive pneumococcal disease — Open questions"): Risikofaktoren, Exposition "Wie", the Labor
// "Anlass", "Spital", and "Gemäss: Impfausweis / Hausarzt / Anamnese".

Logical: ChEkmInvasivePneumococcalDiseaseForm
Parent: Base
Title: "CH EKM Form: Invasive Pneumococcal Disease"
Description: "Logical model for the form ChEkmInvasivePneumococcalDiseaseForm."
Characteristics: #can-be-target

* person 1..1 ChEkmInvasivePneumococcalDiseasePersonForm "Affected person"
* manifestation 1..1 ChEkmInvasivePneumococcalDiseaseManifestationForm "Diagnosis and manifestation"
* laboratory 0..1 Base "Laboratory"
  * organization 0..1 ChEkmLabForm "Analysing laboratory"
  * specimen 0..1 ChEkmLabSpecimenForm "Sample"
* course 0..1 Base "Course of the disease (Verlauf)"
  * hospitalisation 0..1 ChEkmHospitalisationForm "Hospitalisation"
  * death 0..1 ChEkmDeathForm "State (Zustand)"
// Wo and Wann only. The CSV marks neither with an X — confirm the paper form asks them (TODO.md, open
// question 5). "Wie" has no answer list, hence no sub-form refining ChEkmExposureForm.
* exposure 0..1 ChEkmExposureForm "Exposure"
// One row, see ChEkmImmunizationForm for why the model describes a single row.
* immunization 0..1 Base "Vaccination status (Impfstatus)"
  * pneumococcal 0..1 ChEkmInvasivePneumococcalDiseaseImmunizationForm "Pneumococcal vaccination (Pneumokokkenimpfung)"
* treatingPhysician 1..1 Base "Treating physician"
  * practitioner 1..1 ChEkmTreatingPhysicianPractitionerForm "Practitioner"
  * organization 1..1 ChEkmTreatingPhysicianOrganizationForm "Organization"

// INITIALS, like Gonorrhoea: ChEkmCompositionInvasivePneumococcalDisease constrains `subject` to
// ChEkmPatientInitials, and the CSV X-marks "initiale Name" / "initiale Vorname" but not the full
// name rows. No gender identity: the CSV has only "Administratives Geschlecht".
Logical: ChEkmInvasivePneumococcalDiseasePersonForm
Parent: ChEkmPersonForm
Title: "CH EKM Form: Invasive Pneumococcal Disease - Affected Person"
Description: "Logical model for the form section 'Affected person' (German form: 'Angaben zur betroffenen Person') of the invasive pneumococcal disease clinical findings report. One element per form item."
Characteristics: #can-be-target

* surnameInitial 1..1
* surname 0..0
* givennameInitial 1..1
* givenname 0..0
* dateOfBirth 1..1
* ahvn13 0..1
* nationality 0..1
* zipCode 0..1
* city 0..1
* country 0..1
* canton 0..1
* administrativeGender 1..1
* genderIdentity 0..0

Mapping: InvasivePneumococcalDiseasePersonToPatientInitials
Source: ChEkmInvasivePneumococcalDiseasePersonForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-patient-initials"
Id: invasivepneumococcaldisease-person-to-patient-initials
Title: "Person Form to CH EKM Patient Initials"
* -> "Patient" "Maps the form section to the ChEkmPatientInitials profile"
* surnameInitial -> "Patient.name.family" "Initial of the family name"
* givennameInitial -> "Patient.name.given" "Initial of the given name"

// The answer list is the one ChEkmConditionInvasivePneumococcalDisease binds `evidence.code` to.
// Whether it or the pre-coordinated ChEkmPneumococcalDiseaseManifestation is authoritative is still
// open (TODO.md, open question 2); change the binding here and in the Condition profile together.
Logical: ChEkmInvasivePneumococcalDiseaseManifestationForm
Parent: ChEkmManifestationForm
Title: "CH EKM Form: Invasive Pneumococcal Disease - Diagnosis and Manifestation"
Description: "Logical model for the form section 'Diagnosis and manifestation' (German form: 'Diagnose und Manifestation') of the invasive pneumococcal disease clinical findings report. One element per form item."
Characteristics: #can-be-target

* manifestation ^short = "Manifestations (pneumonia / sepsis / meningitis / other / none / unknown)"
* manifestation from ChEkmInvasivePneumococcalDiseaseManifestation (required)

Mapping: InvasivePneumococcalDiseaseManifestationToCondition
Source: ChEkmInvasivePneumococcalDiseaseManifestationForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-condition-invasivepneumococcaldisease"
Id: invasivepneumococcaldisease-manifestation-to-condition
Title: "Manifestation Form to CH EKM Condition Invasive Pneumococcal Disease"
* -> "Condition" "Maps the form section to the ChEkmConditionInvasivePneumococcalDisease profile; Condition.code is fixed to sct#406617004"
* manifestation -> "Condition.evidence.code" "Manifestation coded from ChEkmInvasivePneumococcalDiseaseManifestation"

// The single "Pneumokokkenimpfung" row. The conjugate and the polysaccharide vaccines share it; the
// answered brand (Prevenar 13, Pneumovax 23, ...) is what tells them apart.
Logical: ChEkmInvasivePneumococcalDiseaseImmunizationForm
Parent: ChEkmImmunizationForm
Title: "CH EKM Form: Invasive Pneumococcal Disease - Immunization"
Description: "Logical model for the one row of the form section 'Vaccination status' (German form: 'Impfstatus') of the invasive pneumococcal disease clinical findings report (pneumococcal vaccination). One element per form item."
Characteristics: #can-be-target

* targetDisease ^short = "Pneumococcal infectious disease (sct#16814004)"
* targetDisease from ChEkmInvasivePneumococcalDiseaseImmunizationTargetDisease (required)

Mapping: InvasivePneumococcalDiseaseImmunizationFormToImmunization
Source: ChEkmInvasivePneumococcalDiseaseImmunizationForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-immunization-invasivepneumococcaldisease"
Id: invasivepneumococcaldisease-immunization-form-to-immunization
Title: "Immunization Form to CH EKM Immunization Invasive Pneumococcal Disease"
* -> "Immunization" "Maps the row answered 'yes' to the ChEkmImmunizationInvasivePneumococcalDisease profile"
* targetDisease -> "Immunization.protocolApplied.targetDisease" "sct#16814004 Pneumococcal infectious disease"
* vaccine -> "Immunization.vaccineCode" "A picked Swiss vaccine code or a typed brand name; when nothing was answered, sct#836398006 Streptococcus pneumoniae antigen-containing vaccine product"

Mapping: InvasivePneumococcalDiseaseImmunizationFormToVaccinationStatus
Source: ChEkmInvasivePneumococcalDiseaseImmunizationForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-observation-vaccination-status-invasivepneumococcal"
Id: invasivepneumococcal-immunization-form-to-vaccination-status
Title: "Immunization Form to CH EKM Vaccination Status Invasive Pneumococcal Disease"
* -> "Observation" "Maps the row answered 'no' or 'unknown' to the ChEkmObservationVaccinationStatusInvasivePneumococcalDisease profile"
* targetDisease -> "Observation.component.valueCodeableConcept" "sct#16814004 Pneumococcal infectious disease"
* vaccine -> "Observation.component.code" "Always sct#836398006 Streptococcus pneumoniae antigen-containing vaccine product"
