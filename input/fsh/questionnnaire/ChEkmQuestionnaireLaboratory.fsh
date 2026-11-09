// Modular sub-questionnaire: "Labor" — the laboratory that analysed the sample.
// Source of truth: logical model ChEkmLabForm (-> ChEkmOrganizationLab, reached from
// ChEkmServiceRequest.performer) in input/fsh/logical/ChEkmLabForm.fsh.
//
// DISEASE-AGNOSTIC, and the first laboratory module in the IG: the Hepatitis C and the invasive
// pneumococcal disease CSVs mark the identical nine rows with an "X", Mpox asks the same block
// (issue #42), so all three roots assemble this file unchanged, and any further organism gets it
// with one `insert RuleSetQrLaboratory`.
//
// A SECTION (tab) OF ITS OWN, "Labor", directly after "Diagnose und Manifestation" — on the same
// level as the other sections, not nested in the Diagnose tab (where it sat until issue #42). The
// section group (`laboratory`, text + tab label) is created by RuleSetQrLaboratory in the ROOT, and
// this module deliberately has NO wrapping group: its nine items are top-level, so $assemble puts
// them straight into that section group — the shape of the Person modules. Wrapping them here as
// well would render a second "Labor" heading inside the "Labor" tab. The sample (Probe) module,
// where a form asks it, is assembled into the same section after these items.
//
// linkIds are prefixed `lab*` so they stay unique across the assembled form — the treating
// physician's Organization group already uses orgName/orgZipCode/orgCity/… and $assemble rejects
// duplicate linkIds.
//
// ONLY THE NAME IS REQUIRED. That is what the CSV says (Labor Name 1..1, everything else 0..1) and
// what ChEkmOrganizationLab enforces (`name 1..1`, address and telecom optional) — note this is
// where the block differs from the treating physician's Organization, whose postal code, city and
// phone are all mandatory.
//
// NO PRE-POPULATION, deliberately. The three SDC launch contexts this IG declares are %patient,
// %user (the treating physician's PractitionerRole) and %encounter; none of them carries the
// analysing laboratory, and %user.organization is the SENDING organization, which is a different
// Organization and would pre-fill the block with the wrong one. The form asks. Should a launch
// context for the lab ever appear, these nine items are the natural place to add one.
//
// NOT ASKED HERE — the rest of the reporting form's "Labor" block, because the answer lists are still
// open (see TODO.md): "Anlass" (-> ServiceRequest.reasonCode, value set ChEkmServiceRequestReason
// exists but the CSV gives two different lists), "Material" (-> Specimen.type; only the invasive
// pneumococcal disease form asks it, and the CSV itself asks whether "Anderes" should be coded) and
// "Entnahmedatum" (-> Specimen.collection.collectedDateTime). All three live on resources the
// extracted ChEkmServiceRequest already points at, so they can be added without disturbing the
// nine items below.

Instance: ChEkmQuestionnaireLaboratory
InstanceOf: Questionnaire
Usage: #definition
Title: "EKM: Laboratory"
Description: "Modular sub-questionnaire for the 'Labor' section of the clinical findings report: the laboratory that analysed the sample (name, department, address, phone, email, BUR, GLN). Reusable as an SDC assemble-child; extracted into ChEkmOrganizationLab via ChEkmServiceRequest.performer."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireLaboratory)

// Name — the only mandatory field, and the one the extraction template keys the whole block on.
* item[+].linkId = "labName"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabForm#ChEkmLabForm.name"
* insert RuleSetQrLevel1Text("Name", "Name", "Nom", "Nome")
* item[=].type = #string
* item[=].required = true

// Abteilung -> the ch-elm-ext-department extension on the Organization
* item[+].linkId = "labDepartment"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabForm#ChEkmLabForm.department"
* insert RuleSetQrLevel1Text("Department", "Abteilung", "Service", "Reparto")
* item[=].type = #string

// Strasse / Nr.
* item[+].linkId = "labStreetLine"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabForm#ChEkmLabForm.streetLine"
* insert RuleSetQrLevel1Text("Street and number", "Strasse / Nr.", "Rue et numéro", "Via e numero")
* item[=].type = #string

// PLZ
* item[+].linkId = "labZipCode"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabForm#ChEkmLabForm.zipCode"
* insert RuleSetQrLevel1Text("Zip code", "PLZ", "NPA", "NPA")
* item[=].type = #string

// Ort
* item[+].linkId = "labCity"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabForm#ChEkmLabForm.city"
* insert RuleSetQrLevel1Text("City", "Ort", "Localité", "Località")
* item[=].type = #string

// Telefon
* item[+].linkId = "labPhone"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabForm#ChEkmLabForm.phone"
* insert RuleSetQrLevel1Text("Phone", "Telefon", "Téléphone", "Telefono")
* item[=].type = #string

// E-Mail
* item[+].linkId = "labEmail"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabForm#ChEkmLabForm.email"
* insert RuleSetQrLevel1Text("Email", "E-Mail", "Courriel", "E-mail")
* item[=].type = #string

// BUR — the business register number. `ber` in the model and on the wire
// (identifier[BER], system urn:oid:2.16.756.5.45); "BUR" is what the reporting form calls it.
* item[+].linkId = "labBer"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabForm#ChEkmLabForm.ber"
* insert RuleSetQrLevel1Text("BUR number", "BUR-Nummer", "Numéro REE", "Numero RIS")
* item[=].type = #string

// GLN
* item[+].linkId = "labGln"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabForm#ChEkmLabForm.gln"
* insert RuleSetQrLevel1Text("GLN", "GLN", "GLN", "GLN")
* item[=].type = #string
