// QuestionnaireResponse for the Hepatitis C form, used to test SDC template-based $extract:
//   QuestionnaireResponse  --$extract (ChEkmDocumentHepatitisCTemplate)-->  ChEkmDocumentHepatitisC
//
// linkIds mirror the ASSEMBLED Hepatitis C questionnaire (hepatitisc-form > person /
// manifestation-group / course / exposure / treatingPhysician). Answers are chosen so that ONE
// round trip exercises the branches that differ from the Mpox/Gonorrhoea test inputs:
//   1. `manifestation` repeats (check-box): TWO answers -> two Condition.evidence entries.
//   2. manifestationBeginUnknown = true -> the DATA-ABSENT onset branch
//      (onsetDateTime carries data-absent-reason#asked-unknown and no value).
//   3. Hospitalisation answered "unbekannt" -> an Encounter carrying nothing but
//      hospitalization.extension[data-absent-reason]; the third branch, neither Mpox ("ja") nor a
//      dropped entry ("nein") covers it.
//   4. Zustand: the person did NOT die -> no cause-of-death Observation, no section[cause-death],
//      no deceasedDateTime. Together with Mpox (died of the reported pathogen) both gate states of
//      the two conditional Bundle entries are covered.
//   5. Exposure "Wo": country answered as sct#261665006 "Unbekannt" -> Address._country carries a
//      data-absent-reason instead of an ISO code, while the precise location IS given. Mpox covers
//      the opposite combination.
//   6. Exposure "Wann": answered, so effectiveDateTime is asserted.
//   7. Labor: ONLY the mandatory `labName` and the email are answered, so the eight optional,
//      context-gated elements of the shared ExtractedLabOrganization must all be absent — the
//      closed state of each (the invasive pneumococcal disease QR covers the open one).
//   8. `genderIdentity` left UNANSWERED -> the individual-genderIdentity extension must be absent
//      from the extracted Patient, not an empty shell (Mpox answers it and covers the other branch).
// The person group uses the full-name module (surname / givenname), as ChEkmHepatitisCPersonForm
// requires.
//
// Run: ./scripts/extract-hepatitisc.sh

Instance: ChEkmQuestionnaireResponseHepatitisC
InstanceOf: QuestionnaireResponse
Usage: #example
Title: "CH EKM QuestionnaireResponse: Hepatitis C (test input for $extract)"
Description: "Example Hepatitis C QuestionnaireResponse used as input to SDC template-based $extract (ChEkmDocumentHepatitisCTemplate)."
// Point at the ASSEMBLED questionnaire (flattened groups + real items), not the modular root —
// the root's section items are `display` subQuestionnaire placeholders.
* questionnaire = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireHepatitisCAssembled"
* status = #completed
* authored = "2026-01-27T11:30:00+02:00"

* item[0].linkId = "hepatitisc-form"

// --- Angaben zur betroffenen Person ---
// Item order must follow the assembled questionnaire's person group (surname, givenname,
// dateOfBirth, ahvn13, nationality, zipCode, city, country, canton, administrativeGender,
// genderIdentity) or QR validation reports "items are out of order". `country` is omitted (optional).
* item[0].item[0].linkId = "person"
* item[0].item[0].item[0].linkId = "surname"
* item[0].item[0].item[0].answer.valueString = "Beispielin"
* item[0].item[0].item[1].linkId = "givenname"
* item[0].item[0].item[1].answer.valueString = "Muster"
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
* item[0].item[0].item[8].answer.valueCoding = $administrative-gender#female "female"
// genderIdentity is deliberately LEFT UNANSWERED — it is an optional question, and this is the
// regression test for it: the shared ExtractedPatient template must then emit NO
// individual-genderIdentity extension at all, rather than an empty shell that fails ext-1. Mpox
// answers it, so the two round-trips cover both branches. See the note on that extension in
// questionnnaire/extract/ChEkmDocumentTemplate.fsh.

// --- Diagnose und Manifestation ---
// TWO manifestations (repeats = true) -> two Condition.evidence entries after $extract.
* item[0].item[1].linkId = "manifestation-group"
* item[0].item[1].item[0].linkId = "manifestation"
* item[0].item[1].item[0].answer[0].valueCoding = $sct#18165001 "Jaundice"
* item[0].item[1].item[0].answer[1].valueCoding = $sct#707724006 "Liver enzymes level above reference range"
// Manifestationsbeginn UNKNOWN -> onsetDateTime has no value and carries
// data-absent-reason#asked-unknown; manifestationBeginDate is enableWhen-disabled and unanswered.
* item[0].item[1].item[1].linkId = "manifestationBeginUnknown"
* item[0].item[1].item[1].answer.valueBoolean = true
// Labor — the analysing laboratory, which sits INSIDE this section, after the Manifestationsbeginn.
// Values from the CSV's example column. Deliberately answers ONLY the mandatory `labName` plus the
// email: the eight optional fields stay blank, so this round trip covers the CLOSED state of every
// context-gated element of ExtractedLabOrganization (no identifier, no department, no address, no
// phone) — the invasive pneumococcal disease QR answers all of them and covers the open state.
* item[0].item[1].item[2].linkId = "laboratory"
* item[0].item[1].item[2].item[0].linkId = "labName"
* item[0].item[1].item[2].item[0].answer.valueString = "LabSan GmbH"
* item[0].item[1].item[2].item[1].linkId = "labEmail"
* item[0].item[1].item[2].item[1].answer.valueString = "patho@automation.org"

// --- Verlauf ---
// Hospitalisation "unbekannt" -> an Encounter exists but carries nothing except
// hospitalization.extension[data-absent-reason] = asked-unknown; the reason and admission date
// items are enableWhen-gated on "ja" and stay unanswered. Composition.encounter and
// Condition.encounter still reference it (the gate is "not nein").
* item[0].item[2].linkId = "course"
* item[0].item[2].item[0].linkId = "hospitalisation"
* item[0].item[2].item[0].item[0].linkId = "hospitalisationStatus"
* item[0].item[2].item[0].item[0].answer.valueCoding = $sct#261665006 "Unknown (qualifier value)"
// Zustand: the person is alive -> `deceased` false, so no cause-of-death Observation, no
// section[cause-death] and no Patient.deceasedDateTime are emitted.
* item[0].item[2].item[1].linkId = "death"
* item[0].item[2].item[1].item[0].linkId = "deceased"
* item[0].item[2].item[1].item[0].answer.valueBoolean = false

// --- Exposition (Wo / Wann) ---
// "Wie" is not part of this form yet — see OPEN QUESTIONS #2 in ChEkmQuestionnaireHepatitisC.fsh.
* item[0].item[3].linkId = "exposure"
// Wo: the country is answered as "unbekannt" (a Coding, not an ISO code) while the precise location
// IS given -> after $extract the exposure-address Address carries `city` plus `_country` with a
// data-absent-reason, and NO `country` string.
* item[0].item[3].item[0].linkId = "exposureWhere"
* item[0].item[3].item[0].item[0].linkId = "exposureWhereCountry"
* item[0].item[3].item[0].item[0].answer.valueCoding = $sct#261665006 "Unknown (qualifier value)"
* item[0].item[3].item[0].item[1].linkId = "exposureWherePreciseLocation"
* item[0].item[3].item[0].item[1].answer.valueString = "Bern"
// Wann: the most probable point in time of infection is known -> effectiveDateTime after $extract.
* item[0].item[3].item[1].linkId = "exposureWhen"
* item[0].item[3].item[1].item[0].linkId = "exposureWhenDate"
* item[0].item[3].item[1].item[0].answer.valueDate = "2025-12-01"

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
* item[0].item[4].item[1].item[1].answer.valueString = "Hepatologie"
* item[0].item[4].item[1].item[2].linkId = "orgStreetLine"
* item[0].item[4].item[1].item[2].answer.valueString = "Radixstrasse 88"
* item[0].item[4].item[1].item[3].linkId = "orgZipCode"
* item[0].item[4].item[1].item[3].answer.valueString = "4088"
* item[0].item[4].item[1].item[4].linkId = "orgCity"
* item[0].item[4].item[1].item[4].answer.valueString = "Pankreas"
* item[0].item[4].item[1].item[5].linkId = "orgPhone"
* item[0].item[4].item[1].item[5].answer.valueString = "+26 34 876 54 33"
* item[0].item[4].item[1].item[6].linkId = "orgEmail"
* item[0].item[4].item[1].item[6].answer.valueString = "hepato@hospidoc.com"
* item[0].item[4].item[1].item[7].linkId = "orgBer"
* item[0].item[4].item[1].item[7].answer.valueString = "A99086600"
* item[0].item[4].item[1].item[8].linkId = "orgGln"
* item[0].item[4].item[1].item[8].answer.valueString = "7601000435777"
