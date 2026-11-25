// Modular sub-questionnaire: "Berufliche Tätigkeit" for Mpox (issue #48) — one closed question in the
// "Exposition" section, asked LAST, after "Nach Manifestationsbeginn". It replaces the
// free-text field of the former form with six answers: five groups of occupations by how close the
// contact with other people is, and "unbekannt" (value set ChEkmExposureOccupationalActivity).
//
// EXTRACTED INTO A RESOURCE, unlike its neighbour "Enger Personenkontakt" (issue #43): the answer is
// coded and is what the FOPH evaluates, so it becomes `component[occupationalActivity]` of the
// Exposure (slice on the base ChEkmExposure, RuleSetComponentExposureOccupationalActivity). The
// disease-specific QuestionnaireResponse is for questions WITHOUT a FHIR target.
//
// The linkId is plain (`occupationalActivity`), and the value set, the component slice and the
// extraction rule set are disease-agnostic. Only the item's `definition` names Mpox; should a second
// disease ask the question, this module moves to input/fsh/questionnnaire/ with the element on the
// shared ChEkmExposureForm.
//
// A GROUP WITH ONE ITEM: every other block of the Exposition (Wo, Wann, Wie, Nach
// Manifestationsbeginn) is a group, which the renderer draws as a card with a heading. A bare item
// between them floats outside the cards, so the question gets its own group `occupation`, headed
// "Berufliche Tätigkeit", with the question inside. The extraction reads the item by linkId
// (descendants()), so the wrapping group does not matter to it.
//
// Radio buttons, VERTICAL: six answers with long labels. Optional; unanswered = no component.
// NO PRE-POPULATION: no SDC launch context carries this.

Instance: ChEkmQuestionnaireMpoxOccupationalActivity
InstanceOf: Questionnaire
Usage: #definition
Title: "EKM: Mpox - Occupational Activity"
Description: "Modular sub-questionnaire for the occupational activity of the person (Berufliche Tätigkeit): healthcare and nursing, sex work, services involving close physical contact, supervision and education, occupation without close contact with other people, unknown. Reusable as an SDC assemble-child; extracted into a component of the CH EKM Exposure."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireMpoxOccupationalActivity)

* item[+].linkId = "occupation"
* insert RuleSetQrLevel1Text("Occupation", "Berufliche Tätigkeit", "Activité professionnelle", "Attività professionale")
* item[=].type = #group

* item[=].item[+].linkId = "occupationalActivity"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmMpoxExposureForm#ChEkmMpoxExposureForm.occupationalActivity"
* insert RuleSetQrLevel2Text("Area of activity", "Tätigkeitsbereich", "Domaine d'activité", "Settore di attività")
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmExposureOccupationalActivity"
// "Unknown" is a SNOMED CT code: its de/fr/it labels come from the language supplement.
* item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueCode = #useSupplement
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-snomed-language-supplement"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#radio-button
