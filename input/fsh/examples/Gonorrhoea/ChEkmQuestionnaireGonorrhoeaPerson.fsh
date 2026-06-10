// Modular sub-questionnaire: "Angaben zur betroffenen Person" (Gonorrhoea green section)
// Source of truth: logical model ChEkmGonorrhoeaPersonForm (-> ChEkmPatientInitials)
// Decisions (2026-06-09): pregnancy omitted; gender = administrativeGender + genderIdentity (model).

Instance: ChEkmQuestionnaireGonorrhoeaPerson
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Gonorrhoea - Angaben zur betroffenen Person"
Description: "Modular sub-questionnaire for the 'Angaben zur betroffenen Person' section of the Gonorrhoea clinical findings report. Reusable as an SDC assemble-child."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoeaPerson"
* version = "0.0.1"
* name = "ChEkmQuestionnaireGonorrhoeaPerson"
* status = #active
* experimental = false
* subjectType = #Patient
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-child

* item[+].linkId = "person"
* item[=].text = "Angaben zur betroffenen Person"
* item[=].type = #group

// Initiale Name (surname initial) - required
* item[=].item[+].linkId = "surnameInitial"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.surnameInitial"
* item[=].item[=].text = "Initiale Name"
* item[=].item[=].type = #string
* item[=].item[=].required = true

// Initiale Vorname (given name initial) - required
* item[=].item[+].linkId = "givennameInitial"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.givennameInitial"
* item[=].item[=].text = "Initiale Vorname"
* item[=].item[=].type = #string
* item[=].item[=].required = true

// Geburtsdatum - required
* item[=].item[+].linkId = "dateOfBirth"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.dateOfBirth"
* item[=].item[=].text = "Geburtsdatum"
* item[=].item[=].type = #date
* item[=].item[=].required = true

// Nationalität - choice (BFS country codes), autocomplete
* item[=].item[+].linkId = "nationality"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.nationality"
* item[=].item[=].text = "Nationalität"
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-term/ValueSet/bfs-country-codes"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#autocomplete

// PLZ
* item[=].item[+].linkId = "zipCode"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.zipCode"
* item[=].item[=].text = "PLZ"
* item[=].item[=].type = #string

// Wohnort
* item[=].item[+].linkId = "city"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.city"
* item[=].item[=].text = "Wohnort"
* item[=].item[=].type = #string

// Land - choice (BFS country codes), autocomplete
* item[=].item[+].linkId = "country"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.country"
* item[=].item[=].text = "Land"
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-term/ValueSet/bfs-country-codes"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#autocomplete

// Kanton - plain string for now (eCH-0007 choice to be decided)
* item[=].item[+].linkId = "canton"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.canton"
* item[=].item[=].text = "Kanton"
* item[=].item[=].type = #string

// Gender - administrative gender (male/female/other), radio buttons - required
* item[=].item[+].linkId = "administrativeGender"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.administrativeGender"
* item[=].item[=].text = "Gender"
* item[=].item[=].type = #choice
* item[=].item[=].required = true
* item[=].item[=].answerValueSet = "http://hl7.org/fhir/ValueSet/administrative-gender"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#radio-button

// Gender identity (transgender) - separate item per model
* item[=].item[+].linkId = "genderIdentity"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.genderIdentity"
* item[=].item[=].text = "Geschlechtsidentität (transgender)"
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmGenderIdentity"
