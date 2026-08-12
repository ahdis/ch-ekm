// Modular sub-questionnaire: "Wo" — most probable place of infection.
// Source of truth: logical model ChEkmExposureForm.where (-> ChEkmExposure.extension[exposureAddress])
// Form items per https://github.com/ahdis/ch-ekm/issues/26:
//   1. CH/LI (check-box)                                  -> valueAddress.country = CH (form-only item)
//   2. Ausland, Land (dropdown)                           -> valueAddress.country (+ country coding)
//   3. Genauer Ort (CH/LI und Ausland) (free text)        -> valueAddress.city
//   4. Unbekannt (separate box)                           -> valueAddress.extension[data-absent-reason]
//
// (1) is FORM-ONLY: the logical model has no inland/ausland element ("on the structured level we
// will not have inland/ausland as separate checkbox items", decision of June 1st, see
// ChEkmExposureForm), so the check-box has no `definition` and is collapsed to country = CH by the
// extraction template. Ticking it hides the "Ausland" dropdown (the two are alternatives).
//
// (1) and (4) are `choice` items with a SINGLE `valueString` answerOption and the check-box item
// control, not `boolean` items - see the note on item 1 for why (label placement + un-tick
// behaviour). The option is a plain string, not a Coding: it is a form label, not a coded concept
// (a Coding would have to carry the terminology's own display, e.g. "Switzerland" instead of
// "Schweiz/Liechtenstein (CH/LI)"), and nothing but its presence is read at extraction.
//
// (4) is a separate box, as on the paper form: it neither disables nor overrides the items above.
// It is not yet defined whether "Unbekannt" refers to the country, the precise location or both
// (issue #26), so the extraction template keeps BOTH - the data-absent-reason and whatever country /
// precise location was entered (see RuleSetExposureWhere).

Instance: ChEkmQuestionnaireExposureWhere
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Exposure - Where (place of infection)"
Description: "Modular sub-questionnaire for the 'Wo' (where) group of the Exposure section: the most probable place of infection - Switzerland/Liechtenstein or a country abroad, the precise location, or explicitly unknown. Reusable as an SDC assemble-child."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireExposureWhere)

* item[+].linkId = "exposureWhere"
* insert RuleSetQrLevel1Text("Where (place of infection\)", "Wo (Ort der Ansteckung\)", "Où (lieu de l'infection\)", "Dove (luogo del contagio\)")
* item[=].type = #group

// 1. CH/LI - a single-option check-box (see the file header). Ticking it hides the "Ausland"
//    dropdown below.
//
//    Why a `choice` with ONE answerOption and not a `boolean`: a boolean item puts its label in the
//    renderer's LEFT label column and the box on the right (Smart Forms ItemFieldGrid / BooleanItem),
//    which does not read like the paper form. A check-box `choice` renders "[x] <option label>" in
//    one line, so the option display carries the visible label and the item itself needs NO `text`
//    (the group header "Wo (Ort der Ansteckung)" gives the context). `repeats = true` is what makes
//    an already-ticked box un-tickable: un-ticking then REMOVES the answer (a boolean check-box
//    would leave `false` behind), which is why the enableWhen below and the extraction template gate
//    on `exists()` alone.
* item[=].item[+].linkId = "exposureWhereChLi"
* item[=].item[=].type = #choice
* item[=].item[=].repeats = true
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#check-box
* insert RuleSetQrLevel2AnswerOptionText("Switzerland / Liechtenstein (CH/LI\)", "Schweiz/Liechtenstein (CH/LI\)", "Suisse / Liechtenstein (CH/LI\)", "Svizzera / Liechtenstein (CH/LI\)")

// 2. Ausland, Land - choice (country codes), autocomplete. Shown while CH/LI is not ticked; since
//    un-ticking the check-box above removes its answer, a single `exists = false` is enough.
* item[=].item[+].linkId = "exposureWhereCountry"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmExposureForm#ChEkmExposureForm.where.country"
* insert RuleSetQrLevel2Text("Abroad\, country", "Ausland\, Land", "À l'étranger\, pays", "All'estero\, Paese")
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmCountryCodes"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#autocomplete
* item[=].item[=].enableWhen[+].question = "exposureWhereChLi"
* item[=].item[=].enableWhen[=].operator = #exists
* item[=].item[=].enableWhen[=].answerBoolean = false

// 3. Genauer Ort (CH/LI und Ausland) - free text, applies to both branches above
* item[=].item[+].linkId = "exposureWherePreciseLocation"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmExposureForm#ChEkmExposureForm.where.preciseLocation"
* insert RuleSetQrLevel2Text("Precise location (Switzerland/Liechtenstein and abroad\)", "Genauer Ort (CH/LI und Ausland\)", "Lieu précis (CH/LI et étranger\)", "Luogo preciso (CH/LI ed estero\)")
* item[=].item[=].type = #string

// 4. Unbekannt - separate box (see the file header); extracted IN ADDITION to 1-3, not instead of them.
//    Same single-option check-box shape as the CH/LI item above (ticked = the model's
//    `where.unknown` is true; the answer Coding itself is never written to the Exposure, the
//    template only tests whether it exists).
* item[=].item[+].linkId = "exposureWhereUnknown"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmExposureForm#ChEkmExposureForm.where.unknown"
* item[=].item[=].type = #choice
* item[=].item[=].repeats = true
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#check-box
* insert RuleSetQrLevel2AnswerOptionText("Place of infection unknown", "Unbekannt", "Inconnu", "Sconosciuto")
