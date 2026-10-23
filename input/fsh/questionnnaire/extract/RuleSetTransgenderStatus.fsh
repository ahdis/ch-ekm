// "trans Person" answered "Nein" -> ChEkmObservationTransgenderStatus (issue #35).
//
// The other two answers (trans man / trans woman) are the Patient's gender identity and are built on
// ExtractedPatient (ChEkmDocumentTemplate.fsh), which filters "Nein" out. So exactly one of the two
// shapes is emitted for an answered question, and neither for an unanswered one.
//
// ENTIRELY STATIC below the gate, like the Impfstatus "no" Observation: the profile fixes the code and
// the value, so there is nothing to compute. Shared by every disease whose form asks the question
// (Gonorrhoea, Mpox, Hepatitis C); invasive pneumococcal disease does not ask it and inserts none of
// this.
Instance: ExtractedTransgenderStatus
InstanceOf: ChEkmObservationTransgenderStatus
Usage: #inline
* status = #final
* code = $sct#1384187000 "Identifies as transgender (finding)"
* subject.reference = "Patient/ExtractedPatient"
* valueCodeableConcept = $sct#373067005 "No (qualifier value)"

// The Bundle entry. CONDITIONAL, so it has to come after every static entry (see "A CONDITIONAL
// Bundle entry" in forms-summary §8); with the identity value on fullUrl for the reason given in
// ChEkmDocumentMpoxTemplate.fsh.
RuleSet: RuleSetTransgenderStatusEntry
* entry[+].extension[0].url = $sdc-templateExtractContext
* entry[=].extension[0].valueString = "%resource.descendants().where(linkId='genderIdentity').answer.value.ofType(Coding).where(system='http://snomed.info/sct' and code='373067005')"
* entry[=].fullUrl = "http://test.fhir.ch/r4/Observation/ExtractedTransgenderStatus"
* entry[=].fullUrl.extension[0].url = $sdc-templateExtractValue
* entry[=].fullUrl.extension[0].valueString = "'http://test.fhir.ch/r4/Observation/ExtractedTransgenderStatus'"
* entry[=].resource = ExtractedTransgenderStatus

// The reference from Composition.section[social-history], with the same test as the entry, so it can
// never outlive the resource it points at. It is entry[1], right after the section's one static
// exposure entry: the LAST entry of that section, since a computed element must not precede a static
// one. Explicit indices because the templates declare their sections with explicit indices too.
RuleSet: RuleSetTransgenderStatusSectionEntry(sectionIndex)
* section[{sectionIndex}].entry[1].reference = "Observation/ExtractedTransgenderStatus"
* section[{sectionIndex}].entry[1].extension[0].url = $sdc-templateExtractValue
* section[{sectionIndex}].entry[1].extension[0].valueString = "%resource.descendants().where(linkId='genderIdentity').answer.value.ofType(Coding).where(system='http://snomed.info/sct' and code='373067005').first().select(%factory.withProperty(%factory.create(Reference), 'reference', 'Observation/ExtractedTransgenderStatus'))"
