// ---------------------------------------------------------------------------
// Condition (ChEkmCondition) — fixed disease code; manifestation -> evidence.code;
// manifestation begin date -> onset (omitted when "unknown" is ticked)
// ---------------------------------------------------------------------------
Instance: ExtractedCondition
InstanceOf: ChEkmConditionMpox
Usage: #inline
* code = $sct#359814004 "Mpox"
* category = $condition-category#encounter-diagnosis
* subject.reference = "Patient/ExtractedPatient"
* recorder.reference = "PractitionerRole/ExtractedTreatingPractitionerRole"
// Hospitalisation: reference the Encounter, gated on there being one (see RuleSetEncounterReference)
* insert RuleSetEncounterReference(encounter, ExtractedEncounter)
* insert RuleSetOnsetDateManifestationBeginUnknown
* insert RuleSetEvidenceManifestation
* evidence[0].code[0].coding[0] = $sct#95324001 "Skin lesion (disorder)"

// ---------------------------------------------------------------------------
// Exposure (ChEkmExposureMpox) — fixed component codes; sex & relationship from `transmission`
// ---------------------------------------------------------------------------
Instance: ExtractedExposure
InstanceOf: ChEkmExposureMpox
Usage: #inline
* status = #final
* category = $v3-ActClass#AEXPOS "acquisition exposure"
* code = $v3-ParticipationType#EXPAGNT "Exposure Agent"
* subject.reference = "Patient/ExtractedPatient"
* insert RuleSetComponentExposure
// Wann — inserted AFTER the transmission components so those keep their array indices
// (the extract engine's context bookkeeping is index-sensitive, see RuleSetComponentExposure).
* insert RuleSetEffectiveExposureWhen
// Wo — only touches the `extension` array (two mutually exclusive carriers), so it is independent
// of the component indices above.
* insert RuleSetExposureWhere

// ---------------------------------------------------------------------------
// Encounter (ChEkmEncounter) — the hospitalisation. Emitted only when the Hospitalisation question
// was answered "yes" or "unknown"; the Bundle entry below carries that gate.
// ---------------------------------------------------------------------------
Instance: ExtractedEncounter
InstanceOf: ChEkmEncounter
Usage: #inline
* insert RuleSetEncounterHospitalisation(ExtractedCondition)

// ---------------------------------------------------------------------------
// Cause of death (ChEkmObservationCauseOfDeath) — the "Zustand" half of the Verlauf section.
// Emitted only when the person died; the Bundle entry below carries that gate. The death itself and
// its date are NOT here, they are on ExtractedPatient.deceasedDateTime (RuleSetPatientDeceased).
// ---------------------------------------------------------------------------
// ONE instance for all three answers: since "unknown" is a value (sct#261665006) rather than a
// dataAbsentReason (issue #28), the template no longer trips obs-6 and no longer needs a second,
// mutually exclusive instance. See RuleSetCauseOfDeath.fsh.
Instance: ExtractedCauseOfDeath
InstanceOf: ChEkmObservationCauseOfDeath
Usage: #inline
* insert RuleSetObservationCauseOfDeath(359814004, Mpox, ExtractedCondition)

// ---------------------------------------------------------------------------
// "Impfstatus" / vaccination status (issue #29) - ChEkmImmunizationMpox for "yes",
// ChEkmObservationVaccinationStatusMpox for "no" and "unknown".
//
// SIX MUTUALLY EXCLUSIVE INSTANCES PER FORM ROW, of which exactly one is emitted; a row that was
// not answered emits none. Four of them are Immunizations, because `occurrence[x]` and
// `protocolApplied.doseNumber[x]` are both 1..1 and have to be an answered value on some branches
// and a data-absent-reason on others, which one template instance cannot express. The other two are
// Observations: only "yes" describes a vaccination, so "no" and "unknown" are answers in
// `value[x]` instead. See RuleSetImmunization.fsh for the full reasoning and for which variant
// covers which answer.
// ---------------------------------------------------------------------------

Instance: ExtractedImmunizationSmallpoxDatedDosed
InstanceOf: ChEkmImmunizationMpox
Usage: #inline
* insert RuleSetImmunizationDatedDosed(Smallpox, 67924001, "Smallpox", 1290624003, "Variola virus antigen-containing vaccine product", Variola virus antigen-containing vaccine product)

Instance: ExtractedImmunizationSmallpoxDatedNoDose
InstanceOf: ChEkmImmunizationMpox
Usage: #inline
* insert RuleSetImmunizationDatedNoDose(Smallpox, 67924001, "Smallpox", 1290624003, "Variola virus antigen-containing vaccine product", Variola virus antigen-containing vaccine product)

Instance: ExtractedImmunizationSmallpoxUndatedDosed
InstanceOf: ChEkmImmunizationMpox
Usage: #inline
* insert RuleSetImmunizationUndatedDosed(Smallpox, 67924001, "Smallpox", 1290624003, "Variola virus antigen-containing vaccine product", Variola virus antigen-containing vaccine product)

Instance: ExtractedImmunizationSmallpoxUndatedNoDose
InstanceOf: ChEkmImmunizationMpox
Usage: #inline
* insert RuleSetImmunizationUndatedNoDose(Smallpox, 67924001, "Smallpox", 1290624003, "Variola virus antigen-containing vaccine product", Variola virus antigen-containing vaccine product)

Instance: ExtractedVaccinationStatusSmallpoxNo
InstanceOf: ChEkmObservationVaccinationStatusMpox
Usage: #inline
* insert RuleSetVaccinationStatusNo(67924001, "Smallpox", 1290624003, "Variola virus antigen-containing vaccine product")

Instance: ExtractedVaccinationStatusSmallpoxUnknown
InstanceOf: ChEkmObservationVaccinationStatusMpox
Usage: #inline
* insert RuleSetVaccinationStatusUnknown(67924001, "Smallpox", 1290624003, "Variola virus antigen-containing vaccine product")

Instance: ExtractedImmunizationMpoxDatedDosed
InstanceOf: ChEkmImmunizationMpox
Usage: #inline
* insert RuleSetImmunizationDatedDosed(Mpox, 359814004, "Mpox", 1293025000, "Modified Vaccinia virus Ankara antigen only vaccine product", Modified Vaccinia virus Ankara antigen only vaccine product)

Instance: ExtractedImmunizationMpoxDatedNoDose
InstanceOf: ChEkmImmunizationMpox
Usage: #inline
* insert RuleSetImmunizationDatedNoDose(Mpox, 359814004, "Mpox", 1293025000, "Modified Vaccinia virus Ankara antigen only vaccine product", Modified Vaccinia virus Ankara antigen only vaccine product)

Instance: ExtractedImmunizationMpoxUndatedDosed
InstanceOf: ChEkmImmunizationMpox
Usage: #inline
* insert RuleSetImmunizationUndatedDosed(Mpox, 359814004, "Mpox", 1293025000, "Modified Vaccinia virus Ankara antigen only vaccine product", Modified Vaccinia virus Ankara antigen only vaccine product)

Instance: ExtractedImmunizationMpoxUndatedNoDose
InstanceOf: ChEkmImmunizationMpox
Usage: #inline
* insert RuleSetImmunizationUndatedNoDose(Mpox, 359814004, "Mpox", 1293025000, "Modified Vaccinia virus Ankara antigen only vaccine product", Modified Vaccinia virus Ankara antigen only vaccine product)

Instance: ExtractedVaccinationStatusMpoxNo
InstanceOf: ChEkmObservationVaccinationStatusMpox
Usage: #inline
* insert RuleSetVaccinationStatusNo(359814004, "Mpox", 1293025000, "Modified Vaccinia virus Ankara antigen only vaccine product")

Instance: ExtractedVaccinationStatusMpoxUnknown
InstanceOf: ChEkmObservationVaccinationStatusMpox
Usage: #inline
* insert RuleSetVaccinationStatusUnknown(359814004, "Mpox", 1293025000, "Modified Vaccinia virus Ankara antigen only vaccine product")

// ---------------------------------------------------------------------------
// Composition (ChEkmCompositionMpox) — static structure, references the entries above,
// author = Broker, date taken from QR.authored
// ---------------------------------------------------------------------------
Instance: ExtractedCompositionMpox
InstanceOf: ChEkmCompositionMpox
Usage: #inline
* status = #final
* type = $sct#722143004 "Infectious disease diagnostic study note"
* category = $sct#423876004 "Clinical report"
* subject.reference = "Patient/ExtractedPatient"
// Hospitalisation: the one place the Encounter is referenced from the Composition — there is no
// section[hospitalization] any more (see ChEkmComposition / ChEkmEncounter).
* insert RuleSetEncounterReference(encounter, ExtractedEncounter)
* date.extension[+].url = $sdc-templateExtractValue
* date.extension[=].valueString = "%resource.authored"
* author.reference = "PractitionerRole/ExtractedTreatingPractitionerRole"
* title = "Meldung zum klinischen Befund MPox"
* section[0].title = "Diagnosis section"
* section[0].code = $loinc#29308-4
* section[0].entry.reference = "Condition/ExtractedCondition"
* section[1].title = "Social history section"
* section[1].code = $loinc#29762-2
* section[1].entry.reference = "Observation/ExtractedExposure"
// Cause of death — gated on the person having died, and LAST for the same index-shift reason as the
// conditional Bundle entries (see RuleSetCauseOfDeathSection).
* insert RuleSetCauseOfDeathSection(ExtractedCauseOfDeath)
// Impfstatus — the second gated section, and therefore after the cause of death. Same
// last-element rule; see RuleSetImmunizationSectionMpox.
* insert RuleSetImmunizationSectionMpox

// ---------------------------------------------------------------------------
// The Bundle template itself (ChEkmDocumentMpox shape)
// ---------------------------------------------------------------------------
Instance: ChEkmDocumentMpoxTemplate
InstanceOf: ChEkmDocumentMpox
Usage: #example
Title: "CH EKM $extract template: Mpox document Bundle"
Description: "SDC template-based extraction template. Shaped like ChEkmDocumentMpox; the per-report fields carry sdc-questionnaire-templateExtractValue/-Context FHIRPath expressions that read a Mpox QuestionnaireResponse. Used by tests/extract-gonorrhoea.sh; not a normal example."
// * meta.profile = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-document-gonorrhoea"
* type = #document
* identifier.system = "urn:ietf:rfc:3986"
* identifier.value = "urn:uuid:c376a38a-61b9-4a79-8722-12c75bacf927"
// PLACEHOLDER DEFAULT — replaced at extraction. A document Bundle must have a timestamp value
// (bdl-10: timestamp.hasValue()), so the template needs a real value to be valid; the
// templateExtractValue below overwrites it with the QuestionnaireResponse's authored time at
// extraction. This 1900 sentinel never survives a real extraction.
* timestamp = "1900-01-01T00:00:00Z"
* timestamp.extension[+].url = $sdc-templateExtractValue
* timestamp.extension[=].valueString = "%resource.authored"
* entry[+].fullUrl = "http://test.fhir.ch/r4/Composition/ExtractedCompositionMpox"
* entry[=].resource = ExtractedCompositionMpox
* entry[+].fullUrl = "http://test.fhir.ch/r4/Patient/ExtractedPatient"
* entry[=].resource = ExtractedPatient
* entry[+].fullUrl = "http://test.fhir.ch/r4/Condition/ExtractedCondition"
* entry[=].resource = ExtractedCondition
* entry[+].fullUrl = "http://test.fhir.ch/r4/Observation/ExtractedExposure"
* entry[=].resource = ExtractedExposure
* entry[+].fullUrl = "http://test.fhir.ch/r4/PractitionerRole/ExtractedTreatingPractitionerRole"
* entry[=].resource = ExtractedTreatingPractitionerRole
* entry[+].fullUrl = "http://test.fhir.ch/r4/Practitioner/ExtractedTreatingPractitioner"
* entry[=].resource = ExtractedTreatingPractitioner
* entry[+].fullUrl = "http://test.fhir.ch/r4/Organization/ExtractedTreatingOrganization"
* entry[=].resource = ExtractedTreatingOrganization

// --- LAST ENTRY ON PURPOSE ---------------------------------------------------------------------
// The hospitalisation Encounter is the only CONDITIONAL entry, and a conditional entry must be the
// last one. The engine deletes a context-gated array element from the template and re-inserts it once
// per context result; when the context is empty nothing is re-inserted and every LATER entry has
// shifted down by one, while the extract paths recorded for those entries still carry their original
// index. Putting the Encounter anywhere but last therefore corrupts the entries after it as soon as
// the answer is "no" (observed: a phantom eighth entry holding a half-built Organization).
// Hospitalisation Encounter. The WHOLE entry is context-gated: answered "no" (or unanswered) ->
// the context is empty, the engine drops the indexed element, and no Encounter reaches the document.
// The two references to it (Composition.encounter, Condition.encounter) carry the same test, so they
// disappear together with it. This is the ONLY templateExtractContext in the Encounter's subtree —
// see RuleSetEncounterHospitalisation for why nesting a second one below it cannot work.
* entry[+].extension[0].url = $sdc-templateExtractContext
* entry[=].extension[0].valueString = "iif(%resource.descendants().where(linkId='hospitalisationStatus').answer.value.ofType(Coding).where(system='http://snomed.info/sct' and (code='373066001' or code='261665006')).exists(), true, {})"
* entry[=].fullUrl = "http://test.fhir.ch/r4/Encounter/ExtractedEncounter"
// IDENTITY VALUE, AND IT IS LOAD-BEARING. The engine seeds a context-gated array element from the
// static template with a SHALLOW spread — `{...staticEntry, ...firstValue}` (combineStaticTemplateData).
// The first value it inserts therefore decides what survives at the top level of the entry: a value
// whose path starts at `resource.…` replaces the whole static `resource`, taking `resourceType`,
// `status`, `class` and `subject` with it (only later values are deep-merged). Writing `fullUrl`
// FIRST — it precedes `resource` in the serialised entry, so the engine walks it first — makes that
// first spread overwrite `fullUrl` with itself, leaving the static Encounter intact for the values
// below to merge into. Without it the extracted Encounter comes out with no resourceType.
* entry[=].fullUrl.extension[0].url = $sdc-templateExtractValue
* entry[=].fullUrl.extension[0].valueString = "'http://test.fhir.ch/r4/Encounter/ExtractedEncounter'"
* entry[=].resource = ExtractedEncounter

// Cause of death Observation — the SECOND conditional entry, and therefore after the Encounter.
// Both gated entries are deleted from the template and re-inserted per context result, and the
// engine's entryPathPositionMap tracks how many were actually inserted at `Bundle.entry`, so a
// dropped Encounter correctly shifts this one down instead of leaving a hole. That bookkeeping only
// works between gated entries — a STATIC entry after a gated one still breaks (see above), which is
// why all conditional entries sit at the end.
//
// The gate is "the person died AND a cause was answered", for every one of the three answers: the
// "unknown" branch no longer needs an entry of its own (issue #28).
* entry[+].extension[0].url = $sdc-templateExtractContext
* entry[=].extension[0].valueString = "iif(%resource.descendants().where(linkId='deceased').answer.value.first() = true and %resource.descendants().where(linkId='deathCause').answer.value.exists(), true, {})"
* entry[=].fullUrl = "http://test.fhir.ch/r4/Observation/ExtractedCauseOfDeath"
// IDENTITY VALUE, LOAD-BEARING — see the Encounter entry above for why.
* entry[=].fullUrl.extension[0].url = $sdc-templateExtractValue
* entry[=].fullUrl.extension[0].valueString = "'http://test.fhir.ch/r4/Observation/ExtractedCauseOfDeath'"
* entry[=].resource = ExtractedCauseOfDeath

// Impfstatus Immunizations - the remaining conditional entries, after the Encounter and the
// cause-of-death Observation for the ordering reason above. Twelve gated entries, six per row, of
// which at most one per row ever fires; the gates are mutually exclusive by construction.
* insert RuleSetImmunizationEntries(Smallpox)
* insert RuleSetImmunizationEntries(Mpox)
