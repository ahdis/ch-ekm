// Modular sub-questionnaire: "Labor" — the laboratory that analysed the sample.
// Source of truth: logical model ChEkmLabForm (-> ChEkmOrganizationLab, reached from
// ChEkmServiceRequest.performer) in input/fsh/logical/ChEkmLabForm.fsh.
//
// DISEASE-AGNOSTIC, and the first laboratory module in the IG: the Hepatitis C and the invasive
// pneumococcal disease CSVs mark the identical nine rows with an "X", so both roots assemble this
// file unchanged, and any further organism gets it with one `insert RuleSetQrLaboratory`.
//
// PLACED IN THE "DIAGNOSE UND MANIFESTATION" SECTION, directly after the Manifestationsbeginn, so
// it is inserted at LEVEL 3 (inside `manifestation-group`) rather than as a tab of its own —
// unlike the treating physician, which is a level-2 section. The wrapping group below therefore
// becomes a sub-heading inside the Diagnose tab, the same shape ChEkmQuestionnaireHospitalisation
// has inside "Verlauf". It carries no sdc-questionnaire-shortText for that reason: it is never a
// tab, so there is no tab label to give.
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
// NOT ASKED HERE — the rest of the paper form's "Labor" block, because the answer lists are still
// open (see TODO.md): "Anlass" (-> ServiceRequest.reasonCode, value set ChEkmServiceRequestReason
// exists but the CSV gives two different lists), "Material" (-> Specimen.type; only the invasive
// pneumococcal disease form asks it, and the CSV itself asks whether "Anderes" should be coded) and
// "Entnahmedatum" (-> Specimen.collection.collectedDateTime). All three live on resources the
// extracted ChEkmServiceRequest already points at, so they can be added without disturbing the
// nine items below.

Instance: ChEkmQuestionnaireLaboratory
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Labor"
Description: "Modular sub-questionnaire for the 'Labor' section of the clinical findings report: the laboratory that analysed the sample (name, department, address, phone, email, BUR, GLN). Reusable as an SDC assemble-child; extracted into ChEkmOrganizationLab via ChEkmServiceRequest.performer."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireLaboratory)

* item[+].linkId = "laboratory"
* insert RuleSetQrLevel1Text("Laboratory", "Labor", "Laboratoire", "Laboratorio")
* item[=].type = #group

// Name — the only mandatory field, and the one the extraction template keys the whole block on.
* item[=].item[+].linkId = "labName"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabForm#ChEkmLabForm.name"
* insert RuleSetQrLevel2Text("Name", "Name", "Nom", "Nome")
* item[=].item[=].type = #string
* item[=].item[=].required = true

// Abteilung -> the ch-ekm-ext-department extension on the Organization
* item[=].item[+].linkId = "labDepartment"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabForm#ChEkmLabForm.department"
* insert RuleSetQrLevel2Text("Department", "Abteilung", "Service", "Reparto")
* item[=].item[=].type = #string

// Strasse / Nr.
* item[=].item[+].linkId = "labStreetLine"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabForm#ChEkmLabForm.streetLine"
* insert RuleSetQrLevel2Text("Street and number", "Strasse / Nr.", "Rue et numéro", "Via e numero")
* item[=].item[=].type = #string

// PLZ
* item[=].item[+].linkId = "labZipCode"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabForm#ChEkmLabForm.zipCode"
* insert RuleSetQrLevel2Text("Zip code", "PLZ", "NPA", "NPA")
* item[=].item[=].type = #string

// Ort
* item[=].item[+].linkId = "labCity"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabForm#ChEkmLabForm.city"
* insert RuleSetQrLevel2Text("City", "Ort", "Localité", "Località")
* item[=].item[=].type = #string

// Telefon
* item[=].item[+].linkId = "labPhone"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabForm#ChEkmLabForm.phone"
* insert RuleSetQrLevel2Text("Phone", "Telefon", "Téléphone", "Telefono")
* item[=].item[=].type = #string

// E-Mail
* item[=].item[+].linkId = "labEmail"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabForm#ChEkmLabForm.email"
* insert RuleSetQrLevel2Text("Email", "E-Mail", "Courriel", "E-mail")
* item[=].item[=].type = #string

// BUR — the business register number. `ber` in the model and on the wire
// (identifier[BER], system urn:oid:2.16.756.5.45); "BUR" is what the paper form calls it.
* item[=].item[+].linkId = "labBer"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabForm#ChEkmLabForm.ber"
* insert RuleSetQrLevel2Text("BUR number", "BUR-Nummer", "Numéro REE", "Numero RIS")
* item[=].item[=].type = #string

// GLN
* item[=].item[+].linkId = "labGln"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabForm#ChEkmLabForm.gln"
* insert RuleSetQrLevel2Text("GLN", "GLN", "GLN", "GLN")
* item[=].item[=].type = #string
