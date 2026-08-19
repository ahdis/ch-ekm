// Form section "Zustand" (state) - the second half of the "Verlauf" (course) tab, next to
// Hospitalisation. Three form items: did the person die, when, and was the cause the reported
// pathogen. Gonorrhoea has no Verlauf, so nothing here is assembled into the Gonorrhoea root.
//
// The three items map onto TWO places, deliberately:
//   the death itself -> Patient.deceasedDateTime, so that "did this person die" is answerable
//                       from the Patient alone, without walking the Composition
//   the cause        -> a separate ChEkmObservationCauseOfDeath in section[cause-death]
// The presence of the section is NOT what says the person died - see ChEkmComposition.

Logical: ChEkmDeathForm
Parent: Base
Characteristics: #can-be-target
Title: "CH EKM Form: Death"
Description: "Logical model for the form section 'Zustand' (death), part of the 'Verlauf' section of the reporting form. One element per form item."

// Whether the person died. A plain flag: the form has no "unknown" answer here, unlike the
// hospitalisation question - a reporting physician either knows of the death or does not report one.
* deceased 0..1 boolean "Whether the affected person has died"

// Date of death - only asked when the answer above is true. May be left blank when the death is
// known but the date is not; that becomes a data-absent-reason on Patient.deceasedDateTime rather
// than a missing death.
* deathDate 0..1 dateTime "Date of death"

// Was the cause of death the disease this report is about? Only asked when the person died.
* causeOfDeath 0..1 CodeableConcept "Cause of death - the reported pathogen, another cause, or unknown"
* causeOfDeath from ChEkmCauseOfDeathChoice (required)

Mapping: DeathFormToPatient
Source: ChEkmDeathForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-patient"
Id: death-form-to-patient
Title: "Death Form to CH EKM Patient"
* -> "Patient" "Maps the death of the affected person to the ChEkmPatient profile"
* deceased -> "Patient.deceasedDateTime" "Answered true: deceasedDateTime is present. Not answered: the element is absent and no death is reported"
* deathDate -> "Patient.deceasedDateTime" "The date of death, when it is known"
* deathDate -> "Patient.deceasedDateTime.extension[dataabsentreason]" "Death reported without a date: deceasedDateTime has no value and carries data-absent-reason = asked-unknown"

Mapping: DeathFormToCauseOfDeath
Source: ChEkmDeathForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-observation-cause-of-death"
Id: death-form-to-cause-of-death
Title: "Death Form to CH EKM Observation Cause of Death"
* -> "Observation" "Maps the cause of death to the ChEkmObservationCauseOfDeath profile"
* causeOfDeath -> "Observation.valueCodeableConcept" "Answered 'reported pathogen': the disease code of this report. Answered 'other' (74964007): that qualifier verbatim"
* causeOfDeath -> "Observation.focus" "Answered 'reported pathogen': a reference to the diagnosis Condition of this report"
* causeOfDeath -> "Observation.dataAbsentReason" "Answered 'unknown' (261665006): no value, dataAbsentReason = asked-unknown"
