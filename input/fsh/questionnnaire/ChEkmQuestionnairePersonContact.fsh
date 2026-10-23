// Modular sub-questionnaire: address line, phone and e-mail of the affected person.
// Source of truth: logical model ChEkmPersonForm (-> ChEkmPatient.address[home].line / .telecom).
//
// Part of the harmonised FULL-NAME person block of the FOPH form harmonisation (Strasse/Nr., Tel.,
// E-Mail next to AHV, PLZ/Wohnort, Kanton, Land). It is an OPT-IN companion of
// ChEkmQuestionnairePersonGeneral rather than part of it, because PersonGeneral is shared with the
// initials forms, whose ChEkmPatientInitials forbids `address.line` and `telecom` (privacy). A root
// that asks for the full name inserts it right after RuleSetQrPersonGeneral (Mpox, Hepatitis C);
// SDC $assemble cannot include a child conditionally, so the opt-in is one more insert.
//
// The items are top-level (no wrapping group), so on assembly they merge directly into the
// `person` group, like the other person modules. All three are optional.
//
// SDC pre-population: each item reads the home (or first) address / telecom of %patient.

Instance: ChEkmQuestionnairePersonContact
InstanceOf: Questionnaire
Usage: #definition
Title: "EKM: Person - Address and contact"
Description: "Modular sub-questionnaire for the street address, phone number and e-mail address of the affected person, asked by the forms that report the full name. Reusable as an SDC assemble-child; supports expression-based pre-population from a patient launch context."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnairePersonContact)

// Strasse, Nr.
* item[+].linkId = "streetLine"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmPersonForm#ChEkmPersonForm.streetLine"
* insert RuleSetQrLevel1Text("Address (street\, house number\)", "Adresse (Strasse\, Hausnummer\)", "Adresse (rue\, numéro\)", "Indirizzo (via\, numero civico\)")
* item[=].type = #string
* item[=].extension[+].url = $sdc-initialExpression
* item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].extension[=].valueExpression.expression = "%homeOrFirstAddress.line.first()"

// Telefon
* item[+].linkId = "phone"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmPersonForm#ChEkmPersonForm.phone"
* insert RuleSetQrLevel1Text("Phone", "Telefon", "Téléphone", "Telefono")
* item[=].type = #string
* item[=].extension[+].url = $sdc-initialExpression
* item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].extension[=].valueExpression.expression = "%patient.telecom.where(system='phone').value.first()"

// E-Mail
* item[+].linkId = "email"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmPersonForm#ChEkmPersonForm.email"
* insert RuleSetQrLevel1Text("E-mail", "E-Mail", "E-mail", "E-mail")
* item[=].type = #string
* item[=].extension[+].url = $sdc-initialExpression
* item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].extension[=].valueExpression.expression = "%patient.telecom.where(system='email').value.first()"
