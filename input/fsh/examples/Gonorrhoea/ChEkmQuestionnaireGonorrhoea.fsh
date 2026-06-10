// Modular ROOT questionnaire for the Gonorrhoea clinical findings report (green form sections).
// Assembles the Person, Manifestation and Exposition sub-questionnaires via the SDC $assemble operation.
// Render the assembled output in Smart Forms (../smart-forms).

Instance: ChEkmQuestionnaireGonorrhoea
InstanceOf: Questionnaire
Usage: #example
Title: "CH EKM Questionnaire: Gonorrhoea (modular)"
Description: "Modular root questionnaire for the Gonorrhoea clinical findings report. References the Person, Manifestation and Exposition sub-questionnaires; run Questionnaire/$assemble to produce the renderable form."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoea"
* version = "0.0.1"
* name = "ChEkmQuestionnaireGonorrhoea"
* status = #active
* experimental = false
* meta.profile[+] = $sdc-modular
* meta.profile[+] = $sdc-pop-exp
* subjectType = #Patient

// Required by sdc-questionnaire-modular 4.0.0: the root must declare assemble-root.
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-root
// Required by sdc-2 (sdc-questionnairecommon): version present implies versionAlgorithm.
* extension[+].url = $artifact-versionAlgorithm
* extension[=].valueCoding = $version-algorithm#semver

// SDC pre-population: declare the patient launch context. The %patient resource is
// resolved by the host (e.g. SMART launch) and consumed by the initialExpression
// extensions on the sub-questionnaire items. Propagated onto the assembled questionnaire.
* extension[+].url = $sdc-launchContext
* extension[=].extension[+].url = "name"
* extension[=].extension[=].valueCoding = $sdc-launchContext-cs#patient "Patient"
* extension[=].extension[+].url = "type"
* extension[=].extension[=].valueCode = #Patient
* extension[=].extension[+].url = "description"
* extension[=].extension[=].valueString = "The patient to pre-populate the form with"

// Top-level form group. The SDC subQuestionnaire placeholders are nested one level
// under this group (item[0].item[x]) — required by the CSIRO/aehrc sdc-assemble
// reference implementation, and also accepted by matchbox.
* item[+].linkId = "gonorrhoea-form"
* item[=].type = #group
* item[=].text = "Meldung zum klinischen Befund: Gonorrhoea"

// Angaben zur betroffenen Person
* item[=].item[+].linkId = "person"
* item[=].item[=].type = #display
* item[=].item[=].text = "Angaben zur betroffenen Person"
* item[=].item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoeaPerson"

// Diagnose und Manifestation
* item[=].item[+].linkId = "manifestation"
* item[=].item[=].type = #display
* item[=].item[=].text = "Diagnose und Manifestation"
* item[=].item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoeaManifestation"

// Exposition (Wie / Übertragungsweg)
* item[=].item[+].linkId = "exposition"
* item[=].item[=].type = #display
* item[=].item[=].text = "Exposition (Übertragungsweg)"
* item[=].item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoeaExposition"
