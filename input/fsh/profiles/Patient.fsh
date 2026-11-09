// ChEkmPatient derives from the CH ELM Patient (ch-elm-patient, CH ELM 1.15.x), so the laboratory
// report (ELM) and the clinical report (EKM) send the FOPH the same Patient. CH ELM already brings:
// - name 1..1 as ch-elm-humanname (family 1.., given 1..1, data-absent-reason on both, the
//   ch-elm-ext-hiv-code and the retired ch-elm-ext-vct-code extension, closed below),
// - gender 1.., birthDate 1.. with a data-absent-reason slice,
// - identifier slices: AHVN13 ..1 MS, LocalPid ..1, IDN (Liechtenstein) ..1 MS, EPR-SPID and
//   insuranceCardNumber 0..0,
// - address ..1 with the `home` slice (use = home, line ..1 with street name / house number, city,
//   postalCode, state, country with the countrycode coding bound to bfs-country-codes),
// - telecom[phone] ..1, and the invariants ch-elm-patient-address-require-countrycode and
//   ch-elm-patient-nameorlocalpid.
// What follows is only what the clinical report adds on top.

Profile: ChEkmPatient
Parent: $ch-elm-patient
Id: ch-ekm-patient
Title: "CH EKM Patient"
Description: "This CH EKM base profile constrains the Patient resource. It derives from the CH ELM Patient, so the clinical and the laboratory report identify the person the same way."
* extension ^slicing.discriminator[0].type = #value
* extension ^slicing.discriminator[0].path = "url"
* extension ^slicing.discriminator[1].type = #profile
* extension ^slicing.discriminator[1].path = "$this"
* extension ^slicing.rules = #open

* extension[placeOfBirth] ..1  
* extension[citizenship] ..1 MS 
* extension contains $individual-genderIdentity named genderIdentity 0..1 
* extension[genderIdentity].extension[value].valueCodeableConcept from ChEkmGenderIdentity (required)
* identifier MS
* identifier[AHVN13] ^short = "OASI Number Switzerland"
* name ^short = "Whether the personal data is transmitted by using initials or full name is described under 'Guidance - Personal Data (Patient Name)'"
// The VCT code is an identifier (ChEkmPatientVCT: identifier[LocalPid] of type MR), as in CH ELM, which
// retired its ch-elm-ext-vct-code name extension ("use identifier instead"); ch-elm-humanname still
// allows it, so it is closed here for every CH EKM Patient.
* name.extension[vctcode] 0..0
* name.family ^short = "Family name; its initial only for ChEkmPatientInitials, masked by a data-absent-reason for ChEkmPatientHIV / ChEkmPatientVCT"
* name.given ^short = "Given name; its initial only for ChEkmPatientInitials, masked by a data-absent-reason for ChEkmPatientHIV / ChEkmPatientVCT"
* birthDate ^short = "Date of birth; a data-absent-reason when it is not known"
* gender from ChEkmPatientAdministrativeSex (required)
* gender ^short = "Administrative sex: female or male (the only two administrative sexes in Switzerland)"
// Death. `deceased[x]` is restricted to dateTime so that one element carries both facts the form
// asks for: its presence means the person died, its value is the date of death. The cause of death
// is a separate resource (ChEkmObservationCauseOfDeath) referenced from
// Composition.section[cause-death].
// "Died, date unknown" is the data-absent-reason slice rather than `deceasedBoolean = true`: keeping
// a single element means a consumer never has to check two places to learn whether someone died.
// Same idiom as birthDate above and as ChEkmCondition.onsetDateTime.
* deceased[x] only dateTime
* deceasedDateTime MS
* deceasedDateTime ^short = "Date of death. Present only if the person died; use the data-absent-reason slice when the death is reported without a date"
* deceasedDateTime.extension contains $data-absent-reason named dataabsentreason 0..1
* deceasedDateTime.extension[dataabsentreason] ^short = "Death reported without a date (asked-unknown)"
* address[home].line MS
* address[home].country.extension[countrycode] 1.. 



Profile: ChEkmPatientInitials
Parent: ChEkmPatient
Id: ch-ekm-patient-initials
Title: "CH EKM Patient Initials"
Description: "This CH EKM base profile constrains the Patient resource for patient representation via Initials."
* name obeys name-initials
* identifier[LocalPid] 0..0
* address[home].line ..0
* telecom ..0


Profile: ChEkmPatientHIV
Parent: ChEkmPatient
Title: "CH EKM Patient HIV"
Description: "This CH EKM base profile constrains the Patient resource for patient representation via HIV code."
* . ^short = "CH EKM Patient HIV"
* identifier[LocalPid] 0..0
* name.extension[hivcode] 1..
* name.family.extension[dataabsentreason] 1..
* name.family.extension[dataabsentreason].valueCode = #masked
* name.given.extension[dataabsentreason] 1..
* name.given.extension[dataabsentreason].valueCode = #masked
* address[home].line ..0
* telecom ..0

Profile: VCTIdentifier
Parent: Identifier
Id: ch-ekm-vct-identifier
Title: "VCT Identifier"
Description: "Identifier holding the VCT code."
* system 1..
* type 1..
* type = $v2-0203#MR (exactly)
* value 1..

Profile: ChEkmPatientVCT
Parent: ChEkmPatient
Title: "CH EKM Patient VCT"
Description: "This CH EKM base profile constrains the Patient resource for patient representation via VCT code."
* . ^short = "CH EKM Patient VCT"
* identifier[AHVN13] 0..0
* identifier[IDN] 0..0
* name.extension[hivcode] 0..0
* identifier[LocalPid] 1..1 
* identifier[LocalPid] only VCTIdentifier
* identifier[LocalPid] ^short = "VCT identifier"
* name.family.extension[dataabsentreason] 1..
* name.family.extension[dataabsentreason].valueCode = #unknown
* name.given.extension[dataabsentreason] 1..
* name.given.extension[dataabsentreason].valueCode = #unknown
* address[home].line ..0
* telecom ..0


