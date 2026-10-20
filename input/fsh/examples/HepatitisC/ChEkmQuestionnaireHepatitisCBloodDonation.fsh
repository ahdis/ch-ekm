// Modular sub-questionnaire: "Diagnose im Rahmen einer Blutspende" for Hepatitis C — ja / nein /
// unbekannt (value set ChEkmYesNoUnknown). The question comes from the "Questionnaire — Potentiale
// Questionnaire Fragen" block of the Hepatitis C CSV, where it is marked for this disease.
//
// A DISEASE-SPECIFIC QUESTION WITHOUT A FHIR TARGET, like the Krankheitsverlauf
// (ChEkmQuestionnaireHepatitisCCourseOfDisease). The two are the modules of the disease-specific
// part of the Hepatitis C form, and each is written exactly once, here:
//   * the reporting form (ChEkmQuestionnaireHepatitisC) assembles both, each where it belongs on
//     the form — this one at the START of the "Diagnose und Manifestation" section, before the
//     manifestations; the Krankheitsverlauf after the Manifestationsbeginn;
//   * the disease-specific questionnaire (ChEkmQuestionnaireHepatitisCDiseaseSpecific) assembles the
//     SAME two modules, one after the other. It is what the response carried in the document names,
//     and what that response is validated against.
// $extract copies each module's item from the form's response into that response — see
// ExtractedQuestionnaireResponseHepatitisC in ChEkmDocumentHepatitisCTemplate.fsh.
//
// ONE TOP-LEVEL ITEM PER MODULE, flat like ChEkmQuestionnaireManifestationBeginUnknown: the
// extraction copies a module with one templateExtractValue, which inserts a value only when its
// FHIRPath result is exactly ONE item. A module asking several questions wraps them in one group.
//
// THE LINKID IS PLAIN (`blood-donation`), not prefixed with the disease: the question and its answers
// (yes / no / unknown) are the same for every disease that asks it, and the disease is already named
// by the questionnaire a response answers. Should a second disease ask it, this module moves to
// input/fsh/questionnnaire/ unchanged and is shared — see forms-summary.md §8, "Naming the linkIds".
//
// NO PRE-POPULATION: no SDC launch context carries this. The form asks.

Instance: ChEkmQuestionnaireHepatitisCBloodDonation
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Hepatitis C - Diagnosis from Blood Donation"
Description: "Modular sub-questionnaire for the question whether the Hepatitis C diagnosis was made in the context of a blood donation. Reusable as an SDC assemble-child; NOT extracted into a resource — the answer is carried by the disease-specific QuestionnaireResponse in the document, see ChEkmQuestionnaireResponseDiseaseSpecificHepatitisC."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireHepatitisCBloodDonation)

* item[+].linkId = "blood-donation"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmHepatitisCManifestationForm#ChEkmHepatitisCManifestationForm.bloodDonation"
* insert RuleSetQrLevel1Text("Was the diagnosis made in the context of a blood donation?", "Wurde die Diagnose im Rahmen einer Blutspende gestellt?", "Le diagnostic a-t-il été posé dans le cadre d'un don de sang ?", "La diagnosi è stata posta nell'ambito di una donazione di sangue?")
* item[=].type = #choice
* item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmYesNoUnknown"
* item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].answerValueSet.extension[=].extension[=].valueCode = #useSupplement
* item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-snomed-language-supplement"
* item[=].extension[+].url = $questionnaire-itemControl
* item[=].extension[=].valueCodeableConcept = $item-control#radio-button
* item[=].extension[+].url = $choiceOrientation
* item[=].extension[=].valueCode = #horizontal
