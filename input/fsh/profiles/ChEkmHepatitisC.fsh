Profile: ChEkmDocumentHepatitisC
Parent: ChEkmDocument
Id: ch-ekm-document-hepatitisc
Title: "CH EKM-Document: Clinical findings HepatitisC"
Description: "This profile constrains the Bundle resource for the purpose of clinical findings for Hepatitis C."
* entry[Composition].resource only ChEkmCompositionHepatitisC

Profile: ChEkmCompositionHepatitisC
Parent: ChEkmComposition
Id: ch-ekm-composition-heptatitisc
Title: "CH EKM Composition: Clinical Findings HepatitisC"
Description: "This CH EKM base profile constrains the Composition resource for the purpose of clinical findings for Hepatitis C."
* section[diagnosis].entry only Reference(ChEkmConditionHepatitisC)


Profile: ChEkmConditionHepatitisC
Parent: ChEkmCondition
Id: ch-ekm-condition-heptatitisc
Title: "CH EKM Condition: HepatitisC"
Description: "This CH EKM base profile constrains the Condition resource for the purpose of clinical findings for Hepatitis C."
* code = $sct#50711007 "Viral hepatitis type C (disorder)"