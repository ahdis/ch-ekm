Profile: ChEkmDocumentInvasiveStreptococcusPneumoniae
Parent: ChEkmDocument
Id: ch-ekm-document-invasivestreptococcuspneumoniae
Title: "CH EKM-Document: Clinical findings InvasiveStreptococcusPneumoniae"
Description: "This profile constrains the Bundle resource for the purpose of clinical findings for Hepatitis C."
* entry[Composition].resource only ChEkmCompositionInvasiveStreptococcusPneumoniae

Profile: ChEkmCompositionInvasiveStreptococcusPneumoniae
Parent: ChEkmComposition
Id: ch-ekm-composition-invasivestreptococcuspneumoniae
Title: "CH EKM Composition: Clinical Findings InvasiveStreptococcusPneumoniae"
Description: "This CH EKM base profile constrains the Composition resource for the purpose of clinical findings for Hepatitis C."
* subject only Reference(ChEkmPatientInitials)

Profile: ChEkmConditionInvasiveStreptococcusPneumoniae
Parent: ChEkmCondition
Id: ch-ekm-condition-invasivestreptococcuspneumoniae
Title: "CH EKM Condition: InvasiveStreptococcusPneumoniae"
Description: "This CH EKM base profile constrains the Condition resource for the purpose of clinical findings for Hepatitis C."
* code = $sct#406617004 "Invasive Streptococcus pneumoniae disease (disorder)"
* evidence.code from ChEkmInvasiveStreptococcusPneumoniaeManifestation (required)