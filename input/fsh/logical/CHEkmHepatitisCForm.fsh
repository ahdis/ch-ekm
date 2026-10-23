// Logical model for the Hepatitis C clinical findings report — the master for
// ChEkmQuestionnaireHepatitisC.
//
// Only the sections where the Hepatitis C form differs from the generic models get their own
// sub-form (Person, Diagnose/Manifestation incl. Krankheitsverlauf); Labor, Verlauf, Exposition Wo/Wann
// and the treating physician reuse the generic models unchanged, exactly as the questionnaire reuses
// the shared sub-questionnaires. The form has no Impfstatus section.
//
// NOT MODELLED, because the form item has no agreed answer list or FHIR target yet (see the OPEN
// QUESTIONS in ChEkmQuestionnaireHepatitisC.fsh): Exposition "Wie" (ChEkmHepatitisCExposureForm below
// still carries the Gonorrhoea STI block and is therefore NOT part of the aggregate), Exposition
// "weitere", the Labor "Anlass", Serokonversion and antivirale Therapie.

Logical: ChEkmHepatitisCForm
Parent: Base
Title: "CH EKM Form: Hepatitis C"
Description: "Logical model for the form ChEkmHepatitisCForm."
Characteristics: #can-be-target

* person 1..1 ChEkmHepatitisCPersonForm "Affected person"
* manifestation 1..1 ChEkmHepatitisCManifestationForm "Diagnosis and manifestation"
* laboratory 0..1 Base "Laboratory"
  * organization 0..1 ChEkmLabForm "Analysing laboratory"
* course 0..1 Base "Course of the disease (Verlauf)"
  * hospitalisation 0..1 ChEkmHospitalisationForm "Hospitalisation"
  * death 0..1 ChEkmDeathForm "State (Zustand)"
// Wo and Wann only, see the header.
* exposure 0..1 ChEkmExposureForm "Exposure"
* treatingPhysician 1..1 Base "Treating physician"
  * practitioner 1..1 ChEkmTreatingPhysicianPractitionerForm "Practitioner"
  * organization 1..1 ChEkmTreatingPhysicianOrganizationForm "Organization"

Logical: ChEkmHepatitisCPersonForm
Parent: ChEkmPersonForm
Title: "CH EKM Form: Hepatitis C - Affected Person"
Description: "Logical model for the form section 'Affected person' (German form: 'Angaben zur betroffenen Person') of the Hepatitis C clinical findings report. One element per form item."
Characteristics: #can-be-target

* surnameInitial 0..0
* surname 1..1
* givennameInitial 0..0
* givenname 1..1
* dateOfBirth 1..1
* nationality 0..1
* streetLine 0..1
* zipCode 0..1
* city 0..1
* country 0..1
* canton 0..1
* phone 0..1
* email 0..1
* administrativeGender 1..1
* genderIdentity 0..1

Logical: ChEkmHepatitisCExposureForm
Parent: ChEkmExposureForm
Title: "CH EKM Form: Hepatitis C - Exposure"
Description: "Logical model for the form section 'Exposure' (German form: 'Exposition') of the Hepatitis C clinical findings report. One element per form item."
Characteristics: #can-be-target

// Wo on the structured level we will not have inland/ausland as separate items (discussed June 1st)
// No `unknown` element: both "Wo" questions carry their own unknown answer (see ChEkmExposureForm).
* where 0..1
  * country 0..1
  * preciseLocation 0..1
// Wie (Übertragungsweg)
* transmission 0..1 Base "Transmission route"
  * sexualContactPartner 0..1 CodeableConcept "Sexual contact (female, male)" // "anderes" / "unbekannt" still open in the NASURE form harmonisation (TODO.md)
  * relationshipType 0..1 CodeableConcept "Type of relationship (steady partner / non-steady partner / offered paid sex / used paid sex)"
  * otherTransmission 0..1 string "Other transmission route (free text)"
  * unknown 0..1 boolean "Unknown"

Mapping: HepatitisCExposureFormToExposure
Source: ChEkmHepatitisCExposureForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-exposure-hepatitisc"
Id: hepatitisc-exposure-form-to-exposure
Title: "Exposure Form to CH EKM Exposure"
* -> "Observation" "Maps the form section to the ChEkmExposureHepatitisC profile"
* transmission.sexualContactPartner -> "Observation.component[sexualContactPartner].valueCodeableConcept"
* transmission.relationshipType -> "Observation.component[relationshipType].valueCodeableConcept"
* transmission.otherTransmission -> "Observation.component[otherTransmission].valueString" "Other transmission route (component code sct#74964007)"
* transmission.unknown -> "Observation.component[transmissionRoute].valueCodeableConcept" "Ticked: sct#261665006 'Unknown'; the other transmission components are then not emitted"

// Two questions of this section have no resource target: the blood-donation question (asked first,
// before the manifestations) and the Krankheitsverlauf (directly after the Manifestationsbeginn).
// Their answers travel in the disease-specific QuestionnaireResponse the document carries in
// Composition.section[diagnosis], hence the second mapping.
Logical: ChEkmHepatitisCManifestationForm
Parent: ChEkmManifestationForm
Title: "CH EKM Form: Hepatitis C - Diagnosis and Manifestation"
Description: "Logical model for the form section 'Diagnosis and manifestation' (German form: 'Diagnose und Manifestation') of the Hepatitis C clinical findings report, including the course of the disease (German form: 'Krankheitsverlauf'). One element per form item."
Characteristics: #can-be-target

* manifestation ^short = "Manifestations (jaundice / elevated liver enzymes / elevated ALT / elevated AST / other / none / unknown)"
* manifestation from ChEkmHepatitisCManifestation (required)
* bloodDonation 0..1 CodeableConcept "Diagnosis made in the context of a blood donation (Diagnose im Rahmen einer Blutspende): yes / no / unknown"
* bloodDonation from ChEkmYesNoUnknown (required)
* courseOfDisease 0..* CodeableConcept "Course of the disease (Krankheitsverlauf): acute / chronic / cirrhosis / hepatocellular carcinoma / general wellbeing"
* courseOfDisease from ChEkmHepatitisCCourseOfDisease (required)

Mapping: HepatitisCManifestationToCondition
Source: ChEkmHepatitisCManifestationForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-condition-hepatitisc"
Id: hepatitisc-manifestation-to-condition
Title: "Manifestation Form to CH EKM Condition Hepatitis C"
* -> "Condition" "Maps the form section to the ChEkmConditionHepatitisC profile; Condition.code is fixed to sct#50711007"
* manifestation -> "Condition.evidence.code" "Manifestation coded from ChEkmHepatitisCManifestation"

Mapping: HepatitisCManifestationToQuestionnaireResponse
Source: ChEkmHepatitisCManifestationForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-questionnaireresponse-hepatitisc-diseasespecific"
Id: hepatitisc-manifestation-to-questionnaireresponse
Title: "Manifestation Form to CH EKM Questionnaire Response Disease-specific Hepatitis C"
* -> "QuestionnaireResponse" "The disease-specific response (to ChEkmQuestionnaireHepatitisCDiseaseSpecificAssembled), carried in Composition.section[diagnosis].entry[questionnaire-response]"
* bloodDonation -> "QuestionnaireResponse.item.answer.valueCoding" "The answer of the item with linkId 'blood-donation'"
* courseOfDisease -> "QuestionnaireResponse.item.answer.valueCoding" "The answers of the item with linkId 'hepatitisc-course-of-disease' (invariant ch-ekm-qr-hepatitisc-course)"
