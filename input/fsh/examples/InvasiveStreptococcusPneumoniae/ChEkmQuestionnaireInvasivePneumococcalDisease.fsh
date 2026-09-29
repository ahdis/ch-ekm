// Modular ROOT questionnaire for the invasive pneumococcal disease clinical findings report.
//
// Built from the SAME disease-agnostic sub-questionnaires Gonorrhoea, Mpox and Hepatitis C assemble
// (input/fsh/questionnnaire/), so `sushi . && ./assemble.sh` picks it up automatically: the root is
// discovered by its `assemble-expectation = assemble-root` extension, no script edit needed.
//
// STARTER SCOPE, exactly like the Hepatitis C root. Only the sections whose questions already exist
// as reusable modules AND whose target profiles exist for this organism are assembled:
//   Person (INITIALS, no gender identity)  ·  Diagnose/Manifestation + Labor (incl. Probe)
//   Verlauf (Hospitalisation + Zustand)
//   Exposition Wo/Wann  ·  Impfstatus  ·  Behandelnde Ärztin/Arzt
// The one block the CSV marks with an "X" that is NOT assembled — Risikofaktoren — is
// listed under OPEN QUESTIONS at the bottom of this file. They are DELIBERATELY NOT MODELLED YET:
// each needs a decision first, and guessing would bake the guess into the extraction template.
//
// Sources reconciled here (they disagree in places — see OPEN QUESTIONS):
//   * profiles       input/fsh/profiles/ChEkmInvasiveStreptococcusPneumoniae.fsh
//   * example Bundle input/fsh/examples/InvasiveStreptococcusPneumoniae/ChEkmBundleInvasiveStreptococcusPneumoniae.fsh
//   * paper form CSV "Meldung zum klinischen Befund Infektionskrankheit - Pneumokokkenerkrankung.csv"
//   * logical model  input/fsh/logical/ChEkmInvasivePneumococcalDiseaseForm.fsh
//
// NAMING: the folder is `InvasiveStreptococcusPneumoniae/` but every profile and example instance
// in it is called `…InvasivePneumococcalDisease`. This file follows the instances/profiles.

Instance: ChEkmQuestionnaireInvasivePneumococcalDisease
InstanceOf: Questionnaire
Usage: #example
Title: "CH EKM Questionnaire: Invasive Pneumococcal Disease (modular)"
Description: "Modular root questionnaire for the invasive pneumococcal disease (invasive Streptococcus pneumoniae) clinical findings report. Use Questionnaire/$assemble to produce the renderable form."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireInvasivePneumococcalDisease"
* name = "ChEkmQuestionnaireInvasivePneumococcalDisease"
* title = "CH EKM Questionnaire: Invasive Pneumococcal Disease (modular)"

* insert RuleSetQrHeader("invasivepneumococcaldisease-form", "Clinical findings report: invasive pneumococcal disease", "Meldung zum klinischen Befund: Invasive Pneumokokkenerkrankung", "Déclaration de résultat clinique : infection invasive à pneumocoques", "Notifica del referto clinico: malattia pneumococcica invasiva", ChEkmDocumentInvasivePneumococcalDiseaseTemplate)
// Render the sections below (person / diagnosis / course / exposure / physician) as tabs on the left
* insert RuleSetQrLevel1TabContainer

// --- Angaben zur betroffenen Person -------------------------------------------------------------
// INITIALS, like Gonorrhoea and unlike Mpox/Hepatitis C: ChEkmCompositionInvasivePneumococcalDisease
// constrains `subject` to ChEkmPatientInitials, and the CSV marks "initiale Name" / "initiale
// Vorname" with an X while the full "Vorname" / "Nachname" rows carry none. So the `PersonInitials`
// module is assembled, not `PersonName`.
* insert RuleSetQrGroupPerson
* insert RuleSetQrPersonInitials
* insert RuleSetQrPersonGeneral
// NO Geschlechtsidentität. The CSV has no row for it — only "Administratives Geschlecht", which
// PersonGeneral covers — and unlike Gonorrhoea, Mpox and Hepatitis C this form does not ask it
// (decided; was OPEN QUESTION #6). The shared ExtractedPatient reads `linkId='genderIdentity'` and
// emits nothing when the item is absent, so no extraction change is needed:
// * insert RuleSetQrPersonGenderIdentity

// --- Diagnose und Manifestation -----------------------------------------------------------------
// Manifestationen — multiple-choice, check-boxes, bound to
// ChEkmInvasivePneumococcalDiseaseManifestation (Pneumonie, Sepsis, Meningitis, plus
// Andere/Keine/Unbekannt from ChEkmOtherNoneUnknown). Same shape as Mpox and Hepatitis C;
// Gonorrhoea is the single-choice variant.
//
// `definition` points at ChEkmInvasivePneumococcalDiseaseManifestationForm, as the Gonorrhoea root
// does at its own manifestation sub-form.
* insert RuleSetQrGroupManifestation
* insert RuleSetQrLevel3Item("manifestation", "Manifestations", "Manifestationen", "Manifestations", "Manifestazioni")
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmInvasivePneumococcalDiseaseManifestationForm#ChEkmInvasivePneumococcalDiseaseManifestationForm.manifestation"
* item[=].item[=].item[=].type = #choice
* item[=].item[=].item[=].repeats = true
* item[=].item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].item[=].extension[=].valueCode = #vertical
* item[=].item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmInvasivePneumococcalDiseaseManifestation"
* item[=].item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].item[=].answerValueSet.extension[=].extension[=].valueCode = #useSupplement
* item[=].item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-snomed-language-supplement"
* item[=].item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].item[=].extension[=].valueCodeableConcept = $item-control#check-box

* insert RuleSetQrManifestationBeginUnknown

// --- Labor -------------------------------------------------------------------------------------
// The analysing laboratory, INSIDE the "Diagnose und Manifestation" section and directly after the
// Manifestationsbeginn — so it is a sub-heading of the Diagnose tab, not a tab of its own. All nine
// CSV rows are X-marked and identical to the Hepatitis C ones, so the module is disease-agnostic.
// The rest of the paper form's Labor block (Anlass, Material, Entnahmedatum) is NOT asked — see
// OPEN QUESTIONS #3.
* insert RuleSetQrLaboratory
// Entnahmedatum + Material — the SAMPLE half of the Labor block, an opt-in companion module. Only
// this form asks them (the Hepatitis C CSV has no Entnahmedatum row and mentions Material only in
// its un-mapped wish-list block), which is why they are their own sub-questionnaire rather than two
// more items in the shared one. Material is a dropdown bound to the CH ELM specimen value set —
// the same canonical ChEkmSpecimen binds `type.coding` to.
* insert RuleSetQrLaboratorySpecimen

// --- Verlauf (course of the disease) ------------------------------------------------------------
// Hospitalisation + Zustand (Tot / Todesdatum / Todesursache). The CSV marks both blocks with an X
// and the example Bundle carries an Encounter, so the two modules Mpox and Hepatitis C use apply
// unchanged. The CSV's "Spital" row (the hospital's name) has no X and no module — the
// Hospitalisation sub-questionnaire does not ask it.
* insert RuleSetQrGroupCourse
* insert RuleSetQrHospitalisation
* insert RuleSetQrDeath

// --- Exposition ---------------------------------------------------------------------------------
// Wo before Wann, as on the paper form (https://github.com/ahdis/ch-ekm/issues/26).
// NOTE: the two CSV rows carry NO "X" and the example Bundle has no ChEkmExposure — so this section
// is assembled on the strength of the generic module and the base ChEkmExposure profile alone.
// See OPEN QUESTIONS #5; deleting the three inserts below plus the Exposure entry in the extract
// template removes the section again.
* insert RuleSetQrGroupExposure
* insert RuleSetQrExposureWhere
* insert RuleSetQrExposureWhen

// "Wie (Übertragungsweg)" is DELIBERATELY NOT ASSEMBLED — see OPEN QUESTIONS #5. The CSV row says
// literally "Valueset für exposition Wie", i.e. the answer list does not exist yet, and the only
// module we have is the Gonorrhoea STI transmission block (definition-bound to
// ChEkmGonorrhoeaExposureForm, extracted into the sliced components of ChEkmExposureGonorrhoea).
// Uncomment ONLY after the pneumococcal list is modelled AND a ChEkmExposureInvasivePneumococcalDisease
// profile exists to extract into:
// * insert RuleSetQrExposureHow

// --- Impfstatus (issue #29) ---------------------------------------------------------------------
// One level-2 placeholder, because the section has a single sub-questionnaire whose own root group
// becomes the tab. As on the Mpox form it sits between the Exposition and the treating physician.
// ONE ROW (Pneumokokkenimpfung), asked with a TOTAL dose count -> exactly one ChEkmImmunization per
// answered row. The CSV's "Gemäss: Impfausweis / Hausarzt / Anamnese" is NOT asked: it has no FHIR
// target ("Questionnaire Response level" in the CSV).
* insert RuleSetQrGroupImmunizationInvasivePneumococcalDisease

* insert RuleSetQrGroupTreatingPhysician

// Third launch context (patient + user come from RuleSetQrHeader): the hospitalisation Encounter
// read by the Hospitalisation sub-questionnaire's initialExpressions. Declared here, at the END of
// the root, because it is a Questionnaire-level extension and only roots with a "Verlauf" need it.
* insert RuleSetQrLaunchContextEncounter


// =================================================================================================
// OPEN QUESTIONS — invasive pneumococcal disease diverges from Gonorrhoea/Mpox/Hepatitis C here.
// NOTHING BELOW IS IMPLEMENTED. Mirrored in TODO.md; kept here too so the gap is visible next to
// the form it belongs to.
//
//  1. LOGICAL MODEL — IMPLEMENTED. ChEkmInvasivePneumococcalDiseaseForm is the disease-level
//     aggregate, with its own sub-forms only where this form differs from the generic models:
//     ChEkmInvasivePneumococcalDiseasePersonForm (initials, no gender identity),
//     …ManifestationForm (bound to ChEkmInvasivePneumococcalDiseaseManifestation) and
//     …ImmunizationForm (the one Pneumokokkenimpfung row). Labor, Verlauf, Exposition and the
//     treating physician are the generic models. The manifestation item's `definition` now points
//     at the disease sub-form; the shared sub-questionnaires keep pointing at the generic ones.
//     Also unresolved, identically to Hepatitis C: ChEkmInvasivePneumococcalDiseaseManifestation
//     mixes real findings with "Keine"/"Unbekannt"/"Anderes" from ChEkmOtherNoneUnknown while the
//     item is `repeats = true`, so "Sepsis + keine" is tickable.
//
//  1a. WHICH MANIFESTATION VALUE SET? There are TWO in ValueSet.fsh and they are not the same list:
//     * `ChEkmInvasivePneumococcalDiseaseManifestation` — GENERIC findings plus
//       ChEkmOtherNoneUnknown: sct#233604007 Pneumonia, #91302008 Sepsis, #7180009 Meningitis.
//       This is the one ChEkmConditionInvasivePneumococcalDisease binds `evidence.code` to, so it is
//       the one this form uses.
//     * `ChEkmPneumococcalDiseaseManifestation` — PNEUMOCOCCUS-SPECIFIC findings, and an extra one:
//       sct#448421008 Sepsis caused by Streptococcus pneumoniae, #51169003 Pneumococcal meningitis,
//       #36309003 Pneumococcal ARTHRITIS, #233607000 Pneumococcal pneumonia. It is referenced by
//       NOTHING in the IG today — an orphan.
//     Which is authoritative? The pre-coordinated list says "pneumococcal sepsis" once instead of
//     saying "sepsis" as evidence for a Condition already coded as invasive pneumococcal disease,
//     which is arguably redundant; the generic list is the shape Mpox and Hepatitis C use. The CSV
//     sides with neither: it lists Pneumonie / Sepsis / "Arthritis" / Keine / Unbekannt / Anderes
//     but gives sct#7180009 — which is MENINGITIS, not arthritis — as the code for "Arthritis".
//     So the answer list is undecided on three counts: generic vs. pre-coordinated codes, whether
//     ARTHRITIS is a fourth manifestation (only the orphan value set has it), and whether
//     MENINGITIS is on the form at all (only the bound value set has it, mislabelled in the CSV).
//     Delete whichever value set loses, so the IG stops carrying both.
//
//  2. IMPFSTATUS — IMPLEMENTED (decided: our row model). The section is assembled, with ONE row
//     (Pneumokokkenimpfung) built from the shared RuleSetQrImmunizationRow, and it extracts to
//     exactly ONE ChEkmImmunizationInvasivePneumococcalDisease carrying
//     protocolApplied.doseNumberPositiveInt = the TOTAL number of doses (or to a
//     ChEkmObservationVaccinationStatusInvasivePneumococcalDisease for "nein"/"unbekannt").
//     The example Bundle ChEkmBundleInvasiveStreptococcusPneumoniae has been ALIGNED with it: it
//     used to carry one unprofiled Immunization PER DOSE (Pneumococcal1/2, doseNumber 1 and 2, two
//     occurrence dates), the CH VACD vaccination-RECORD shape the CSV comment describes; it now
//     carries the single ChEkmImmunizationExample-Pneumococcal — two doses in total, last dose
//     2000-05-01, Prevenar 13 — so the IG gives ONE answer to "what does an Impfstatus row look
//     like?". The date of the first dose is no longer reported: the form never asked for it.
//     What remains open is smaller:
//     * sct#16814004 "Pneumococcal infectious disease" and sct#836398006 "Streptococcus pneumoniae
//       antigen-containing vaccine product" are only PREFERRED-bound in ChEkmImmunization
//       (targetDisease -> CH VACD target diseases, vaccineCode -> Swiss vaccines), so the IG
//       Publisher may warn about them. Confirm both are the concepts the FOPH wants.
//     * The conjugate (Prevenar 13/20) and polysaccharide (Pneumovax 23) vaccines share ONE row;
//       which of them was given is only visible in the answered brand. Confirm that is enough.
//     NOT ASKED, per the decision: "Gemäss: Impfausweis / Hausarzt / Anamnese" — the CSV itself
//     annotates it "Questionnaire Response level", i.e. it has no FHIR target.
//
//  3. LABOR — the ORGANISATION half is now IMPLEMENTED. The nine X-marked rows (name, department,
//     address, phone, email, BUR, GLN) are the shared, disease-agnostic sub-questionnaire
//     ChEkmQuestionnaireLaboratory, assembled INSIDE this section right after the
//     Manifestationsbeginn, with the logical model ChEkmLabForm behind it; they extract into
//     ChEkmOrganizationLab, reached from ChEkmServiceRequest.performer in
//     Composition.section[laboratory]. Hepatitis C assembles the same module unchanged — it is the
//     first lab module in the IG and every further organism gets it with one insert.
//     "Material" and "Entnahmedatum" are IMPLEMENTED TOO, as the opt-in companion module
//     ChEkmQuestionnaireLaboratorySpecimen (logical model ChEkmLabSpecimenForm -> ChEkmSpecimen,
//     referenced from ChEkmServiceRequest.specimen). Material is a dropdown bound DIRECTLY to
//     http://fhir.ch/ig/ch-elm/ValueSet/ch-elm-results-complete-spec, the same canonical
//     ChEkmSpecimen binds `type.coding` to. (The local ChEkmSpecimenType wrapper that used to sit in
//     between is gone: it added no concepts, and its nested include made tx.fhir.ch refuse
//     `useSupplement` with HTTP 422, which broke the de/fr/it preview build.) Only this form
//     assembles the module; the Hepatitis C form has neither row.
//     STILL OPEN:
//       * The list has 73 concepts (the whole CH ELM specimen list), not the five the paper form
//         prints (Blut, Liquor, Pleurapunktat, Gelenkpunktat, Anderes). All five are in it, so
//         nothing is missing — but if the FOPH wants exactly those five, that is a value set
//         decision, not a form change.
//       * The dropdown shows ENGLISH displays in all four languages: the ch-ekm SNOMED language
//         supplement carries designations for 41 curated codes, of which exactly one (74964007
//         "Other") is a specimen code. Translating the list means adding designations, whichever
//         value set it ends up being.
//       * "Anlass" (klinischer Verdacht / Exposition / Screening / anderer / unbekannt ->
//         ServiceRequest.reasonCode; ChEkmServiceRequestReason exists) appears TWICE in the CSV's
//         "Questionnaire" wish-list block with two DIFFERENT answer lists — which one applies?
//     All of these attach to the ChEkmServiceRequest / ChEkmSpecimen the form already extracts.
//
//  4. RISIKOFAKTOREN — marked X, and NEW: no other organism in this IG has this section.
//     The example Bundle puts a plain (unprofiled) `Condition` with
//     `category = problem-list-item`, `code = sct#38013005 "Immunosuppression (finding)"` into
//     `Composition.section[risk-factors]` (LOINC 46467-7). Missing before a question can be written:
//       * the ANSWER LIST — the CSV gives only Keine / Unbekannt / Anderes and points at the CH VACD
//         medical-problems profile and the IPS problems value set as a basis. Which risk factors
//         does the pneumococcal form actually enumerate?
//       * a ChEkmConditionRiskFactor PROFILE (the example uses a bare Condition, so the section
//         entry is unprofiled today) and a logical model for it;
//       * "Anderes as free text or coded?" — the CSV asks this itself;
//       * the extraction shape: `repeats = true` over a value set means a VARIABLE number of
//         Condition resources, which is the same single-Bundle-template limit as #2 above
//         (forms-summary.md §8). A fixed row per risk factor, as with the Impfstatus rows, is the
//         shape that works — but that presupposes a closed list.
//
//  5. EXPOSITION — neither "Wo" nor "Wann" carries an X in the CSV and the example Bundle has no
//     Exposure at all; "Wie" has no answer list ("Valueset für exposition Wie"). Wo and Wann ARE
//     assembled above because the modules are disease-agnostic and the base ChEkmExposure is what
//     ChEkmComposition's section[social-history] requires — but CONFIRM that the pneumococcal paper
//     form really asks them before this ships. There is also no
//     ChEkmExposureInvasivePneumococcalDisease profile; as for Hepatitis C the BASE ChEkmExposure is
//     extracted into, which is fine for Wo/Wann and not enough for Wie.
//
//  6. GESCHLECHTSIDENTITÄT — DECIDED: this form does NOT ask it. The CSV's first row is an empty
//     "Gender / Gender" placeholder with no X, no mapping and no value, and there is no
//     "Geschlechtsidentität" row; RuleSetQrPersonGenderIdentity is therefore not assembled (the
//     other three forms still ask it). Nothing else changes — the shared ExtractedPatient builds the
//     individual-genderIdentity extension only when the item is answered.
//
//  7. "WEITERE EXPONIERTE PERSONEN / FÄLLE" and "BERUFLICHE TÄTIGKEIT RELEVANT FÜR VOLLZUG" sit in
//     the CSV's "Questionnaire" wish-list block (no X, no mapping, no value set). Same category as
//     Hepatitis C OPEN QUESTION #3: no form item, no model element, no target element. Note the rest
//     of that CSV block is a cross-disease dump (HIV, malaria, measles, syphilis, rubella …) and is
//     NOT about this organism — only the two rows named here plus the "Labor Anlass" rows in #3 read
//     as pneumococcal candidates.
//
//  8. TODESURSACHE, WHICH CODE? The extraction template writes the reported-pathogen answer as
//     `sct#406617004 "Invasive Streptococcus pneumoniae disease (disorder)"`, i.e. the same code
//     ChEkmConditionInvasivePneumococcalDisease fixes for the diagnosis — that is what "the cause of
//     death is the disease this report is about" means, and it is how Mpox and Hepatitis C do it.
//     The CSV instead proposes `sct#16814004 "Pneumococcal infectious disease"` (the broader parent)
//     for the cause of death, and `sct#87309006 "Death of unknown cause (event)"` for "unbekannt"
//     where our shared ChEkmCauseOfDeathChoice uses `sct#261665006 "Unknown"`. Both divergences are
//     one-word changes if the CSV is authoritative — but changing the "unknown" code affects EVERY
//     organism, since ChEkmCauseOfDeathChoice is shared.
// =================================================================================================
