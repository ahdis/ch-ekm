// Modular sub-questionnaire: "Diagnose und Manifestation" -> Manifestationen (Gonorrhoea green section)
// Source of truth: logical model ChEkmManifestationForm (-> ChEkmConditionGonorrhoea)

Instance: ChEkmQuestionnaireManifestationBeginUnknown
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Gonorrhoea - Manifestation"
Description: "Modular sub-questionnaire for the 'Manifestationen' part of the 'Diagnose und Manifestation' section of the Gonorrhoea clinical findings report. Reusable as an SDC assemble-child."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireManifestationBeginUnknown"
* version = "0.0.1"
* name = "ChEkmQuestionnaireManifestationBeginUnknown"
* status = #active
* language = #en
* experimental = false
* subjectType = #Patient
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-child

// Manifestationsbeginn unbekannt - default false; when checked it disables the date below
* item[+].linkId = "manifestationBeginUnknown"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmManifestationForm#ChEkmManifestationForm.manifestationBeginUnknown"
* item[=].text = "Onset of manifestation unknown"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Manifestationsbeginn unbekannt"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Début des manifestations inconnu"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Inizio delle manifestazioni sconosciuto"
* item[=].type = #boolean
* item[=].initial.valueBoolean = false

// Manifestationsbeginn (Datum) - only enabled while "unbekannt" is not ticked
* item[+].linkId = "manifestationBeginDate"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmManifestationForm#ChEkmManifestationForm.manifestationBeginDate"
* item[=].text = "Onset of manifestation (date)"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Manifestationsbeginn (Datum)"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Début des manifestations (date)"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Inizio delle manifestazioni (data)"
* item[=].type = #date
* item[=].enableWhen[+].question = "manifestationBeginUnknown"
* item[=].enableWhen[=].operator = #=
* item[=].enableWhen[=].answerBoolean = false
