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
// ChEkmCompositionHepatitisC; instead the answer travels in the document in the DISEASE-SPECIFIC
// QuestionnaireResponse, `Composition.section[diagnosis].entry[questionnaire-response]`, whose profile
// ChEkmQuestionnaireResponseDiseaseSpecificHepatitisC (input/fsh/profiles/ChEkmHepatitisC.fsh)
// carries the invariant that says this linkId must be answered inside it. The item's `definition` is
// ChEkmHepatitisCManifestationForm.courseOfDisease, whose mapping targets exactly that
// QuestionnaireResponse.
// This module is assembled TWICE, from this one definition: into the reporting form
// (ChEkmQuestionnaireHepatitisC) and into the disease-specific questionnaire
// (ChEkmQuestionnaireHepatitisCDiseaseSpecific) that response answers. The extraction template copies
// this item from the form's response into it — see ChEkmDocumentHepatitisCTemplate.fsh.
//
// THE LINKID IS PREFIXED (`hepatitisc-course-of-disease`) because the question is disease-specific in
// content: its answer list is Hepatitis C only. A course-of-disease question for another disease will
// have other answers and therefore another linkId. A generic question keeps a plain linkId (compare
// `blood-donation`) — see forms-summary.md §8, "Naming the linkIds".
//
// NO PRE-POPULATION: no SDC launch context (%patient / %user / %encounter) carries the course of
// the disease. The form asks.

Instance: ChEkmQuestionnaireHepatitisCCourseOfDisease
InstanceOf: Questionnaire
Usage: #definition
Title: "EKM: Hepatitis C - Course of Disease"
Description: "Modular sub-questionnaire for the 'Krankheitsverlauf' question of the Hepatitis C clinical findings report. Reusable as an SDC assemble-child; NOT extracted into a resource — the answer is carried by the disease-specific QuestionnaireResponse in the document, see ChEkmQuestionnaireResponseDiseaseSpecificHepatitisC."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireHepatitisCCourseOfDisease)

* item[+].linkId = "hepatitisc-course-of-disease"
* insert RuleSetQrLevel1Text("Course of the disease", "Krankheitsverlauf", "Évolution de la maladie", "Decorso della malattia")
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmHepatitisCManifestationForm#ChEkmHepatitisCManifestationForm.courseOfDisease"
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
