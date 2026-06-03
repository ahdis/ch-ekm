Logical: ChEkmTreatingPhysicianPractitionerForm
Parent: Base
Title: "CH EKM Form: Treating Physician - Practitioner"
Description: "Logical model for the form section 'Treating Physician: Practitioner' in the clinical findings report. One element per form item."
Characteristics: #can-be-target

* givenname 1..1 string "Given name"
* surname 1..1 string "Surname"
* streetLine 0..1 string "Street name, house number"
* zipCode 1..1 string "Zip code"
* city 1..1 string "City"
* phone 1..1 string "Phone"
* email 0..1 string "Email"
* gln 0..1 string "GLN"

Mapping: TreatingPhysicianPractitionerToPractitioner
Source: ChEkmTreatingPhysicianPractitionerForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-practitioner-treating-physician"
Title: "Treating Physician Practitioner Form to CH EKM Practitioner"
* -> "Practitioner" "Maps the form section to the ChEkmPractitionerTreatingPhysician profile"
* givenname -> "Practitioner.name.given" "Given name"
* surname -> "Practitioner.name.family" "Family name"
* streetLine -> "Practitioner.address.line" "Work address line"
* zipCode -> "Practitioner.address.postalCode" "Zip code"
* city -> "Practitioner.address.city" "City"
* phone -> "Practitioner.telecom[phone].value" "Phone"
* email -> "Practitioner.telecom[email].value" "Email"
* gln -> "Practitioner.identifier[GLN].value" "GLN (system urn:oid:2.51.1.3)"

Logical: ChEkmTreatingPhysicianOrganizationForm
Parent: Base
Title: "CH EKM Form: Treating Physician - Organization"
Description: "Logical model for the form section 'Treating Physician: Organization' in the clinical findings report. One element per form item."
Characteristics: #can-be-target

* name 1..1 string "Name"
* department 0..1 string "Department"
* streetLine 0..1 string "Street name, house number"
* zipCode 1..1 string "Zip code"
* city 1..1 string "City"
* phone 1..1 string "Phone"
* email 0..1 string "Email"
* ber 0..1 string "BER"
* gln 0..1 string "GLN"

Mapping: TreatingPhysicianOrganizationToOrganization
Source: ChEkmTreatingPhysicianOrganizationForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-organization-treating-physician"
Title: "Treating Physician Organization Form to CH EKM Organization"
* -> "Organization" "Maps the form section to the ChEkmOrganizationTreatingPhysician profile"
* name -> "Organization.name" "Name"
* department -> "Organization.extension[department].valueString" "Department (ch-ekm-ext-department extension)"
* streetLine -> "Organization.address.line" "Address line"
* zipCode -> "Organization.address.postalCode" "Zip code"
* city -> "Organization.address.city" "City"
* phone -> "Organization.telecom[phone].value" "Phone"
* email -> "Organization.telecom[email].value" "Email"
* ber -> "Organization.identifier[BER].value" "BER (system urn:oid:2.16.756.5.45)"
* gln -> "Organization.identifier[GLN].value" "GLN (system urn:oid:2.51.1.3)"
