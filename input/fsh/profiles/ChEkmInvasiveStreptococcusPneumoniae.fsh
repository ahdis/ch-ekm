Profile: ChEkmDocumentInvasivePneumococcalDisease
Parent: ChEkmDocument
Id: ch-ekm-document-invasivepneumococcaldisease
Title: "CH EKM-Document: Clinical findings InvasivePneumococcalDisease"
Description: "This profile constrains the Bundle resource for the purpose of clinical findings for Hepatitis C."
* entry[Composition].resource only ChEkmCompositionInvasivePneumococcalDisease

Profile: ChEkmCompositionInvasivePneumococcalDisease
Parent: ChEkmComposition
Id: ch-ekm-composition-invasivepneumococcaldisease
Title: "CH EKM Composition: Clinical Findings InvasivePneumococcalDisease"
Description: "This CH EKM base profile constrains the Composition resource for the purpose of clinical findings for Hepatitis C."
* subject only Reference(ChEkmPatientInitials)
* section[diagnosis].entry[condition] only Reference(ChEkmConditionInvasivePneumococcalDisease)

Profile: ChEkmConditionInvasivePneumococcalDisease
Parent: ChEkmCondition
Id: ch-ekm-condition-invasivepneumococcaldisease
Title: "CH EKM Condition: InvasivePneumococcalDisease"
Description: "This CH EKM base profile constrains the Condition resource for the purpose of clinical findings for Hepatitis C."
* code = $sct#406617004 "Invasive Streptococcus pneumoniae disease (disorder)"
* evidence.code from ChEkmInvasivePneumococcalDiseaseManifestation (required)