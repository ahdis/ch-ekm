// Modular sub-questionnaire: "Nach Manifestationsbeginn: Enger Personenkontakt" for Mpox — ja / nein /
// unbekannt (value set ChEkmYesNoUnknown) plus a free-text "Bemerkung" (issue #43). Asked at the END
// of the "Exposition" section, after "Wie". Kept for contact tracing.
//
// A DISEASE-SPECIFIC QUESTION WITHOUT A FHIR TARGET, the Mpox counterpart of the Hepatitis C
// blood-donation question (ChEkmQuestionnaireHepatitisCBloodDonation): decided in the meeting of
// 2.11.2026, the answer travels as a QuestionnaireResponse, not in a resource. The module is written
// exactly once, here, and assembled twice:
//   * into the reporting form (ChEkmQuestionnaireMpox), at the end of the Exposition section;
//   * into the disease-specific questionnaire (ChEkmQuestionnaireMpoxDiseaseSpecific), which the
//     response carried in the document names and is validated against.
// $extract copies this module's item from the form's response into that response — see
// ExtractedQuestionnaireResponseMpox in ChEkmDocumentMpoxTemplate.fsh.
//
// ONE TOP-LEVEL ITEM: the extraction copies a module with one templateExtractValue, which inserts a
// value only when its FHIRPath result is exactly ONE item. This module asks two things (the contact
// and the remark), so they are wrapped in one group, `close-contact-after-onset`, which is also the
// "Nach Manifestationsbeginn" heading of the form. The extraction gate therefore tests the group's
// CHILDREN for an answer (`item.answer.value.exists()`), where a flat module tests its own answer.
//
// THE LINKIDS ARE PLAIN (`close-contact-after-onset`, `close-contact`, `close-contact-note`), not
// prefixed with the disease: yes / no / unknown and a free text are the same for every disease that
// asks the question. Should a second disease ask it, this module moves to input/fsh/questionnnaire/
// unchanged and is shared — see forms-summary.md §8, "Naming the linkIds".
//
// The remark is NOT gated on the answer: it may explain a "ja" (who, how many) as well as an
// "unbekannt". Both items are optional; the form asks.
//
// NO PRE-POPULATION: no SDC launch context carries this.

Instance: ChEkmQuestionnaireMpoxCloseContact
InstanceOf: Questionnaire
Usage: #definition
Title: "EKM: Mpox - Close Contact after Onset of Manifestation"
Description: "Modular sub-questionnaire for the question whether the person had close contact with other persons after the onset of the manifestation, with a remark. Reusable as an SDC assemble-child; NOT extracted into a resource — the answers are carried by the disease-specific QuestionnaireResponse in the document, see ChEkmQuestionnaireResponseDiseaseSpecificMpox."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireMpoxCloseContact)

* item[+].linkId = "close-contact-after-onset"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmMpoxExposureForm#ChEkmMpoxExposureForm.closeContactAfterOnset"
* insert RuleSetQrLevel1Text("After the onset of the manifestation", "Nach Manifestationsbeginn", "Après le début des manifestations", "Dopo l'inizio delle manifestazioni")
* item[=].type = #group

* item[=].item[+].linkId = "close-contact"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmMpoxExposureForm#ChEkmMpoxExposureForm.closeContactAfterOnset.closeContact"
* insert RuleSetQrLevel2Text("Close contact with other persons", "Enger Personenkontakt", "Contact étroit avec d'autres personnes", "Contatto stretto con altre persone")
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmYesNoUnknown"
* item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueCode = #useSupplement
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-snomed-language-supplement"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#radio-button
* item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].extension[=].valueCode = #horizontal

* item[=].item[+].linkId = "close-contact-note"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmMpoxExposureForm#ChEkmMpoxExposureForm.closeContactAfterOnset.note"
* insert RuleSetQrLevel2Text("Remark", "Bemerkung", "Remarque", "Osservazione")
* item[=].item[=].type = #string
