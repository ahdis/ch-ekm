// Modular sub-questionnaire: "Wie (Übertragungsweg)" — route-of-transmission group.
// Extracted from the Gonorrhoea root so the transmission group is a reusable assemble-child.
// Source of truth: logical model ChEkmGonorrhoeaExposureForm.transmission (-> ChEkmExposureGonorrhoea)
// Decisions (2026-06-09): contact-partner sex = administrative-gender (model);
// Art der Beziehung = ChEkmExposureRelationshipType (model codes).
//
// THE ITEMS LIVE IN THREE RULE SETS, the module only arranges them (issue #44). A disease whose "Wie"
// asks more than these four questions cannot get them from this module: $assemble can neither
// parameterise a sub-questionnaire nor include a child conditionally, and the extra questions sit IN
// THE MIDDLE of the group (above "Anderer Übertragungsweg"). So such a disease writes its own "Wie"
// module from the same rule sets, with its extra rule set in between — the Impfstatus pattern
// (RuleSetQrImmunizationRow). Mpox does so in ChEkmQuestionnaireExposureHowMpox:
//   RuleSetQrExposureHowSexualContact   Sexualkontakt (Geschlecht), Art der Beziehung
//   RuleSetQrExposureHowContacts        Andere Übertragungswege (Kontakt als Medizinal- /
//                                       Pflegepersonal | im Haushalt), Kontakt mit laborbestätigtem
//                                       Fall (ja / nein / unbekannt) — #44
//   RuleSetQrExposureHowOtherUnknown    Anderer Übertragungsweg (Freitext), Übertragungsweg unbekannt
// All of them expect to be inserted right after the `exposureHow` group item (level-2 items). The
// linkIds are the same in every "Wie" module: the extraction (RuleSetComponentExposure,
// RuleSetComponentExposureContacts) reads them by linkId, whichever module the form assembled.

Instance: ChEkmQuestionnaireExposureHow
InstanceOf: Questionnaire
Usage: #definition
Title: "EKM: Exposure - How (route of transmission)"
Description: "Modular sub-questionnaire for the 'Wie (Übertragungsweg)' (route of transmission) group. Holds the transmission group (sexual-contact partner sex, relationship type, other route, unknown). Reusable as an SDC assemble-child."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireExposureHow)

* item[+].linkId = "exposureHow"
* insert RuleSetQrLevel1Text("How (route of transmission\)", "Wie (Übertragungsweg\)", "Comment (voie de transmission\)", "Come (via di trasmissione\)")
* item[=].type = #group
* insert RuleSetQrExposureHowSexualContact
* insert RuleSetQrExposureHowOtherUnknown


RuleSet: RuleSetQrExposureHowSexualContact
// Sexualkontakt mit infizierter Person - Geschlecht (Frau / Mann; "Andere" dropped with #32)
* item[=].item[+].linkId = "exposureHowSexualContactPartner"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaExposureForm#ChEkmGonorrhoeaExposureForm.transmission.sexualContactPartner"
* insert RuleSetQrLevel2Text("Sexual contact with an infected person (gender\)", "Sexualkontakt mit infizierter Person (Geschlecht\)", "Rapport sexuel avec une personne infectée (sexe\)", "Rapporto sessuale con una persona infetta (sesso\)")
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmExposureSexualContactPartner"
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


RuleSet: RuleSetQrExposureHowOtherUnknown
// Anderer Übertragungsweg (Freitext)
* item[=].item[+].linkId = "exposureHowOtherTransmission"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaExposureForm#ChEkmGonorrhoeaExposureForm.transmission.otherTransmission"
* insert RuleSetQrLevel2Text("Other route of transmission (free text\)", "Anderer Übertragungsweg (Freitext\)", "Autre voie de transmission (texte libre\)", "Altra via di trasmissione (testo libero\)")
* item[=].item[=].type = #string
// * item[=].item[=].enableWhen[+].question = "unknown"
// * item[=].item[=].enableWhen[=].operator = #=
// * item[=].item[=].enableWhen[=].answerBoolean = false

// "Übertragungsweg unbekannt" (route of transmission unknown) - default false; when checked it
// disables the details below
* item[=].item[+].linkId = "exposureHowUnknown"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaExposureForm#ChEkmGonorrhoeaExposureForm.transmission.unknown"
* insert RuleSetQrLevel2Text("Route of transmission unknown", "Übertragungsweg unbekannt", "Voie de transmission inconnue", "Via di trasmissione sconosciuta")
* item[=].item[=].type = #boolean
//* item[=].item[=].initial.valueBoolean = false


// The contact questions (issue #44, asked by the Mpox form today):
//   Andere Übertragungswege   radio buttons, one of: Kontakt als Medizinal- / Pflegepersonal |
//                             Kontakt im Haushalt (ChEkmExposureContactRoute) — the same control as
//                             "Art der Beziehung"; no "unbekannt", unanswered = not reported
//   Kontakt mit laborbestätigtem <Krankheit>-Fall   ja / nein / unbekannt — a closed question of its
//                             own: its "nein" is an answer FOPH wants to receive
//
// Disease-agnostic on purpose, parameterised by what differs between diseases:
//   form       the disease's exposure logical model, which declares the two elements under
//              `transmission` (e.g. ChEkmMpoxExposureForm) — the items' `definition`
//   case-*     the text of the second question in four languages, which names the disease
//              ("Kontakt mit laborbestätigtem Mpox-Fall")
// The linkIds are NOT parameterised: the extraction (RuleSetComponentExposureContacts) is shared too
// and reads them by name, into components of the base ChEkmExposure.
//
// The items are not disabled by "Übertragungsweg unbekannt", for the same reason the other items of
// the group are not (the enableWhen there is commented out): the physician may know a household
// contact and still not know the route.
RuleSet: RuleSetQrExposureHowContacts(form, case, case-de-CH, case-fr-CH, case-it-CH)
* item[=].item[+].linkId = "exposureHowContactRoute"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/{form}#{form}.transmission.contactRoute"
* insert RuleSetQrLevel2Text("Other routes of transmission", "Andere Übertragungswege", "Autres voies de transmission", "Altre vie di trasmissione")
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmExposureContactRoute"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#radio-button
* item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].extension[=].valueCode = #horizontal

* item[=].item[+].linkId = "exposureHowConfirmedCaseContact"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/{form}#{form}.transmission.confirmedCaseContact"
* insert RuleSetQrLevel2Text({case}, {case-de-CH}, {case-fr-CH}, {case-it-CH})
* insert RuleSetQrExposureHowYesNoUnknown

// ja / nein / unbekannt as horizontal radio buttons, labels from the SNOMED CT language supplement —
// the same control as "Enger Personenkontakt" (ChEkmQuestionnaireMpoxCloseContact).
RuleSet: RuleSetQrExposureHowYesNoUnknown
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
