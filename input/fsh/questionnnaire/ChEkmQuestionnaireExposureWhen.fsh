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
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireExposureWhen)

* item[+].linkId = "exposureWhen"
* insert RuleSetQrLevel1Text("When (point in time of infection\)", "Wann (Zeitpunkt der Ansteckung\)", "Quand (moment de l'infection\)", "Quando (momento del contagio\)")
* item[=].type = #group

// 1. Meistwahrscheinlicher Zeitpunkt der Ansteckung (Datum, ggf. unvollständig: JJJJ / JJJJ-MM)
* item[=].item[+].linkId = "exposureWhenDate"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmExposureForm#ChEkmExposureForm.when.exposureDate"
* insert RuleSetQrLevel2Text("When was the most probable point in time of infection?", "Wann war der meistwahrscheinliche Zeitpunkt der Ansteckung?", "Quand a eu lieu le moment le plus probable de l'infection ?", "Quando è avvenuto il momento più probabile del contagio?")
* item[=].item[=].type = #date

// 2. Nur wenn 1. unbekannt (= unbeantwortet): letzte Einreise in die Schweiz
* item[=].item[+].linkId = "exposureWhenLastEntryDate"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmExposureForm#ChEkmExposureForm.when.lastEntryDate"
* insert RuleSetQrLevel2Text("If unknown\, when was the last entry into Switzerland?", "Wenn unbekannt\, wann war die letzte Einreise in die Schweiz?", "Si inconnu\, quand a eu lieu la dernière entrée en Suisse ?", "Se sconosciuto\, quando è avvenuto l'ultimo ingresso in Svizzera?")
* item[=].item[=].type = #date
* item[=].item[=].enableWhen[+].question = "exposureWhenDate"
* item[=].item[=].enableWhen[=].operator = #exists
* item[=].item[=].enableWhen[=].answerBoolean = false
