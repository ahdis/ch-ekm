Profile: ChEkmSpecimen
Parent: Specimen
Id: ch-ekm-specimen
Title: "CH EKM Specimen: Laboratory"
Description: "This CH EKM base profile constrains the Specimen resource for the purpose of clinical finding reports associated to a infectious disease."
* . ^short = "CH Lab Specimen: Laboratory"

* type.coding ..1
* type.coding from ChElmResultsCompleteSpec (required)

* subject 1..
* subject only Reference(ChEkmPatient)

* collection MS
* collection.collectedDateTime obeys ch-ekm-dateTime
* collection.collectedDateTime MS

