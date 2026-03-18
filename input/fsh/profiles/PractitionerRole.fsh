Profile: ChEkmPractitionerRoleResponsiblePhysician
Parent: $ch-core-practitioner-role
Id: ch-ekm-practitionerrole-responsible-physician
Title: "CH EKM PractitionerRole: Responsible Physician"
Description:    "This CH EKM base profile constrains the Organization resource for the responsible physician and organization of the responsible clinician."
* . ^short = "CH EKM PractitionerRole: Responsible Physician."
* practitioner MS
* practitioner only Reference(ChEkmPractitionerResponsiblePhysician)
* organization MS
* organization only Reference(ChEkmOrganizationResponsiblePhysician)