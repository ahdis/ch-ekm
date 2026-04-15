Profile: ChEkmOrganizationBroker
Parent:  $ch-core-organization
Id: ch-ekm-organization-author
Title: "CH EKM Organization: Broker"
Description: "This CH EKM base profile constrains the Organization resource for the broker."
* . ^short = "CH EKM Organization: Broker"
* extension contains ChEkmExtDepartment named department 0..1 MS
* identifier 1..2 MS
* identifier[GLN] 1..1 
* identifier[BER] ..1 MS
* identifier[ZSR] 0..0
* identifier[UIDB] 0..0
* name 1..1
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
* telecom[internet] 0..0


Profile: ChEkmOrganizationTreatingPhysician
Parent: $ch-core-organization
Id: ch-ekm-organization-treating-physician
Title: "CH EKM Organization: Treating Physician"
Description: "This CH EKM base profile constrains the Organization resource for the treating physician."
* . ^short = "CH EKM Organization: Treating Physician"
* extension contains ChEkmExtDepartment named department 0..1 MS
* identifier ..2 MS
* identifier[GLN] ..1 MS
* identifier[BER] ..1 MS
* identifier[ZSR] 0..0
* identifier[UIDB] 0..0
* name 1..1
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
* telecom[internet] 0..0

Profile: ChEkmOrganizationLab
Parent: $ch-core-organization
Id: ch-ekm-organization-lab
Title: "CH EKM Organization: Lab"
Description: "This CH EKM base profile constrains the Organization resource for the reporting laboratory."
* . ^short = "CH EKM Organization: Lab"
* extension contains ChEkmExtDepartment named department 0..1 
* identifier ..2
* identifier[GLN] ..1 
* identifier[BER] ..1 
* identifier[ZSR] 0..0
* identifier[UIDB] 0..0
* name 1..1
* address ..1 
* address.line ..1 
* address.city ..1
* address.postalCode ..1
* telecom[email] ..1 MS
* telecom[email].value ^example.label = "CH EKM"
* telecom[email].value ^example.valueString = "info@domain.ch"
* telecom[phone] ..1  MS
* telecom[phone].value ^example.label = "CH EKM"
* telecom[phone].value ^example.valueString = "+24 74 200 88 77"
* telecom[internet] 0..0