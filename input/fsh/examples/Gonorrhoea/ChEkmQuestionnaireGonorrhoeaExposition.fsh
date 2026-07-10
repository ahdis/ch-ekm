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
* language = #en
* experimental = false
* subjectType = #Patient
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-child

* item[+].linkId = "transmission"
* item[=].text = "How (route of transmission)"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Wie (Übertragungsweg)"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Comment (voie de transmission)"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Come (via di trasmissione)"
* item[=].type = #group

// Sexualkontakt mit infizierter Person - Geschlecht (Frau / Mann / Andere)
* item[=].item[+].linkId = "sexualContactPartner"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaExpositionForm#ChEkmGonorrhoeaExpositionForm.transmission.sexualContactPartner"
* item[=].item[=].text = "Sexual contact with an infected person (gender)"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Sexualkontakt mit infizierter Person (Geschlecht)"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Rapport sexuel avec une personne infectée (sexe)"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Rapporto sessuale con una persona infetta (sesso)"
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://hl7.org/fhir/ValueSet/administrative-gender"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#radio-button
* item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].extension[=].valueCode = #horizontal
// * item[=].item[=].enableWhen[+].question = "unknown"
// * item[=].item[=].enableWhen[=].operator = #=
// * item[=].item[=].enableWhen[=].answerBoolean = false

// Art der Beziehung (fester / nicht fester Partner / Angebot bzw. Inanspruchnahme von bezahltem Sex)
* item[=].item[+].linkId = "relationshipType"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaExpositionForm#ChEkmGonorrhoeaExpositionForm.transmission.relationshipType"
* item[=].item[=].text = "Type of relationship"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Art der Beziehung"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Type de relation"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Tipo di relazione"
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmExposureRelationshipType"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#radio-button
* item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].extension[=].valueCode = #horizontal
// * item[=].item[=].enableWhen[+].question = "unknown"
// * item[=].item[=].enableWhen[=].operator = #=
// * item[=].item[=].enableWhen[=].answerBoolean = false

// Anderer Übertragungsweg (Freitext)
* item[=].item[+].linkId = "otherTransmission"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaExpositionForm#ChEkmGonorrhoeaExpositionForm.transmission.otherTransmission"
* item[=].item[=].text = "Other route of transmission (free text)"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Anderer Übertragungsweg (Freitext)"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Autre voie de transmission (texte libre)"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Altra via di trasmissione (testo libero)"
* item[=].item[=].type = #string
// * item[=].item[=].enableWhen[+].question = "unknown"
// * item[=].item[=].enableWhen[=].operator = #=
// * item[=].item[=].enableWhen[=].answerBoolean = false

// Übertragungsweg unbekannt - default false; when checked it disables the details below
* item[=].item[+].linkId = "unknown"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaExpositionForm#ChEkmGonorrhoeaExpositionForm.transmission.unknown"
* item[=].item[=].text = "Route of transmission unknown"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Übertragungsweg unbekannt"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Voie de transmission inconnue"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Via di trasmissione sconosciuta"
* item[=].item[=].type = #boolean
//* item[=].item[=].initial.valueBoolean = false

