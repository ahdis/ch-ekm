// "Labor" (the analysing laboratory) — the two Bundle entries and the Composition section.
//
// The extraction counterpart of RuleSetQrLaboratory: that rule set puts the nine questions into the
// "Diagnose und Manifestation" section of a root, these two put the resources they extract to into
// that root's Bundle template. The instances themselves (ExtractedLabOrganization,
// ExtractedLabServiceRequest) are shared and live in extract/ChEkmDocumentTemplate.fsh next to the
// treating physician's, because nothing about them is disease-specific.
//
// UNGATED, unlike the Encounter / cause-of-death / Impfstatus entries. `labName` is a REQUIRED form
// item, so a completed QuestionnaireResponse always answers the laboratory, and the entries can be
// plain static ones — which is what allows the Organization's many optional fields to be
// context-gated individually (see the note on ExtractedLabOrganization). Being ungated they must be
// inserted BEFORE any conditional entry: a static entry placed after a gated one is corrupted as
// soon as that gate does not fire.

RuleSet: RuleSetLaboratoryEntries
* entry[+].fullUrl = "http://test.fhir.ch/r4/ServiceRequest/ExtractedLabServiceRequest"
* entry[=].resource = ExtractedLabServiceRequest
* entry[+].fullUrl = "http://test.fhir.ch/r4/Organization/ExtractedLabOrganization"
* entry[=].resource = ExtractedLabOrganization

// Composition.section[laboratory] — LOINC 30954-2, whose mandatory `entry[lab-order]` slice is the
// ChEkmServiceRequest above (that is why a laboratory cannot be reported as a bare Organization).
//
// `section[+]` appends after the sections the caller has already declared, so insert this straight
// after the static sections and BEFORE the gated ones (cause of death, Impfstatus) — those must
// stay last, and an ungated section appended after them would be shifted when their gate misses.
RuleSet: RuleSetLaboratorySection
* section[+].title = "Laboratory section"
* section[=].code = $loinc#30954-2
* section[=].entry[0].reference = "ServiceRequest/ExtractedLabServiceRequest"


// The SAMPLE (ChEkmSpecimen) — CONDITIONAL entries, unlike the two above, so they are inserted with
// the rest of a template's conditional entries and must stay after every static one.
//
// TWO mutually exclusive instances, at most one emitted; see ExtractedLabSpecimenDated in
// extract/ChEkmDocumentTemplate.fsh for why `ch-ekm-dateTime` forces the split. The gates:
//   Dated    the Entnahmedatum was answered (Material may or may not have been)
//   Undated  the Entnahmedatum was NOT answered but Material was
// Together they cover every answered state exactly once. A root that does not assemble
// ChEkmQuestionnaireLaboratorySpecimen has neither linkId, both gates are empty, no Specimen is
// emitted — and ExtractedLabServiceRequest.specimen carries the same test, so it disappears too.
//
// IDENTITY VALUE on fullUrl, load-bearing as always for a gated entry: the engine seeds the entry
// with a shallow spread of its FIRST value, so a value whose path starts at `resource.` would
// replace the whole static resource. See ChEkmDocumentMpoxTemplate.
RuleSet: RuleSetLaboratorySpecimenEntry
* entry[+].extension[0].url = $sdc-templateExtractContext
* entry[=].extension[0].valueString = "iif(%resource.descendants().where(linkId='specimenCollectionDate').answer.value.exists(), true, {})"
* entry[=].fullUrl = "http://test.fhir.ch/r4/Specimen/ExtractedLabSpecimenDated"
* entry[=].fullUrl.extension[0].url = $sdc-templateExtractValue
* entry[=].fullUrl.extension[0].valueString = "'http://test.fhir.ch/r4/Specimen/ExtractedLabSpecimenDated'"
* entry[=].resource = ExtractedLabSpecimenDated
* entry[+].extension[0].url = $sdc-templateExtractContext
* entry[=].extension[0].valueString = "iif(%resource.descendants().where(linkId='specimenCollectionDate').answer.value.exists().not() and %resource.descendants().where(linkId='specimenType').answer.value.exists(), true, {})"
* entry[=].fullUrl = "http://test.fhir.ch/r4/Specimen/ExtractedLabSpecimenUndated"
* entry[=].fullUrl.extension[0].url = $sdc-templateExtractValue
* entry[=].fullUrl.extension[0].valueString = "'http://test.fhir.ch/r4/Specimen/ExtractedLabSpecimenUndated'"
* entry[=].resource = ExtractedLabSpecimenUndated
