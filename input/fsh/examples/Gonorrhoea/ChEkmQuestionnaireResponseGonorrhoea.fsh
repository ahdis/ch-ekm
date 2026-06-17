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
* questionnaire = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoea"
* status = #completed
* authored = "2026-05-27T11:30:00+02:00"

* item[0].linkId = "gonorrhoea-form"

// --- Angaben zur betroffenen Person ---
* item[0].item[0].linkId = "person"
* item[0].item[0].item[0].linkId = "surnameInitial"
* item[0].item[0].item[0].answer.valueString = "M"
* item[0].item[0].item[1].linkId = "givennameInitial"
* item[0].item[0].item[1].answer.valueString = "B"
* item[0].item[0].item[2].linkId = "dateOfBirth"
* item[0].item[0].item[2].answer.valueDate = "2000-01-01"
* item[0].item[0].item[3].linkId = "zipCode"
* item[0].item[0].item[3].answer.valueString = "3097"
* item[0].item[0].item[4].linkId = "city"
* item[0].item[0].item[4].answer.valueString = "Liebefeld"
* item[0].item[0].item[5].linkId = "canton"
* item[0].item[0].item[5].answer.valueString = "BE"
* item[0].item[0].item[6].linkId = "administrativeGender"
* item[0].item[0].item[6].answer.valueCoding = $administrative-gender#male "Male"
* item[0].item[0].item[7].linkId = "nationality"
* item[0].item[0].item[7].answer.valueCoding = $iso3166#CH "Switzerland"
* item[0].item[0].item[8].linkId = "genderIdentity"
* item[0].item[0].item[8].answer.valueCoding = $sct#1384187000 "Identifies as transgender (finding)"

// --- Diagnose und Manifestation ---
* item[0].item[1].linkId = "manifestation-group"
* item[0].item[1].item[0].linkId = "manifestation"
* item[0].item[1].item[0].answer.valueCoding = $sct#264931009 "Symptomatic (qualifier value)"
* item[0].item[1].item[1].linkId = "manifestationBeginUnknown"
* item[0].item[1].item[1].answer.valueBoolean = true

// --- Exposition (Wie / Übertragungsweg) ---
* item[0].item[2].linkId = "transmission"
* item[0].item[2].item[0].linkId = "sexualContactPartner"
* item[0].item[2].item[0].answer.valueCoding = $administrative-gender#male "Male"
* item[0].item[2].item[1].linkId = "relationshipType"
* item[0].item[2].item[1].answer.valueCoding = ChEkmRelationshipType#offered-paid-sex "Offered paid sex"
* item[0].item[2].item[2].linkId = "unknown"
* item[0].item[2].item[2].answer.valueBoolean = false
