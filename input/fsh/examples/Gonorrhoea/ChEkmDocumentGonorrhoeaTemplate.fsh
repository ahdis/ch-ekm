// SDC template-based extraction — BUNDLE TEMPLATE for Gonorrhoea.
//
// This is a single "Bundle template" (SDC template-based extraction,
// http://hl7.org/fhir/uv/sdc/extraction.html#template-based-extraction). It is shaped
// exactly like the target document Bundle (Profile: ChEkmDocumentGonorrhoea). The parts
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
Instance: GonExtractPatient
InstanceOf: Patient
Usage: #inline
// * meta.profile = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-patient-initials"
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
// Context on name[0] (the person group) so the array-primitive `given` maps correctly into
// given[*] — the same idiom the SDC reference patient template uses for repeating names.
* name[0].extension[+].url = $sdc-templateExtractContext
* name[0].extension[=].valueString = "%resource.descendants().where(linkId='person')"
* name[0].family.extension[+].url = $sdc-templateExtractValue
* name[0].family.extension[=].valueString = "item.where(linkId='surnameInitial').answer.value.first()"
* name[0].given[0].extension[+].url = $sdc-templateExtractValue
* name[0].given[0].extension[=].valueString = "item.where(linkId='givennameInitial').answer.value"
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
// Condition (ChEkmConditionGonorrhoea) — fixed disease code; manifestation -> evidence.code;
// manifestation begin date -> onset (omitted when "unbekannt" is ticked)
// ---------------------------------------------------------------------------
Instance: GonExtractCondition
InstanceOf: Condition
Usage: #inline
// * meta.profile = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-condition-gonorrhoea"
* category = $condition-category#encounter-diagnosis
* code = $sct#15628003 "Gonorrhea (disorder)"
* subject.reference = "Patient/GonExtractPatient"
// Manifestationsbeginn:
//  - known   -> onsetDateTime = the answered date.
//  - unbekannt -> no value; onsetDateTime.extension[data-absent-reason] = asked-unknown.
//
// extension[0] is the data-absent-reason extension, gated by a templateExtractContext that is
// non-empty only when manifestationBeginUnknown = true (empty context -> element excluded), with
// its valueCode set by a templateExtractValue inside that context scope.
// extension[1] is the onset value (iif -> {} when unbekannt, so onsetDateTime is omitted then).
//
// ORDER MATTERS: the context-gated extension MUST come before the plain onset value extension.
// The reference engine's array index bookkeeping mis-handles the reverse order (the gated element
// is not deleted and the valueCode splits into a stray entry). See forms-summary.md §8.
* onsetDateTime.extension[0].url = $data-absent-reason
* onsetDateTime.extension[0].extension[0].url = $sdc-templateExtractContext
* onsetDateTime.extension[0].extension[0].valueString = "%resource.descendants().where(linkId='manifestationBeginUnknown').answer.value.where($this = true)"
* onsetDateTime.extension[0].valueCode.extension[0].url = $sdc-templateExtractValue
* onsetDateTime.extension[0].valueCode.extension[0].valueString = "'asked-unknown'"
* onsetDateTime.extension[1].url = $sdc-templateExtractValue
* onsetDateTime.extension[1].valueString = "iif(%resource.descendants().where(linkId='manifestationBeginUnknown').answer.value.first() = true, {}, %resource.descendants().where(linkId='manifestationBeginDate').answer.value.first())"
// Manifestation -> evidence.code (identity pass-through of the answered Coding)
* evidence[0].code[0].extension[+].url = $sdc-templateExtractContext
* evidence[0].code[0].extension[=].valueString = "%resource.descendants().where(linkId='manifestation').answer.value"
* evidence[0].code[0].coding[0].extension[+].url = $sdc-templateExtractValue
* evidence[0].code[0].coding[0].extension[=].valueString = "ofType(Coding)"

// ---------------------------------------------------------------------------
// Exposure (ChEkmExposureGonorrhoea) — fixed component codes; sex & relationship from `transmission`
// ---------------------------------------------------------------------------
Instance: GonExtractExposure
InstanceOf: Observation
Usage: #inline
// * meta.profile = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-exposure-gonorrhoea"
* status = #final
* category = $v3-ActClass#AEXPOS "acquisition exposure"
* code = $v3-ParticipationType#EXPAGNT "Exposure Agent"
* subject.reference = "Patient/GonExtractPatient"
// Sexualkontakt mit infizierter Person (Geschlecht)
* component[0].code = ChEkmExposureComponent#sexual-contact-partner
* component[0].extension[+].url = $sdc-templateExtractContext
* component[0].extension[=].valueString = "%resource.descendants().where(linkId='sexualContactPartner').answer.value"
* component[0].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[0].valueCodeableConcept.coding[0].extension[=].valueString = "ofType(Coding)"
// Art der Beziehung
* component[1].code = $sct#228465009 "Sexual relationship details (observable entity)"
* component[1].extension[+].url = $sdc-templateExtractContext
* component[1].extension[=].valueString = "%resource.descendants().where(linkId='relationshipType').answer.value"
* component[1].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[1].valueCodeableConcept.coding[0].extension[=].valueString = "ofType(Coding)"
// Anderer Übertragungsweg (Freitext) -> component[2] (no code, just a text value). This is a free-text field, so no context gating or coding idiom — just write the string directly, and if it's blank the component is omitted.
* component[2].code = $sct#74964007  "Other (qualifier value)"
* component[2].extension[+].url = $sdc-templateExtractContext
* component[2].extension[=].valueString = "%resource.descendants().where(linkId='otherTransmission').answer.value"
* component[2].valueString.extension[+].url = $sdc-templateExtractValue
* component[2].valueString.extension[=].valueString = "$this"


// TransmissionRoute: a single component recording "unknown transmission route", emitted ONLY when the
// "unknown" checkbox is ticked.
//
// The component is gated by a templateExtractContext on component[3] scoped to `…unknown… = true`
// (empty when unticked/unanswered -> the whole component is omitted). CRUCIAL: the engine DELETES any
// array element carrying a templateExtractContext and only re-inserts it while iterating that element's
// templateExtractValue paths — so a context WITHOUT any nested templateExtractValue is dropped and
// never restored (that is why a static-only `valueCodeableConcept` produced no component at all).
//
// The value is a FIXED Coding. fhirpath.js has no object literals, and assembling a Coding from
// several primitive templateExtractValues fails (multiple value-paths deepmerge-concat the coding
// array; a single one shallow-overwrites valueCodeableConcept and loses system/display). The clean
// way is one value-path on coding[0] whose result is already a full Coding — built with the FHIR
// Type Factory API `%factory.Coding(system, code, display)` (fhirpath.js 4.11, r4 model loaded by
// the engine). This both materialises the element and yields a complete Coding; the static
// `component[3].code` survives (it is a different key from the shallow-merged valueCodeableConcept).
// See forms-summary §8.
* component[3].code = $sct#409496000  "Mode of transmission (observable entity)"
* component[3].extension[+].url = $sdc-templateExtractContext
* component[3].extension[=].valueString = "%resource.descendants().where(linkId='unknown').answer.value.where($this = true)"
* component[3].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[3].valueCodeableConcept.coding[0].extension[=].valueString = "%factory.Coding('http://snomed.info/sct', '261665006', 'Unknown (qualifier value)')"

// Emit only when "unknown" is NOT ticked AND otherTransmission has a value. The iif gates on unknown
// (empty -> component omitted when unknown=true); otherwise it yields the otherTransmission answer,
// which is itself empty when blank, so the component is also omitted when there is no free text.
// Note: a plain `.where($this != true)` negation would miss the unanswered/absent case (empty
// collection), so the iif form is required — see forms-summary §8.
* component[4].code = $sct#409496000  "Mode of transmission (observable entity)"
* component[4].extension[+].url = $sdc-templateExtractContext
* component[4].extension[=].valueString = "iif(%resource.descendants().where(linkId='unknown').answer.value = true, {}, %resource.descendants().where(linkId='otherTransmission').answer.value)"
* component[4].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[4].valueCodeableConcept.coding[0].extension[=].valueString = "%factory.Coding('http://snomed.info/sct', '74964007', 'Other (qualifier value)')"

* component[5].code = $sct#409496000  "Mode of transmission (observable entity)"
* component[5].extension[+].url = $sdc-templateExtractContext
// Fallback: emit sexualContactPartner only when unknown is NOT true AND otherTransmission has no
// value. NB the inner iif criterion must be a Boolean — a bare `…otherTransmission…answer.value`
// (a string) is not treated as truthy by FHIRPath, so it falls through to the else branch and the
// component fires even when other-transmission IS present. Use `.exists()` to make it a Boolean.
* component[5].extension[=].valueString = "iif(%resource.descendants().where(linkId='unknown').answer.value = true, {}, iif(%resource.descendants().where(linkId='otherTransmission').answer.value.exists(), {}, %resource.descendants().where(linkId='sexualContactPartner').answer.value))"
* component[5].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[5].valueCodeableConcept.coding[0].extension[=].valueString = "%factory.Coding('http://snomed.info/sct', '417564009', 'Sexual transmission (qualifier value)')"

// ---------------------------------------------------------------------------

// Composition (ChEkmCompositionGonorrhoea) — static structure, references the entries above,
// author = Broker, date taken from QR.authored
// ---------------------------------------------------------------------------
Instance: GonExtractComposition
InstanceOf: Composition
Usage: #inline
// * meta.profile = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-composition-gonorrhoea"
* status = #final
* type = $sct#722143004 "Infectious disease diagnostic study note"
* category = $sct#423876004 "Clinical report"
* subject.reference = "Patient/GonExtractPatient"
* date.extension[+].url = $sdc-templateExtractValue
* date.extension[=].valueString = "%resource.authored"
* author.reference = "PractitionerRole/ChEkmPractitionerRoleBrokerExample"
* title = "Meldung zum klinischen Befund Infektionskrankheit"
* section[0].title = "Diagnosis section"
* section[0].code = $loinc#29308-4
* section[0].entry.reference = "Condition/GonExtractCondition"
* section[1].title = "Social history section"
* section[1].code = $loinc#29762-2
* section[1].entry.reference = "Observation/GonExtractExposure"

// ---------------------------------------------------------------------------
// The Bundle template itself (ChEkmDocumentGonorrhoea shape)
// ---------------------------------------------------------------------------
Instance: ChEkmDocumentGonorrhoeaTemplate
InstanceOf: Bundle
Usage: #example
Title: "CH EKM $extract template: Gonorrhoea document Bundle"
Description: "SDC template-based extraction template. Shaped like ChEkmDocumentGonorrhoea; the per-report fields carry sdc-questionnaire-templateExtractValue/-Context FHIRPath expressions that read a Gonorrhoea QuestionnaireResponse. Used by tests/extract-gonorrhoea.sh; not a normal example."
// * meta.profile = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-document-gonorrhoea"
* type = #document
* identifier.system = "urn:ietf:rfc:3986"
* identifier.value = "urn:uuid:c376a38a-61b9-4a79-8722-12c75bacf927"
* timestamp.extension[+].url = $sdc-templateExtractValue
* timestamp.extension[=].valueString = "%resource.authored"
* entry[+].fullUrl = "http://test.fhir.ch/r4/Composition/GonExtractComposition"
* entry[=].resource = GonExtractComposition
* entry[+].fullUrl = "http://test.fhir.ch/r4/Patient/GonExtractPatient"
* entry[=].resource = GonExtractPatient
* entry[+].fullUrl = "http://test.fhir.ch/r4/PractitionerRole/ChEkmPractitionerRoleBrokerExample"
* entry[=].resource = ChEkmPractitionerRoleBrokerExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/Practitioner/ChEkmPractitionerBrokerExample"
* entry[=].resource = ChEkmPractitionerBrokerExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/Organization/ChEkmOrganizationBrokerExample"
* entry[=].resource = ChEkmOrganizationBrokerExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/Condition/GonExtractCondition"
* entry[=].resource = GonExtractCondition
* entry[+].fullUrl = "http://test.fhir.ch/r4/Observation/GonExtractExposure"
* entry[=].resource = GonExtractExposure
