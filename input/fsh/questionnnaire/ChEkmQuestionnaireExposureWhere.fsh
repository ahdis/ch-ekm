// Modular sub-questionnaire: "Wo" — most probable place of infection.
// Source of truth: logical model ChEkmExposureForm.where (-> ChEkmExposure.extension[exposureAddress])
// Form items per https://github.com/ahdis/ch-ekm/issues/26:
//   1. Land (dropdown, mandatory)   -> valueAddress.country (+ country coding), or, answered
//                                      "Unbekannt", valueAddress._country.extension[data-absent-reason]
//   2. Genauer Ort (dropdown+text)  -> valueAddress.city, or, answered "Unbekannt",
//                                      valueAddress._city.extension[data-absent-reason]
//
// TWO questions, each with its OWN "unbekannt" answer, each becoming a data-absent-reason on its own
// Address element - so "Land Schweiz, genauer Ort unbekannt" and "Land unbekannt, genauer Ort Zürich"
// are both reportable as such.
//
// There is exactly ONE country question. The paper form's "CH/LI check-box next to an Ausland
// dropdown" layout is NOT reproduced: the place of infection is a single country, never a
// combination of two, and it is always reported as a country CODE. Switzerland and Liechtenstein
// are simply the first two entries of the answer value set (ChEkmCountryCodesInclUnknown), so the
// inland case is answered in the same field as any other country - which also removes the former
// form-only item `exposureWhereChLi` and its enableWhen gate on the dropdown.
//
// The country value set additionally offers sct#261665006 "Unknown" as a last resort: the country is
// a MANDATORY field, so "unbekannt" must be selectable rather than left blank. That option is a
// SNOMED CT concept, not an ISO 3166 country, so the extraction template does NOT write it to
// `country`; it marks the country itself as absent (see RuleSetExposureWhere).
//
// (2) is likewise ONE widget rather than a text field plus a separate "Unbekannt" check-box: an
// `open-choice` item is a dropdown that also accepts free text. In Smart Forms every open-choice
// item control other than autocomplete / check-box / radio-button renders as `Select`, which is a
// freeSolo MUI Autocomplete: typing commits the text on blur, picking commits the option
// (getOpenChoiceControlType + OpenChoiceSelectAnswerValueSetField in smart-forms-renderer).
//
// This is why the "unbekannt" answer MUST be a Coding and not a plain string: free text arrives as
// `answer.valueString`, so a string option would be indistinguishable from someone typing the word
// "Unbekannt". Coming from ChEkmUnknown it arrives as `answer.valueCoding` instead, and the
// extraction template simply splits on the answer type. The de/fr/it labels come from the SNOMED CT
// supplement in CodeSystemSupplements.fsh, so no answerOption translations are needed here.

Instance: ChEkmQuestionnaireExposureWhere
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Exposure - Where (place of infection)"
Description: "Modular sub-questionnaire for the 'Wo' (where) group of the Exposure section: the most probable place of infection - the country (Switzerland/Liechtenstein first, 'unknown' as a last resort) and the precise location, which may likewise be reported as unknown. Reusable as an SDC assemble-child."
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

// 2. Genauer Ort - one open-choice widget (see the file header): type the location, or pick the
//    single offered option "Unbekannt". No itemControl, so Smart Forms renders the `Select` variant
//    (a dropdown you can type into); the two answer types are what the extraction template reads.
* item[=].item[+].linkId = "exposureWherePreciseLocation"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmExposureForm#ChEkmExposureForm.where.preciseLocation"
* insert RuleSetQrLevel2Text("Precise location", "Genauer Ort", "Lieu précis", "Luogo preciso")
* item[=].item[=].required = true
* item[=].item[=].type = #open-choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmUnknown"
