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
* experimental = false
* subjectType = #Patient
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-child

* item[+].linkId = "manifestation-group"
* item[=].text = "Diagnose und Manifestation"
* item[=].type = #group

// Manifestationen - single-choice (symptomatic / asymptomatic), radio buttons
* item[=].item[+].linkId = "manifestation"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaManifestationForm#ChEkmGonorrhoeaManifestationForm.manifestation"
* item[=].item[=].text = "Manifestationen"
* item[=].item[=].type = #choice
* item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].extension[=].valueCode = #horizontal
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmGonorrhoeaManifestationFormChoice"
* item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "displayLanguage"
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "de-CH"
* item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "useSupplement"
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-snomed-language-supplement"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#radio-button

// Manifestationsbeginn unbekannt - default false; when checked it disables the date below
* item[=].item[+].linkId = "manifestationBeginUnknown"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaManifestationForm#ChEkmGonorrhoeaManifestationForm.manifestationBeginUnknown"
* item[=].item[=].text = "Manifestationsbeginn unbekannt"
* item[=].item[=].type = #boolean
* item[=].item[=].initial.valueBoolean = false

// Manifestationsbeginn (Datum) - only enabled while "unbekannt" is not ticked
* item[=].item[+].linkId = "manifestationBeginDate"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaManifestationForm#ChEkmGonorrhoeaManifestationForm.manifestationBeginDate"
* item[=].item[=].text = "Manifestationsbeginn (Datum)"
* item[=].item[=].type = #date
* item[=].item[=].enableWhen[+].question = "manifestationBeginUnknown"
* item[=].item[=].enableWhen[=].operator = #=
* item[=].item[=].enableWhen[=].answerBoolean = false
