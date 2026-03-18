Profile: ChEkmPractitionerResponsiblePhysician
Parent: $ch-core-practitioner
Id: ch-ekm-practitioner-responsible-physician
Title: "CH EKM Practitioner: Responsible Physician"
Description: "This CH EKM base profile constrains the Practitioner resource for the responsible physician."
//* obeys ch-ekm-practitioner-zsr-check-length and ch-ekm-practitioner-zsr-check-digit
* . ^short = "CH EKM Practitioner: Responsible Physician"
* identifier ..2 MS
* identifier[GLN] ..1 MS
* identifier[ZSR] 0..1 MS
* name ..1
* name.given ..1 MS
* name.given.extension contains $data-absent-reason named dataabsentreason 0..1
* name.family MS
* name.family.extension contains $data-absent-reason named dataabsentreason 0..0
* telecom[email] MS
* telecom[email].value ^example.label = "CH EKM"
* telecom[email].value ^example.valueString = "info@domain.ch"
* telecom[phone] MS
* telecom[phone].value ^example.label = "CH EKM"
* telecom[phone].value ^example.valueString = "+41 79 999 55 66"
* address ..1 MS
* address.postalCode MS
* address.city MS
