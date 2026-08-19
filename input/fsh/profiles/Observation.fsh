Profile: ChEkmExposure
Parent: Observation
Id: ch-ekm-exposure
Title: "CH EKM Exposure"
Description: "This CH EKM base profile constrains the Observation resource to represent the exposure (Exposition): how and where the patient was most likely exposed to the infectious agent. The structure mirrors the HL7 Europe HDR 'Infectious Contact' profile (ActClassExposure category, exposure agent as value), extended with the CH EKM exposure address extension for the place of exposure. See http://hl7.eu/fhir/hdr/StructureDefinition/observation-infectious-contact-eu-hdr."
* status MS
* category 1..1
* category from ChEkmExposureClass (required)
* category ^short = "Exposure classification (acquisition / transmission / unknown)"
* code = $v3-ParticipationType#EXPAGNT "Exposure Agent"
* value[x] only CodeableConcept
* value[x] ^short = "The exposure agent, e.g. the organism the patient was exposed to"
* effective[x] only dateTime or Period
* effective[x] ^short = "When the exposure took place (When) - the most probable point in time of infection; a Period when only a time window is known"
* subject 1..1
* subject only Reference(ChEkmPatient)

* extension contains ChEkmExtExposureAddress named exposureAddress 0..1
* extension[exposureAddress] ^short = "Place/address of exposure (Where)"

// When - the form asks for the date of the last entry into Switzerland when the point in time of
// infection itself is unknown. That date is NOT the exposure time (it only bounds the window in
// which the exposure abroad must have happened), so it is recorded as its own component instead of
// as effective[x]. Sliced here on the base profile: every organism asking "Wann" reuses this slice.
* component ^slicing.discriminator.type = #pattern
* component ^slicing.discriminator.path = "code"
* component ^slicing.rules = #open
* component contains dateOfEntry 0..1 MS
* component[dateOfEntry] ^short = "Date of the last entry into Switzerland (Only when the point in time of infection is unknown)"
* component[dateOfEntry].code = $sct#161097008 "Date of return from travel"
* component[dateOfEntry].value[x] only dateTime



// Cause of death (the "Zustand" half of the Verlauf section).
//
// AN OBSERVATION, NOT A CONDITION. The form asks one CLOSED question — was the cause of death the
// reported pathogen, another cause, or unknown — which is an answer to a question rather than an
// assertion that the person has a disease. Three consequences settle the resource choice:
//   * "unknown" needs `dataAbsentReason`; Condition has no equivalent, so a Condition-based model
//     has to invent a code (sct#87309006) that pretends "we don't know" is a diagnosis.
//   * "another cause" would become `Condition.code = 74964007 "Other"`, i.e. asserting the person
//     has a condition called "Other".
//   * HL7 US VRDR, the reference IG for death reporting, moved exactly this profile from Condition
//     (STU1, VRDR-Cause-Of-Death-Condition) to Observation (STU2/STU3, vrdr-cause-of-death-part1,
//     LOINC 69453-9 + dataAbsentReason). US MDI and the vr-common-library followed.
// The Swiss precedent, ch-crl-condition-finalcauseofdeath, is a Condition with
// `category = loinc#79378-6`; if cross-IG consistency ever outweighs the above, that is the shape
// to switch to.
//
// Deliberately NOT adopted from VRDR/MDI: the part1 / part2 split and the cause-of-death pathway
// List. Those model an ordered causal chain on a death certificate; CH EKM asks a single question
// and issues no certificate.
//
// The date of death is NOT here — it is `Patient.deceasedDateTime` (see ChEkmPatient), so that a
// consumer can find the fact of death without walking the Composition.
Profile: ChEkmObservationCauseOfDeath
Parent: Observation
Id: ch-ekm-observation-cause-of-death
Title: "CH EKM Observation: Cause of Death"
Description: "This CH EKM base profile constrains the Observation resource to represent the cause of death: whether the person died of the disease this report is about, of another cause, or of a cause that is not known. Referenced from Composition.section[cause-death]."
* status = #final
* code = $loinc#79378-6 "Cause of death"
* subject 1..1
* subject only Reference(ChEkmPatient)

// The cause itself. Absent when the cause was reported as unknown - `dataAbsentReason` carries that
// case, which is the whole reason this is an Observation (see the header).
* value[x] only CodeableConcept
* valueCodeableConcept MS
* valueCodeableConcept ^short = "The cause of death: the reported disease itself, or sct#74964007 'Other'. Absent when reported as unknown - see dataAbsentReason"
* dataAbsentReason MS
* dataAbsentReason ^short = "Present instead of a value when the cause of death was reported as unknown (asked-unknown)"

// "The cause of death is the disease this report is about". The value already carries the disease
// code; this reference makes the statement machine-checkable without comparing codes, and is what
// links the death back to the diagnosis. NOT Condition.evidence.detail on the diagnosis, which the
// paper proposal suggested: `evidence` is evidence FOR a condition, and a death is not evidence
// that somebody had mpox.
* focus 0..1 MS
* focus only Reference(ChEkmCondition)
* focus ^short = "The diagnosis Condition of this report, when the reported disease is the cause of death"
