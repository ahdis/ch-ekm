Profile: ChEkmDocumentHepatitisC
Parent: ChEkmDocument
Id: ch-ekm-document-hepatitisc
Title: "CH EKM-Document: Clinical findings HepatitisC"
Description: "This profile constrains the Bundle resource for the purpose of clinical findings for Hepatitis C."
* entry[Composition].resource only ChEkmCompositionHepatitisC

Profile: ChEkmCompositionHepatitisC
Parent: ChEkmComposition
Id: ch-ekm-composition-hepatitisc
Title: "CH EKM Composition: Clinical Findings HepatitisC"
Description: "This CH EKM base profile constrains the Composition resource for the purpose of clinical findings for Hepatitis C."
* subject only Reference(ChEkmPatient)
* section[diagnosis].entry[condition] only Reference(ChEkmConditionHepatitisC)
* section[diagnosis].entry[questionnaire-response] only Reference(ChEkmQuestionnaireResponseCourseOfDiseaseHepatitisC) 

Profile: ChEkmQuestionnaireResponseCourseOfDiseaseHepatitisC
Parent: QuestionnaireResponse
Id: ch-ekm-questionnaireresponse-hepatitisc-courseofdisease
Title: "CH EKM Questionnaire Response: Course of Disease - HepatitisC"
Description: "This CH EKM base profile constrains the QuestionnaireResponse resource for the purpose of clinical findings for Hepatitis C."
* questionnaire = Canonical(ChEkmQuestionnaireHepatitisCCourseOfDisease)

Profile: ChEkmConditionHepatitisC
Parent: ChEkmCondition
Id: ch-ekm-condition-hepatitisc
Title: "CH EKM Condition: HepatitisC"
Description: "This CH EKM base profile constrains the Condition resource for the purpose of clinical findings for Hepatitis C."
* code = $sct#50711007 "Viral hepatitis type C (disorder)"
* evidence.code from ChEkmHepatitisCManifestation (required)