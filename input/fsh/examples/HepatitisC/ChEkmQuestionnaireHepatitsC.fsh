// 2. Nur wenn 1. unbekannt (= unbeantwortet): letzte Einreise in die Schweiz
// * item[=].item[+].linkId = "exposureWhenLastEntryDate"
// * item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmExposureForm#ChEkmExposureForm.when.lastEntryDate"
// * insert RuleSetQrLevel2Text("If unknown\, when was the last entry into Switzerland?", "Wenn unbekannt\, wann war die letzte Einreise in die Schweiz?", "Si inconnu\, quand a eu lieu la dernière entrée en Suisse ?", "Se sconosciuto\, quando è avvenuto l'ultimo ingresso in Svizzera?")
// * item[=].item[=].type = #date
// * item[=].item[=].enableWhen[+].question = "exposureWhenDate"
// * item[=].item[=].enableWhen[=].operator = #exists
// * item[=].item[=].enableWhen[=].answerBoolean = false
