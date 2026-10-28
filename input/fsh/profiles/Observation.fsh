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
//   * every one of the three answers, "unknown" included, is a VALUE of that question:
//     `Observation.value[x]` holds an answer, whereas `Condition.code` asserts that the person has
//     the disease it names — a Condition-based model would have to pretend sct#261665006 "Unknown"
//     is a diagnosis.
//   * "another cause" would become `Condition.code = 74964007 "Other"`, i.e. asserting the person
//     has a condition called "Other".
//   * HL7 US VRDR, the reference IG for death reporting, moved exactly this profile from Condition
//     (STU1, VRDR-Cause-Of-Death-Condition) to Observation (STU2/STU3, vrdr-cause-of-death-part1,
//     LOINC 69453-9). US MDI and the vr-common-library followed.
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
Description: "This CH EKM base profile constrains the Observation resource to represent the cause of death: whether the person died of the disease this report is about, of another cause, or of a cause that is not known. All three are recorded as valueCodeableConcept - 'unknown' is the answer sct#261665006, not a dataAbsentReason. Referenced from Composition.section[cause-death]."
* status = #final
* code = $loinc#79378-6 "Cause of death"
* subject 1..1
* subject only Reference(ChEkmPatient)

// The cause itself, and the ONLY place the answer is carried: the three answers of
// ChEkmCauseOfDeathChoice map to the reported disease code, sct#74964007 "Other" and sct#261665006
// "Unknown" respectively.
//
// "UNKNOWN" IS A VALUE, NOT A dataAbsentReason (issue #28). The reporting physician did answer the
// question; the answer is "unknown", which is the same thing Encounter.reasonCode carries when the
// hospitalisation reason is unknown. `dataAbsentReason` would instead say that nothing was recorded,
// and would put the same fact in two different places depending on the answer. So it is forbidden
// here - one element, one shape, whatever the answer.
* value[x] 1..1
* value[x] only CodeableConcept
* valueCodeableConcept MS
* valueCodeableConcept ^short = "The cause of death: the reported disease itself, sct#74964007 'Other', or sct#261665006 'Unknown'"

// "The cause of death is the disease this report is about". The value already carries the disease
// code; this reference makes the statement machine-checkable without comparing codes, and is what
// links the death back to the diagnosis. NOT Condition.evidence.detail on the diagnosis, which an earlier
// proposal suggested: `evidence` is evidence FOR a condition, and a death is not evidence
// that somebody had mpox.
* focus 0..1 MS
* focus only Reference(ChEkmCondition)
* focus ^short = "The diagnosis Condition of this report, when the reported disease is the cause of death"


// Vaccination status - the "no" and "unknown" answers of the "Impfstatus" (vaccination status) section
// (https://github.com/ahdis/ch-ekm/issues/29).
//
// WHY AN OBSERVATION AND NOT AN Immunization. The form asks one CLOSED question per vaccination
// row - "Geimpft?", yes / no / unknown - and only "yes" describes a vaccination. R4
// `Immunization.status` has no "unknown", so "unknown" used to be carried as `not-done` plus a
// modifier extension that took the assertion back: a consumer that ignored the extension read
// "definitely not vaccinated" from a record that said the opposite. The two non-vaccination answers
// are therefore ANSWERS, not vaccinations, and they live in `Observation.value[x]` - the same move
// this IG already made for the cause of death (issue #28, ChEkmObservationCauseOfDeath above) and
// the same reason: `value[x]` holds an answer, whereas a resource's `status` asserts a fact.
//
// The three answers now reach the wire as:
//   yes       ChEkmImmunization, status = completed (with the date and the dose count)
//   no        this Observation, value = sct#373067005 "No"
//   unknown   this Observation, value = sct#261665006 "Unknown"
//   unanswered the same as "unknown" (issue #36: the question is optional, and FOPH records a row
//             left blank as "unknown" - the form pre-selects that answer)
// All of them are referenced from Composition.section[immunization], so the section holds one entry
// per form row whatever the answer was - which is what makes "was this person asked about the
// smallpox vaccination?" answerable, the argument that decided issue #28.
//
// WHICH VACCINATION THE ANSWER IS ABOUT - the single component. `Observation.code` is the generic
// observable sct#408864009 "Vaccination status"; SNOMED pre-coordinates a per-disease vaccination
// status for a handful of diseases only (308532005 influenza, 310374009 MMR, 442364007 H1N1) and
// for neither smallpox nor mpox, so the vaccination has to be post-coordinated. It is named by the
// SNOMED CT VACCINE PRODUCT of the row, which is the same concept ChEkmImmunizationMpox fixes as
// its `vaccineCode` fallback, with the target disease as the component's value. No CH EKM code
// system is minted for the component: both the code and the value are SNOMED CT.
//
// ONE component, not a slice: a row asks exactly one question about exactly one vaccination, so
// there is nothing to discriminate between. The disease specialisation fixes the two allowed
// products and the two allowed target diseases (see ChEkmObservationVaccinationStatusMpox), exactly
// as it does for Immunization.protocolApplied.targetDisease.
//
// `dataAbsentReason` is forbidden for the same reason as on the cause of death: "unknown" is an
// answer, not a missing recording. That holds for the unanswered row too - FOPH decided (issue #36)
// that it MEANS "unknown", so it is carried as that answer rather than as an absent value.
Profile: ChEkmObservationVaccinationStatus
Parent: Observation
Id: ch-ekm-observation-vaccination-status
Title: "CH EKM Observation: Vaccination status"
Description: "This CH EKM base profile constrains the Observation resource for the 'no' and 'unknown' answers of the 'Impfstatus' (vaccination status) section: for one vaccination relevant to the reported disease, that the affected person was not vaccinated, or that it is not known whether they were. A row left unanswered is reported as 'unknown'. A 'yes' answer is a ChEkmImmunization instead. Referenced from Composition.section[immunization]."
* . ^short = "CH EKM Observation: vaccination status ('no' / 'unknown') for one vaccination"
* status = #final
* code = $sct#408864009 "Vaccination status (observable entity)"
* subject 1..1
* subject only Reference(ChEkmPatient)

// The answer, and the only place it is carried.
* value[x] 1..1
* value[x] only CodeableConcept
* valueCodeableConcept from ChEkmVaccinationStatusNoUnknown (required)
* valueCodeableConcept MS
* valueCodeableConcept ^short = "sct#373067005 'No' or sct#261665006 'Unknown' — never 'Yes', which is a ChEkmImmunization"
* dataAbsentReason 0..0
* dataAbsentReason ^short = "Not used: 'unknown' is an answer and is carried in value[x]; an unanswered row is reported as 'unknown' too"

// The vaccination the answer is about.
* component 1..1
* component ^short = "The vaccination this answer is about: the vaccine product, with the disease it targets as its value"
* component.code from $SwissVaccinesVS (preferred)
* component.code ^short = "The SNOMED CT vaccine product of the form row — the same concept the 'yes' row of that line puts in Immunization.vaccineCode"
* component.value[x] 1..1
* component.value[x] only CodeableConcept
* component.valueCodeableConcept from $TargetDiseasesVS (preferred)
* component.valueCodeableConcept ^short = "The disease the vaccination protects against (e.g. smallpox, mpox) — the same concept the 'yes' row puts in Immunization.protocolApplied.targetDisease"


// Transgender status - the "Nein" answer of the form question "trans Person"
// (https://github.com/ahdis/ch-ekm/issues/35).
//
// WHY NOT THE PATIENT'S GENDER IDENTITY. The question has three answers: Nein, trans Mann, trans Frau.
// The two trans answers ARE gender identities and go to Patient.extension[genderIdentity]
// (individual-genderIdentity, the extension HL7 Gender Harmony recommends). "Nein" is not: putting
// sct#373067005 "No" there would state "gender identity = No", SNOMED CT has no "cisgender" or "not
// transgender" concept, and "not a trans man or trans woman" is not the same as cisgender anyway (a
// non-binary person, or a clinician who simply knows of nothing). Leaving the extension out would make
// an explicit "Nein" indistinguishable from an unanswered question, and FOPH wants the two apart.
//
// So "Nein" is an ANSWER to a closed question, and an answer lives in `Observation.value[x]` - the same
// split this IG makes for the Impfstatus (yes -> ChEkmImmunization, no/unknown ->
// ChEkmObservationVaccinationStatus) and for the cause of death. The three answers reach the wire as:
//   Nein         this Observation, value = sct#373067005 "No"
//   trans Mann   Patient.extension[genderIdentity].value = sct#1332083003
//   trans Frau   Patient.extension[genderIdentity].value = sct#1332082008
//   unanswered   nothing at all
//
// `code` is sct#1384187000 "Identifies as transgender (finding)", the direct parent of both trans
// concepts, so the question and its two positive answers sit in the same SNOMED CT hierarchy (under
// 285116001 "Gender identity finding"). Gender Harmony lists an Observation as one of the two
// standard ways to exchange gender identity; this is the narrower trans-status question.
//
// `value` is FIXED to "No": a trans answer must never appear here, or the same fact would have two
// homes. `dataAbsentReason` is forbidden: an unanswered question produces no Observation.
Profile: ChEkmObservationTransgenderStatus
Parent: Observation
Id: ch-ekm-observation-transgender-status
Title: "CH EKM Observation: Transgender status"
Description: "This CH EKM base profile constrains the Observation resource for the answer 'no' to the reporting form question 'trans person': the affected person is reported not to be a trans person. The answers 'trans man' and 'trans woman' are the gender identity of the patient (Patient.extension[genderIdentity]) instead. Referenced from Composition.section[social-history]."
* . ^short = "CH EKM Observation: transgender status ('no')"
* status = #final
* code = $sct#1384187000 "Identifies as transgender (finding)"
* subject 1..1
* subject only Reference(ChEkmPatient)

// The answer, and the only place it is carried.
* value[x] 1..1
* value[x] only CodeableConcept
* valueCodeableConcept = $sct#373067005 "No (qualifier value)"
* valueCodeableConcept MS
* valueCodeableConcept ^short = "Always sct#373067005 'No' - 'trans man' / 'trans woman' are Patient.extension[genderIdentity]"
* dataAbsentReason 0..0
* dataAbsentReason ^short = "Not used: an unanswered question produces no Observation at all"
