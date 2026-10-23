// Street, phone and e-mail of the affected person (ChEkmQuestionnairePersonContact) on the extracted
// Patient — FULL-NAME forms only (Mpox, Hepatitis C).
//
// NOT part of the shared ExtractedPatient: every root's template Bundle embeds that one instance,
// and the initials forms' Composition requires its subject to be a ChEkmPatientInitials, which
// forbids `address.line` and `telecom` outright. A gated element is still a STATIC skeleton in the
// template (`telecom[0].system`, a value-less `line[0]` carrying the extract extension), so declaring
// them on ExtractedPatient made the Gonorrhoea and pneumococcal templates fail their Composition
// slice. Instead a full-name template adds them to its OWN inline Patient entry: insert this rule set
// directly after `* entry[=].resource = ExtractedPatient`.
//
// Same idioms as the treating physician (forms-summary §8):
//   * `line` is an ARRAY primitive -> templateExtractContext on address[0] scoped to the `person`
//     group + a relative `item.where(...)` path (a standalone value path mis-targets `_line`). The
//     absolute %resource paths of ExtractedPatient's other address fields resolve unchanged inside it.
//   * phone / e-mail -> each WHOLE telecom element gated on its answer: blank -> no entry at all.
RuleSet: RuleSetExtractedPatientContact
* entry[=].resource.address[0].extension[+].url = $sdc-templateExtractContext
* entry[=].resource.address[0].extension[=].valueString = "%resource.descendants().where(linkId='person')"
* entry[=].resource.address[0].line[0].extension[+].url = $sdc-templateExtractValue
* entry[=].resource.address[0].line[0].extension[=].valueString = "item.where(linkId='streetLine').answer.value"
* entry[=].resource.telecom[0].extension[+].url = $sdc-templateExtractContext
* entry[=].resource.telecom[0].extension[=].valueString = "%resource.descendants().where(linkId='phone').answer.value"
* entry[=].resource.telecom[0].system = #phone
* entry[=].resource.telecom[0].value.extension[+].url = $sdc-templateExtractValue
* entry[=].resource.telecom[0].value.extension[=].valueString = "$this"
* entry[=].resource.telecom[1].extension[+].url = $sdc-templateExtractContext
* entry[=].resource.telecom[1].extension[=].valueString = "%resource.descendants().where(linkId='email').answer.value"
* entry[=].resource.telecom[1].system = #email
* entry[=].resource.telecom[1].value.extension[+].url = $sdc-templateExtractValue
* entry[=].resource.telecom[1].value.extension[=].valueString = "$this"
