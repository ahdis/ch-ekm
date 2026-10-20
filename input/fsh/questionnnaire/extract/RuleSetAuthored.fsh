// The time of the report: the QuestionnaireResponse's `authored`, and the extraction time when the
// response has none yet. Used for Bundle.timestamp, Composition.date, DocumentReference.date /
// content.attachment.creation and the disease-specific QuestionnaireResponse's `authored`.
//
// The fallback is needed because a client may extract a response it has not saved: Smart Forms'
// "Save as Final" extracts the form's in-memory response and only sets `authored` when it saves the
// response afterwards (apps/smart-forms-app/src/api/saveQr.ts). With `%resource.authored` alone,
// timestamp and date were then dropped — the Composition failed ChEkmComposition (date 1..1), with
// it the Bundle's entry:Composition slice, and ch-ekm-patient-birthdate (compares with timestamp).
//
// iif() rather than `%resource.authored | now()`: the union would return BOTH values when `authored`
// is set.
RuleSet: RuleSetExtractAuthored(element)
* {element}.extension[+].url = $sdc-templateExtractValue
* {element}.extension[=].valueString = "iif(%resource.authored.exists(), %resource.authored, now())"
