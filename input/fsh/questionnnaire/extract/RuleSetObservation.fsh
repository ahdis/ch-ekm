RuleSet: RuleSetExposureWhere
// Exposure "Wo" (https://github.com/ahdis/ch-ekm/issues/26) -> extension[exposureAddress]:
//   exposureWhereCountry (Coding)              = an ISO 3166 country -> valueAddress.country + coding
//   exposureWhereCountry (Coding)              = sct#261665006 -> valueAddress._country DAR
//   exposureWherePreciseLocation (string)      = free text      -> valueAddress.city
//   exposureWherePreciseLocation (Coding)      = sct#261665006 -> valueAddress._city DAR
//
// TWO items, and each carries its OWN "unknown" answer, expressed as a data-absent-reason on the
// element it belongs to - so "country CH, precise location unknown" and "country unknown, precise
// location Zürich" are both reportable. There is no third item and no Address-level DAR.
//
// The precise-location item is an `open-choice` (a dropdown that also takes free text), so its
// answer arrives EITHER as a string (what the user typed) OR as the Coding of the single offered
// option (ChEkmUnknown = sct#261665006). Splitting on the answer type - `ofType(string)` vs
// `ofType(Coding)` - is exactly why that option has to be a Coding and not a plain string: typed
// text lands in `answer.valueString`, so a string option would be indistinguishable from someone
// typing the word "Unbekannt".
//
// There is only ONE country item (the former form-only CH/LI check-box `exposureWhereChLi` is gone,
// Switzerland/Liechtenstein are just the first two entries of the answer value set), so the country
// code is always taken from the answered Coding - no inland special case.
//
// The value set (ChEkmCountryCodesInclUnknown) also offers sct#261665006 "Unknown", because the
// country is a mandatory form field. That code is NOT a country: writing it to `Address.country`
// (an ISO 3166 string) would be wrong. The unknown answer is therefore filtered out of %ctry by
// `where(system='urn:iso:std:iso:3166')` and instead marks the COUNTRY as absent -
// `%factory.string({}, <data-absent-reason>)`, i.e. an EMPTY value carrying the extension. Raw
// FHIRPath yields `{country: null, _country: {extension: [...]}}`; `country` does not repeat, so the
// null is correctly dropped on serialisation and the emitted Address carries `_country` only. The
// precise location uses the identical shape on `city` / `_city`.
//
// The WHOLE extension is built at extraction time by one templateExtractValue via the FHIR Type
// Factory on the ch-ekm SdcTemplateExtractExtension carrier (idiom: forms-summary §8). Why not
// annotate a pre-declared `extension[exposureAddress]` field by field:
//   * the extension cannot be context-gated as a whole - the gate would have to be a
//     templateExtractContext SUB-extension of it, which is illegal next to a value[x] (ext-1) and
//     forbidden by the extension definition. Field-level gating alone leaves an empty
//     `{url: ch-ekm-ext-exposure-address}` shell (no value -> invalid) whenever the whole optional
//     "Wo" block is left blank - exactly the caveat documented for patient-citizenship.
//   * the country coding lives on the `_country` primitive-extension slot, which a value directive
//     on `country` cannot reach (it would set the string itself).
// %factory.Address(line, city, …) + %factory.withProperty(address, 'country', %factory.string(code,
// %factory.Extension(...))) produce the complete Address - including `_country.extension` - in one
// result, so the engine places it whole (no deepmerge-concat, no shallow overwrite) and the carrier
// url is overwritten by the built extension's url.
//
// ONE carrier for all cases (the exposure-address extension is 0..1, so two carriers could not both
// fire). Resulting branches, combined freely since country and precise location are independent:
//   country answered   -> `country` = the ISO code (+ the Coding on `_country`)
//   Land = Unbekannt   -> country absent (`_country` DAR)
//   Ort typed          -> `city` = the free text
//   Ort = Unbekannt    -> city absent (`_city` DAR)
//   nothing answered   -> no extension at all
//
// The context yields a single `true` sentinel (a bare collection of the answers could hold several
// values, which would emit the extension once per value - see the evidence-per-manifestation
// idiom); the value expression reads the answers absolutely (%resource), so the context only gates.
* extension[+].url = $sdc-templateExtractExtension
* extension[=].extension[+].url = $sdc-templateExtractContext
* extension[=].extension[=].valueString = "iif(%resource.descendants().where(linkId='exposureWhereCountry').answer.value.exists() or %resource.descendants().where(linkId='exposureWherePreciseLocation').answer.value.exists(), true, {})"
// Four chained `defineVariable`s (fhirpath.js supports them, and they chain - the last one even
// binds a value built by %factory), so every answer is read exactly once:
//   %ctry        - the answered country, restricted to real ISO 3166 codes: sct#261665006 "Unknown"
//                  is an answer of the same item but must not become an Address.country string.
//   %ctryUnknown - that same item answered with sct#261665006 "Unknown".
//   %loc         - the precise location as TYPED (`ofType(string)` - the open-choice item's other
//                  possible answer is the Coding handled by %locUnknown).
//   %base        - the Address with the city part settled, shared by all three country branches.
// `%resource.…select(…)` fixes the focus to exactly one node, so the result is always a single
// Extension no matter what the engine passes in as the focus.
//
// The city part has to branch rather than always going through `withProperty`: `withProperty` copies
// the value's `_data`, which `ResourceNode` forces to `{}` even when there are no extensions, so the
// no-extension case would emit a stray, invalid `"_city": {}`. `%factory.Address({}, %loc)` sets
// `city` directly (and omits it when %loc is empty), so only the data-absent branch needs
// `withProperty`. The typed text wins if a response somehow carries both answers.
//
// The country part then wraps %base: answered -> `country` = the code plus the same country as a
// Coding via iso21090-codedString on the `_country` element (a slot no value directive on `country`
// could reach); "Unbekannt" -> `%factory.string({}, …)` leaves the value empty and puts the
// data-absent-reason on `_country`; unanswered -> %base unchanged.
* extension[=].extension[+].url = $sdc-templateExtractValue
* extension[=].extension[=].valueString = "%resource.defineVariable('ctry', %resource.descendants().where(linkId='exposureWhereCountry').answer.value.ofType(Coding).where(system='urn:iso:std:iso:3166').first()).defineVariable('ctryUnknown', %resource.descendants().where(linkId='exposureWhereCountry').answer.value.ofType(Coding).where(system='http://snomed.info/sct' and code='261665006').exists()).defineVariable('loc', %resource.descendants().where(linkId='exposureWherePreciseLocation').answer.value.ofType(string).first()).defineVariable('base', iif(%loc.empty() and %resource.descendants().where(linkId='exposureWherePreciseLocation').answer.value.ofType(Coding).where(system='http://snomed.info/sct' and code='261665006').exists(), %factory.withProperty(%factory.Address({}), 'city', %factory.string({}, %factory.Extension('http://hl7.org/fhir/StructureDefinition/data-absent-reason', %factory.code('asked-unknown')))), %factory.Address({}, %loc))).select(%factory.Extension('http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-ext-exposure-address', iif(%ctry.exists(), %factory.withProperty(%base, 'country', %factory.string(%ctry.code, %factory.Extension('http://hl7.org/fhir/StructureDefinition/iso21090-codedString', %ctry))), iif(%ctryUnknown, %factory.withProperty(%base, 'country', %factory.string({}, %factory.Extension('http://hl7.org/fhir/StructureDefinition/data-absent-reason', %factory.code('asked-unknown')))), %base))))"

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
