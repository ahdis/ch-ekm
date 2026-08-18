// Hospitalisation  https://github.com/ahdis/ch-ekm/issues/27 "Hospitalisation").
//
//
// The three form answers (ja / nein / unbekannt) are encoded WITHOUT a coded flag anywhere:
//
//   ja        -> an Encounter exists: class = IMP, `period.start` = Eintrittsdatum,
//                `reasonReference` -> the diagnosis Condition (Hospitalisationsgrund = the reported
//                pathogen) or `reasonCode` (anderer / unbekannt). The inpatient class plus the
//                admission date already assert the stay, so no `hospitalization` element is needed.
//   nein      -> no Encounter at all, and no reference to one.
//   unbekannt -> an Encounter exists carrying nothing but
//                `hospitalization.extension[unknown]` = data-absent-reason#asked-unknown, i.e.
//                "we asked whether there was a hospitalisation and do not know". This is the reason
//                `hospitalization` is profiled here at all: an empty BackboneElement would violate
//                ele-1, the data-absent-reason extension is what gives it a child.
//
// "Spital" (the hospital name) is deliberately NOT yet modelled — the target is still
// undecided between `serviceProvider` (an Organization) and `location` (see TODO.md #6).

Profile: ChEkmEncounter
Parent: CHCoreEncounter
Id: ch-ekm-encounter
Title: "CH EKM Encounter: Hospitalisation"
Description: "This CH EKM base profile constrains the Encounter resource to represent the hospitalisation of the affected person: whether there was one, when it started and why. Referenced from Composition.encounter and from the diagnosis Condition.encounter."

* subject 1..
* subject only Reference(ChEkmPatient)

// Hospitalisation is an inpatient stay by definition; the report never carries an ambulatory
// contact, so the class is fixed rather than merely bound.
* class = $v3-ActCode#IMP "inpatient encounter"

// Eintrittsdatum. `period.end` is not asked on the form (the report is sent while the patient is
// still a case), so only the start is Must Support.
* period MS
* period.start MS
* period.start ^short = "Admission date"

// Hospitalisationsgrund. Exactly one of the two is used:
//   reasonReference -> the diagnosis Condition, when the stay is because of the reported disease
//   reasonCode      -> sct#74964007 (anderer) or sct#261665006 (unbekannt)
* reasonCode MS
* reasonCode ^short = "Hospitalisation reason when it is not the reported disease: 74964007 'Other' or 261665006 'Unknown'"
* reasonReference MS
* reasonReference ^short = "Hospitalisation reason if it is the reported disease: the diagnosis Condition of this report"
* reasonReference only Reference(ChEkmCondition)

// "Hospitalisation unknown". The element exists ONLY to carry the data-absent-reason; when the
// hospitalisation is reported as "yes" it is absent (the inpatient class and the admission date say
// it), and when it is "no" there is no Encounter in the first place.
* hospitalization 0..1 MS
* hospitalization ^short = "Present only when the hospitalisation question was answered 'unknown': carries extension[unknown] = data-absent-reason#asked-unknown and nothing else"
* hospitalization.extension contains $data-absent-reason named unknown 0..1 MS
* hospitalization.extension[unknown] ^short = "Hospitalisation reported as unknown (asked-unknown)"
