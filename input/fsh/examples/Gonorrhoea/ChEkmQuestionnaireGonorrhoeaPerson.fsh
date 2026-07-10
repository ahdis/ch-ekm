// Standalone modular questionnaire: "Angaben zur betroffenen Person" (Gonorrhoea green section).
// This is ONE group with the three person sub-questionnaires included as subQuestionnaire children:
//   - ChEkmQuestionnairePersonInitials       (Namensinitialen)
//   - ChEkmQuestionnairePersonGeneral        (allgemeine Angaben)
//   - ChEkmQuestionnairePersonGenderIdentity (Geschlechtsidentität)
//
// It is used BOTH ways: assembled standalone (its `person` group is item[0], the three
// placeholders are item[0].item[x]) AND as a nested child of the disease root
// ChEkmQuestionnaireGonorrhoea (root → this aggregator → the three leaves). The root recurses
// into it, producing one flat `person` group of all fields. Run standalone with:
//   ./tests/assemble-questionnaire.sh ChEkmQuestionnaireGonorrhoeaPerson
//
// NB: nested/recursive assembly relies on a one-line fix to @aehrc/sdc-assemble (its recursion
// result was discarded upstream) — applied via patch-package in tests/assemble/ (see the patch
// and forms-summary §1/§2). With the stock library, a nested modular child is NOT flattened.

Instance: ChEkmQuestionnaireGonorrhoeaPerson
InstanceOf: Questionnaire
Usage: #example
Title: "CH EKM Questionnaire: Gonorrhoea - Angaben zur betroffenen Person (modular)"
Description: "Standalone modular questionnaire for the 'Angaben zur betroffenen Person' section: one group that includes the name initials, general person data and gender identity sub-questionnaires. Run Questionnaire/$assemble to produce the renderable Person form."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoeaPerson"
* version = "0.0.1"
* name = "ChEkmQuestionnaireGonorrhoeaPerson"
* status = #active
* language = #en
* experimental = false
* meta.profile[+] = $sdc-modular
* meta.profile[+] = $sdc-pop-exp
* subjectType = #Patient

// assemble-root-or-child: this questionnaire is assembled BOTH as a standalone modular root
// AND as a nested child of the disease root ChEkmQuestionnaireGonorrhoea.
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-root-or-child
// Required by sdc-2: version present implies versionAlgorithm.
* extension[+].url = $artifact-versionAlgorithm
* extension[=].valueCoding = $version-algorithm#semver

// SDC pre-population: patient launch context, consumed by the initialExpression extensions on
// the child items (%patient). Propagated onto the assembled questionnaire.
* extension[+].url = $sdc-launchContext
* extension[=].extension[+].url = "name"
* extension[=].extension[=].valueCoding = $sdc-launchContext-cs#patient "Patient"
* extension[=].extension[+].url = "type"
* extension[=].extension[=].valueCode = #Patient
* extension[=].extension[+].url = "description"
* extension[=].extension[=].valueString = "The patient to pre-populate the form with"

// Top-level `person` group — the SDC subQuestionnaire placeholders are its direct children
// (item[0].item[x]), as required by the reference assembler.
* item[+].linkId = "person"
* item[=].type = #group
* item[=].text = "Affected person's details"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Angaben zur betroffenen Person"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Données relatives à la personne concernée"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Dati relativi alla persona interessata"

// Namensinitialen
* item[=].item[+].linkId = "personInitials"
* item[=].item[=].type = #display
* item[=].item[=].text = "Name initials"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Namensinitialen"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Initiales du nom"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Iniziali del nome"
* item[=].item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnairePersonInitials"

// Allgemeine Angaben
* item[=].item[+].linkId = "personGeneral"
* item[=].item[=].type = #display
* item[=].item[=].text = "General information"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Allgemeine Angaben"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Informations générales"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Informazioni generali"
* item[=].item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnairePersonGeneral"

// Geschlechtsidentität
* item[=].item[+].linkId = "personGenderIdentity"
* item[=].item[=].type = #display
* item[=].item[=].text = "Gender identity"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Geschlechtsidentität"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Identité de genre"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Identità di genere"
* item[=].item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnairePersonGenderIdentity"
