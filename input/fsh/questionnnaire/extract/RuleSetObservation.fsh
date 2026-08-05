RuleSet: RuleSetComponentExposure
// Sexualkontakt mit infizierter Person (Geschlecht)
// PLACEHOLDER DEFAULT valueCodeableConcept — replaced/dropped at extraction. These sliced components
// have a REQUIRED value binding, so a coding is needed for the template to validate as a standalone
// example; the templateExtractValue overwrites coding[0] at extraction, and when the answer is absent
// the whole context-gated component is dropped. (Same idea as the gender/timestamp defaults, §8.)
* component[+].code = ChEkmExposureComponent#sexual-contact-partner
* component[=].extension[+].url = $sdc-templateExtractContext
* component[=].extension[=].valueString = "%resource.descendants().where(linkId='sexualContactPartner').answer.value"
* component[=].valueCodeableConcept.coding[0] = $administrative-gender#unknown "Unknown"
* component[=].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[=].valueCodeableConcept.coding[0].extension[=].valueString = "ofType(Coding)"
// Art der Beziehung
* component[+].code = $sct#228465009 "Sexual relationship details (observable entity)"
* component[=].extension[+].url = $sdc-templateExtractContext
* component[=].extension[=].valueString = "%resource.descendants().where(linkId='relationshipType').answer.value"
* component[=].valueCodeableConcept.coding[0] = ChEkmRelationshipType#steady-partner "Steady partner"
* component[=].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[=].valueCodeableConcept.coding[0].extension[=].valueString = "ofType(Coding)"
// Anderer Übertragungsweg (Freitext) -> component[2] (no code, just a text value). This is a free-text field, so no context gating or coding idiom — just write the string directly, and if it's blank the component is omitted.
* component[+].code = $sct#74964007  "Other (qualifier value)"
* component[=].extension[+].url = $sdc-templateExtractContext
* component[=].extension[=].valueString = "%resource.descendants().where(linkId='otherTransmission').answer.value"
* component[=].valueString.extension[+].url = $sdc-templateExtractValue
* component[=].valueString.extension[=].valueString = "$this"

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
* component[+].code = $sct#409496000  "Mode of transmission (observable entity)"
* component[=].extension[+].url = $sdc-templateExtractContext
* component[=].extension[=].valueString = "%resource.descendants().where(linkId='unknown').answer.value.where($this = true)"
* component[=].valueCodeableConcept.coding[0] = $sct#261665006 "Unknown (qualifier value)"
* component[=].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[=].valueCodeableConcept.coding[0].extension[=].valueString = "%factory.Coding('http://snomed.info/sct', '261665006', 'Unknown (qualifier value)')"

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
* component[+].extension[+].url = $sdc-templateExtractContext
* component[=].extension[=].valueString = "iif(%resource.descendants().where(linkId='unknown').answer.value = true, {}, %resource.descendants().where(linkId='otherTransmission').answer.value)"
* component[=].code.extension[+].url = $sdc-templateExtractValue
* component[=].code.extension[=].valueString = "%factory.CodeableConcept(%factory.Coding('http://snomed.info/sct', '409496000', 'Mode of transmission (observable entity)'))"
* component[=].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[=].valueCodeableConcept.coding[0].extension[=].valueString = "%factory.Coding('http://snomed.info/sct', '74964007', 'Other (qualifier value)')"

// code built at extraction (same reason as component[4] above — avoid a third static 409496000).
* component[+].extension[+].url = $sdc-templateExtractContext
// Fallback: emit sexualContactPartner only when unknown is NOT true AND otherTransmission has no
// value. NB the inner iif criterion must be a Boolean — a bare `…otherTransmission…answer.value`
// (a string) is not treated as truthy by FHIRPath, so it falls through to the else branch and the
// component fires even when other-transmission IS present. Use `.exists()` to make it a Boolean.
* component[=].extension[=].valueString = "iif(%resource.descendants().where(linkId='unknown').answer.value = true, {}, iif(%resource.descendants().where(linkId='otherTransmission').answer.value.exists(), {}, %resource.descendants().where(linkId='sexualContactPartner').answer.value))"
* component[=].code.extension[+].url = $sdc-templateExtractValue
* component[=].code.extension[=].valueString = "%factory.CodeableConcept(%factory.Coding('http://snomed.info/sct', '409496000', 'Mode of transmission (observable entity)'))"
* component[=].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[=].valueCodeableConcept.coding[0].extension[=].valueString = "%factory.Coding('http://snomed.info/sct', '417564009', 'Sexual transmission (qualifier value)')"
