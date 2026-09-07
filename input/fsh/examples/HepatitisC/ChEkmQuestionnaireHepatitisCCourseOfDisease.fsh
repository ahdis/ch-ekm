// Modular sub-questionnaire: "Krankheitsverlauf" for Hepatitis C — akut / chronisch / Zirrhose /
// Hepatokarzinom / General wellbeing (value set ChEkmHepatitisCCourseOfDisease).
//
// This file is disease-SPECIFIC — like ChEkmQuestionnaireImmunizationMpox, and unlike the children
// in input/fsh/questionnnaire/ — because the answer list is a property of the disease.
//
// PLACED IN THE "DIAGNOSE UND MANIFESTATION" SECTION, directly after the Manifestationsbeginn and
// before the Labor block, so it is inserted at LEVEL 3 (inside `manifestation-group`) rather than
// as a tab of its own. Like ChEkmQuestionnaireManifestationBeginUnknown it contributes a FLAT item,
// not a wrapping group, so the question renders as one more row of the Diagnose tab. It carries no
// sdc-questionnaire-shortText for that reason: it is never a tab, so there is no tab label to give.
//
// NOT EXTRACTED INTO A RESOURCE — deliberately, and this is the whole point of the design decided
// for TODO.md #7. There is no Condition/Observation target for the course of the disease in
// ChEkmCompositionHepatitisC; instead THE QUESTIONNAIRERESPONSE ITSELF travels in the document, as
// `Composition.section[diagnosis].entry[questionnaire-response]`, and the profile
// ChEkmQuestionnaireResponseCourseOfDiseaseHepatitisC (input/fsh/profiles/ChEkmHepatitisC.fsh)
// carries the invariant that says this linkId must be answered inside it. That is why the item has
// no `definition`: there is no logical-model element behind it, because there is no mapping target.
// The extraction template copies the whole QuestionnaireResponse into the Bundle — see
// ChEkmDocumentHepatitisCTemplate.fsh.
//
// NO PRE-POPULATION: no SDC launch context (%patient / %user / %encounter) carries the course of
// the disease. The form asks.

Instance: ChEkmQuestionnaireHepatitisCCourseOfDisease
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: HepatitisC - Course of Disease"
Description: "Modular sub-questionnaire for the 'Krankheitsverlauf' question of the Hepatitis C clinical findings report. Reusable as an SDC assemble-child; NOT extracted into a resource — the QuestionnaireResponse itself is carried in the document, see ChEkmQuestionnaireResponseCourseOfDiseaseHepatitisC."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireHepatitisCCourseOfDisease)

* item[+].linkId = "course-of-disease"
* insert RuleSetQrLevel1Text("Course of the disease", "Krankheitsverlauf", "Évolution de la maladie", "Decorso della malattia")
* item[=].type = #choice
* item[=].repeats = true
* item[=].extension[+].url = $choiceOrientation
* item[=].extension[=].valueCode = #vertical
* item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmHepatitisCCourseOfDisease"
* item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].answerValueSet.extension[=].extension[=].valueCode = #useSupplement
* item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-snomed-language-supplement"
* item[=].extension[+].url = $questionnaire-itemControl
* item[=].extension[=].valueCodeableConcept = $item-control#check-box
