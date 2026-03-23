Profile: ChEkmServiceRequest
Parent: CHCoreServiceRequest
Id: ch-ekm-servicerequest
Title: "CH EKM ServiceRequest: Laboratory Information"
Description: "This CH EKM base profile constrains the ServiceRequest resource for the purpose of clinical finding reports associated to a infectious disease."
* . ^short = "CH EKM ServiceRequest: Laboratory Order"
* status = #completed
* intent = #order

* subject only Reference(ChEkmPatient)

* specimen ..1 MS
* specimen only Reference(ChEkmSpecimen)

* performer ..1 MS
* performer only Reference(ChEkmOrganizationLab)

* reasonCode ..1
* reasonCode.coding ..1
* reasonCode.coding from ChEkmServiceRequestReason