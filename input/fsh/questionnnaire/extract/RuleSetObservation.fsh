RuleSet: RuleSetEffectiveExposureWhen
// Exposure "Wann" (https://github.com/ahdis/ch-ekm/issues/25) — two mutually exclusive answers:
//   exposureWhenDate -> effectiveDateTime          (the point in time of infection itself)
//   exposureWhenLastEntryDate  -> component[dateOfEntry]     (only asked when exposureWhenDate is unanswered)
//
// effectiveDateTime carries BOTH branches:
//   answered      -> effectiveDateTime = the date (extension[1], a plain value directive; an
//                    unanswered item yields an empty expression and the element is omitted).
//                    The answer is a `date` (partial dates allowed) = a valid dateTime lexical form.
//   unknown       -> no value; effectiveDateTime.extension[data-absent-reason] = asked-unknown, so
//                    the "when" question is explicitly answered as unknown rather than silently
//                    absent. The entry date then lands in component[dateOfEntry] below.
//
// extension[0] builds the WHOLE data-absent-reason extension at extraction time via the FHIR Type
// Factory (%factory.Extension + %factory.code) on the ch-ekm SdcTemplateExtractExtension carrier —
// it cannot be pre-declared as data-absent-reason in the template (a to-be-computed valueCode
// leaves the extension valueless => fails ext-1, and the templateExtractContext sub-extension is
// not allowed by the data-absent-reason profile). Identical idiom to
// RuleSetOnsetDateManifestationBeginUnknown; see forms-summary §8.
//
// The context gates on exposureWhenLastEntryDate: that item is only answerable while
// exposureWhenDate is empty (enableWhen exists=false), so "entry date given" IS "infection date
// unknown" — the two branches can never both fire.
//
// ORDER MATTERS: the context-gated carrier MUST come before the plain value extension. The
// reference engine's array index bookkeeping mis-handles the reverse order (the gated element is
// not deleted and the value splits into a stray entry). See forms-summary.md §8.
* effectiveDateTime.extension[0].url = $sdc-templateExtractExtension
* effectiveDateTime.extension[0].extension[0].url = $sdc-templateExtractContext
* effectiveDateTime.extension[0].extension[0].valueString = "%resource.descendants().where(linkId='exposureWhenLastEntryDate').answer.value"
* effectiveDateTime.extension[0].extension[1].url = $sdc-templateExtractValue
* effectiveDateTime.extension[0].extension[1].valueString = "%factory.Extension('http://hl7.org/fhir/StructureDefinition/data-absent-reason', %factory.code('asked-unknown'))"
* effectiveDateTime.extension[1].url = $sdc-templateExtractValue
* effectiveDateTime.extension[1].valueString = "%resource.descendants().where(linkId='exposureWhenDate').answer.value.first()"

// The component IS gated: an element that is present in the template but has no answer must not
// produce an empty component. The templateExtractContext scopes to the exposureWhenLastEntryDate answer (empty
// -> the whole component is dropped); the nested templateExtractValue on valueDateTime both
// materialises the element and writes the date. The static `code` survives the merge (different
// key than valueDateTime) — the same shape as the otherTransmission component below.
* component[+].code = $sct#161097008 "Date of return from travel"
* component[=].extension[+].url = $sdc-templateExtractContext
* component[=].extension[=].valueString = "%resource.descendants().where(linkId='exposureWhenLastEntryDate').answer.value"
* component[=].valueDateTime.extension[+].url = $sdc-templateExtractValue
* component[=].valueDateTime.extension[=].valueString = "$this"

RuleSet: RuleSetComponentExposure
// Sexualkontakt mit infizierter Person (Geschlecht)
// PLACEHOLDER DEFAULT valueCodeableConcept — replaced/dropped at extraction. These sliced components
// have a REQUIRED value binding, so a coding is needed for the template to validate as a standalone
// example; the templateExtractValue overwrites coding[0] at extraction, and when the answer is absent
// the whole context-gated component is dropped. (Same idea as the gender/timestamp defaults, §8.)
* component[+].code = ChEkmExposureComponent#sexual-contact-partner
* component[=].extension[+].url = $sdc-templateExtractContext
* component[=].extension[=].valueString = "%resource.descendants().where(linkId='exposureHowSexualContactPartner').answer.value"
* component[=].valueCodeableConcept.coding[0] = $administrative-gender#unknown "Unknown"
* component[=].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[=].valueCodeableConcept.coding[0].extension[=].valueString = "ofType(Coding)"
// Art der Beziehung
* component[+].code = $sct#228465009 "Sexual relationship details (observable entity)"
* component[=].extension[+].url = $sdc-templateExtractContext
* component[=].extension[=].valueString = "%resource.descendants().where(linkId='exposureHowRelationshipType').answer.value"
* component[=].valueCodeableConcept.coding[0] = ChEkmRelationshipType#steady-partner "Steady partner"
* component[=].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[=].valueCodeableConcept.coding[0].extension[=].valueString = "ofType(Coding)"
// Anderer Übertragungsweg (Freitext) -> component[2] (no code, just a text value). This is a free-text field, so no context gating or coding idiom — just write the string directly, and if it's blank the component is omitted.
* component[+].code = $sct#74964007  "Other (qualifier value)"
* component[=].extension[+].url = $sdc-templateExtractContext
* component[=].extension[=].valueString = "%resource.descendants().where(linkId='exposureHowOtherTransmission').answer.value"
* component[=].valueString.extension[+].url = $sdc-templateExtractValue
* component[=].valueString.extension[=].valueString = "$this"

// TransmissionRoute: a single component recording "unknown transmission route", emitted ONLY when the
// "exposureHowUnknown" checkbox is ticked.
//
// The component is gated by a templateExtractContext on component[3] scoped to `…exposureHowUnknown… = true`
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
* component[+].code = $sct#409496000  "Mode of transmission (observable entity)"
* component[=].extension[+].url = $sdc-templateExtractContext
* component[=].extension[=].valueString = "%resource.descendants().where(linkId='exposureHowUnknown').answer.value.where($this = true)"
* component[=].valueCodeableConcept.coding[0] = $sct#261665006 "Unknown (qualifier value)"
* component[=].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[=].valueCodeableConcept.coding[0].extension[=].valueString = "%factory.Coding('http://snomed.info/sct', '261665006', 'Unknown (qualifier value)')"

// Emit only when "exposureHowUnknown" is NOT ticked AND exposureHowOtherTransmission has a value. The iif gates on exposureHowUnknown
// (empty -> component omitted when unknown=true); otherwise it yields the exposureHowOtherTransmission answer,
// which is itself empty when blank, so the component is also omitted when there is no free text.
// Note: a plain `.where($this != true)` negation would miss the unanswered/absent case (empty
// collection), so the iif form is required — see forms-summary §8.
// NB: `code` is NOT set statically here. component[transmissionRoute] (code 409496000) is 0..1 in the
// profile, and components 3/4/5 all carry that code — three static ones would trip the max-1 slice on
// the *template* (only one is ever emitted at runtime). So 4/5 build their code at extraction too, via
// %factory.CodeableConcept: at template-validation time the code is an empty CodeableConcept that does
// not match the 409496000 pattern (open slice → allowed); at extraction it becomes the real code, and
// only one of 3/4/5 is emitted so the output still has exactly one transmissionRoute component.
* component[+].extension[+].url = $sdc-templateExtractContext
* component[=].extension[=].valueString = "iif(%resource.descendants().where(linkId='exposureHowUnknown').answer.value = true, {}, %resource.descendants().where(linkId='exposureHowOtherTransmission').answer.value)"
* component[=].code.extension[+].url = $sdc-templateExtractValue
* component[=].code.extension[=].valueString = "%factory.CodeableConcept(%factory.Coding('http://snomed.info/sct', '409496000', 'Mode of transmission (observable entity)'))"
* component[=].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[=].valueCodeableConcept.coding[0].extension[=].valueString = "%factory.Coding('http://snomed.info/sct', '74964007', 'Other (qualifier value)')"

// code built at extraction (same reason as component[4] above — avoid a third static 409496000).
* component[+].extension[+].url = $sdc-templateExtractContext
// Fallback: emit exposureHowSexualContactPartner only when unknown is NOT true AND exposureHowOtherTransmission has no
// value. NB the inner iif criterion must be a Boolean — a bare `…exposureHowOtherTransmission…answer.value`
// (a string) is not treated as truthy by FHIRPath, so it falls through to the else branch and the
// component fires even when other-transmission IS present. Use `.exists()` to make it a Boolean.
* component[=].extension[=].valueString = "iif(%resource.descendants().where(linkId='exposureHowUnknown').answer.value = true, {}, iif(%resource.descendants().where(linkId='exposureHowOtherTransmission').answer.value.exists(), {}, %resource.descendants().where(linkId='exposureHowSexualContactPartner').answer.value))"
* component[=].code.extension[+].url = $sdc-templateExtractValue
* component[=].code.extension[=].valueString = "%factory.CodeableConcept(%factory.Coding('http://snomed.info/sct', '409496000', 'Mode of transmission (observable entity)'))"
* component[=].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[=].valueCodeableConcept.coding[0].extension[=].valueString = "%factory.Coding('http://snomed.info/sct', '417564009', 'Sexual transmission (qualifier value)')"
