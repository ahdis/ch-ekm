// Modular sub-questionnaire: "Diagnose und Manifestation" -> Manifestationsbeginn (onset, or unknown)
// Source of truth: logical model ChEkmManifestationForm (-> ChEkmCondition)
//
// Layout (issue #41): the date question with an "Unbekannt" tick box directly under its field,
// instead of a separate "Manifestationsbeginn unbekannt: ja / nein" question above the date:
//
//   Manifestationsbeginn   [DD.MM.YYYY]
//                          [ ] Unbekannt
//
// Standard SDC only, no renderer-specific layout:
//   - The box is a `choice` item with a `check-box` control and ONE answer, sct#261665006 "Unknown"
//     (ChEkmUnknown, de/fr/it from the SNOMED CT supplement). Its text sits next to the box. The item
//     itself has NO text, so its field lines up under the date field with an empty label column.
//     A boolean would not do: Smart Forms shows a boolean check-box's text to screen readers only.
//   - The box is enableWhen-gated on the date (`exists = false`): entering a date removes it, so a
//     date and "unknown" can never be answered together, with no validation message. The date
//     stays visible, so nothing is left without the "Manifestationsbeginn" label next to it.
//
// One line ("Manifestationsbeginn [Datum] [ ] unbekannt") was tried as a one-row `grid` and dropped:
// Smart Forms always draws a grid's header row ("Datum | unbekannt"), and SDC has no item control or
// extension that puts two questions on one line without a table. R5 `answerConstraint =
// optionsOrType` does not fit either: answerOption values must have the item's type, so a date item
// cannot offer a coded "unknown" (and neither Smart Forms nor LHC-Forms supports it).

Instance: ChEkmQuestionnaireManifestationBeginUnknown
InstanceOf: Questionnaire
Usage: #definition
Title: "EKM: Manifestation - Onset"
Description: "Modular sub-questionnaire for the onset of the manifestations ('Manifestationsbeginn': the date, with an 'unknown' tick box under it) in the 'Diagnose und Manifestation' section of the clinical findings report. Reusable as an SDC assemble-child."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireManifestationBeginUnknown)

// Manifestationsbeginn (Datum)
* item[+].linkId = "manifestationBeginDate"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmManifestationForm#ChEkmManifestationForm.manifestationBeginDate"
* insert RuleSetQrLevel1Text("Onset of manifestation", "Manifestationsbeginn", "Début des manifestations", "Inizio delle manifestazioni")
* item[=].type = #date

// "Unbekannt" - one tick box, offered only while no date is entered. No item text: the label is
// the answer option's display, next to the box.
* item[+].linkId = "manifestationBeginUnknown"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmManifestationForm#ChEkmManifestationForm.manifestationBeginUnknown"
* item[=].type = #choice
* item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmUnknown"
* item[=].extension[+].url = $questionnaire-itemControl
* item[=].extension[=].valueCodeableConcept = $item-control#check-box
* item[=].enableWhen[+].question = "manifestationBeginDate"
* item[=].enableWhen[=].operator = #exists
* item[=].enableWhen[=].answerBoolean = false
