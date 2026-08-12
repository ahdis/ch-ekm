Instance: ChEkmQuestionnaireMpox
InstanceOf: Questionnaire
Usage: #example
Title: "CH EKM Questionnaire: Mpox (modular)"
Description: "Modular root questionnaire for the Mpox clinical findings report. Use Questionnaire/$assemble to produce the renderable form."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireMpox"

* insert RuleSetQrHeader("mpox-form", "Clinical findings report: mpox", "Meldung zum klinischen Befund: Mpox", "Déclaration de résultat clinique : Mpox", "Notifica del referto clinico: Mpox", ChEkmDocumentMpoxTemplate)
// Render the sections below (person / diagnosis / exposure / physician) as tabs on the left
* insert RuleSetQrLevel1TabContainer

* insert RuleSetQrGroupPerson
* insert RuleSetQrPersonName
* insert RuleSetQrPersonGeneral
* insert RuleSetQrPersonGenderIdentity

* insert RuleSetQrGroupManifestation
// Manifestationen - multiple-choice, radio buttons
* insert RuleSetQrLevel3Item("manifestation", "Manifestations", "Manifestationen", "Manifestations", "Manifestazioni")
// TODO? * item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmMpoxManifestationForm#ChEkmMpoxManifestationForm.manifestation"
* item[=].item[=].item[=].type = #choice
* item[=].item[=].item[=].repeats = true
* item[=].item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].item[=].extension[=].valueCode = #vertical
* item[=].item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmMpoxManifestation"
* item[=].item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].item[=].answerValueSet.extension[=].extension[=].valueCode = #useSupplement
* item[=].item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-snomed-language-supplement"
* item[=].item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].item[=].extension[=].valueCodeableConcept = $item-control#check-box
* insert RuleSetQrManifestationBeginUnknown

* insert RuleSetQrGroupExposure

// Wo before Wann and Wie, as on the paper form (https://github.com/ahdis/ch-ekm/issues/26)
* insert RuleSetQrExposureWhere

* insert RuleSetQrExposureWhen

* insert RuleSetQrExposureHow

* insert RuleSetQrGroupTreatingPhysician
