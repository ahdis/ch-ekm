// Logical model for the "Labor" block of the reporting form — the laboratory that analysed the
// sample. DISEASE-AGNOSTIC: the Hepatitis C and the invasive pneumococcal disease CSVs ask for the
// identical nine fields, and every other organism's form has the same block, so this is the master
// for the shared sub-questionnaire ChEkmQuestionnaireLaboratory.
//
// The sibling of ChEkmTreatingPhysicianOrganizationForm, and deliberately shaped like it — same
// nine items, same order — because both describe an Organization on the same paper form. The two
// differ only in what is mandatory: for the treating physician the postal code, city and phone are
// required (1..1 in the CSV), for the laboratory only the NAME is (everything else is 0..1 there).
//
// ONLY THE ORGANIZATION. The rest of the "Labor" block on the paper form — Anlass
// (ServiceRequest.reasonCode), Material (Specimen.type) and Entnahmedatum
// (Specimen.collection.collectedDateTime) — is NOT modelled here: the answer lists are still open
// (see TODO.md). The wire representation reaches those through the ChEkmServiceRequest this form
// extracts to, so they can be added later without disturbing the nine items below.
Logical: ChEkmLabForm
Parent: Base
Title: "CH EKM Form: Laboratory"
Description: "Logical model for the form section 'Laboratory' (German form: 'Labor'), the analysing laboratory, in the clinical findings report. One element per form item."
Characteristics: #can-be-target

* name 1..1 string "Name"
* department 0..1 string "Department"
* streetLine 0..1 string "Street name, house number"
* zipCode 0..1 string "Zip code"
* city 0..1 string "City"
* phone 0..1 string "Phone"
* email 0..1 string "Email"
* ber 0..1 string "BER/BUR"
* gln 0..1 string "GLN"

Mapping: LabFormToOrganization
Source: ChEkmLabForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-organization-lab"
Title: "Lab Form to CH EKM Organization Lab"
* -> "Organization" "Maps the form section to the ChEkmOrganizationLab profile, referenced from ChEkmServiceRequest.performer"
* name -> "Organization.name" "Name"
* department -> "Organization.extension[department].valueString" "Department (ch-ekm-ext-department)"
* streetLine -> "Organization.address.line" "Address line"
* zipCode -> "Organization.address.postalCode" "Zip code"
* city -> "Organization.address.city" "City"
* phone -> "Organization.telecom[phone].value" "Phone"
* email -> "Organization.telecom[email].value" "Email"
* ber -> "Organization.identifier[BER].value" "BER/BUR (system urn:oid:2.16.756.5.45)"
* gln -> "Organization.identifier[GLN].value" "GLN (system urn:oid:2.51.1.3)"


// The SAMPLE the laboratory analysed — the other half of the paper form's "Labor" block, and a
// different resource: ChEkmSpecimen, reached from ChEkmServiceRequest.specimen (the laboratory
// itself is ChEkmOrganizationLab, reached from .performer). Kept as its own model because only some
// organisms' forms ask these two questions; see ChEkmQuestionnaireLaboratorySpecimen.
Logical: ChEkmLabSpecimenForm
Parent: Base
Title: "CH EKM Form: Laboratory - Sample"
Description: "Logical model for the sample questions of the form section 'Laboratory' (German form: 'Labor'): collection date and material. One element per form item."
Characteristics: #can-be-target

* collectionDate 0..1 dateTime "Sample collection date (Entnahmedatum)"
* material 0..1 CodeableConcept "Material of the sample (Blut, Liquor, ...)"

Mapping: LabSpecimenFormToSpecimen
Source: ChEkmLabSpecimenForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-specimen"
Title: "Lab Sample Form to CH EKM Specimen"
* -> "Specimen" "Maps the sample questions to the ChEkmSpecimen profile, referenced from ChEkmServiceRequest.specimen"
* collectionDate -> "Specimen.collection.collectedDateTime" "Sample collection date"
* material -> "Specimen.type" "Material, bound to the CH ELM specimen value set ch-elm-results-complete-spec"
