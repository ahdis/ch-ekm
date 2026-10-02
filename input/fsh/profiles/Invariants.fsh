
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

// Taken over from CH ELM (ch-elm-patient-birthdate, ../ch-elm input/fsh/invariants.fsh), same expression.
// It sits on the DOCUMENT, not on the Patient, because it compares against Bundle.timestamp, which a
// Patient cannot see. The three branches compare at the precision the birth date was given in (year,
// year-month, full date). A valueless birthDate (data-absent-reason, or an $extract template that only
// carries the templateExtractValue directive) is skipped by `hasValue()`.
Invariant: ch-ekm-patient-birthdate
Description: "If a Patient entry has a birthDate set, it must be >= 1900-01-01 and before the Bundle's creation date (timestamp)."
Severity: #error
Expression: "entry.resource.ofType(Patient).where(birthDate.exists() and birthDate.hasValue()).all(birthDate >= @1900-01-01 and ((birthDate.toString().length()=4 and birthDate <= %resource.timestamp.toString().substring(0,4).toDateTime()) or (birthDate.toString().length()=7 and birthDate <= %resource.timestamp.toString().substring(0,7).toDateTime()) or (birthDate.toString().length()=10 and birthDate <= %resource.timestamp.toString().substring(0,10).toDateTime())))"


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

// ChEkmExtractTransaction: the DocumentReference must point at the document stored in the SAME
// transaction — by location (attachment.url = the document entry's fullUrl, which the server rewrites
// to the document's new id) and by identity (masterIdentifier = Bundle.identifier, which survives).
Invariant: ch-ekm-docref-document
Description: "The DocumentReference's content.attachment.url is the document entry's fullUrl and its masterIdentifier is the document Bundle's identifier."
Severity: #error
Expression: "entry.where(resource is DocumentReference).resource.content.attachment.url = entry.where(resource is Bundle).fullUrl and entry.where(resource is DocumentReference).resource.masterIdentifier.value = entry.where(resource is Bundle).resource.identifier.value"

// ChEkmDocumentReference: subject and author point at resources on the server the report is stored on,
// which a validator cannot resolve — so `only Reference(...)` alone is never checked (verified: a
// PractitionerRole/... author passes it). These check the literal reference instead.
Invariant: ch-ekm-docref-subject-patient
Description: "The subject is a literal reference to a Patient."
Severity: #error
Expression: "reference.matches('(^|/)Patient/[^/]+(/_history/[^/]+)?$')"

Invariant: ch-ekm-docref-author-practitioner
Description: "The author is a literal reference to a Practitioner (not the PractitionerRole of the SMART user)."
Severity: #error
Expression: "reference.matches('(^|/)Practitioner/[^/]+(/_history/[^/]+)?$')"
