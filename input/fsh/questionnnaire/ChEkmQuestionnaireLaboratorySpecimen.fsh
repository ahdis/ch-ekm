// Modular sub-questionnaire: the SAMPLE the laboratory analysed — "Entnahmedatum" and "Material".
// Source of truth: logical model ChEkmLabSpecimenForm (-> ChEkmSpecimen, reached from
// ChEkmServiceRequest.specimen) in input/fsh/logical/ChEkmLabForm.fsh.
//
// A SECOND, SEPARATE module rather than two more items in ChEkmQuestionnaireLaboratory, because the
// two blocks have different scope: every organism's form asks for the analysing laboratory (the
// nine fields of ChEkmQuestionnaireLaboratory), but only some ask what was sampled and when. Today
// that is the invasive pneumococcal disease form alone — the Hepatitis C CSV has no Entnahmedatum
// row at all and mentions "Labor: Material" only in its un-mapped "Questionnaire" wish-list block.
// SDC's $assemble cannot include a sub-questionnaire conditionally, so "shared module + opt-in
// second module" is how a root says "my form asks these too": one extra `insert
// RuleSetQrLaboratorySpecimen` right after `RuleSetQrLaboratory`.
//
// Assembled directly after the `laboratory` group, inside "Diagnose und Manifestation", so on screen
// the two questions read as a continuation of the Labor block — which is where the paper form has
// them.
//
// They target a DIFFERENT RESOURCE from the nine laboratory fields: ChEkmSpecimen, not
// ChEkmOrganizationLab. Both hang off the one ChEkmServiceRequest in
// Composition.section[laboratory] — `performer` for the laboratory, `specimen` for the sample.
//
// BOTH OPTIONAL, and independently so: the CSV marks Material with an "X" and the Entnahmedatum
// without one, and `ChEkmSpecimen` leaves `type` at 0..1 as well. The extraction template therefore
// emits the Specimen when EITHER is answered and simply omits the other half.
//
// NO PRE-POPULATION: no launch context carries the sample (see ChEkmQuestionnaireLaboratory).

Instance: ChEkmQuestionnaireLaboratorySpecimen
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Laboratory - Specimen"
Description: "Modular sub-questionnaire for the sample analysed by the laboratory: the collection date (Entnahmedatum) and the material (Material). Reusable as an SDC assemble-child; extracted into ChEkmSpecimen via ChEkmServiceRequest.specimen. Assembled only by organisms whose form asks for the sample."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireLaboratorySpecimen)

* item[+].linkId = "specimen"
* insert RuleSetQrLevel1Text("Sample", "Probe", "Échantillon", "Campione")
* item[=].type = #group

// Entnahmedatum -> Specimen.collection.collectedDateTime. A `date`, like every other date on these
// forms: partial dates are allowed and a date is a valid dateTime lexical form.
* item[=].item[+].linkId = "specimenCollectionDate"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabSpecimenForm#ChEkmLabSpecimenForm.collectionDate"
* insert RuleSetQrLevel2Text("Sample collection date", "Entnahmedatum", "Date du prélèvement", "Data del prelievo")
* item[=].item[=].type = #date

// Material -> Specimen.type. A plain single-choice DROPDOWN (no itemControl: Smart Forms renders a
// `Select` for a `choice` item), bound to the CH ELM specimen value set — the SAME canonical
// ChEkmSpecimen binds `type.coding` to (required), so the form can only offer what the profile
// accepts and no second list has to be maintained.
//
// DIRECTLY, not through a local ChEkmSpecimenType wrapper (which existed and has been removed): a
// value set whose only content is `include codes from valueset ...` adds nothing, and tx.fhir.ch
// refuses `useSupplement` on a value set that pulls its codes in through a nested include
// ("Required supplement not found", HTTP 422), which broke the de/fr/it preview build.
//
// NB the list has 73 concepts — the whole CH ELM specimen list, not the five the paper form prints
// (Blut, Liquor, Pleurapunktat, Gelenkpunktat, Anderes). All five are in it, so nothing the form
// needs is missing, and narrowing it is a terminology decision (see TODO.md). Note also that the
// ch-ekm SNOMED language supplement carries designations for 41 curated codes, of which exactly one
// is a specimen code, so the options render with their ENGLISH displays in all four languages until
// those designations exist.
* item[=].item[+].linkId = "specimenType"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmLabSpecimenForm#ChEkmLabSpecimenForm.material"
* insert RuleSetQrLevel2Text("Material", "Material", "Matériel", "Materiale")
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-elm/ValueSet/ch-elm-results-complete-spec"
* item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueCode = #useSupplement
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-snomed-language-supplement"
