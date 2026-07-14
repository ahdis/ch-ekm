// QuestionnaireResponse for the Gonorrhoea form, reconstructed from the example document
// Bundle (ChEkmBundleGonorrhoea) so we can test SDC template-based $extract round-trip:
//   QuestionnaireResponse  --$extract (ChEkmDocumentGonorrhoeaTemplate)-->  ChEkmDocumentGonorrhoea
//
// linkIds mirror the assembled questionnaire (gonorrhoea-form > person / manifestation-group /
// transmission). Answers are taken from ChEkmPatientInitialsExample, ChEkmConditionExample and
// ChEkmExposureExample. Manifestation uses the form code 264931009 "Symptomatic" (the cleaner
// evidence.code per the forms-summary decision); manifestationBeginUnknown=true reproduces the
// example's data-absent onset (the template omits onset rather than asserting a date).

Instance: ChEkmQuestionnaireResponseGonorrhoea
InstanceOf: QuestionnaireResponse
Usage: #example
Title: "CH EKM QuestionnaireResponse: Gonorrhoea (test input for $extract)"
Description: "Example Gonorrhoea QuestionnaireResponse used as input to SDC template-based $extract (ChEkmDocumentGonorrhoeaTemplate)."
// Point at the ASSEMBLED questionnaire (flattened groups + real items), not the modular root:
// the root's section items are `display` subQuestionnaire placeholders, so validating this QR
// (which has the actual nested group/item structure) against the root errors with
// "LinkId not found" / "Items not of type DISPLAY should not have items". The assembled
// questionnaire is the artifact a renderer loads and the QR is filled against.
* questionnaire = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoeaAssembled"
* status = #completed
* authored = "2026-05-27T11:30:00+02:00"

* item[0].linkId = "gonorrhoea-form"

// --- Angaben zur betroffenen Person ---
// Item order must follow the assembled questionnaire's person group
// (surnameInitial, givennameInitial, dateOfBirth, ahvn13, nationality, zipCode, city,
// country, canton, administrativeGender, genderIdentity) or QR validation reports
// "items are out of order". country is omitted (optional).
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
* item[0].item[0].item[8].answer.valueCoding = $administrative-gender#male "Male"
* item[0].item[0].item[9].linkId = "genderIdentity"
* item[0].item[0].item[9].answer.valueCoding = $sct#1384187000 "Identifies as transgender (finding)"

// --- Diagnose und Manifestation ---
* item[0].item[1].linkId = "manifestation-group"
* item[0].item[1].item[0].linkId = "manifestation"
* item[0].item[1].item[0].answer.valueCoding = $sct#264931009 "Symptomatic (qualifier value)"
* item[0].item[1].item[1].linkId = "manifestationBeginUnknown"
* item[0].item[1].item[1].answer.valueBoolean = true

// --- Exposition (Wie / Übertragungsweg) ---
// exposure = outer wrapper group; transmission = route-of-transmission sub-questionnaire.
* item[0].item[2].linkId = "exposure"
* item[0].item[2].item[0].linkId = "transmission"
* item[0].item[2].item[0].item[0].linkId = "sexualContactPartner"
* item[0].item[2].item[0].item[0].answer.valueCoding = $administrative-gender#male "Male"
* item[0].item[2].item[0].item[1].linkId = "relationshipType"
* item[0].item[2].item[0].item[1].answer.valueCoding = ChEkmRelationshipType#offered-paid-sex "Offered paid sex"
* item[0].item[2].item[0].item[2].linkId = "unknown"
* item[0].item[2].item[0].item[2].answer.valueBoolean = false

// --- Behandelnde Ärztin / behandelnder Arzt (Practitioner + Organization) ---
// Answers taken from ChEkmPractitionerTreatingPhysicianExample / ChEkmOrganizationTreatingPhysicianExample.
* item[0].item[3].linkId = "treatingPhysician"
// Practitioner
* item[0].item[3].item[0].linkId = "treatingPhysicianPractitioner"
* item[0].item[3].item[0].item[0].linkId = "physicianGivenname"
* item[0].item[3].item[0].item[0].answer.valueString = "Potagon"
* item[0].item[3].item[0].item[1].linkId = "physicianSurname"
* item[0].item[3].item[0].item[1].answer.valueString = "Brachialis"
* item[0].item[3].item[0].item[2].linkId = "physicianStreetLine"
* item[0].item[3].item[0].item[2].answer.valueString = "Sodaweg 55"
* item[0].item[3].item[0].item[3].linkId = "physicianZipCode"
* item[0].item[3].item[0].item[3].answer.valueString = "3921"
* item[0].item[3].item[0].item[4].linkId = "physicianCity"
* item[0].item[3].item[0].item[4].answer.valueString = "Flammingen"
* item[0].item[3].item[0].item[5].linkId = "physicianPhone"
* item[0].item[3].item[0].item[5].answer.valueString = "+24 74 200 88 77"
* item[0].item[3].item[0].item[6].linkId = "physicianEmail"
* item[0].item[3].item[0].item[6].answer.valueString = "p.brach@sampledoc.com"
* item[0].item[3].item[0].item[7].linkId = "physicianGln"
* item[0].item[3].item[0].item[7].answer.valueString = "7601000435666"
// Organization
* item[0].item[3].item[1].linkId = "treatingPhysicianOrganization"
* item[0].item[3].item[1].item[0].linkId = "orgName"
* item[0].item[3].item[1].item[0].answer.valueString = "Regionalspital Genesis"
* item[0].item[3].item[1].item[1].linkId = "orgDepartment"
* item[0].item[3].item[1].item[1].answer.valueString = "Immunologie"
* item[0].item[3].item[1].item[2].linkId = "orgStreetLine"
* item[0].item[3].item[1].item[2].answer.valueString = "Radixstrasse 88"
* item[0].item[3].item[1].item[3].linkId = "orgZipCode"
* item[0].item[3].item[1].item[3].answer.valueString = "4088"
* item[0].item[3].item[1].item[4].linkId = "orgCity"
* item[0].item[3].item[1].item[4].answer.valueString = "Pankreas"
* item[0].item[3].item[1].item[5].linkId = "orgPhone"
* item[0].item[3].item[1].item[5].answer.valueString = "+26 34 876 54 33"
* item[0].item[3].item[1].item[6].linkId = "orgEmail"
* item[0].item[3].item[1].item[6].answer.valueString = "immuno@hospidoc.com"
* item[0].item[3].item[1].item[7].linkId = "orgBer"
* item[0].item[3].item[1].item[7].answer.valueString = "A99086600"
* item[0].item[3].item[1].item[8].linkId = "orgGln"
* item[0].item[3].item[1].item[8].answer.valueString = "7601000435777"
