Profile: ChEkmOrganizationAuthor
Parent:  CHCoreOrganization
Id: ch-ekm-organization-author
Title: "CH EKM Organization: Author"
Description: "This CH EKM base profile constrains the Organization resource for the author of the report."
* . ^short = "CH EKM Organization: Author"
* identifier ..1
* identifier[GLN] 1..
* identifier[ZSR] 0..0
* identifier[UIDB] 0..0
* identifier[BER] 0..0

Profile: ChEkmOrganizationResponsiblePhysician
Parent: CHCoreOrganization
Id: ch-ekm-organization-responsible-physician
Title: "CH EKM Organization: Responsible Physician"
Description: "This CH EKM base profile constrains the Organization resource for the responsible physician."
* . ^short = "CH EKM Organization: Responsible Physician"
//* extension contains ChElmExtDepartment named department 0..1 MS
* identifier MS
* identifier[UIDB] 0..1 MS
* identifier[BER] 0..1 MS
* name MS
* name ^maxLength = 100
* address ..1 MS
* address.line ..1 MS
* address.line.extension[streetName] MS
* address.line.extension[houseNumber] MS
* address.line.extension[postOfficeBoxNumber] MS
* address.postalCode MS
* address.city MS

Profile: ChEkmOrganizationLab
Parent: CHCoreOrganization
Id: ch-ekm-organization-lab
Title: "CH EKM Organization: Lab"
Description: "This CH EKM base profile constrains the Organization resource for the reporting laboratory."
* . ^short = "CH EKM Organization: Lab"
* name 1..
* telecom ..1
* telecom[phone] ..1 


