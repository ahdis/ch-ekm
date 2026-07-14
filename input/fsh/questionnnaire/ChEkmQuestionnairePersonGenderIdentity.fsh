// Modular sub-questionnaire: "Geschlechtsidentität" (gender identity of the affected person).
// Split out of the former ChEkmQuestionnaireGonorrhoeaPerson so the gender identity can be
// assembled (or omitted) independently of the general person data.
// Source of truth: logical model ChEkmPersonForm (-> ChEkmPatientInitials).
//
// SDC pre-population: the item carries an initialExpression that reads from %patient
// (the launch context declared on the modular root ChEkmQuestionnaireGonorrhoea). The host
// resolves %patient (e.g. SMART launch / $populate) before rendering.

Instance: ChEkmQuestionnairePersonGenderIdentity
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Geschlechtsidentität der betroffenen Person"
Description: "Modular sub-questionnaire for the gender identity of the affected person. Reusable as an SDC assemble-child; supports expression-based pre-population from a patient launch context."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnairePersonGenderIdentity"
* version = "0.0.1"
* name = "ChEkmQuestionnairePersonGenderIdentity"
* status = #active
* language = #en
* experimental = false
* subjectType = #Patient
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-child

// Gender identity (transgender) - separate item per model, top-level (no wrapping group).
// Pre-populated from the individual-genderIdentity extension's `value` Coding
// (http://hl7.org/fhir/StructureDefinition/individual-genderIdentity -> extension.where(url='value')).
// Source and form share the ChEkmGenderIdentity value set (SNOMED), so the Coding matches directly.
* item[+].linkId = "genderIdentity"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmPersonForm#ChEkmPersonForm.genderIdentity"
* item[=].text = "Gender identity (transgender)"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Geschlechtsidentität (transgender)"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Identité de genre (transgenre)"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Identità di genere (transgender)"
* item[=].type = #choice
* item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmGenderIdentity"
* item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].answerValueSet.extension[=].extension[=].valueCode = #useSupplement
* item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-snomed-language-supplement"
* item[=].extension[+].url = $sdc-initialExpression
* item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].extension[=].valueExpression.expression = "%patient.extension.where(url = 'http://hl7.org/fhir/StructureDefinition/individual-genderIdentity').extension.where(url = 'value').valueCodeableConcept.coding.first()"
