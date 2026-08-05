// Modular ROOT questionnaire for the Gonorrhoea clinical findings report 

Instance: ChEkmQuestionnaireGonorrhoea
InstanceOf: Questionnaire
Usage: #example
Title: "CH EKM Questionnaire: Gonorrhoea (modular)"
Description: "Modular root questionnaire for the Gonorrhoea clinical findings report. Use Questionnaire/$assemble to produce the renderable form."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoea"

* insert RuleSetQrHeader("gonorrhoea-form", "Clinical findings report: gonorrhoea", "Meldung zum klinischen Befund: Gonorrhoea", "Déclaration de résultat clinique : Gonorrhoea", "Notifica del referto clinico: Gonorrhoea", ChEkmDocumentGonorrhoeaTemplate)

* insert RuleSetQrGroupPerson
* insert RuleSetQrPersonInitials
* insert RuleSetQrPersonGeneral
* insert RuleSetQrPersonGenderIdentity

* insert RuleSetQrGroupManifestation

// Manifestationen - single-choice (symptomatic / asymptomatic), radio buttons
* insert RuleSetQrLevel3Item("manifestation", "Manifestations", "Manifestationen", "Manifestations", "Manifestazioni")
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaManifestationForm#ChEkmGonorrhoeaManifestationForm.manifestation"
* item[=].item[=].item[=].type = #choice
* item[=].item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].item[=].extension[=].valueCode = #horizontal
* item[=].item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmGonorrhoeaManifestationFormChoice"
* item[=].item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].item[=].answerValueSet.extension[=].extension[=].valueCode = #useSupplement
* item[=].item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-snomed-language-supplement"
* item[=].item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].item[=].extension[=].valueCodeableConcept = $item-control#radio-button

* insert RuleSetQrManifestationBeginUnknown

* insert RuleSetQrGroupExposure
* insert RuleSetQrExposureHow

* insert RuleSetQrGroupTreatingPhysician

