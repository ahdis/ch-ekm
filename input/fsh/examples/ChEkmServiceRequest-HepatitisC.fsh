Instance: ChEkmServiceRequestExample-HepatitisC
InstanceOf: ChEkmServiceRequest
Usage: #example
* intent = #order
* status = #completed
* reasonCode =  $sct#171112000 "Screening due (finding)" 
* reasonCode.text = "Screening due (finding)" 
* subject = Reference(ChEkmPatientExample)
* specimen = Reference(ChEkmSpecimenExample-HepatitisC)
* performer = Reference(ChEkmOrganizationLabExample)