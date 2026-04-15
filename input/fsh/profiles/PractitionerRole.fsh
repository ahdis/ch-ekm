Profile: ChEkmPractitionerRole
Parent: $ch-core-practitioner-role
Id: ch-ekm-practitionerrole
Title: "CH EKM PractitionerRole: Treating Physician or Broker"
Description: "This CH EKM base profile constrains the PractitionerRole resource for the treating physician or broker."
* . ^short = "CH EKM PractitionerRole: Treating Physician or Broker"
* practitioner MS
* practitioner only Reference(ChEkmPractitionerTreatingPhysician or ChEkmPractitionerBroker)
* organization MS
* organization only Reference(ChEkmOrganizationTreatingPhysician or ChEkmOrganizationBroker)