// Modular sub-questionnaire: "Name der betroffenen Person" (name of the affected person).
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
Title: "CH EKM Questionnaire: Name der betroffenen Person"
Description: "Modular sub-questionnaire for the name (surname / given name) of the affected person. Reusable as an SDC assemble-child; supports expression-based pre-population from a patient launch context."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnairePersonName)

// Name (surname ) - required
* item[+].linkId = "surname"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmPersonForm#ChEkmPersonForm.surname"
* insert RuleSetQrLevel1Text("Surname", "Name", "Nom", "Cognome")
* item[=].type = #string
* item[=].required = true
* item[=].extension[+].url = $sdc-initialExpression
* item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].extension[=].valueExpression.expression = "%patient.name.first().family"


// given name - require
* item[+].linkId = "givenname"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmPersonForm#ChEkmPersonForm.givenname"
* insert RuleSetQrLevel1Text("First name", "Vorname", "Prénom", "Nome")
* item[=].type = #string
* item[=].required = true
* item[=].extension[+].url = $sdc-initialExpression
* item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].extension[=].valueExpression.expression = "%patient.name.first().given.join(' ')"
