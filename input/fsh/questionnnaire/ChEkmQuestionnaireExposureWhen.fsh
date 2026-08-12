// Modular sub-questionnaire: "Wann" — most probable point in time of infection.
// Source of truth: logical model ChEkmExposureForm.when (-> ChEkmExposure)
// Form items per https://github.com/ahdis/ch-ekm/issues/25:
//   1. Wann war der meistwahrscheinliche Zeitpunkt der Ansteckung?          -> effectiveDateTime
//   2. Wenn unbekannt, wann war die letzte Einreise in die Schweiz?         -> component[dateOfEntry]
// (2) is only shown while (1) is unanswered — the two are alternatives, never both.

Instance: ChEkmQuestionnaireExposureWhen
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Exposure - When (point in time of infection)"
Description: "Modular sub-questionnaire for the 'Wann' (when) group of the Exposure section: the most probable point in time of infection and, if that is unknown, the date of the last entry into Switzerland. Reusable as an SDC assemble-child."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireExposureWhen"
* version = "0.0.1"
* name = "ChEkmQuestionnaireExposureWhen"
* status = #active
* language = #en
* experimental = false
* subjectType = #Patient
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-child

* item[+].linkId = "exposureWhen"
* item[=].text = "When (point in time of infection)"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Wann (Zeitpunkt der Ansteckung)"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Quand (moment de l'infection)"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Quando (momento del contagio)"
* item[=].type = #group

// 1. Meistwahrscheinlicher Zeitpunkt der Ansteckung (Datum, ggf. unvollständig: JJJJ / JJJJ-MM)
* item[=].item[+].linkId = "exposureWhenDate"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmExposureForm#ChEkmExposureForm.when.exposureDate"
* item[=].item[=].text = "When was the most probable point in time of infection?"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Wann war der meistwahrscheinliche Zeitpunkt der Ansteckung?"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Quand a eu lieu le moment le plus probable de l'infection ?"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Quando è avvenuto il momento più probabile del contagio?"
* item[=].item[=].type = #date

// 2. Nur wenn 1. unbekannt (= unbeantwortet): letzte Einreise in die Schweiz
* item[=].item[+].linkId = "exposureWhenLastEntryDate"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmExposureForm#ChEkmExposureForm.when.lastEntryDate"
* item[=].item[=].text = "If unknown, when was the last entry into Switzerland?"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Wenn unbekannt, wann war die letzte Einreise in die Schweiz?"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Si inconnu, quand a eu lieu la dernière entrée en Suisse ?"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Se sconosciuto, quando è avvenuto l'ultimo ingresso in Svizzera?"
* item[=].item[=].type = #date
* item[=].item[=].enableWhen[+].question = "exposureWhenDate"
* item[=].item[=].enableWhen[=].operator = #exists
* item[=].item[=].enableWhen[=].answerBoolean = false
