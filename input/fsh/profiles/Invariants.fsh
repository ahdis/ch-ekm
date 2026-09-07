
Invariant: name-initials
Description: "a name with initials"
Severity: #error
Expression: "given.exists() and given.first().exists() and (''+given.first()).length() = 1 and family.exists() and (''+family).length() = 1"

Invariant: ch-ekm-hiv-check
Description: "invalid hiv code: 1) either start with a letter or the number 0, 2) be a maximum of 2 characters long, 3) have a number in the last place 4) if it starts with 0, it must either consist only of 0 or be followed by a 1."
Severity: #error
Expression: "value.matches('^[A-Za-z][0-9]$|^0$|^01$')"

Invariant: ch-ekm-dateTime
Description: "At least the format YYYY-MM-DD is required."
Severity: #error
Expression: "$this.toString().length() >= 10"


// The Hepatitis C "Krankheitsverlauf" (akut / chronisch / Zirrhose / Hepatokarzinom / General
// wellbeing) is the one question of that form with no resource target: it is not extracted, it stays
// in the QuestionnaireResponse the document carries. This invariant is what makes the document
// self-sufficient — without it, a conforming document could omit the answer entirely.
//
// `descendants()` rather than a fixed path, because the question sits three levels deep in the
// ASSEMBLED form (hepatitisc-form > manifestation-group > course-of-disease) and a re-ordering of
// the assembled sections must not invalidate documents already sent. Starting from the resource
// rather than from `item` so that a top-level `course-of-disease` would match too.
//
// GUARDED ON `questionnaire.hasValue()`, and that guard is not cosmetic: the SDC $extract template
// (ExtractedQuestionnaireResponseHepatitisC) is itself a QuestionnaireResponse that has to conform
// to this profile, and it can name neither a questionnaire nor an answer — a template that named
// one would have its placeholder linkId validated against that questionnaire's items, and any
// placeholder it could use is either absent from the form (12 errors) or a que-2 duplicate of it
// (5 errors). Every REAL response names the form it answers, so the guard is open for all of them.
//
// `hasValue()`, NOT `exists()`. The template's `questionnaire` is a value-less carrier — the JSON
// has `_questionnaire` with the extraction extension and no `questionnaire` — and that element node
// DOES exist as far as FHIRPath is concerned, so `exists()` opens the guard and the template fails
// its own invariant. It fails silently, too: the profile is reached through the `$this.resolve()`
// slice discriminator on Composition.section[diagnosis].entry, so the only symptom is the diagnosis
// entry no longer matching its slice, which takes the Composition out of conformance and shows up
// as "Slice 'Bundle.entry:Composition': a matching slice is required, but not found" on the
// template Bundle. `hasValue()` asks the question actually meant: is there a canonical here.
Invariant: ch-ekm-qr-hepatitisc-course
Description: "A response that names the questionnaire it answers must answer the 'course-of-disease' question (Krankheitsverlauf) of the Hepatitis C form."
Severity: #error
Expression: "questionnaire.hasValue() implies descendants().where(linkId = 'course-of-disease').answer.value.exists()"
