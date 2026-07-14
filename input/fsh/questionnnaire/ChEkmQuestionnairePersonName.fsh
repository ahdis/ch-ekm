// Modular sub-questionnaire: "Namensinitialen" (name initials of the affected person).
// Split out of the former ChEkmQuestionnaireGonorrhoeaPerson so the initials, the general
// person data and the gender identity can be assembled independently.
// Source of truth: logical model ChEkmPersonForm (-> ChEkmPatientName).
//
// The items are top-level (no wrapping group), so on assembly they merge directly into the
// referencing root's group without an extra nesting level.
//
// SDC pre-population: each item carries an initialExpression that reads from %patient
// (the launch context declared on the modular root ChEkmQuestionnaireGonorrhoea). The host
// resolves %patient (e.g. SMART launch / $populate) before rendering.

Instance: ChEkmQuestionnairePersonName
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Namensinitialen der betroffenen Person"
Description: "Modular sub-questionnaire for the name initials (surname / given name) of the affected person. Reusable as an SDC assemble-child; supports expression-based pre-population from a patient launch context."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnairePersonName"
* version = "0.0.1"
* name = "ChEkmQuestionnairePersonName"
* status = #active
* language = #en
* experimental = false
* subjectType = #Patient
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-child

// Name (surname ) - required
* item[+].linkId = "surname"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmPersonForm#ChEkmPersonForm.surname"
* item[=].text = "Surname initial"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Name"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Nom"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Cognome"
* item[=].type = #string
* item[=].required = true

// given name initial) - require
* item[+].linkId = "givenname"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmPersonForm#ChEkmPersonForm.givenname"
* item[=].text = "First name initial"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Vorname"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Prénom"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Nome"
* item[=].type = #string
* item[=].required = true
