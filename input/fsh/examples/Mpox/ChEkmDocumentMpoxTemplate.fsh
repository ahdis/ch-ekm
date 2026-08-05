// ---------------------------------------------------------------------------
// Condition (ChEkmCondition) — fixed disease code; manifestation -> evidence.code;
// manifestation begin date -> onset (omitted when "unbekannt" is ticked)
// ---------------------------------------------------------------------------
Instance: ExtractedConditionMpox
InstanceOf: ChEkmConditionMpox
// Usage: #inline
// code already fixed by the profile (ChEkmConditionMpox) to Mpox (disorder)
* category = $condition-category#encounter-diagnosis
* subject.reference = "Patient/ExtractedPatient"
// recorder -> the treating physician PractitionerRole (static reference; the role bundles the
// treating Practitioner + sending Organization, both populated from the form below). This is the
// navigation the report consumer follows: Condition.recorder.practitioner / .organization.
* recorder.reference = "PractitionerRole/ExtractedTreatingPractitionerRole"
// Manifestationsbeginn: refactor: Two options
// make a parent profile extract with those extensions defined, but then we cannot derive from ChEkmConditionMpox
// otherwise use FSH templating to add those extensions to the this condition instance
* onsetDateTime.extension[0].url = $sdc-templateExtractExtension
* onsetDateTime.extension[0].extension[0].url = $sdc-templateExtractContext
* onsetDateTime.extension[0].extension[0].valueString = "%resource.descendants().where(linkId='manifestationBeginUnknown').answer.value.where($this = true)"
* onsetDateTime.extension[0].extension[1].url = $sdc-templateExtractValue
* onsetDateTime.extension[0].extension[1].valueString = "%factory.Extension('http://hl7.org/fhir/StructureDefinition/data-absent-reason', %factory.code('asked-unknown'))"
* onsetDateTime.extension[1].url = $sdc-templateExtractValue
* onsetDateTime.extension[1].valueString = "iif(%resource.descendants().where(linkId='manifestationBeginUnknown').answer.value.first() = true, {}, %resource.descendants().where(linkId='manifestationBeginDate').answer.value.first())"
// Manifestation -> one `evidence` entry PER answered manifestation (identity pass-through of the
// answered Coding).
// REPEATING: the `manifestation` item is `repeats = true` (check-box), so the context expression
// returns 0..n Codings. The extract engine repeats the INDEXED element that carries the context,
// once per context result. The context therefore sits on `evidence[0]` (not on `code[0]`): n answers
// produce evidence[0]..evidence[n-1], each with a single code[0] whose coding[0] is written by the
// `ofType(Coding)` value below. Putting the context one level down on `code[0]` instead yields the
// other shape — ONE evidence with code[0]..code[n-1] — which is not what we want here.
// Unanswered -> empty context -> the whole evidence element is dropped.
// PLACEHOLDER DEFAULT coding — replaced/dropped at extraction (evidence.code has a required binding to
// ChEkmMpoxManifestation, so a valid coding is needed for the template to validate standalone;
// the templateExtractValue overwrites coding[0] at extraction). 95324001 is a member of that value set.
* evidence[0].extension[+].url = $sdc-templateExtractContext
* evidence[0].extension[=].valueString = "%resource.descendants().where(linkId='manifestation').answer.value"
* evidence[0].code[0].coding[0] = $sct#95324001 "Skin lesion (disorder)"
* evidence[0].code[0].coding[0].extension[+].url = $sdc-templateExtractValue
* evidence[0].code[0].coding[0].extension[=].valueString = "ofType(Coding)"

// ---------------------------------------------------------------------------
// Exposure (ChEkmExposureMpox) — fixed component codes; sex & relationship from `transmission`
// ---------------------------------------------------------------------------
Instance: ExtractedExposureMpox
InstanceOf: ChEkmExposureMpox
// Usage: #inline
* status = #final
* category = $v3-ActClass#AEXPOS "acquisition exposure"
* code = $v3-ParticipationType#EXPAGNT "Exposure Agent"
* subject.reference = "Patient/ExtractedPatient"
// Sexualkontakt mit infizierter Person (Geschlecht)
// PLACEHOLDER DEFAULT valueCodeableConcept — replaced/dropped at extraction. These sliced components
// have a REQUIRED value binding, so a coding is needed for the template to validate as a standalone
// example; the templateExtractValue overwrites coding[0] at extraction, and when the answer is absent
// the whole context-gated component is dropped. (Same idea as the gender/timestamp defaults, §8.)
* component[0].code = ChEkmExposureComponent#sexual-contact-partner
* component[0].extension[+].url = $sdc-templateExtractContext
* component[0].extension[=].valueString = "%resource.descendants().where(linkId='sexualContactPartner').answer.value"
* component[0].valueCodeableConcept.coding[0] = $administrative-gender#unknown "Unknown"
* component[0].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[0].valueCodeableConcept.coding[0].extension[=].valueString = "ofType(Coding)"
// Art der Beziehung
* component[1].code = $sct#228465009 "Sexual relationship details (observable entity)"
* component[1].extension[+].url = $sdc-templateExtractContext
* component[1].extension[=].valueString = "%resource.descendants().where(linkId='relationshipType').answer.value"
* component[1].valueCodeableConcept.coding[0] = ChEkmRelationshipType#steady-partner "Steady partner"
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
* component[3].valueCodeableConcept.coding[0] = $sct#261665006 "Unknown (qualifier value)"
* component[3].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[3].valueCodeableConcept.coding[0].extension[=].valueString = "%factory.Coding('http://snomed.info/sct', '261665006', 'Unknown (qualifier value)')"

// Emit only when "unknown" is NOT ticked AND otherTransmission has a value. The iif gates on unknown
// (empty -> component omitted when unknown=true); otherwise it yields the otherTransmission answer,
// which is itself empty when blank, so the component is also omitted when there is no free text.
// Note: a plain `.where($this != true)` negation would miss the unanswered/absent case (empty
// collection), so the iif form is required — see forms-summary §8.
// NB: `code` is NOT set statically here. component[transmissionRoute] (code 409496000) is 0..1 in the
// profile, and components 3/4/5 all carry that code — three static ones would trip the max-1 slice on
// the *template* (only one is ever emitted at runtime). So 4/5 build their code at extraction too, via
// %factory.CodeableConcept: at template-validation time the code is an empty CodeableConcept that does
// not match the 409496000 pattern (open slice → allowed); at extraction it becomes the real code, and
// only one of 3/4/5 is emitted so the output still has exactly one transmissionRoute component.
* component[4].extension[+].url = $sdc-templateExtractContext
* component[4].extension[=].valueString = "iif(%resource.descendants().where(linkId='unknown').answer.value = true, {}, %resource.descendants().where(linkId='otherTransmission').answer.value)"
* component[4].code.extension[+].url = $sdc-templateExtractValue
* component[4].code.extension[=].valueString = "%factory.CodeableConcept(%factory.Coding('http://snomed.info/sct', '409496000', 'Mode of transmission (observable entity)'))"
* component[4].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[4].valueCodeableConcept.coding[0].extension[=].valueString = "%factory.Coding('http://snomed.info/sct', '74964007', 'Other (qualifier value)')"

// code built at extraction (same reason as component[4] above — avoid a third static 409496000).
* component[5].extension[+].url = $sdc-templateExtractContext
// Fallback: emit sexualContactPartner only when unknown is NOT true AND otherTransmission has no
// value. NB the inner iif criterion must be a Boolean — a bare `…otherTransmission…answer.value`
// (a string) is not treated as truthy by FHIRPath, so it falls through to the else branch and the
// component fires even when other-transmission IS present. Use `.exists()` to make it a Boolean.
* component[5].extension[=].valueString = "iif(%resource.descendants().where(linkId='unknown').answer.value = true, {}, iif(%resource.descendants().where(linkId='otherTransmission').answer.value.exists(), {}, %resource.descendants().where(linkId='sexualContactPartner').answer.value))"
* component[5].code.extension[+].url = $sdc-templateExtractValue
* component[5].code.extension[=].valueString = "%factory.CodeableConcept(%factory.Coding('http://snomed.info/sct', '409496000', 'Mode of transmission (observable entity)'))"
* component[5].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[5].valueCodeableConcept.coding[0].extension[=].valueString = "%factory.Coding('http://snomed.info/sct', '417564009', 'Sexual transmission (qualifier value)')"

// ---------------------------------------------------------------------------
// Composition (ChEkmCompositionMpox) — static structure, references the entries above,
// author = Broker, date taken from QR.authored
// ---------------------------------------------------------------------------
Instance: ExtractedCompositionMpox
InstanceOf: ChEkmCompositionMpox
//Usage: #inline
* status = #final
* type = $sct#722143004 "Infectious disease diagnostic study note"
* category = $sct#423876004 "Clinical report"
* subject.reference = "Patient/ExtractedPatient"
* date.extension[+].url = $sdc-templateExtractValue
* date.extension[=].valueString = "%resource.authored"
* author.reference = "PractitionerRole/ExtractedTreatingPractitionerRole"
* title = "Meldung zum klinischen Befund Infektionskrankheit"
* section[0].title = "Diagnosis section"
* section[0].code = $loinc#29308-4
* section[0].entry.reference = "Condition/ExtractedConditionMpox"
* section[1].title = "Social history section"
* section[1].code = $loinc#29762-2
* section[1].entry.reference = "Observation/ExtractedExposureMpox"

// ---------------------------------------------------------------------------
// The Bundle template itself (ChEkmDocumentMpox shape)
// ---------------------------------------------------------------------------
Instance: ChEkmDocumentMpoxTemplate
InstanceOf: ChEkmDocumentMpox
Usage: #example
Title: "CH EKM $extract template: Mpox document Bundle"
Description: "SDC template-based extraction template. Shaped like ChEkmDocumentMpox; the per-report fields carry sdc-questionnaire-templateExtractValue/-Context FHIRPath expressions that read a Mpox QuestionnaireResponse. Used by tests/extract-gonorrhoea.sh; not a normal example."
// * meta.profile = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-document-gonorrhoea"
* type = #document
* identifier.system = "urn:ietf:rfc:3986"
* identifier.value = "urn:uuid:c376a38a-61b9-4a79-8722-12c75bacf927"
// PLACEHOLDER DEFAULT — replaced at extraction. A document Bundle must have a timestamp value
// (bdl-10: timestamp.hasValue()), so the template needs a real value to be valid; the
// templateExtractValue below overwrites it with the QuestionnaireResponse's authored time at
// extraction. This 1900 sentinel never survives a real extraction.
* timestamp = "1900-01-01T00:00:00Z"
* timestamp.extension[+].url = $sdc-templateExtractValue
* timestamp.extension[=].valueString = "%resource.authored"
* entry[+].fullUrl = "http://test.fhir.ch/r4/Composition/ExtractedCompositionMpox"
* entry[=].resource = ExtractedCompositionMpox
* entry[+].fullUrl = "http://test.fhir.ch/r4/Patient/ExtractedPatient"
* entry[=].resource = ExtractedPatient
* entry[+].fullUrl = "http://test.fhir.ch/r4/Condition/ExtractedConditionMpox"
* entry[=].resource = ExtractedConditionMpox
* entry[+].fullUrl = "http://test.fhir.ch/r4/Observation/ExtractedExposureMpox"
* entry[=].resource = ExtractedExposureMpox
* entry[+].fullUrl = "http://test.fhir.ch/r4/PractitionerRole/ExtractedTreatingPractitionerRole"
* entry[=].resource = ExtractedTreatingPractitionerRole
* entry[+].fullUrl = "http://test.fhir.ch/r4/Practitioner/ExtractedTreatingPractitioner"
* entry[=].resource = ExtractedTreatingPractitioner
* entry[+].fullUrl = "http://test.fhir.ch/r4/Organization/ExtractedTreatingOrganization"
* entry[=].resource = ExtractedTreatingOrganization