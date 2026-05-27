Instance: ChEkmQuestionnaireHepatitisCCourseOfDisease
InstanceOf: Questionnaire
Usage: #example
Title: "CH EKM Questionnaire: HepatitisC - Course of Disease"
Description: "Questionnaire for capturing the course of disease for HepatitisC."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireHepatitisCCourseOfDisease"
* status = #active
* experimental = false

* item[+].linkId = "course-of-disease"
* item[=].text = "Verlauf der Erkrankung"
* item[=].type = #choice
* item[=].repeats = true
* item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmInvasivePneumococcalDiseaseCourseOfDisease"
