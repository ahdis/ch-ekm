Profile: ChEkmPractitionerTreatingPhysician
Parent: $ch-core-practitioner
Id: ch-ekm-practitioner-treating-physician
Title: "CH EKM Practitioner: Treating Physician"
Description: "This CH EKM base profile constrains the Practitioner resource for the treating physician."
* . ^short = "CH EKM Practitioner: Treating Physician"
* identifier ..1 
* identifier[GLN] ..1 MS
* name 1..1
* name.given 1..1 
* name.family ..1 
* address 1..1
* address.line ..1 MS
* address.city 1..1
* address.postalCode 1..1
* telecom[email] ..1 MS
* telecom[email].value ^example.label = "CH EKM"
* telecom[email].value ^example.valueString = "info@domain.ch"
* telecom[phone] 1..1
* telecom[phone].value ^example.label = "CH EKM"
* telecom[phone].value ^example.valueString = "+24 74 200 88 77"
