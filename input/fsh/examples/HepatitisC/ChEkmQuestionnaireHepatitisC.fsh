// Modular ROOT questionnaire for the Hepatitis C clinical findings report.
//
// Built from the SAME disease-agnostic sub-questionnaires Mpox and Gonorrhoea assemble
// (input/fsh/questionnnaire/), so `sushi . && ./assemble.sh` picks it up automatically: the root is
// discovered by its `assemble-expectation = assemble-root` extension, no script edit needed.
//
// STARTER SCOPE. Only the sections whose questions already exist as reusable modules AND whose
// target profiles exist for Hepatitis C are assembled here:
//   Person (FULL name)  ·  Diagnose/Manifestation  ·  Verlauf (Hospitalisation + Zustand)
//   Exposition Wo/Wann  ·  Behandelnde Ärztin/Arzt
// Everything the Hepatitis C paper form asks on top of that is listed under OPEN QUESTIONS at the
// bottom of this file. Those are DELIBERATELY NOT MODELLED YET — each one needs a decision before a
// question can be written, and guessing would bake the guess into the extraction template.
//
// Sources reconciled here (they disagree in places — see OPEN QUESTIONS):
//   * logical model  input/fsh/logical/CHEkmHepatitisCForm.fsh   (the master, per AGENTS.md)
//   * profiles       input/fsh/profiles/ChEkmHepatitisC.fsh
//   * paper form CSV "Meldung zum klinischen Befund Infektionskrankheit - Hepatitis C.csv"

Instance: ChEkmQuestionnaireHepatitisC
InstanceOf: Questionnaire
Usage: #example
Title: "CH EKM Questionnaire: Hepatitis C (modular)"
Description: "Modular root questionnaire for the Hepatitis C clinical findings report. Use Questionnaire/$assemble to produce the renderable form."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireHepatitisC"

* insert RuleSetQrHeader("hepatitisc-form", "Clinical findings report: hepatitis C", "Meldung zum klinischen Befund: Hepatitis C", "Déclaration de résultat clinique : hépatite C", "Notifica del referto clinico: epatite C", ChEkmDocumentHepatitisCTemplate)
// Render the sections below (person / diagnosis / course / exposure / physician) as tabs on the left
* insert RuleSetQrLevel1TabContainer

// --- Angaben zur betroffenen Person -------------------------------------------------------------
// FULL NAME, like Mpox and unlike Gonorrhoea: ChEkmHepatitisCPersonForm sets
// `surnameInitial 0..0` / `surname 0..1`, and ChEkmCompositionHepatitisC's subject is the
// un-masked ChEkmPatient. So the `PersonName` module is assembled, not `PersonInitials`.
* insert RuleSetQrGroupPerson
* insert RuleSetQrPersonName
* insert RuleSetQrPersonGeneral
* insert RuleSetQrPersonGenderIdentity

// --- Diagnose und Manifestation -----------------------------------------------------------------
// Manifestationen — multiple-choice, check-boxes, bound to ChEkmHepatitisCManifestation
// (Ikterus, erhöhte Leberenzyme/Transaminasen, plus Andere/Keine/Unbekannt from
// ChEkmOtherNoneUnknown). Same shape as Mpox; Gonorrhoea is the single-choice variant.
//
// `definition` points at the GENERIC ChEkmManifestationForm: there is no
// ChEkmHepatitisCManifestationForm logical model (Gonorrhoea has one, Hepatitis C does not) —
// see OPEN QUESTIONS #1.
* insert RuleSetQrGroupManifestation
* insert RuleSetQrLevel3Item("manifestation", "Manifestations", "Manifestationen", "Manifestations", "Manifestazioni")
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmManifestationForm#ChEkmManifestationForm.manifestation"
* item[=].item[=].item[=].type = #choice
* item[=].item[=].item[=].repeats = true
* item[=].item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].item[=].extension[=].valueCode = #vertical
* item[=].item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmHepatitisCManifestation"
* item[=].item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].item[=].answerValueSet.extension[=].extension[=].valueCode = #useSupplement
* item[=].item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-snomed-language-supplement"
* item[=].item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].item[=].extension[=].valueCodeableConcept = $item-control#check-box

* insert RuleSetQrManifestationBeginUnknown

// --- Verlauf (course of the disease) ------------------------------------------------------------
// Hospitalisation + Zustand (Tot / Todesdatum / Todesursache). The Hepatitis C paper form has both
// blocks (CSV rows "Hospitalisation" and "Zustand"), so the same two modules Mpox uses apply
// unchanged. Note the CSV comment on "Todesdatum" ("appears in the sheet but not in the PDF") — the
// module asks for it, which matches ChEkmDeathForm.
* insert RuleSetQrGroupCourse
* insert RuleSetQrHospitalisation
* insert RuleSetQrDeath

// --- Exposition ---------------------------------------------------------------------------------
// Wo before Wann, as on the paper form (https://github.com/ahdis/ch-ekm/issues/26).
* insert RuleSetQrGroupExposure
* insert RuleSetQrExposureWhere
* insert RuleSetQrExposureWhen

// "Wie (Übertragungsweg)" is DELIBERATELY NOT ASSEMBLED — see OPEN QUESTIONS #2. The existing
// module is the STI transmission block (sexual-contact partner sex / relationship type), whose
// items are `definition`-bound to ChEkmGonorrhoeaExposureForm and whose extraction targets the
// sliced components of ChEkmExposureGonorrhoea. The Hepatitis C form asks a different list
// entirely. Uncomment ONLY after that list is modelled (and after a ChEkmExposureHepatitisC
// profile exists to extract into):
// * insert RuleSetQrExposureHow

* insert RuleSetQrGroupTreatingPhysician

// Third launch context (patient + user come from RuleSetQrHeader): the hospitalisation Encounter
// read by the Hospitalisation sub-questionnaire's initialExpressions. Declared here, at the END of
// the root, because it is a Questionnaire-level extension and only roots with a "Verlauf" need it.
* insert RuleSetQrLaunchContextEncounter


// =================================================================================================
// OPEN QUESTIONS — Hepatitis C diverges from Gonorrhoea/Mpox here. NOTHING BELOW IS IMPLEMENTED.
// Mirrored in TODO.md; kept here too so the gap is visible next to the form it belongs to.
//
//  1. NO ChEkmHepatitisCManifestationForm logical model. Gonorrhoea and Mpox each refine
//     ChEkmManifestationForm per disease; CHEkmHepatitisCForm.fsh only defines the Person and the
//     Exposure sub-forms, and no disease-level aggregate `ChEkmHepatitisCForm` at all. The
//     manifestation item above therefore points at the generic model. Also unresolved: the
//     manifestation value set mixes real findings with "Keine"/"Unbekannt" from
//     ChEkmOtherNoneUnknown while the item is `repeats = true`, so "Ikterus + keine" is tickable.
//     (Same latent problem in Gonorrhoea; Mpox has the ChEkmOtherNoneUnknown include commented out.)
//
//  2. EXPOSITION "WIE" — the model and the paper form disagree, and neither is implementable yet.
//     ChEkmHepatitisCExposureForm.transmission is a verbatim copy of the Gonorrhoea STI block
//     (sexualContactPartner / relationshipType / otherTransmission / unknown). The CSV asks for a
//     completely different list: perinatal, contact with an infected person, sexual contact with an
//     infected person, injected/nasal drug use, transfusion(s), healthcare occupation, dialysis,
//     other, unknown — several with their own follow-up (family/workplace, partner sex, years since
//     transfusion). Blocking decisions: which list is authoritative; free text vs. coded for
//     "Andere"; and there is NO `ChEkmExposureHepatitisC` PROFILE — the Mapping in
//     CHEkmHepatitisCForm.fsh already targets `ch-ekm-exposure-hepatitisc`, which does not exist
//     (Gonorrhoea and Mpox both have theirs).
//
//  3. EXPOSITION "WEITERE" (further exposed persons: Sexualpartner / unborn or newborn child /
//     household members / andere, plus ja-nein-unbekannt). No form item, no model element, no
//     target element. The CSV maps it to `component.where(code='PART')`, which is not in any profile.
//
//  4. LABOR — the whole block (lab name, department, address, phone, email, BUR, GLN) and "Anlass"
//     (klinischer Verdacht / Exposition / Screening / anderer / unbekannt ->
//     ServiceRequest.reasonCode, value set ChEkmServiceRequestReason exists). The profiles are
//     there (ChEkmServiceRequest, ChEkmSpecimen, ChEkmOrganizationLab) and the example Bundle uses
//     them, but there is NO logical model and NO sub-questionnaire for a laboratory — this would be
//     the first one, and it is reusable across all organisms (a sibling of
//     ChEkmQuestionnaireTreatingPhysician).
//
//  5. DOKUMENTIERTE SEROKONVERSION — "ja, zuletzt negative Serologie anti-HCV vor der Diagnose am:
//     __ / nein / unbekannt". ChEkmComposition already has the slot
//     (`section[laboratory].entry[seroconversion]`, an unprofiled Observation), but no profile, no
//     model element and no question exist. Needs the same yes/no/unknown treatment decision as the
//     Impfstatus rows (issue #29): is "nein"/"unbekannt" an Observation value or no resource at all?
//
//  6. ANTIVIRALE THERAPIE — "ja, Therapiebeginn / nein / Therapiestart wird erwogen". The example
//     Bundle carries it as an Observation (`code = sct#427314002`, value =
//     `sct#386053000 Evaluation procedure`) in section[medication], and the CSV itself flags that
//     codification as uncertain. No profile, no model element, no question.
//
//  7. KRANKHEITSVERLAUF (akut / chronisch / Zirrhose / Hepatokarzinom / General wellbeing) is
//     currently a SEPARATE, non-modular questionnaire — ChEkmQuestionnaireHepatitisCCourseOfDisease
//     — referenced from `section[diagnosis].entry[questionnaire-response]` via the profile
//     ChEkmQuestionnaireResponseCourseOfDiseaseHepatitisC. Two incompatible designs are in the repo
//     at once: a nested QuestionnaireResponse inside the document, versus a question in THIS form
//     whose answer is extracted into a resource. Decide before wiring it in; the value set
//     (ChEkmHepatitisCCourseOfDisease) exists either way.
//
//  8. IMPFSTATUS — the CSV has the block, but it cannot be filled in as-is: it says
//     "targetDisease = gemeldete Erreger", and there is no hepatitis C vaccine. Presumably this
//     means the hepatitis A / hepatitis B vaccinations. The machinery is ready (issue #29:
//     RuleSetQrImmunizationRow + RuleSetImmunizationRow, one insert per vaccination type, plus a
//     per-disease ChEkmImmunizationHepatitisC / ChEkmObservationVaccinationStatusHepatitisC pair
//     fixing the target diseases and vaccine products) — only the question "which vaccinations does
//     the Hepatitis C form ask about?" is open.
//
//  9. PERSON — three CSV fields have no element in ChEkmPersonForm and therefore no question:
//     Herkunftsland (place of birth, ch-core-address-ech-11-placeofbirth), Adresse (address line)
//     and Telefon. ChEkmHepatitisCPersonForm does not add them either. Note ChEkmPatientInitials
//     forbids address line / telecom for privacy reasons — Hepatitis C uses the un-masked
//     ChEkmPatient, so the privacy argument does not carry over automatically.
//
// 10. EXPOSITION "WANN", second question — "Wenn unbekannt, wann war die letzte Einreise in die
//     Schweiz?" (`exposureWhenLastEntryDate` -> component[dateOfEntry]). The EXTRACTION side exists
//     and is generic (RuleSetEffectiveExposureWhen), and the ChEkmExposure profile has the
//     `dateOfEntry` slice — but the QUESTION is missing from ChEkmQuestionnaireExposureWhen; it
//     survives only as the commented-out block that used to live in this file:
//       * item[=].item[+].linkId = "exposureWhenLastEntryDate"
//       * item[=].item[=].definition = ".../ChEkmExposureForm#ChEkmExposureForm.when.lastEntryDate"
//       * item[=].item[=].type = #date
//       * item[=].item[=].enableWhen[+].question = "exposureWhenDate"
//       * item[=].item[=].enableWhen[=].operator = #exists
//       * item[=].item[=].enableWhen[=].answerBoolean = false
//     This affects Mpox too, not just Hepatitis C, so it belongs in the shared module.
//
// 11. TWO ROWS THE CSV MARKS AS "added by Yolanda Sabuco, not in the Google sheet":
//     "Ich habe für diese(n) Patient/in bereits eine Arztmeldung ... versendet" and "Diagnose seit
//     mehr als 1 Jahr bekannt". Both are annotated "QuestionnaireResponse level ??" — i.e. it is
//     not decided whether they are form-only routing questions (no FHIR target) or reportable data.
// =================================================================================================
