// Source data for SDC $populate: the hospitalisation the Mpox form is pre-filled from.
//
// scripts/populate-mpox.sh hands this Encounter to the form as the `encounter` launch context
// (%encounter), where the three Hospitalisation items read it:
//   hospitalisationStatus        <- no data-absent-reason on `hospitalization` -> "ja" (373066001)
//   hospitalisationReason        <- reasonReference is set  -> the local `reported-pathogen` answer
//   hospitalisationAdmissionDate <- period.start
// To exercise the "unbekannt" branch instead, hand the script an Encounter whose `hospitalization`
// carries data-absent-reason#asked-unknown; to exercise "anderer", one with a reasonCode.
//
// The full-name patient (ChEkmPatientExample) is used because Mpox reports the full name, unlike
// Gonorrhoea, which pre-populates from ChEkmPatientInitialsExample.

Instance: ChEkmConditionMpoxExample
InstanceOf: ChEkmConditionMpox
Usage: #example
Description: "Example for a CH EKM Condition: Mpox. The diagnosis the hospitalisation Encounter below points at as its reason."
* category = $condition-category#encounter-diagnosis
* subject = Reference(ChEkmPatientExample)
* onsetDateTime = "2026-01-20"
* evidence[0].code = $sct#95324001 "Skin lesion (disorder)"

Instance: ChEkmEncounterMpoxExample
InstanceOf: ChEkmEncounter
Usage: #example
Description: "Example for a CH EKM Encounter: hospitalisation because of Mpox. Used as the `encounter` launch context by scripts/populate-mpox.sh."
* status = #unknown
* class = $v3-ActCode#IMP "inpatient encounter"
* subject = Reference(ChEkmPatientExample)
* period.start = "2026-01-27"
* reasonReference = Reference(ChEkmConditionMpoxExample)
