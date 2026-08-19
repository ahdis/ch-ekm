RuleSet: RuleSetEncounterHospitalisation
// Hospitalisation -> ChEkmEncounter. Three form answers, three shapes:
//
//   ja (373066001)        -> this Encounter, with period.start = Eintrittsdatum and the
//                            Hospitalisationsgrund in reasonReference / reasonCode. NO
//                            `hospitalization` element: the inpatient class and the admission date
//                            already assert the stay, and an empty BackboneElement violates ele-1.
//   nein (373067005)      -> no Encounter at all. The whole Bundle entry is dropped, as are the
//                            references to it from Composition.encounter and Condition.encounter.
//   unbekannt (261665006) -> this Encounter carrying nothing but
//                            hospitalization.extension[data-absent-reason] = asked-unknown.
//
// ONE CONTEXT, ON THE BUNDLE ENTRY, AND NO NESTED CONTEXT ANYWHERE BELOW IT.
// This is a hard constraint of the reference engine, not a style choice. `walkTemplateForContexts`
// registers every context it meets as its own entry in the extract-path map, while
// `walkTemplateForContextValues` ALSO attaches every value below an outer context to that outer
// context. A context nested inside another therefore has its values evaluated twice, once against
// the wrong focus, and — because an entry path ending in an array index is deleted from the
// template and re-inserted per context result (populateIntoTemplates step 5a) — the inner and outer
// re-insertions fight over the same indices. Concretely, gating the entry AND `reasonCode[0]`
// separately emitted the hospitalisation ANSWER as the reason code and lost the Encounter's static
// `resourceType`/`status`/`class`/`subject`.
//
// The Encounter must vanish as a whole for "nein", so the gate has to sit on the Bundle entry — and
// then every conditional part below it must be a plain `templateExtractValue` instead of a context.
// The idiom for that is the one already used by RuleSetExposureWhere: the context yields a single
// `true` sentinel and only gates, while each value reads the answers ABSOLUTELY through %resource
// and ends in `.first().select(%factory.…)`. `select()` on an empty collection returns an empty
// collection, so "not applicable" and "no element emitted" are the same thing — no `iif` needed, and
// no half-built element can survive.
* status = #unknown
* class = $v3-ActCode#IMP "inpatient encounter"
* subject.reference = "Patient/ExtractedPatient"

// Eintrittsdatum -> period.start. A primitive, so a bare value directive suffices: the item is
// enableWhen-gated on "ja", so an answer can only exist in the "ja" branch, and an unanswered item
// yields an empty result, which omits `period.start` (and with it `period`).
* period.start.extension[+].url = $sdc-templateExtractValue
* period.start.extension[=].valueString = "%resource.descendants().where(linkId='hospitalisationAdmissionDate').answer.value.first()"

// Hospitalisationsgrund. The answer value set mixes ONE local discriminator code with TWO SNOMED CT
// qualifiers, and the two kinds go to different elements — which is what makes them separable by a
// `where(system=…)` filter, the same split as country vs. "unknown" in RuleSetExposureWhere:
//
//   ch-ekm#reported-pathogen  -> reasonReference = the diagnosis Condition of this document
//   sct#74964007 / #261665006 -> reasonCode, the answered Coding wrapped in a CodeableConcept
//
// Both are built WHOLE by %factory so that the element is either complete or absent. Annotating
// `reasonReference[0].reference` field-wise instead would leave a `"_reference": {}` shell behind
// when unanswered (the artifact-stripped primitive-extension slot), which is not valid FHIR;
// `%factory.create(Reference)` + `withProperty` produces the finished Reference in one value.
//
// PLACEHOLDER DEFAULT — replaced at extraction (same idiom as Patient.gender / Bundle.timestamp).
// A Reference carrying nothing but a templateExtractValue makes the TEMPLATE flag "a Reference
// without an actual reference or identifier should have a display". The engine deletes the whole
// `reasonReference[0]` element when it strips the artifacts (a lone extension in the array collapses
// to its parent), before the clean template is taken, so this placeholder never survives extraction.
* reasonReference[0].reference = "Condition/ExtractedCondition"
* reasonReference[0].extension[+].url = $sdc-templateExtractValue
* reasonReference[0].extension[=].valueString = "%resource.descendants().where(linkId='hospitalisationReason').answer.value.ofType(Coding).where(system='http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-reported-pathogen' and code='reported-pathogen').first().select(%factory.withProperty(%factory.create(Reference), 'reference', 'Condition/ExtractedCondition'))"
* reasonCode[0].extension[+].url = $sdc-templateExtractValue
* reasonCode[0].extension[=].valueString = "%resource.descendants().where(linkId='hospitalisationReason').answer.value.ofType(Coding).where(system='http://snomed.info/sct').first().select(%factory.CodeableConcept($this))"

// "unbekannt" -> hospitalization.extension[unknown] = data-absent-reason#asked-unknown, and nothing
// else in the whole element. The extension is built by %factory.Extension on the ch-ekm
// SdcTemplateExtractExtension carrier, the same idiom as the onsetDateTime data-absent-reason in
// RuleSetOnsetDateManifestationBeginUnknown: it cannot be pre-declared with
// `url = data-absent-reason`, because a to-be-computed valueCode leaves the extension valueless
// (fails ext-1). The factory result deep-merges onto the carrier and overwrites the carrier url.
// Any other answer -> empty result -> no extension, and `hospitalization` loses its only child and
// disappears with it.
* hospitalization.extension[0].url = $sdc-templateExtractExtension
* hospitalization.extension[0].extension[0].url = $sdc-templateExtractValue
* hospitalization.extension[0].extension[0].valueString = "%resource.descendants().where(linkId='hospitalisationStatus').answer.value.ofType(Coding).where(system='http://snomed.info/sct' and code='261665006').first().select(%factory.Extension('http://hl7.org/fhir/StructureDefinition/data-absent-reason', %factory.code('asked-unknown')))"

RuleSet: RuleSetEncounterReference(target)
// The reference TO the hospitalisation Encounter, used twice: on Composition.encounter and on
// Condition.encounter  "we add it in Composition.encounter … and we add a
// reference in the Condition.encounter in the condition created for the diagnosis").
//
// Same "either whole or absent" shape as the reason above, and for the same reason it is a value and
// not a context: `Composition.encounter` sits inside no context, but `Condition.encounter` would
// otherwise nest under nothing while the Bundle entry gate lives in a different resource — keeping
// both as plain %factory values makes the two identical and keeps the template context-free apart
// from the one gate on the entry.
//
// The condition is "the hospitalisation question was answered anything other than 'nein'", i.e.
// exactly the condition under which the Encounter entry exists. A dangling reference to a resource
// that was dropped from the Bundle would break the document, so the two must be spelled with the
// same test.
//
// PLACEHOLDER DEFAULT — replaced at extraction, exactly as for reasonReference above. Without it the
// TEMPLATE has a Composition that does not point at the Encounter, and the publisher reports the
// Encounter entry as "isn't reachable by traversing forwards from the Composition".
* {target}.reference = "Encounter/ExtractedEncounter"
* {target}.extension[+].url = $sdc-templateExtractValue
* {target}.extension[=].valueString = "%resource.descendants().where(linkId='hospitalisationStatus').answer.value.ofType(Coding).where(system='http://snomed.info/sct' and (code='373066001' or code='261665006')).first().select(%factory.withProperty(%factory.create(Reference), 'reference', 'Encounter/ExtractedEncounter'))"
