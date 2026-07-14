// Modular sub-questionnaire: "Diagnose und Manifestation" -> Manifestationen (Gonorrhoea green section)
// Source of truth: logical model ChEkmGonorrhoeaManifestationForm (-> ChEkmConditionGonorrhoea)

Instance: ChEkmQuestionnaireGonorrhoeaManifestation
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Gonorrhoea - Manifestation"
Description: "Modular sub-questionnaire for the 'Manifestationen' part of the 'Diagnose und Manifestation' section of the Gonorrhoea clinical findings report. Reusable as an SDC assemble-child."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoeaManifestation"
* version = "0.0.1"
* name = "ChEkmQuestionnaireGonorrhoeaManifestation"
* status = #active
* language = #en
* experimental = false
* subjectType = #Patient
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-child

* item[+].linkId = "manifestation-group"
* item[=].text = "Diagnosis and manifestation"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Diagnose und Manifestation"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Diagnostic et manifestation"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Diagnosi e manifestazione"
* item[=].type = #group

// Manifestationen - single-choice (symptomatic / asymptomatic), radio buttons
* item[=].item[+].linkId = "manifestation"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaManifestationForm#ChEkmGonorrhoeaManifestationForm.manifestation"
* item[=].item[=].text = "Manifestations"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Manifestationen"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Manifestations"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Manifestazioni"
* item[=].item[=].type = #choice
* item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].extension[=].valueCode = #horizontal
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmGonorrhoeaManifestationFormChoice"
* item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueCode = #useSupplement
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-snomed-language-supplement"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#radio-button


// Subquestionnaire: Manifestationsbeginn unbekannt (Manifestation begin unknown) - checkbox + date
* item[=].item[+].linkId = "manifestationBeginUnknown"
* item[=].item[=].type = #display
* item[=].item[=].text = "Onset of manifestation unknown"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Manifestationsbeginn Beginn / unbekannt"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Début des manifestations / inconnu"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Inizio delle manifestazioni /sconosciuto"
* item[=].item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireManifestationBeginUnknown"
