// Modular sub-questionnaire: "Wo" — most probable place of infection.
// Source of truth: logical model ChEkmExposureForm.where (-> ChEkmExposure.extension[exposureAddress])
// Form items per https://github.com/ahdis/ch-ekm/issues/26:
//   1. Land (dropdown, mandatory)                        -> valueAddress.country (+ country coding)
//   2. Genauer Ort (free text)                           -> valueAddress.city
//   3. Unbekannt (check-box belonging to 2.)             -> valueAddress._city.extension[data-absent-reason]
//
// (2) and (3) are ONE question in two widgets: the precise location, or "unbekannt" when it is not
// known. Each of the two questions therefore carries its own unknown - the dropdown's "Unbekannt"
// option for the country, this box for the precise location - and each becomes a data-absent-reason
// on its own Address element, so "Land Schweiz, genauer Ort unbekannt" is reportable as such.
//
// There is exactly ONE country question. The paper form's "CH/LI check-box next to an Ausland
// dropdown" layout is NOT reproduced: the place of infection is a single country, never a
// combination of two, and it is always reported as a country CODE. Switzerland and Liechtenstein
// are simply the first two entries of the answer value set (ChEkmCountryCodesInclUnknown), so the
// inland case is answered in the same field as any other country - which also removes the former
// form-only item `exposureWhereChLi` and its enableWhen gate on the dropdown.
//
// The value set additionally offers sct#261665006 "Unknown" as a last resort: the country is a
// MANDATORY field, so "unbekannt" must be selectable rather than left blank. That option is a
// SNOMED CT concept, not an ISO 3166 country, so the extraction template does NOT write it to
// `country`; it marks the country itself as absent - `valueAddress._country.extension` carries a
// data-absent-reason (asked-unknown) instead (see RuleSetExposureWhere).
//
// (3) is a `choice` item with a SINGLE `valueString` answerOption and the check-box item control,
// not a `boolean` item: a boolean item puts its label in the renderer's LEFT label column and the
// box on the right (Smart Forms ItemFieldGrid / BooleanItem), which does not read like the paper
// form. A check-box `choice` renders "[x] <option label>" in one line, so the option display
// carries the visible label and the item itself needs NO `text` (the group header gives the
// context). The option is a plain string, not a Coding: it is a form label, not a coded concept,
// and nothing but its presence is read at extraction. `repeats = true` is what makes an
// already-ticked box un-tickable: un-ticking then REMOVES the answer (a boolean check-box would
// leave `false` behind), which is why the extraction template gates on `exists()` alone.
//
// (3) sits in its own row, as on the paper form, and does not disable (2): the two are alternatives
// only in practice. Should a response carry both, the extraction template keeps the entered text
// rather than claiming the value is absent (see RuleSetExposureWhere).

Instance: ChEkmQuestionnaireExposureWhere
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Exposure - Where (place of infection)"
Description: "Modular sub-questionnaire for the 'Wo' (where) group of the Exposure section: the most probable place of infection - the country (Switzerland/Liechtenstein first, 'unknown' as a last resort), the precise location, or explicitly unknown. Reusable as an SDC assemble-child."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireExposureWhere)

* item[+].linkId = "exposureWhere"
* insert RuleSetQrLevel1Text("What is the most probable place of infection?", "Was ist der meistwahrscheinlichste Ort der Ansteckung?", "Quel est le lieu de contamination le plus probable ?", "Qual è il luogo di contagio più probabile?")
* item[=].type = #group

// 1. Land - choice (country codes incl. "Unbekannt"), autocomplete, mandatory. Switzerland and
//    Liechtenstein are the first two entries of the value set so they sit at the top of the popup.
* item[=].item[+].linkId = "exposureWhereCountry"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmExposureForm#ChEkmExposureForm.where.country"
* insert RuleSetQrLevel2Text("Country", "Land", "Pays", "Paese")
* item[=].item[=].type = #choice
* item[=].item[=].required = true
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmCountryCodesInclUnknown"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#autocomplete

// 2. Genauer Ort - free text, applies to any country answered above
* item[=].item[+].linkId = "exposureWherePreciseLocation"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmExposureForm#ChEkmExposureForm.where.preciseLocation"
* insert RuleSetQrLevel2Text("Precise location", "Genauer Ort", "Lieu précis", "Luogo preciso")
* item[=].item[=].type = #string

// 3. Unbekannt - the "genauer Ort ist nicht bekannt" answer to item 2 above, rendered as its own
//    check-box row (see the file header). Ticked = the model's `where.unknown` is true; the answer
//    string itself is never written to the Exposure, the template only tests whether it exists and
//    marks `city` as absent.
* item[=].item[+].linkId = "exposureWhereUnknown"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmExposureForm#ChEkmExposureForm.where.unknown"
* item[=].item[=].type = #choice
* item[=].item[=].repeats = true
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#check-box
* insert RuleSetQrLevel2AnswerOptionText("Precise location unknown", "Unbekannt", "Inconnu", "Sconosciuto")
