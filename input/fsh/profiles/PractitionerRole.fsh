Profile: ChEkmPractitionerRoleTreatingPhysician
Parent: $ch-core-practitioner-role
Id: ch-ekm-practitionerrole-Treating-physician
Title: "CH EKM PractitionerRole: Treating Physician"
Description:    "This CH EKM base profile constrains the Organization resource for the Treating physician and organization of the Treating clinician."
* . ^short = "CH EKM PractitionerRole: Treating Physician."
* practitioner MS
* practitioner only Reference(ChEkmPractitionerTreatingPhysician)
* organization MS
* organization only Reference(ChEkmOrganizationTreatingPhysician)