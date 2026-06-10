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
* meta.profile = $sdc-modular
* subjectType = #Patient

// Angaben zur betroffenen Person
* item[+].linkId = "person"
* item[=].type = #display
* item[=].text = "Angaben zur betroffenen Person"
* item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoeaPerson"

// Diagnose und Manifestation
* item[+].linkId = "manifestation"
* item[=].type = #display
* item[=].text = "Diagnose und Manifestation"
* item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoeaManifestation"

// Exposition (Wie / Übertragungsweg)
* item[+].linkId = "exposition"
* item[=].type = #display
* item[=].text = "Exposition (Übertragungsweg)"
* item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoeaExposition"
