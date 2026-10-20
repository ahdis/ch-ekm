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
Title: "EKM: Person - Gender identity"
Description: "Modular sub-questionnaire for the gender identity of the affected person. Reusable as an SDC assemble-child; supports expression-based pre-population from a patient launch context."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnairePersonGenderIdentity)

// "trans Person" (issue #32): trans man / trans woman - separate item per model, top-level (no
// wrapping group). The form's third answer "Nein" is NOT offered yet (issue #35): "No" is not a
// gender identity, so it has no place in individual-genderIdentity. Until then the item stays
// optional, and leaving it unanswered is the only way to say "not trans".
// Pre-populated from the individual-genderIdentity extension's `value` Coding
// (http://hl7.org/fhir/StructureDefinition/individual-genderIdentity -> extension.where(url='value')).
// Source and form share the ChEkmGenderIdentity value set (SNOMED), so the Coding matches directly.
* item[+].linkId = "genderIdentity"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmPersonForm#ChEkmPersonForm.genderIdentity"
* insert RuleSetQrLevel1Text("trans person", "trans Person", "Personne trans", "Persona trans")
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
