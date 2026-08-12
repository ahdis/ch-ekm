// Modular sub-questionnaire: "Wie (Übertragungsweg)" — route-of-transmission group.
// Extracted from the Gonorrhoea root so the transmission group is a reusable assemble-child.
// Source of truth: logical model ChEkmGonorrhoeaExposureForm.transmission (-> ChEkmExposureGonorrhoea)
// Decisions (2026-06-09): contact-partner sex = administrative-gender (model);
// Art der Beziehung = ChEkmExposureRelationshipType (model codes).

Instance: ChEkmQuestionnaireExposureHow
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Exposure - How (route of transmission)"
Description: "Modular sub-questionnaire for the 'Wie (Übertragungsweg)' (route of transmission) group. Holds the transmission group (sexual-contact partner sex, relationship type, other route, unknown). Reusable as an SDC assemble-child."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireExposureHow)

* item[+].linkId = "exposureHow"
* insert RuleSetQrLevel1Text("How (route of transmission\)", "Wie (Übertragungsweg\)", "Comment (voie de transmission\)", "Come (via di trasmissione\)")
* item[=].type = #group

// Sexualkontakt mit infizierter Person - Geschlecht (Frau / Mann / Andere)
* item[=].item[+].linkId = "exposureHowSexualContactPartner"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaExposureForm#ChEkmGonorrhoeaExposureForm.transmission.sexualContactPartner"
* insert RuleSetQrLevel2Text("Sexual contact with an infected person (gender\)", "Sexualkontakt mit infizierter Person (Geschlecht\)", "Rapport sexuel avec une personne infectée (sexe\)", "Rapporto sessuale con una persona infetta (sesso\)")
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmPatientAdministrativeSex"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#radio-button
* item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].extension[=].valueCode = #horizontal
// * item[=].item[=].enableWhen[+].question = "unknown"
// * item[=].item[=].enableWhen[=].operator = #=
// * item[=].item[=].enableWhen[=].answerBoolean = false

// Art der Beziehung (fester / nicht fester Partner / Angebot bzw. Inanspruchnahme von bezahltem Sex)
* item[=].item[+].linkId = "exposureHowRelationshipType"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaExposureForm#ChEkmGonorrhoeaExposureForm.transmission.relationshipType"
* insert RuleSetQrLevel2Text("Type of relationship", "Art der Beziehung", "Type de relation", "Tipo di relazione")
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
* item[=].item[+].linkId = "exposureHowOtherTransmission"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaExposureForm#ChEkmGonorrhoeaExposureForm.transmission.otherTransmission"
* insert RuleSetQrLevel2Text("Other route of transmission (free text\)", "Anderer Übertragungsweg (Freitext\)", "Autre voie de transmission (texte libre\)", "Altra via di trasmissione (testo libero\)")
* item[=].item[=].type = #string
// * item[=].item[=].enableWhen[+].question = "unknown"
// * item[=].item[=].enableWhen[=].operator = #=
// * item[=].item[=].enableWhen[=].answerBoolean = false

// Übertragungsweg unbekannt - default false; when checked it disables the details below
* item[=].item[+].linkId = "exposureHowUnknown"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaExposureForm#ChEkmGonorrhoeaExposureForm.transmission.unknown"
* insert RuleSetQrLevel2Text("Route of transmission unknown", "Übertragungsweg unbekannt", "Voie de transmission inconnue", "Via di trasmissione sconosciuta")
* item[=].item[=].type = #boolean
//* item[=].item[=].initial.valueBoolean = false

