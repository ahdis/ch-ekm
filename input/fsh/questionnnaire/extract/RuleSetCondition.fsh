RuleSet: RuleSetOnsetDateManifestationBeginUnknown
// Manifestationsbeginn:
//  - known    -> onsetDateTime = the answered date.
//  - unknown   -> no value; onsetDateTime.extension[data-absent-reason] = asked-unknown.
//
// extension[0] is the data-absent-reason extension. It CANNOT be pre-declared with url =
// data-absent-reason in the template: a to-be-computed valueCode leaves the extension with no
// value at authoring time (fails ext-1) and the templateExtractContext sub-extension violates the
// data-absent-reason profile (0 sub-extensions allowed). Instead the WHOLE extension is built at
// extraction time by a single templateExtractValue via the FHIR Type Factory
// %factory.Extension(url, value) — the same idiom as %factory.Coding above (see forms-summary §8).
// %factory.code(...) makes the value a `code`, so the result is {url: data-absent-reason,
// valueCode: 'asked-unknown'}. The factory result deep-merges onto the carrier, overwriting the
// carrier url, so the extracted extension is a clean, valid data-absent-reason.
// The carrier is the ch-ekm SdcTemplateExtractExtension (defined so the template validates as FHIR
// — an engine value directive on onsetDateTime.extension would set the primitive value, not a
// sibling extension, so a carrier is required to reach _onsetDateTime.extension).
// The templateExtractContext gates emission: empty (element excluded) unless the "Unbekannt" box
// (a choice item answered with sct#261665006, issue #41) is ticked AND no date is answered. The
// form never lets both through (the box is disabled once a date is entered), but a renderer that
// keeps a disabled item's answer must not turn a reported date into "unknown": the date wins.
// extension[1] is the onset value: the answered date, or nothing (onsetDateTime omitted).
//
// ORDER MATTERS: the context-gated extension MUST come before the plain onset value extension.
// The reference engine's array index bookkeeping mis-handles the reverse order (the gated element
// is not deleted and the valueCode splits into a stray entry). See forms-summary.md §8.
* onsetDateTime.extension[0].url = $sdc-templateExtractExtension
* onsetDateTime.extension[0].extension[0].url = $sdc-templateExtractContext
* onsetDateTime.extension[0].extension[0].valueString = "%resource.descendants().where(linkId='manifestationBeginUnknown').answer.value.ofType(Coding).where(code = '261665006' and %resource.descendants().where(linkId='manifestationBeginDate').answer.exists().not())"
* onsetDateTime.extension[0].extension[1].url = $sdc-templateExtractValue
* onsetDateTime.extension[0].extension[1].valueString = "%factory.Extension('http://hl7.org/fhir/StructureDefinition/data-absent-reason', %factory.code('asked-unknown'))"
* onsetDateTime.extension[1].url = $sdc-templateExtractValue
* onsetDateTime.extension[1].valueString = "%resource.descendants().where(linkId='manifestationBeginDate').answer.value.first()"

RuleSet: RuleSetEvidenceManifestation
// Manifestation -> one `evidence` entry PER answered manifestation (identity pass-through of the
// answered Coding).
// REPEATING: the `manifestation` item is `repeats = true` (check-box), so the context expression
// returns 0..n Codings. The extract engine repeats the INDEXED element that carries the context,
// once per context result. The context therefore sits on `evidence[0]` (not on `code[0]`): n answers
// produce evidence[0]..evidence[n-1], each with a single code[0] whose coding[0] is written by the
// `ofType(Coding)` value below. Putting the context one level down on `code[0]` instead yields the
// other shape — ONE evidence with code[0]..code[n-1] — which is not what we want here.
// Unanswered -> empty context -> the whole evidence element is dropped.
* evidence[0].extension[+].url = $sdc-templateExtractContext
* evidence[0].extension[=].valueString = "%resource.descendants().where(linkId='manifestation').answer.value"
* evidence[0].code[0].coding[0].extension[+].url = $sdc-templateExtractValue
* evidence[0].code[0].coding[0].extension[=].valueString = "ofType(Coding)"
// "Andere" (sct#74964007) -> the free text of the `manifestationOther` item (RuleSetQrManifestationOther,
// issue #40) becomes code.text of THAT evidence entry only: the expression runs once per answered
// Coding (the context above) and yields nothing for every other code. A form without the item, or an
// "Andere" left without text, gives an evidence coded "Other" with no text.
* evidence[0].code[0].text.extension[+].url = $sdc-templateExtractValue
* evidence[0].code[0].text.extension[=].valueString = "iif(ofType(Coding).where(system = 'http://snomed.info/sct' and code = '74964007').exists(), %resource.descendants().where(linkId='manifestationOther').answer.value.first(), {})"
