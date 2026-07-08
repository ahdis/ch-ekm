// Modular sub-questionnaire: "Namensinitialen" (name initials of the affected person).
// Split out of the former ChEkmQuestionnaireGonorrhoeaPerson so the initials, the general
// person data and the gender identity can be assembled independently.
// Source of truth: logical model ChEkmGonorrhoeaPersonForm (-> ChEkmPatientInitials).
//
// The items are top-level (no wrapping group), so on assembly they merge directly into the
// referencing root's group without an extra nesting level.
//
// SDC pre-population: each item carries an initialExpression that reads from %patient
// (the launch context declared on the modular root ChEkmQuestionnaireGonorrhoea). The host
// resolves %patient (e.g. SMART launch / $populate) before rendering.

Instance: ChEkmQuestionnairePersonInitials
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Namensinitialen der betroffenen Person"
Description: "Modular sub-questionnaire for the name initials (surname / given name) of the affected person. Reusable as an SDC assemble-child; supports expression-based pre-population from a patient launch context."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnairePersonInitials"
* version = "0.0.1"
* name = "ChEkmQuestionnairePersonInitials"
* status = #active
* experimental = false
* subjectType = #Patient
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-child

// Initiale Name (surname initial) - required; first letter of the family name
* item[+].linkId = "surnameInitial"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.surnameInitial"
* item[=].text = "Initiale Name"
* item[=].type = #string
* item[=].required = true
// Initials are a single letter. maxLength is a NATIVE Questionnaire.item element (not an
// extension) — Smart Forms enforces qItem.maxLength, so it must be set natively here.
* item[=].maxLength = 1
* item[=].extension[+].url = $sdc-initialExpression
* item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].extension[=].valueExpression.expression = "%patient.name.first().family.substring(0,1)"

// Initiale Vorname (given name initial) - required; first letter of the given name
* item[+].linkId = "givennameInitial"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.givennameInitial"
* item[=].text = "Initiale Vorname"
* item[=].type = #string
* item[=].required = true
* item[=].maxLength = 1
* item[=].extension[+].url = $sdc-initialExpression
* item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].extension[=].valueExpression.expression = "%patient.name.first().given.first().substring(0,1)"
