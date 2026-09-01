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
// Patient (ChEkmPatient) — initials, name, DOB, gender, address from the `person` group
// ---------------------------------------------------------------------------
Instance: ExtractedPatient
InstanceOf: ChEkmPatient
// Usage: #inline
// Nationalität -> patient-citizenship.code, Geschlechtsidentität -> individual-genderIdentity.value.
//
// BOTH ARE BUILT WHOLE AT EXTRACTION, on the ch-ekm SdcTemplateExtractExtension carrier — the same
// idiom as the onsetDateTime data-absent-reason and the exposure address (forms-summary §8), and
// NOT the field-level gating this used to do. The old shape declared the extension statically and
// put a templateExtractContext on the inner valueCodeableConcept:
//
//     {url: patient-citizenship, extension: [{url: code, valueCodeableConcept: <gated>}]}
//
// which drops the VALUE when the question is unanswered but never prunes the parent, leaving
// `{url: …, extension: [{url: "code"}]}` — a sub-extension with neither a value nor children, i.e.
// a FAILED ext-1. That is not cosmetic: the invalid Patient stops conforming to ChEkmPatient, so
// `Composition.subject only Reference(ChEkmPatient)` fails, and the document Bundle's required
// `entry:Composition` slice stops matching. Three QA errors from one skipped OPTIONAL question.
//
// Gating the whole extension instead was not an option either: a templateExtractContext as a
// SIBLING of the static `code`/`value` sub-extension trips the engine's sibling-strip bug, which
// corrupts the data-bearing sibling (loses its `url`) in the ANSWERED case.
//
// Building the complete Extension in ONE templateExtractValue avoids both. There is no
// templateExtractContext at all: a value-only carrier whose expression yields empty is dropped
// together with its carrier, so "unanswered" and "no extension emitted" are the same thing — the
// shape already proven by `hospitalization.extension[0]` in RuleSetEncounterHospitalisation.
//
// Why this particular factory chain: `%factory.Extension(url, value)` can only build a SIMPLE
// extension (url + value[x]), and these two are COMPLEX (url + a nested `extension` array).
// `%factory.withProperty(…, 'extension', …)` does not work — it writes the child as a bare object
// rather than an array and leaves a stray `"_extension": {}` behind. `%factory.withExtension(el,
// url, value)` appends a proper array element, so: create the Extension, set its `url` with
// withProperty, then add the single named sub-extension with withExtension.
* extension[0].url = $sdc-templateExtractExtension
* extension[0].extension[0].url = $sdc-templateExtractValue
* extension[0].extension[0].valueString = "%resource.descendants().where(linkId='nationality').answer.value.ofType(Coding).first().select(%factory.withExtension(%factory.withProperty(%factory.create(Extension), 'url', 'http://hl7.org/fhir/StructureDefinition/patient-citizenship'), 'code', %factory.CodeableConcept($this)))"
* extension[1].url = $sdc-templateExtractExtension
* extension[1].extension[0].url = $sdc-templateExtractValue
* extension[1].extension[0].valueString = "%resource.descendants().where(linkId='genderIdentity').answer.value.ofType(Coding).first().select(%factory.withExtension(%factory.withProperty(%factory.create(Extension), 'url', 'http://hl7.org/fhir/StructureDefinition/individual-genderIdentity'), 'value', %factory.CodeableConcept($this)))"
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
// Both name modules are accepted: ChEkmQuestionnairePersonInitials contributes surnameInitial/
// givennameInitial, ChEkmQuestionnairePersonName contributes surname/givenname. A root assembles
// exactly one of them (Gonorrhoea -> initials, Mpox -> full name) and both merge FLAT into the
// `person` group, so the two linkIds per part are mutually exclusive and can simply be or-ed in the
// same `where()` — whichever module is present supplies the answer.
* name[0].family = "X"          // placeholder default — replaced at extraction by surnameInitial
* name[0].given[0] = "Y"        // placeholder default — replaced at extraction by givennameInitial
* name[0].extension[0].url = $sdc-templateExtractContext
* name[0].extension[0].valueString = "%resource.descendants().where(linkId='person')"
* name[0].extension[1].url = $sdc-templateExtractValue
* name[0].extension[1].valueString = "%factory.HumanName(item.where(linkId='surnameInitial' or linkId='surname').answer.value.first(), item.where(linkId='givennameInitial' or linkId='givenname').answer.value)"
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
// Death ("Zustand"). Only forms with a Verlauf section answer these; elsewhere the expressions are
// empty and no deceasedDateTime is emitted. See RuleSetPatientDeceased.
* insert RuleSetPatientDeceased
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
// "Labor" — the analysing laboratory (ChEkmOrganizationLab) from the `laboratory` group, plus the
// ChEkmServiceRequest that carries it. Shared, like the treating physician above: every organism
// whose root inserts RuleSetQrLaboratory extracts into exactly these two instances, and adds them
// to its Bundle and its Composition with RuleSetLaboratoryEntries / RuleSetLaboratorySection
// (extract/RuleSetLaboratory.fsh).
//
// UNGATED, for the same reason the treating physician is: `labName` is a REQUIRED form item, so a
// completed QuestionnaireResponse always answers it. The optional fields are context-gated one by
// one (identifier, department, address, email) exactly as on ExtractedTreatingOrganization, which
// is only possible BECAUSE the two Bundle entries carry no gate of their own — a
// templateExtractContext nested inside a gated entry is what RuleSetEncounterHospitalisation warns
// about. A form that made the whole laboratory optional would have to give all of this up and go
// back to the six-instances-per-answer shape the Impfstatus rows use.
//
// Department (ch-ekm-ext-department, a SIMPLE valueString extension) is built via the
// SdcTemplateExtractExtension carrier + %factory.Extension — see the note on
// ExtractedTreatingOrganization for why it cannot be pre-declared.
// ---------------------------------------------------------------------------
Instance: ExtractedLabOrganization
InstanceOf: ChEkmOrganizationLab
// GLN (optional) -> identifier[GLN], gated on labGln
* identifier[0].extension[0].url = $sdc-templateExtractContext
* identifier[0].extension[0].valueString = "%resource.descendants().where(linkId='labGln').answer.value"
* identifier[0].system = "urn:oid:2.51.1.3"
* identifier[0].value.extension[0].url = $sdc-templateExtractValue
* identifier[0].value.extension[0].valueString = "$this"
// BER/BUR (optional) -> identifier[BER], gated on labBer
* identifier[1].extension[0].url = $sdc-templateExtractContext
* identifier[1].extension[0].valueString = "%resource.descendants().where(linkId='labBer').answer.value"
* identifier[1].system = "urn:oid:2.16.756.5.45"
* identifier[1].value.extension[0].url = $sdc-templateExtractValue
* identifier[1].value.extension[0].valueString = "$this"
// Department (optional, ch-ekm-ext-department) -> gated on labDepartment
* extension[0].url = $sdc-templateExtractExtension
* extension[0].extension[0].url = $sdc-templateExtractContext
* extension[0].extension[0].valueString = "%resource.descendants().where(linkId='labDepartment').answer.value"
* extension[0].extension[1].url = $sdc-templateExtractValue
* extension[0].extension[1].valueString = "%factory.Extension('http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-ext-department', %resource.descendants().where(linkId='labDepartment').answer.value.first())"
// name (required, single)
* name.extension[+].url = $sdc-templateExtractValue
* name.extension[=].valueString = "%resource.descendants().where(linkId='labName').answer.value.first()"
// address — GATED AS A WHOLE, unlike the treating physician's: every one of its three parts is
// optional here, so an unanswered address must not leave an empty Address behind. The context is
// the `laboratory` group scoped to "at least one address answer exists"; inside it the relative
// `item.where(...)` paths resolve, which is also what `line` (an array primitive) needs.
* address[0].extension[+].url = $sdc-templateExtractContext
* address[0].extension[=].valueString = "%resource.descendants().where(linkId='laboratory').where(item.where(linkId='labStreetLine' or linkId='labZipCode' or linkId='labCity').answer.value.exists())"
* address[0].line[0].extension[+].url = $sdc-templateExtractValue
* address[0].line[0].extension[=].valueString = "item.where(linkId='labStreetLine').answer.value"
* address[0].postalCode.extension[+].url = $sdc-templateExtractValue
* address[0].postalCode.extension[=].valueString = "item.where(linkId='labZipCode').answer.value.first()"
* address[0].city.extension[+].url = $sdc-templateExtractValue
* address[0].city.extension[=].valueString = "item.where(linkId='labCity').answer.value.first()"
// telecom phone (optional here, unlike the treating physician) -> gated on labPhone
* telecom[0].extension[+].url = $sdc-templateExtractContext
* telecom[0].extension[=].valueString = "%resource.descendants().where(linkId='labPhone').answer.value"
* telecom[0].system = #phone
* telecom[0].value.extension[+].url = $sdc-templateExtractValue
* telecom[0].value.extension[=].valueString = "$this"
// telecom email (optional) -> gated on labEmail
* telecom[1].extension[+].url = $sdc-templateExtractContext
* telecom[1].extension[=].valueString = "%resource.descendants().where(linkId='labEmail').answer.value"
* telecom[1].system = #email
* telecom[1].value.extension[+].url = $sdc-templateExtractValue
* telecom[1].value.extension[=].valueString = "$this"

// The ServiceRequest is entirely STATIC: it exists to carry `performer` -> the laboratory, which is
// how ChEkmComposition.section[laboratory] reaches an Organization at all (the section's mandatory
// entry slice is `lab-order`, a ChEkmServiceRequest). Nothing on it is a form answer today —
// `reasonCode` (the "Anlass" question) and `specimen` (Material / Entnahmedatum) are the parts of
// the paper form's Labor block that are still open, and both attach here when they are decided.
Instance: ExtractedLabServiceRequest
InstanceOf: ChEkmServiceRequest
* status = #completed
* intent = #order
* subject.reference = "Patient/ExtractedPatient"
* performer[0].reference = "Organization/ExtractedLabOrganization"

// ---------------------------------------------------------------------------
// Treating physician — PractitionerRole linking the two above (static, fully owned by the template)
// ---------------------------------------------------------------------------
Instance: ExtractedTreatingPractitionerRole
InstanceOf: ChEkmPractitionerRole
// Usage: #inline
* practitioner.reference = "Practitioner/ExtractedTreatingPractitioner"
* organization.reference = "Organization/ExtractedTreatingOrganization"
