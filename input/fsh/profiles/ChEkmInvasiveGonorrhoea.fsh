Profile: ChEkmDocumentGonorrhoea
Parent: ChEkmDocument
Id: ch-ekm-document-gonorrhoea
Title: "CH EKM-Document: Clinical findings Gonorrhoea"
Description: "This profile constrains the Bundle resource for the purpose of clinical findings for Gonorrhoea"
* entry[Composition].resource only ChEkmCompositionGonorrhoea

Profile: ChEkmCompositionGonorrhoea
Parent: ChEkmComposition
Id: ch-ekm-composition-gonorrhoea
Title: "CH EKM Composition: Clinical Findings Gonorrhoea"
Description: "This CH EKM base profile constrains the Composition resource for the purpose of clinical findings for Gonorrhoea"
* subject only Reference(ChEkmPatientInitials)
* section[diagnosis].entry[condition] only Reference(ChEkmConditionGonorrhoea)

Profile: ChEkmConditionGonorrhoea
Parent: ChEkmCondition
Id: ch-ekm-condition-gonorrhoea
Title: "CH EKM Condition: Gonorrhoea"
Description: "This CH EKM base profile constrains the Condition resource for the purpose of clinical findings for Gonorrhoea"
* code = $sct#15628003 "Gonorrhea (disorder)"
* evidence.code from ChEkmGonorrhoeaManifestation (required)