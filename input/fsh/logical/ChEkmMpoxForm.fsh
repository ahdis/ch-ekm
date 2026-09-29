// Logical model for the Mpox clinical findings report — the master for ChEkmQuestionnaireMpox.
//
// Only the sections where the Mpox form differs from the generic models get their own sub-form
// (Person, Manifestation, Exposure "Wie", the two Impfstatus rows); Verlauf and the treating
// physician reuse the generic models unchanged, exactly as the questionnaire reuses the shared
// sub-questionnaires. The Mpox form has no Labor block.
//
// NOT MODELLED: "Spital" (see ChEkmHospitalisationForm) and the second "Wann" question, the last entry
// into Switzerland (commented out in ChEkmExposureForm, TODO.md Hepatitis C open question 9).

Logical: ChEkmMpoxForm
Parent: Base
Title: "CH EKM Form: Mpox"
Description: "Logical model for the form ChEkmMpoxForm."
Characteristics: #can-be-target

* person 1..1 ChEkmMpoxPersonForm "Affected person"
* manifestation 1..1 ChEkmMpoxManifestationForm "Diagnosis and manifestation"
* course 0..1 Base "Course of the disease (Verlauf)"
  * hospitalisation 0..1 ChEkmHospitalisationForm "Hospitalisation"
  * death 0..1 ChEkmDeathForm "State (Zustand)"
* exposure 0..1 ChEkmMpoxExposureForm "Exposure"
// Two rows, see ChEkmImmunizationForm for why the model describes a single row.
* immunization 0..1 Base "Vaccination status (Impfstatus)"
  * smallpox 0..1 ChEkmMpoxImmunizationForm "Smallpox vaccination (Pockenimpfung), target disease sct#67924001"
  * mpox 0..1 ChEkmMpoxImmunizationForm "Mpox vaccination (Affenpockenimpfung), target disease sct#359814004"
* treatingPhysician 1..1 Base "Treating physician"
  * practitioner 1..1 ChEkmTreatingPhysicianPractitionerForm "Practitioner"
  * organization 1..1 ChEkmTreatingPhysicianOrganizationForm "Organization"

// FULL NAME, like Hepatitis C and unlike Gonorrhoea: ChEkmCompositionMpox constrains `subject` to
// ChEkmPatient. Both name items are required on the form.
Logical: ChEkmMpoxPersonForm
Parent: ChEkmPersonForm
Title: "CH EKM Form: Mpox - Affected Person"
Description: "Logical model for the form section 'Affected person' (German form: 'Angaben zur betroffenen Person') of the Mpox clinical findings report. One element per form item."
Characteristics: #can-be-target

* surnameInitial 0..0
* surname 1..1
* givennameInitial 0..0
* givenname 1..1
* dateOfBirth 1..1
* ahvn13 0..1
* nationality 0..1
* zipCode 0..1
* city 0..1
* country 0..1
* canton 0..1
* administrativeGender 1..1
* genderIdentity 0..1

Logical: ChEkmMpoxManifestationForm
Parent: ChEkmManifestationForm
Title: "CH EKM Form: Mpox - Diagnosis and Manifestation"
Description: "Logical model for the form section 'Diagnosis and manifestation' (German form: 'Diagnose und Manifestation') of the Mpox clinical findings report. One element per form item."
Characteristics: #can-be-target

* manifestation ^short = "Manifestations (skin lesions by site / lymphadenopathy / systemic symptoms / other / none / unknown)"
* manifestation from ChEkmMpoxManifestation (required)

Mapping: MpoxManifestationToCondition
Source: ChEkmMpoxManifestationForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-condition-mpox"
Id: mpox-manifestation-to-condition
Title: "Manifestation Form to CH EKM Condition Mpox"
* -> "Condition" "Maps the form section to the ChEkmConditionMpox profile; Condition.code is fixed to sct#359814004"
* manifestation -> "Condition.evidence.code" "Manifestation coded from ChEkmMpoxManifestation"

// Wo and Wann come from ChEkmExposureForm; "Wie" is the same four questions the Gonorrhoea form asks
// (the shared ChEkmQuestionnaireExposureHow, whose item definitions point at
// ChEkmGonorrhoeaExposureForm), extracted into the sliced components of ChEkmExposureMpox.
Logical: ChEkmMpoxExposureForm
Parent: ChEkmExposureForm
Title: "CH EKM Form: Mpox - Exposure"
Description: "Logical model for the form section 'Exposure' (German form: 'Exposition') of the Mpox clinical findings report. One element per form item."
Characteristics: #can-be-target

// Wie (Übertragungsweg)
* transmission 0..1 Base "Transmission route"
  * sexualContactPartner 0..1 CodeableConcept "Sexual contact (female, male, other)"
  * sexualContactPartner from ChEkmPatientAdministrativeSex (required)
  * relationshipType 0..1 CodeableConcept "Type of relationship (anonymous partner / known partner / paid sex / unknown)"
  * relationshipType from ChEkmExposureRelationshipType (required)
  * otherTransmission 0..1 string "Other transmission route (free text)"
  * unknown 0..1 boolean "Unknown"

Mapping: MpoxExposureFormToExposure
Source: ChEkmMpoxExposureForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-exposure-mpox"
Id: mpox-exposure-form-to-exposure
Title: "Exposure Form to CH EKM Exposure Mpox"
* -> "Observation" "Maps the form section to the ChEkmExposureMpox profile"
* transmission.sexualContactPartner -> "Observation.component[sexualContactPartner].valueCodeableConcept"
* transmission.relationshipType -> "Observation.component[relationshipType].valueCodeableConcept"
* transmission.otherTransmission -> "Observation.component[otherTransmission].valueString" "Other transmission route (component code sct#74964007)"
* transmission.unknown -> "Observation.component[transmissionRoute].valueCodeableConcept" "Ticked: sct#261665006 'Unknown'; the other transmission components are then not emitted"

// One instance per row; the row's target disease is fixed by the extraction template, and this binding
// keeps it to the two the Mpox form asks about.
Logical: ChEkmMpoxImmunizationForm
Parent: ChEkmImmunizationForm
Title: "CH EKM Form: Mpox - Immunization"
Description: "Logical model for one row of the form section 'Vaccination status' (German form: 'Impfstatus') of the Mpox clinical findings report (smallpox vaccination or mpox vaccination). One element per form item."
Characteristics: #can-be-target

* targetDisease ^short = "Smallpox (sct#67924001) or Mpox (sct#359814004)"
* targetDisease from ChEkmMpoxImmunizationTargetDisease (required)

Mapping: MpoxImmunizationFormToImmunization
Source: ChEkmMpoxImmunizationForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-immunization-mpox"
Id: mpox-immunization-form-to-immunization
Title: "Immunization Form to CH EKM Immunization Mpox"
* -> "Immunization" "Maps a row answered 'yes' to the ChEkmImmunizationMpox profile"
* targetDisease -> "Immunization.protocolApplied.targetDisease" "sct#67924001 Smallpox or sct#359814004 Mpox"
* vaccine -> "Immunization.vaccineCode" "A picked Swiss vaccine code or a typed brand name; when nothing was answered, the row's product from ChEkmMpoxVaccineProduct"

Mapping: MpoxImmunizationFormToVaccinationStatus
Source: ChEkmMpoxImmunizationForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-observation-vaccination-status-mpox"
Id: mpox-immunization-form-to-vaccination-status
Title: "Immunization Form to CH EKM Vaccination Status Mpox"
* -> "Observation" "Maps a row answered 'no' or 'unknown' to the ChEkmObservationVaccinationStatusMpox profile"
* targetDisease -> "Observation.component.valueCodeableConcept" "sct#67924001 Smallpox or sct#359814004 Mpox"
* vaccine -> "Observation.component.code" "Always the row's product: sct#1290624003 (smallpox) or sct#1293025000 (mpox, MVA-BN)"
