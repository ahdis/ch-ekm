Profile: ChEkmCondition
Parent: CHCoreCondition
Id: ch-ekm-condition
Title: "CH Ekm Condition"
Description: "This CH EKM base profile constrains the Condition resource to represent the diagnosis and manifestations"
* code MS
* onset[x] only dateTime
* onsetDateTime MS
* onsetDateTime ^short = "Manifestation beginning date, use data-absent-reason #unknown if the date is explicitly not known"
* onsetDateTime.extension contains $data-absent-reason named dataabsentreason 0..1 
* evidence MS 
* evidence ^short = "Manifestation"