// Modular sub-questionnaire: "Exposition" -> Wie (Übertragungsweg) (Gonorrhoea green section)
// Source of truth: logical model ChEkmGonorrhoeaExpositionForm.transmission (-> ChEkmExposureGonorrhoea)
// Decisions (2026-06-09): contact-partner sex = administrative-gender (model);
// Art der Beziehung = ChEkmExposureRelationshipType (model codes).

Instance: ChEkmQuestionnaireGonorrhoeaExposition
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Gonorrhoea - Exposition (Übertragungsweg)"
Description: "Modular sub-questionnaire for the 'Wie (Übertragungsweg)' part of the 'Exposition' section of the Gonorrhoea clinical findings report. Reusable as an SDC assemble-child."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoeaExposition"
* version = "0.0.1"
* name = "ChEkmQuestionnaireGonorrhoeaExposition"
* status = #active
* experimental = false
* subjectType = #Patient
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-child

* item[+].linkId = "transmission"
* item[=].text = "Wie (Übertragungsweg)"
* item[=].type = #group

// Sexualkontakt mit infizierter Person - Geschlecht (Frau / Mann / Andere)
* item[=].item[+].linkId = "sexualContactPartner"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaExpositionForm#ChEkmGonorrhoeaExpositionForm.transmission.sexualContactPartner"
* item[=].item[=].text = "Sexualkontakt mit infizierter Person (Geschlecht)"
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://hl7.org/fhir/ValueSet/administrative-gender"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#radio-button
* item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].extension[=].valueCode = #horizontal
* item[=].item[=].enableWhen[+].question = "unknown"
* item[=].item[=].enableWhen[=].operator = #=
* item[=].item[=].enableWhen[=].answerBoolean = false

// Art der Beziehung (fester / nicht fester Partner / Angebot bzw. Inanspruchnahme von bezahltem Sex)
* item[=].item[+].linkId = "relationshipType"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaExpositionForm#ChEkmGonorrhoeaExpositionForm.transmission.relationshipType"
* item[=].item[=].text = "Art der Beziehung"
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmExposureRelationshipType"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#radio-button
* item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].extension[=].valueCode = #horizontal
* item[=].item[=].enableWhen[+].question = "unknown"
* item[=].item[=].enableWhen[=].operator = #=
* item[=].item[=].enableWhen[=].answerBoolean = false

// Anderer Übertragungsweg (Freitext)
* item[=].item[+].linkId = "otherTransmission"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaExpositionForm#ChEkmGonorrhoeaExpositionForm.transmission.otherTransmission"
* item[=].item[=].text = "Anderer Übertragungsweg (Freitext)"
* item[=].item[=].type = #string
* item[=].item[=].enableWhen[+].question = "unknown"
* item[=].item[=].enableWhen[=].operator = #=
* item[=].item[=].enableWhen[=].answerBoolean = false

// Übertragungsweg unbekannt - default false; when checked it disables the details below
* item[=].item[+].linkId = "unknown"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaExpositionForm#ChEkmGonorrhoeaExpositionForm.transmission.unknown"
* item[=].item[=].text = "Übertragungsweg unbekannt"
* item[=].item[=].type = #boolean
* item[=].item[=].initial.valueBoolean = false

