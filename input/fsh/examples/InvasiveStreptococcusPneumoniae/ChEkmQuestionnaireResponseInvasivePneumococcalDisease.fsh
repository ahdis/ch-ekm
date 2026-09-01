// QuestionnaireResponse for the invasive pneumococcal disease form, used to test SDC
// template-based $extract:
//   QuestionnaireResponse
//     --$extract (ChEkmDocumentInvasivePneumococcalDiseaseTemplate)-->
//   ChEkmDocumentInvasivePneumococcalDisease
//
// linkIds mirror the ASSEMBLED questionnaire (invasivepneumococcaldisease-form > person /
// manifestation-group / course / exposure / treatingPhysician). Answers are chosen so that ONE
// round trip exercises the branches the other three round-trips do NOT cover:
//   1. INITIALS person module TOGETHER WITH a "Verlauf" section — Gonorrhoea is the only other
//      initials form and it has no Verlauf, so this combination is untested today.
//   2. `manifestation` (check-box, repeats): exactly ONE answer -> exactly one Condition.evidence
//      entry (Mpox gives three, Hepatitis C two — one is the boundary case of the repeating context).
//   3. Hospitalisation answered "nein" -> NO Encounter at all: the dropped-entry state of the first
//      conditional Bundle entry, and with it the two references that must disappear with it
//      (Composition.encounter, Condition.encounter). Mpox covers "ja", Hepatitis C "unbekannt".
//   4. Zustand: the person DIED but the date of death is NOT given -> Patient.deceasedDateTime with
//      no value, carrying data-absent-reason#asked-unknown. Mpox covers died+date, Hepatitis C alive.
//   5. Todesursache "unbekannt" -> valueCodeableConcept = sct#261665006 verbatim and NO
//      Observation.focus (issue #28's pass-through branch; Mpox answers "reported pathogen" and
//      therefore covers the focus branch instead).
//   6. Exposure "Wo": the country IS given (Switzerland) while the precise location is answered
//      "unbekannt" -> Address.country = "CH" plus `_city` with a data-absent-reason. Mpox gives
//      both, Hepatitis C the opposite combination — this is the third of the four states.
//   7. Exposure "Wann": answered, so effectiveDateTime is asserted.
//   8. Labor: all nine fields answered, so every context-gated element of the shared
//      ExtractedLabOrganization fires at once (GLN, BUR, department, address, phone, email).
//   9. Impfstatus: "ja", 2 doses, NO last-dose date, and the product TYPED as free text rather than
//      picked from the Swiss vaccine list. Two Immunization branches that no other round-trip
//      reaches: the UndatedDosed template instance (occurrenceDateTime valueless with a
//      data-absent-reason, doseNumberPositiveInt = the answered total) and the `ofType(string)` leg
//      of RuleSetImmunizationVaccineAnswered (vaccineCode.text = the typed name, coding[0] left as
//      the SNOMED CT fallback product). Mpox covers DatedDosed with a picked brand Coding, and the
//      "unknown" Observation.
//
// Person data reproduces ChEkmPatientInitialsExample / the example Bundle
// (ChEkmBundleInvasiveStreptococcusPneumoniae), and Sepsis is the manifestation the example
// Condition carries.
//
// Run: ./scripts/extract-invasivepneumococcaldisease.sh

Instance: ChEkmQuestionnaireResponseInvasivePneumococcalDisease
InstanceOf: QuestionnaireResponse
Usage: #example
Title: "CH EKM QuestionnaireResponse: Invasive pneumococcal disease (test input for $extract)"
Description: "Example invasive pneumococcal disease QuestionnaireResponse used as input to SDC template-based $extract (ChEkmDocumentInvasivePneumococcalDiseaseTemplate)."
// Point at the ASSEMBLED questionnaire (flattened groups + real items), not the modular root —
// the root's section items are `display` subQuestionnaire placeholders.
* questionnaire = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireInvasivePneumococcalDiseaseAssembled"
* status = #completed
* authored = "2026-01-27T11:30:00+02:00"

* item[0].linkId = "invasivepneumococcaldisease-form"

// --- Angaben zur betroffenen Person ---
// Item order must follow the assembled questionnaire's person group (surnameInitial,
// givennameInitial, dateOfBirth, ahvn13, nationality, zipCode, city, country, canton,
// administrativeGender, genderIdentity) or QR validation reports "items are out of order".
// `country` is omitted (optional).
* item[0].item[0].linkId = "person"
* item[0].item[0].item[0].linkId = "surnameInitial"
* item[0].item[0].item[0].answer.valueString = "M"
* item[0].item[0].item[1].linkId = "givennameInitial"
* item[0].item[0].item[1].answer.valueString = "B"
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
* item[0].item[0].item[9].linkId = "genderIdentity"
* item[0].item[0].item[9].answer.valueCoding = $sct#1384187000 "Identifies as transgender (finding)"

// --- Diagnose und Manifestation ---
// ONE manifestation (the item repeats, this answers it once) -> exactly one Condition.evidence
// entry. Sepsis is what the example Bundle's Condition carries.
* item[0].item[1].linkId = "manifestation-group"
* item[0].item[1].item[0].linkId = "manifestation"
* item[0].item[1].item[0].answer.valueCoding = $sct#91302008 "Sepsis (disorder)"
// Manifestationsbeginn known -> onsetDateTime is asserted (no data-absent-reason).
* item[0].item[1].item[1].linkId = "manifestationBeginUnknown"
* item[0].item[1].item[1].answer.valueBoolean = false
* item[0].item[1].item[2].linkId = "manifestationBeginDate"
* item[0].item[1].item[2].answer.valueDate = "2026-01-27"
// Labor — the analysing laboratory, which sits INSIDE this section, after the Manifestationsbeginn.
// All nine values come from the CSV's example column. Only `labName` is required; the rest are
// answered here so the round trip exercises every context-gated element of ExtractedLabOrganization
// (GLN, BUR, department, address, phone, email) at once.
* item[0].item[1].item[3].linkId = "laboratory"
* item[0].item[1].item[3].item[0].linkId = "labName"
* item[0].item[1].item[3].item[0].answer.valueString = "LabSan GmbH"
* item[0].item[1].item[3].item[1].linkId = "labDepartment"
* item[0].item[1].item[3].item[1].answer.valueString = "Mikrobiologie"
* item[0].item[1].item[3].item[2].linkId = "labStreetLine"
* item[0].item[1].item[3].item[2].answer.valueString = "Petriweg 88"
* item[0].item[1].item[3].item[3].linkId = "labZipCode"
* item[0].item[1].item[3].item[3].answer.valueString = "7575"
* item[0].item[1].item[3].item[4].linkId = "labCity"
* item[0].item[1].item[3].item[4].answer.valueString = "Rumplikon"
* item[0].item[1].item[3].item[5].linkId = "labPhone"
* item[0].item[1].item[3].item[5].answer.valueString = "+36 87 987 65 43"
* item[0].item[1].item[3].item[6].linkId = "labEmail"
* item[0].item[1].item[3].item[6].answer.valueString = "patho@automation.org"
* item[0].item[1].item[3].item[7].linkId = "labBer"
* item[0].item[1].item[3].item[7].answer.valueString = "A99082200"
* item[0].item[1].item[3].item[8].linkId = "labGln"
* item[0].item[1].item[3].item[8].answer.valueString = "7601000435111"

// --- Verlauf ---
// Hospitalisation "nein" -> the context on the Encounter Bundle entry is empty, so NO Encounter is
// emitted and neither Composition.encounter nor Condition.encounter survives (both carry the same
// test). This is the branch neither the Mpox ("ja") nor the Hepatitis C ("unbekannt") round-trip
// covers. The reason and admission-date items are enableWhen-gated on "ja" and stay unanswered.
* item[0].item[2].linkId = "course"
* item[0].item[2].item[0].linkId = "hospitalisation"
* item[0].item[2].item[0].item[0].linkId = "hospitalisationStatus"
* item[0].item[2].item[0].item[0].answer.valueCoding = $sct#373067005 "No (qualifier value)"
// Zustand: the person died, but the DATE OF DEATH IS NOT KNOWN -> Patient.deceasedDateTime carries
// data-absent-reason#asked-unknown and no value (the death is still asserted; only its date is
// missing — see RuleSetPatientDeceased). The cause is answered "unbekannt", which is a VALUE, not a
// dataAbsentReason (issue #28): the Observation's valueCodeableConcept is the SNOMED qualifier
// passed through unchanged, and there is NO `focus` reference to the diagnosis Condition — that
// exists only for the "reported pathogen" answer.
* item[0].item[2].item[1].linkId = "death"
* item[0].item[2].item[1].item[0].linkId = "deceased"
* item[0].item[2].item[1].item[0].answer.valueBoolean = true
* item[0].item[2].item[1].item[1].linkId = "deathCause"
* item[0].item[2].item[1].item[1].answer.valueCoding = $sct#261665006 "Unknown (qualifier value)"

// --- Exposition (Wo / Wann) ---
// "Wie" is not part of this form yet — see OPEN QUESTIONS #5 in
// ChEkmQuestionnaireInvasivePneumococcalDisease.fsh.
* item[0].item[3].linkId = "exposure"
// Wo: the country IS answered (Switzerland, an ISO 3166 code) while the precise location is
// answered with the "unbekannt" Coding from ChEkmUnknown -> after $extract the exposure-address
// Address carries `country` = "CH" plus the iso21090-codedString Coding, and `_city` with a
// data-absent-reason instead of a `city` string.
* item[0].item[3].item[0].linkId = "exposureWhere"
* item[0].item[3].item[0].item[0].linkId = "exposureWhereCountry"
* item[0].item[3].item[0].item[0].answer.valueCoding = $iso3166#CH "Switzerland"
* item[0].item[3].item[0].item[1].linkId = "exposureWherePreciseLocation"
* item[0].item[3].item[0].item[1].answer.valueCoding = $sct#261665006 "Unknown (qualifier value)"
// Wann: the most probable point in time of infection is known -> effectiveDateTime after $extract.
* item[0].item[3].item[1].linkId = "exposureWhen"
* item[0].item[3].item[1].item[0].linkId = "exposureWhenDate"
* item[0].item[3].item[1].item[0].answer.valueDate = "2026-01-20"

// --- Impfstatus (issue #29) ---
// ONE row (Pneumokokkenimpfung), answered "ja" with a TOTAL of 2 doses — the CSV's own example
// ("ja, mit total 2 Dosen", "Prevenar 13") — but deliberately WITHOUT the date of the last dose and
// with the product TYPED instead of picked, so the round trip exercises the two branches Mpox does
// not: after $extract this is ONE ChEkmImmunizationInvasivePneumococcalDisease with
//   protocolApplied.doseNumberPositiveInt = 2   (the TOTAL, not one resource per dose)
//   protocolApplied.targetDisease           = sct#16814004 Pneumococcal infectious disease
//   occurrenceDateTime                      = valueless, data-absent-reason#asked-unknown
//   vaccineCode.coding[0]                   = sct#836398006 (the template's SNOMED fallback, kept)
//   vaccineCode.text                        = "Prevenar 13" (the typed answer)
// A "nein" / "unbekannt" answer would instead emit a
// ChEkmObservationVaccinationStatusInvasivePneumococcalDisease, and an unanswered row nothing at all.
* item[0].item[4].linkId = "immunization"
* item[0].item[4].item[0].linkId = "immunizationPneumococcal"
* item[0].item[4].item[0].item[0].linkId = "immunizationStatusPneumococcal"
* item[0].item[4].item[0].item[0].answer.valueCoding = $sct#373066001 "Yes (qualifier value)"
* item[0].item[4].item[0].item[1].linkId = "immunizationDosesPneumococcal"
* item[0].item[4].item[0].item[1].answer.valueInteger = 2
* item[0].item[4].item[0].item[2].linkId = "immunizationVaccinePneumococcal"
* item[0].item[4].item[0].item[2].answer.valueString = "Prevenar 13"

// --- Behandelnde Ärztin / behandelnder Arzt (Practitioner + Organization) ---
// Values from the CSV's example column, so the extracted document matches the paper form's sample.
* item[0].item[5].linkId = "treatingPhysician"
// Practitioner
* item[0].item[5].item[0].linkId = "treatingPhysicianPractitioner"
* item[0].item[5].item[0].item[0].linkId = "physicianGivenname"
* item[0].item[5].item[0].item[0].answer.valueString = "Potagon"
* item[0].item[5].item[0].item[1].linkId = "physicianSurname"
* item[0].item[5].item[0].item[1].answer.valueString = "Brachialis"
* item[0].item[5].item[0].item[2].linkId = "physicianStreetLine"
* item[0].item[5].item[0].item[2].answer.valueString = "Sodaweg 55"
* item[0].item[5].item[0].item[3].linkId = "physicianZipCode"
* item[0].item[5].item[0].item[3].answer.valueString = "3921"
* item[0].item[5].item[0].item[4].linkId = "physicianCity"
* item[0].item[5].item[0].item[4].answer.valueString = "Flammingen"
* item[0].item[5].item[0].item[5].linkId = "physicianPhone"
* item[0].item[5].item[0].item[5].answer.valueString = "+24 74 200 88 77"
* item[0].item[5].item[0].item[6].linkId = "physicianEmail"
* item[0].item[5].item[0].item[6].answer.valueString = "p.brach@sampledoc.com"
* item[0].item[5].item[0].item[7].linkId = "physicianGln"
* item[0].item[5].item[0].item[7].answer.valueString = "7601000435666"
// Organization
* item[0].item[5].item[1].linkId = "treatingPhysicianOrganization"
* item[0].item[5].item[1].item[0].linkId = "orgName"
* item[0].item[5].item[1].item[0].answer.valueString = "Regionalspital Genesis"
* item[0].item[5].item[1].item[1].linkId = "orgDepartment"
* item[0].item[5].item[1].item[1].answer.valueString = "Immunologie"
* item[0].item[5].item[1].item[2].linkId = "orgStreetLine"
* item[0].item[5].item[1].item[2].answer.valueString = "Radixstrasse 88"
* item[0].item[5].item[1].item[3].linkId = "orgZipCode"
* item[0].item[5].item[1].item[3].answer.valueString = "4088"
* item[0].item[5].item[1].item[4].linkId = "orgCity"
* item[0].item[5].item[1].item[4].answer.valueString = "Pankreas"
* item[0].item[5].item[1].item[5].linkId = "orgPhone"
* item[0].item[5].item[1].item[5].answer.valueString = "+26 34 876 54 33"
* item[0].item[5].item[1].item[6].linkId = "orgEmail"
* item[0].item[5].item[1].item[6].answer.valueString = "immuno@hospidoc.com"
* item[0].item[5].item[1].item[7].linkId = "orgBer"
* item[0].item[5].item[1].item[7].answer.valueString = "A99086600"
* item[0].item[5].item[1].item[8].linkId = "orgGln"
* item[0].item[5].item[1].item[8].answer.valueString = "7601000435777"
