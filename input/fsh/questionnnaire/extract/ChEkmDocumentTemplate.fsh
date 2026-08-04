// SDC template-based extraction — BUNDLE TEMPLATE
//
// This is a single "Bundle template" (SDC template-based extraction,
// http://hl7.org/fhir/uv/sdc/extraction.html#template-based-extraction). It is shaped
// exactly like the target document Bundle (Profile: ChEkmDocument). The parts
// that vary per report carry sdc-questionnaire-templateExtractValue / -templateExtractContext
// FHIRPath expressions that read the answers from a QuestionnaireResponse (%resource).
//
// At $extract time the engine deep-copies this Bundle, evaluates each expression against the
// QR, writes the result into the annotated field, strips the template extensions, and returns
// the populated Bundle (wrapped in an outer transaction Bundle — tests/extract/extract.mjs
// unwraps entry[0].resource).
//
// Conventions used here (see the smart-forms reference impl, ../smart-forms/packages/sdc-template-extract):
//  * primitive value  -> templateExtractValue on the element (FSH `x.extension` => the `_x` sibling);
//                        an empty FHIRPath result simply omits the field (conditional).
//  * Coding/CodeableConcept -> templateExtractContext on the CodeableConcept (sets the answer.value
//                        scope) + templateExtractValue `ofType(Coding)` on coding[0].
//  * cross-references (Composition -> Patient/Condition/Observation) are static here: because the
//                        whole document is one template we own all the fullUrls and references,
//                        so nothing has to be re-wired after extraction.
//  * static system metadata (Broker PractitionerRole/Practitioner/Organization) is reused verbatim
//                        from the existing examples — it is supplied by the transmitting system,
//                        not by the form.
//
// Run:  ./tests/extract-gonorrhoea.sh   (sushi . first to (re)generate this Bundle JSON)

// ---------------------------------------------------------------------------
// Patient (ChEkmPatientInitials) — initials, DOB, gender, address from the `person` group
// ---------------------------------------------------------------------------
Instance: ExtractedPatient
InstanceOf: ChEkmPatientInitials
// Usage: #inline
* meta.profile = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-patient-initials"
// Nationalität -> patient-citizenship.code (identity pass-through of the answered Coding).
// Coding idiom: templateExtractContext on the value CodeableConcept sets the answer.value scope,
// templateExtractValue `ofType(Coding)` on coding[0] writes the Coding.
//
// NB: the gate is at the valueCodeableConcept level, NOT the whole patient-citizenship extension.
// Gating the whole extension (context as a sibling of the static `code` sub-extension) DOES drop it
// cleanly when unanswered, but the extract engine's sibling-strip bug then loses `code`'s `url` in
// the ANSWERED case (it corrupts the data-bearing sibling left behind in the same `extension` array
// — see forms-summary §8/§11). The identifier above CAN be fully gated only because system/value
// are plain Identifier fields, not sibling extensions. Consequence here: if nationality is
// unanswered the engine still emits an empty `{url: patient-citizenship, extension:[{url: code}]}`
// shell (the parent is not pruned). Acceptable for now; the form normally answers nationality.
* extension[0].url = $patient-citizenship
* extension[0].extension[0].url = "code"
* extension[0].extension[0].valueCodeableConcept.extension[+].url = $sdc-templateExtractContext
* extension[0].extension[0].valueCodeableConcept.extension[=].valueString = "%resource.descendants().where(linkId='nationality').answer.value"
* extension[0].extension[0].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* extension[0].extension[0].valueCodeableConcept.coding[0].extension[=].valueString = "ofType(Coding)"
// Geschlechtsidentität -> individual-genderIdentity.value (identity pass-through of the answered
// Coding). Same Coding idiom; if genderIdentity is unanswered the context is empty and the
// extension is omitted.
* extension[1].url = $individual-genderIdentity
* extension[1].extension[0].url = "value"
* extension[1].extension[0].valueCodeableConcept.extension[+].url = $sdc-templateExtractContext
* extension[1].extension[0].valueCodeableConcept.extension[=].valueString = "%resource.descendants().where(linkId='genderIdentity').answer.value"
* extension[1].extension[0].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* extension[1].extension[0].valueCodeableConcept.coding[0].extension[=].valueString = "ofType(Coding)"
// Name. Two parts working together:
//  1. Static placeholders `family="X"` / `given=["Y"]` (each 1 char) so the ChEkmPatientInitials
//     `name-initials` invariant (family length 1 AND given.first() length 1) validates on the template.
//  2. The WHOLE HumanName is built at extraction by ONE templateExtractValue via
//     %factory.HumanName(family, given), which materialises name[0] as {family, given[*]}. Because it
//     produces the complete HumanName, the engine REPLACES name[0] with it — the "X"/"Y" placeholders
//     do NOT survive extraction. (Contrast per-field templateExtractValue on family/given: the engine
//     deep-merges the computed values onto the static fields, so family keeps "X" and given
//     CONCATENATES to ["Y","B"] — corrupting the name. The whole-name factory value avoids this.)
// GATED by a templateExtractContext on name[0] scoped to the `person` group: empty (person unanswered)
// -> name[0] dropped entirely; otherwise the relative `item.where(...)` paths resolve within that scope.
// Order: the context-gated extension MUST come before the value (see forms-summary §8).
* name[0].family = "X"          // placeholder default — replaced at extraction by surnameInitial
* name[0].given[0] = "Y"        // placeholder default — replaced at extraction by givennameInitial
* name[0].extension[0].url = $sdc-templateExtractContext
* name[0].extension[0].valueString = "%resource.descendants().where(linkId='person')"
* name[0].extension[1].url = $sdc-templateExtractValue
* name[0].extension[1].valueString = "%factory.HumanName(item.where(linkId='surnameInitial').answer.value.first(), item.where(linkId='givennameInitial').answer.value)"
// PLACEHOLDER DEFAULT — replaced at extraction. gender has a required binding, so the template
// needs a real code to be valid; the templateExtractValue below overwrites it with the answered
// administrativeGender at extraction. The #unknown default never survives a real extraction.
* gender = #unknown
* gender.extension[+].url = $sdc-templateExtractValue
* gender.extension[=].valueString = "%resource.descendants().where(linkId='administrativeGender').answer.value.code.first()"
* birthDate.extension[+].url = $sdc-templateExtractValue
* birthDate.extension[=].valueString = "%resource.descendants().where(linkId='dateOfBirth').answer.value.first()"
// AHVN13 / OASI number -> identifier[AHVN13]. The WHOLE identifier is context-gated on the ahvn13
// answer: templateExtractContext on identifier[0] is non-empty only when answered, so when ahvn13 is
// blank the entire element (incl. the static system) is omitted — not just the value. Same gating
// idiom as the onsetDateTime data-absent extension below (empty context -> element excluded).
* identifier[0].extension[0].url = $sdc-templateExtractContext
* identifier[0].extension[0].valueString = "%resource.descendants().where(linkId='ahvn13').answer.value"
* identifier[0].system = $ahvn13-system
// value (the `_value` sibling, NOT identifier[0] itself, else the string becomes the array element).
// Inside the context scope $this is the answer string.
* identifier[0].value.extension[0].url = $sdc-templateExtractValue
* identifier[0].value.extension[0].valueString = "$this"
* address[0].use = #home
* address[0].postalCode.extension[+].url = $sdc-templateExtractValue
* address[0].postalCode.extension[=].valueString = "%resource.descendants().where(linkId='zipCode').answer.value.first()"
* address[0].city.extension[+].url = $sdc-templateExtractValue
* address[0].city.extension[=].valueString = "%resource.descendants().where(linkId='city').answer.value.first()"
// canton is open-choice -> the answer is either a valueString (free text) or a valueCoding (eCH-7).
// address.state is a string, so pull the Coding's .code when it's a Coding, else the string as-is.
* address[0].state.extension[+].url = $sdc-templateExtractValue
* address[0].state.extension[=].valueString = "iif(%resource.descendants().where(linkId='canton').answer.value.first() is Coding, %resource.descendants().where(linkId='canton').answer.value.first().code, %resource.descendants().where(linkId='canton').answer.value.first())"

// ---------------------------------------------------------------------------
// Treating physician — Practitioner (ChEkmPractitionerTreatingPhysician) from the
// `treatingPhysicianPractitioner` group. Array primitives (name.given, address.line) use the
// parent-context idiom (templateExtractContext on name[0]/address[0] scoped to the group, then
// relative `item.where(linkId=…)` paths) — a standalone value path mis-targets the `_x` sibling
// (forms-summary §8). Optional fields (GLN, email) are whole-element context-gated so they are
// omitted when blank (same idiom as the Patient AHVN13 identifier; static system survives).
// ---------------------------------------------------------------------------
Instance: ExtractedTreatingPractitioner
InstanceOf: ChEkmPractitionerTreatingPhysician
// Usage: #inline
// * meta.profile = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-practitioner-treating-physician"
// GLN (optional) -> identifier[GLN], gated on physicianGln
* identifier[0].extension[0].url = $sdc-templateExtractContext
* identifier[0].extension[0].valueString = "%resource.descendants().where(linkId='physicianGln').answer.value"
* identifier[0].system = "urn:oid:2.51.1.3"
* identifier[0].value.extension[0].url = $sdc-templateExtractValue
* identifier[0].value.extension[0].valueString = "$this"
// name (given is array -> context on name[0], relative paths)
* name[0].extension[+].url = $sdc-templateExtractContext
* name[0].extension[=].valueString = "%resource.descendants().where(linkId='treatingPhysicianPractitioner')"
* name[0].family.extension[+].url = $sdc-templateExtractValue
* name[0].family.extension[=].valueString = "item.where(linkId='physicianSurname').answer.value.first()"
* name[0].given[0].extension[+].url = $sdc-templateExtractValue
* name[0].given[0].extension[=].valueString = "item.where(linkId='physicianGivenname').answer.value"
// address (line is array -> context on address[0], relative paths)
* address[0].use = #work
* address[0].extension[+].url = $sdc-templateExtractContext
* address[0].extension[=].valueString = "%resource.descendants().where(linkId='treatingPhysicianPractitioner')"
* address[0].line[0].extension[+].url = $sdc-templateExtractValue
* address[0].line[0].extension[=].valueString = "item.where(linkId='physicianStreetLine').answer.value"
* address[0].postalCode.extension[+].url = $sdc-templateExtractValue
* address[0].postalCode.extension[=].valueString = "item.where(linkId='physicianZipCode').answer.value.first()"
* address[0].city.extension[+].url = $sdc-templateExtractValue
* address[0].city.extension[=].valueString = "item.where(linkId='physicianCity').answer.value.first()"
// telecom phone (required, ungated)
* telecom[0].system = #phone
* telecom[0].value.extension[+].url = $sdc-templateExtractValue
* telecom[0].value.extension[=].valueString = "%resource.descendants().where(linkId='physicianPhone').answer.value.first()"
// telecom email (optional) -> gated on physicianEmail
* telecom[1].extension[+].url = $sdc-templateExtractContext
* telecom[1].extension[=].valueString = "%resource.descendants().where(linkId='physicianEmail').answer.value"
* telecom[1].system = #email
* telecom[1].value.extension[+].url = $sdc-templateExtractValue
* telecom[1].value.extension[=].valueString = "$this"

// ---------------------------------------------------------------------------
// Treating physician — Organization (ChEkmOrganizationTreatingPhysician) from the
// `treatingPhysicianOrganization` group. Department (ch-ekm-ext-department, a SIMPLE valueString
// extension) is built via the SdcTemplateExtractExtension carrier + %factory.Extension, the same
// idiom as the onsetDateTime data-absent-reason: pre-declaring `url = ch-ekm-ext-department` with a
// templateExtractContext sub-extension makes the template invalid (ext-1 + the department profile
// allows 0 sub-extensions). Instead the WHOLE extension is produced by one templateExtractValue;
// its %factory.Extension result deep-merges onto the carrier (overwriting the carrier url). The
// context gates emission: empty -> extension omitted; answered -> {url: ch-ekm-ext-department,
// valueString: <department>}.
// ---------------------------------------------------------------------------
Instance: ExtractedTreatingOrganization
InstanceOf: ChEkmOrganizationTreatingPhysician
// Usage: #inline
// * meta.profile = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-organization-treating-physician"
// GLN (optional) -> identifier[GLN], gated on orgGln
* identifier[0].extension[0].url = $sdc-templateExtractContext
* identifier[0].extension[0].valueString = "%resource.descendants().where(linkId='orgGln').answer.value"
* identifier[0].system = "urn:oid:2.51.1.3"
* identifier[0].value.extension[0].url = $sdc-templateExtractValue
* identifier[0].value.extension[0].valueString = "$this"
// BER/BUR (optional) -> identifier[BER], gated on orgBer
* identifier[1].extension[0].url = $sdc-templateExtractContext
* identifier[1].extension[0].valueString = "%resource.descendants().where(linkId='orgBer').answer.value"
* identifier[1].system = "urn:oid:2.16.756.5.45"
* identifier[1].value.extension[0].url = $sdc-templateExtractValue
* identifier[1].value.extension[0].valueString = "$this"
// Department (optional, ch-ekm-ext-department) -> gated on orgDepartment; whole extension built
// via the carrier + %factory.Extension (see header note).
* extension[0].url = $sdc-templateExtractExtension
* extension[0].extension[0].url = $sdc-templateExtractContext
* extension[0].extension[0].valueString = "%resource.descendants().where(linkId='orgDepartment').answer.value"
* extension[0].extension[1].url = $sdc-templateExtractValue
* extension[0].extension[1].valueString = "%factory.Extension('http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-ext-department', %resource.descendants().where(linkId='orgDepartment').answer.value.first())"
// name (required, single)
* name.extension[+].url = $sdc-templateExtractValue
* name.extension[=].valueString = "%resource.descendants().where(linkId='orgName').answer.value.first()"
// address (line is array -> context on address[0], relative paths)
* address[0].extension[+].url = $sdc-templateExtractContext
* address[0].extension[=].valueString = "%resource.descendants().where(linkId='treatingPhysicianOrganization')"
* address[0].line[0].extension[+].url = $sdc-templateExtractValue
* address[0].line[0].extension[=].valueString = "item.where(linkId='orgStreetLine').answer.value"
* address[0].postalCode.extension[+].url = $sdc-templateExtractValue
* address[0].postalCode.extension[=].valueString = "item.where(linkId='orgZipCode').answer.value.first()"
* address[0].city.extension[+].url = $sdc-templateExtractValue
* address[0].city.extension[=].valueString = "item.where(linkId='orgCity').answer.value.first()"
// telecom phone (required, ungated)
* telecom[0].system = #phone
* telecom[0].value.extension[+].url = $sdc-templateExtractValue
* telecom[0].value.extension[=].valueString = "%resource.descendants().where(linkId='orgPhone').answer.value.first()"
// telecom email (optional) -> gated on orgEmail
* telecom[1].extension[+].url = $sdc-templateExtractContext
* telecom[1].extension[=].valueString = "%resource.descendants().where(linkId='orgEmail').answer.value"
* telecom[1].system = #email
* telecom[1].value.extension[+].url = $sdc-templateExtractValue
* telecom[1].value.extension[=].valueString = "$this"

// ---------------------------------------------------------------------------
// Treating physician — PractitionerRole linking the two above (static, fully owned by the template)
// ---------------------------------------------------------------------------
Instance: ExtractedTreatingPractitionerRole
InstanceOf: ChEkmPractitionerRole
// Usage: #inline
* practitioner.reference = "Practitioner/ExtractedTreatingPractitioner"
* organization.reference = "Organization/ExtractedTreatingOrganization"
