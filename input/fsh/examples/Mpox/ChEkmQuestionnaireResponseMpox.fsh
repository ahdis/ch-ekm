// QuestionnaireResponse for the Mpox form, used to test SDC template-based $extract round-trip:
//   QuestionnaireResponse  --$extract (ChEkmDocumentMpoxTemplate)-->  ChEkmDocumentMpox
//
// linkIds mirror the ASSEMBLED Mpox questionnaire (mpox-form > person / manifestation-group /
// exposure / treatingPhysician). Two things are deliberately exercised here that the Gonorrhoea
// QR does not cover:
//   1. `manifestation` is repeats=true (check-box): THREE answers are given, so the template's
//      context on evidence[0] must produce THREE evidence entries, one code each
//      (see ChEkmDocumentMpoxTemplate).
//   2. manifestationBeginUnknown=false + a real manifestationBeginDate, i.e. the ANSWERED onset
//      path (the Gonorrhoea QR ticks "unknown" and tests the data-absent branch instead).
//   3. Exposure "Wann" (see issue #25).
//   4. Exposure "Wo": a country abroad + a precise location -> the exposure-address extension is
//      built at extraction with country code, country Coding and city (see issue #26).
//   5. Verlauf / Hospitalisation: answered "ja" with a reason and an admission date, so the
//      context-gated Encounter entry and both references to it (Composition.encounter,
//      Condition.encounter) must appear in the extracted Bundle.
// The person group uses the full-name module (surname / givenname), not the initials module.
//
// Run: ./tests/extract-mpox.sh

Instance: ChEkmQuestionnaireResponseMpox
InstanceOf: QuestionnaireResponse
Usage: #example
Title: "CH EKM QuestionnaireResponse: Mpox (test input for $extract)"
Description: "Example Mpox QuestionnaireResponse used as input to SDC template-based $extract (ChEkmDocumentMpoxTemplate). Answers several manifestations to cover the repeating check-box item."
// Point at the ASSEMBLED questionnaire (flattened groups + real items), not the modular root —
// the root's section items are `display` subQuestionnaire placeholders (see the note on
// ChEkmQuestionnaireResponseGonorrhoea).
* questionnaire = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireMpoxAssembled"
* status = #completed
* authored = "2026-08-05T11:30:00+02:00"

* item[0].linkId = "mpox-form"

// --- Angaben zur betroffenen Person ---
// Item order must follow the assembled questionnaire's person group
// (surname, givenname, dateOfBirth, ahvn13, nationality, zipCode, city, country, canton,
// administrativeGender, genderIdentity) or QR validation reports "items are out of order".
// country is omitted (optional).
* item[0].item[0].linkId = "person"
* item[0].item[0].item[0].linkId = "surname"
* item[0].item[0].item[0].answer.valueString = "Muster"
* item[0].item[0].item[1].linkId = "givenname"
* item[0].item[0].item[1].answer.valueString = "Beat Ruedi"
* item[0].item[0].item[2].linkId = "dateOfBirth"
* item[0].item[0].item[2].answer.valueDate = "2000-01-01"
* item[0].item[0].item[3].linkId = "ahvn13"
* item[0].item[0].item[3].answer.valueString = "7560000000000"
* item[0].item[0].item[4].linkId = "nationality"
* item[0].item[0].item[4].answer.valueCoding = $iso3166#CH "Switzerland"
* item[0].item[0].item[5].linkId = "zipCode"
* item[0].item[0].item[5].answer.valueString = "3097"
* item[0].item[0].item[6].linkId = "city"
* item[0].item[0].item[6].answer.valueString = "Liebefeld"
* item[0].item[0].item[7].linkId = "canton"
* item[0].item[0].item[7].answer.valueString = "BE"
* item[0].item[0].item[8].linkId = "administrativeGender"
* item[0].item[0].item[8].answer.valueCoding = $administrative-gender#male "male"
* item[0].item[0].item[9].linkId = "genderIdentity"
* item[0].item[0].item[9].answer.valueCoding = $sct#1384187000 "Identifies as transgender (finding)"

// --- Diagnose und Manifestation ---
// THREE manifestations (repeats=true) -> three Condition.evidence entries after $extract.
// The first one is a post-coordinated SNOMED expression (skin lesion + finding site), which also
// checks that such codes survive the identity pass-through unchanged.
* item[0].item[1].linkId = "manifestation-group"
* item[0].item[1].item[0].linkId = "manifestation"
* item[0].item[1].item[0].answer[0].valueCoding = $sct#"95324001:{363698007=73897004}" "Skin lesion of face"
* item[0].item[1].item[0].answer[1].valueCoding = $sct#386661006 "Fever (finding)"
* item[0].item[1].item[0].answer[2].valueCoding = $sct#25064002 "Headache (finding)"
// Manifestationsbeginn known -> onsetDateTime is asserted (no data-absent-reason).
* item[0].item[1].item[1].linkId = "manifestationBeginUnknown"
* item[0].item[1].item[1].answer.valueBoolean = false
* item[0].item[1].item[2].linkId = "manifestationBeginDate"
* item[0].item[1].item[2].answer.valueDate = "2026-07-20"

// --- Verlauf: Hospitalisation ---
// Hospitalised ("ja"), because of the reported pathogen, admitted on 2026-01-27 
// after $extract an Encounter with class IMP, period.start and a reasonReference to the
// diagnosis Condition, referenced from Composition.encounter and Condition.encounter. The two other
// branches are covered by the round-trip notes in RuleSetEncounterHospitalisation: "nein" drops the
// whole Bundle entry, "unbekannt" leaves an Encounter carrying only the data-absent-reason.
* item[0].item[2].linkId = "course"
* item[0].item[2].item[0].linkId = "hospitalisation"
* item[0].item[2].item[0].item[0].linkId = "hospitalisationStatus"
* item[0].item[2].item[0].item[0].answer.valueCoding = $sct#373066001 "Yes (qualifier value)"
* item[0].item[2].item[0].item[1].linkId = "hospitalisationReason"
* item[0].item[2].item[0].item[1].answer.valueCoding = ChEkmReportedPathogen#reported-pathogen "Reported pathogen"
* item[0].item[2].item[0].item[2].linkId = "hospitalisationAdmissionDate"
* item[0].item[2].item[0].item[2].answer.valueDate = "2026-01-27"

// Zustand: the person died of the reported pathogen on 2026-02-03 -> after $extract
// Patient.deceasedDateTime, plus a cause-of-death Observation (value = the Mpox code, focus -> the
// diagnosis Condition) in a section[cause-death] that only exists because the person died.
// The other branches are covered by the notes in RuleSetObservationCauseOfDeath: "anderer" writes
// the SNOMED qualifier verbatim, "unbekannt" writes dataAbsentReason instead of a value, and an
// unticked `deceased` drops the Observation, the section and deceasedDateTime together.
* item[0].item[2].item[1].linkId = "death"
* item[0].item[2].item[1].item[0].linkId = "deceased"
* item[0].item[2].item[1].item[0].answer.valueBoolean = true
* item[0].item[2].item[1].item[1].linkId = "deathDate"
* item[0].item[2].item[1].item[1].answer.valueDate = "2026-02-03"
* item[0].item[2].item[1].item[2].linkId = "deathCause"
* item[0].item[2].item[1].item[2].answer.valueCoding = ChEkmReportedPathogen#reported-pathogen "Reported pathogen"

// --- Exposure (Wo / Wann / Wie) ---
// exposure = outer wrapper group; exposureWhere, exposureWhen and exposureHow are the three
// sub-questionnaires, in the order they are assembled into the root.
* item[0].item[3].linkId = "exposure"

// Wo: a country with a precise location -> after $extract
// extension[exposureAddress].valueAddress = {country "CD" + iso21090-codedString Coding, city}.
// Both items are dropdowns with their own "Unbekannt" option. The country is a plain `choice`
// (CH/LI are just its first two entries); the precise location is an `open-choice`, so a TYPED
// answer comes back as valueString - as here - and picking "Unbekannt" would come back as
// valueCoding sct#261665006 and put a data-absent-reason on `_city` instead of a `city` string.
* item[0].item[3].item[0].linkId = "exposureWhere"
* item[0].item[3].item[0].item[0].linkId = "exposureWhereCountry"
* item[0].item[3].item[0].item[0].answer.valueCoding = $iso3166#CD "Congo (Kinshasa)"
* item[0].item[3].item[0].item[1].linkId = "exposureWherePreciseLocation"
* item[0].item[3].item[0].item[1].answer.valueString = "Kinshasa"

// Wann: the most probable point in time of infection is known -> effectiveDateTime after $extract.
* item[0].item[3].item[1].linkId = "exposureWhen"
* item[0].item[3].item[1].item[0].linkId = "exposureWhenDate"
* item[0].item[3].item[1].item[0].answer.valueDate = "2026-07-01"

// Wie (Übertragungsweg)
* item[0].item[3].item[2].linkId = "exposureHow"
* item[0].item[3].item[2].item[0].linkId = "exposureHowSexualContactPartner"
* item[0].item[3].item[2].item[0].answer.valueCoding = $administrative-gender#male "male"
* item[0].item[3].item[2].item[1].linkId = "exposureHowRelationshipType"
* item[0].item[3].item[2].item[1].answer.valueCoding = ChEkmRelationshipType#offered-paid-sex "Offered paid sex"
* item[0].item[3].item[2].item[2].linkId = "exposureHowUnknown"
* item[0].item[3].item[2].item[2].answer.valueBoolean = false

// --- Behandelnde Ärztin / behandelnder Arzt (Practitioner + Organization) ---
* item[0].item[4].linkId = "treatingPhysician"
// Practitioner
* item[0].item[4].item[0].linkId = "treatingPhysicianPractitioner"
* item[0].item[4].item[0].item[0].linkId = "physicianGivenname"
* item[0].item[4].item[0].item[0].answer.valueString = "Potagon"
* item[0].item[4].item[0].item[1].linkId = "physicianSurname"
* item[0].item[4].item[0].item[1].answer.valueString = "Brachialis"
* item[0].item[4].item[0].item[2].linkId = "physicianStreetLine"
* item[0].item[4].item[0].item[2].answer.valueString = "Sodaweg 55"
* item[0].item[4].item[0].item[3].linkId = "physicianZipCode"
* item[0].item[4].item[0].item[3].answer.valueString = "3921"
* item[0].item[4].item[0].item[4].linkId = "physicianCity"
* item[0].item[4].item[0].item[4].answer.valueString = "Flammingen"
* item[0].item[4].item[0].item[5].linkId = "physicianPhone"
* item[0].item[4].item[0].item[5].answer.valueString = "+24 74 200 88 77"
* item[0].item[4].item[0].item[6].linkId = "physicianEmail"
* item[0].item[4].item[0].item[6].answer.valueString = "p.brach@sampledoc.com"
* item[0].item[4].item[0].item[7].linkId = "physicianGln"
* item[0].item[4].item[0].item[7].answer.valueString = "7601000435666"
// Organization
* item[0].item[4].item[1].linkId = "treatingPhysicianOrganization"
* item[0].item[4].item[1].item[0].linkId = "orgName"
* item[0].item[4].item[1].item[0].answer.valueString = "Regionalspital Genesis"
* item[0].item[4].item[1].item[1].linkId = "orgDepartment"
* item[0].item[4].item[1].item[1].answer.valueString = "Immunologie"
* item[0].item[4].item[1].item[2].linkId = "orgStreetLine"
* item[0].item[4].item[1].item[2].answer.valueString = "Radixstrasse 88"
* item[0].item[4].item[1].item[3].linkId = "orgZipCode"
* item[0].item[4].item[1].item[3].answer.valueString = "4088"
* item[0].item[4].item[1].item[4].linkId = "orgCity"
* item[0].item[4].item[1].item[4].answer.valueString = "Pankreas"
* item[0].item[4].item[1].item[5].linkId = "orgPhone"
* item[0].item[4].item[1].item[5].answer.valueString = "+26 34 876 54 33"
* item[0].item[4].item[1].item[6].linkId = "orgEmail"
* item[0].item[4].item[1].item[6].answer.valueString = "immuno@hospidoc.com"
* item[0].item[4].item[1].item[7].linkId = "orgBer"
* item[0].item[4].item[1].item[7].answer.valueString = "A99086600"
* item[0].item[4].item[1].item[8].linkId = "orgGln"
* item[0].item[4].item[1].item[8].answer.valueString = "7601000435777"
