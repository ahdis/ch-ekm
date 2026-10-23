// Modular ROOT questionnaire for the Hepatitis C clinical findings report.
//
// Built from the SAME disease-agnostic sub-questionnaires Mpox and Gonorrhoea assemble
// (input/fsh/questionnnaire/), so `sushi . && ./assemble.sh` picks it up automatically: the root is
// discovered by its `assemble-expectation = assemble-root` extension, no script edit needed.
//
// STARTER SCOPE. Only the sections whose questions already exist as reusable modules AND whose
// target profiles exist for Hepatitis C are assembled here:
//   Person (FULL name)  ·  Diagnose/Manifestation + Labor  ·  Verlauf (Hospitalisation + Zustand)
//   Exposition Wo/Wann  ·  Behandelnde Ärztin/Arzt
// Everything the Hepatitis C reporting form asks on top of that is listed under OPEN QUESTIONS at the
// bottom of this file. Those are DELIBERATELY NOT MODELLED YET — each one needs a decision before a
// question can be written, and guessing would bake the guess into the extraction template.
//
// Sources reconciled here (they disagree in places — see OPEN QUESTIONS):
//   * logical model  input/fsh/logical/CHEkmHepatitisCForm.fsh   (the master, per AGENTS.md)
//   * profiles       input/fsh/profiles/ChEkmHepatitisC.fsh
//   * reporting form CSV "Meldung zum klinischen Befund Infektionskrankheit - Hepatitis C.csv"

Instance: ChEkmQuestionnaireHepatitisC
InstanceOf: Questionnaire
Usage: #example
Title: "EKM: Hepatitis C (modular)"
Description: "Modular root questionnaire for the Hepatitis C clinical findings report. Use Questionnaire/$assemble to produce the renderable form."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireHepatitisC"
* name = "ChEkmQuestionnaireHepatitisC"
* title = "EKM: Hepatitis C (modular)"

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
* insert RuleSetQrPersonContact
* insert RuleSetQrPersonGenderIdentity

// --- Diagnose und Manifestation -----------------------------------------------------------------
// Manifestationen — multiple-choice, check-boxes, bound to ChEkmHepatitisCManifestation
// (Ikterus, erhöhte Leberenzyme/Transaminasen). Andere/Keine/Unbekannt from ChEkmOtherNoneUnknown are
// commented out of the value set for now, as for Mpox (see ChEkmHepatitisCManifestation). Same shape
// as Mpox; Gonorrhoea is the single-choice variant.
//
// `definition` points at ChEkmHepatitisCManifestationForm, as the Gonorrhoea root does at its own
// manifestation sub-form.
* insert RuleSetQrGroupManifestation

// Diagnose im Rahmen einer Blutspende — the FIRST question of this section, before the
// manifestations. Disease-specific and not extracted into a resource, like the Krankheitsverlauf
// below: both modules are ALSO assembled, one after the other, into the disease-specific
// questionnaire ChEkmQuestionnaireHepatitisCDiseaseSpecific, which the response carried in the
// document answers. Two modules, two places on the form, one definition each.
* insert RuleSetQrBloodDonationHepatitisC

* insert RuleSetQrLevel3Item("manifestation", "Manifestations", "Manifestationen", "Manifestations", "Manifestazioni")
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmHepatitisCManifestationForm#ChEkmHepatitisCManifestationForm.manifestation"
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

// --- Krankheitsverlauf --------------------------------------------------------------------------
// akut / chronisch / Zirrhose / Hepatokarzinom / General wellbeing. A LEVEL-3 child of this section,
// like the Labor block below it. NOT extracted into a resource: the answer travels in the
// disease-specific QuestionnaireResponse that the document carries, as
// Composition.section[diagnosis].entry[questionnaire-response], and the profile on it
// (ChEkmQuestionnaireResponseDiseaseSpecificHepatitisC) has an invariant requiring exactly this
// linkId to be answered. See ChEkmQuestionnaireHepatitisCCourseOfDisease.fsh for the reasoning and
// ChEkmDocumentHepatitisCTemplate.fsh for how the QuestionnaireResponse gets into the Bundle.
* insert RuleSetQrCourseOfDiseaseHepatitisC

// --- Labor -------------------------------------------------------------------------------------
// The analysing laboratory, INSIDE the "Diagnose und Manifestation" section and after the
// Manifestationsbeginn/Krankheitsverlauf — so it is a sub-heading of the Diagnose tab, not a tab of
// its own. The nine
// CSV rows are all X-marked and identical to the invasive pneumococcal disease ones, so the module
// (ChEkmQuestionnaireLaboratory) is disease-agnostic and both roots assemble it unchanged. This
// closes the first half of OPEN QUESTION #4; "Anlass" is still open, and so is the seroconversion
// Observation the same section can carry (#5).
* insert RuleSetQrLaboratory

// --- Verlauf (course of the disease) ------------------------------------------------------------
// Hospitalisation + Zustand (Tot / Todesdatum / Todesursache). The Hepatitis C reporting form has both
// blocks (CSV rows "Hospitalisation" and "Zustand"), so the same two modules Mpox uses apply
// unchanged. Note the CSV comment on "Todesdatum" ("appears in the sheet but not in the PDF") — the
// module asks for it, which matches ChEkmDeathForm.
* insert RuleSetQrGroupCourse
* insert RuleSetQrHospitalisation
* insert RuleSetQrDeath

// --- Exposition ---------------------------------------------------------------------------------
// Wo before Wann, as on the reporting form (https://github.com/ahdis/ch-ekm/issues/26).
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
// "NASURE:" lines give the state of the FOPH form-harmonisation discussion (export of 2026-10-20).
//
//  1. LOGICAL MODEL — IMPLEMENTED. ChEkmHepatitisCForm is the disease-level aggregate, with
//     ChEkmHepatitisCPersonForm and ChEkmHepatitisCManifestationForm (incl. Krankheitsverlauf) as its
//     own sub-forms; the manifestation and hepatitisc-course-of-disease items point at the latter. Still
//     to discuss: how to answer "Keine"/"Unbekannt"/"Andere". Mixed into the value set while the item is
//     `repeats = true`, "Ikterus + keine" was tickable, so the ChEkmOtherNoneUnknown include is commented
//     out (as for Mpox) and an unanswered item now covers all three. (Same latent problem in Gonorrhoea.)
//     Decided (meeting 4.5): coded answers only, "Andere" without free text.
//     NASURE: MT-DAT and P&P prefer reducing the manifestation to symptomatisch / asymptomatisch (as
//     Gonorrhoea); EPI wants several boxes tickable and no "Transaminasen nicht erhöht". If the
//     reduction wins, the item takes the Gonorrhoea two-option shape and the "Ikterus + keine" problem
//     goes away.
//
//  2. EXPOSITION "WIE" — the model and the reporting form disagree, and neither is implementable yet.
//     ChEkmHepatitisCExposureForm.transmission is a verbatim copy of the Gonorrhoea STI block
//     (sexualContactPartner / relationshipType / otherTransmission / unknown). The CSV asks for a
//     completely different list: perinatal, contact with an infected person, sexual contact with an
//     infected person, injected/nasal drug use, transfusion(s), healthcare occupation, dialysis,
//     other, unknown — several with their own follow-up (family/workplace, partner sex, years since
//     transfusion). Blocking decisions: which list is authoritative; free text vs. coded for
//     "Andere"; and there is NO `ChEkmExposureHepatitisC` PROFILE — the Mapping in
//     CHEkmHepatitisCForm.fsh already targets `ch-ekm-exposure-hepatitisc`, which does not exist
//     (Gonorrhoea and Mpox both have theirs).
//     NASURE: discussed — P&P want the order and wording changed and perinatal moved to "Wann"; EPI
//     want perinatal kept here (one place for exposures; a child is not necessarily perinatal).
//     Coding proposal from the earlier mapping sheet (not reviewed, kept so it is not lost):
//       perinatal                          sct#1381730000 Perinatal fetal and/or neonatal infection
//       contact with infected person       sct#409753000  Contact with person with contagious disease
//         (follow-up family / workplace / other as a component, code EXSRC)
//       sexual contact with infected person sct#8098009   Sexually transmitted infectious disease
//         (partner sex as a component, code EXSRC)
//       drug use, injected / nasal         sct#226034001  Injecting drug user / sct#228381000 Sniffs drugs
//       transfusion(s)                     sct#119426009  Transfusion-transmitted infectious disease
//         (years as a component valueQuantity; component code not found)
//       healthcare occupation              sct#223366009  Healthcare professional
//       dialysis                           sct#216933008  Failure of sterile precautions during kidney dialysis
//       other / unknown                    sct#74964007   Other / sct#261665006 Unknown
//
//  3. EXPOSITION "WEITERE" (further exposed persons: Sexualpartner / unborn or newborn child /
//     household members / andere, plus ja-nein-unbekannt). No form item, no model element, no
//     target element. The CSV maps it to `component.where(code='PART')`, which is not in any profile.
//     NASURE: leaning to drop — P&P: only useful if contact tracing is wanted; EPI agree; the cantons
//     (workshop 17.11.2025) do not need it for Hepatitis C. Same for "Berufliche Tätigkeit".
//
//  4. LABOR — the ORGANISATION half is now IMPLEMENTED. The nine X-marked rows (lab name,
//     department, address, phone, email, BUR, GLN) are the shared, disease-agnostic
//     sub-questionnaire ChEkmQuestionnaireLaboratory, assembled INSIDE the Diagnose section right
//     after the Manifestationsbeginn, with the logical model ChEkmLabForm behind it; they extract
//     into ChEkmOrganizationLab, reached from ChEkmServiceRequest.performer in
//     Composition.section[laboratory]. It is the first lab module in the IG and is shared with the
//     invasive pneumococcal disease root unchanged.
//     STILL OPEN: "Anlass" (klinischer Verdacht / Exposition / Screening / anderer / unbekannt ->
//     ServiceRequest.reasonCode, value set ChEkmServiceRequestReason exists) — the CSV gives two
//     different answer lists for it. It attaches to the ChEkmServiceRequest the form already
//     extracts, so adding it later disturbs nothing.
//     NASURE: the list is klinischer Verdacht / Exposition / Screening / anderer / unbekannt (the
//     CSV's first list). P&P: the categories are not clear-cut and follow from the manifestation;
//     EPI: keep it. Whether the Labor block itself stays on this form is still marked "?" there
//     (Gonorrhoea dropped it as already in the lab report; Mpox has no decision).
//
//  5. DOKUMENTIERTE SEROKONVERSION — "ja, zuletzt negative Serologie anti-HCV vor der Diagnose am:
//     __ / nein / unbekannt". ChEkmComposition already has the slot
//     (`section[laboratory].entry[seroconversion]`, an unprofiled Observation), but no profile, no
//     model element and no question exist. Needs the same yes/no/unknown treatment decision as the
//     Impfstatus rows (issue #29): is "nein"/"unbekannt" an Observation value or no resource at all?
//     NASURE: EPI: must stay, with the date (needed to classify cases as acute); P&P: may move
//     under Krankheitsverlauf.
//
//  6. ANTIVIRALE THERAPIE — "ja, Therapiebeginn / nein / Therapiestart wird erwogen". The example
//     Bundle carries it as an Observation (`code = sct#427314002`, value =
//     `sct#386053000 Evaluation procedure`) in section[medication], and the CSV itself flags that
//     codification as uncertain. No profile, no model element, no question.
//     NASURE: both proposals ask "nein / ja, Therapiebeginn" — "Therapiestart wird erwogen" is in
//     neither, so the uncertain coding goes with it. P&P: relevant for the care cascade, maybe "mit
//     DAA"; EPI: for Hepatitis C yes, not for B. Whether it is asked at all is still open.
//
//  7. KRANKHEITSVERLAUF — DECIDED AND IMPLEMENTED, see the section above, and since then
//     generalised to every DISEASE-SPECIFIC question without a FHIR target. Each such question is a
//     module of its own (ChEkmQuestionnaireHepatitisCCourseOfDisease,
//     ChEkmQuestionnaireHepatitisCBloodDonation), assembled into THIS form where it belongs and into
//     the disease-specific questionnaire ChEkmQuestionnaireHepatitisCDiseaseSpecific. The answers are
//     NOT extracted into resources: $extract copies the modules' items into a QuestionnaireResponse
//     to the disease-specific questionnaire, which `section[diagnosis].entry[questionnaire-response]`
//     carries (mandatory); ChEkmQuestionnaireResponseDiseaseSpecificHepatitisC constrains it
//     (invariants `ch-ekm-qr-hepatitisc-questionnaire`, `ch-ekm-qr-hepatitisc-course`). Every other
//     answer goes into a resource and is not repeated in that response.
//     NASURE: the Krankheitsverlauf proposal is now akut / chronisch / virämisch / avirämisch, with
//     Zirrhose and Hepatokarzinom moved to the manifestation — not what ChEkmHepatitisCCourseOfDisease
//     offers. The blood-donation question is not on the NASURE page.
//
//  8. IMPFSTATUS — DECIDED: NOT ASKED. Hepatitis C has no vaccine, so the CSV's
//     "targetDisease = gemeldete Erreger" cannot be filled in, and asking about the hepatitis A /
//     hepatitis B vaccinations instead would be a different question than the form states. No
//     ChEkmImmunizationHepatitisC / ChEkmObservationVaccinationStatusHepatitisC pair is created and
//     `Composition.section[immunization]` stays empty for this organism. The shared machinery
//     (issue #29: RuleSetQrImmunizationRow + RuleSetImmunizationRow) is untouched and remains
//     available should the FOPH later decide the form asks about hepatitis A/B after all.
//
//  9. PERSON — three CSV fields have no element in ChEkmPersonForm and therefore no question:
//     Herkunftsland (place of birth, ch-core-address-ech-11-placeofbirth), Adresse (address line)
//     and Telefon. ChEkmHepatitisCPersonForm does not add them either. Note ChEkmPatientInitials
//     forbids address line / telecom for privacy reasons — Hepatitis C uses the un-masked
//     ChEkmPatient, so the privacy argument does not carry over automatically.
//     NASURE: address (Strasse, Nr.), phone and e-mail are part of the harmonised full-name person
//     block (with AHV), so they are to be implemented, not discussed. Herkunftsland is an open
//     cross-cutting topic (P&P: RKI definition; EPI: parents' origin / place of birth for hepatitis;
//     MT-DAT: keep Nationalität, add origin only where relevant).
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
//     NASURE: the NASURE proposal asks only the most likely date of infection; departure / entry
//     dates are from the April 2025 form, so this question is probably NOT to be added. For
//     Hepatitis C P&P propose "infected as a child / as an adult" + approximate year, and EPI want
//     year-only answers for chronic cases. "Wann" is still open.
//
// 11. TWO ROWS THE CSV MARKS AS "added by Yolanda Sabuco, not in the Google sheet" (if they are
//     reportable data, they become disease-specific modules like the blood-donation question, see #7):
//     "Ich habe für diese(n) Patient/in bereits eine Arztmeldung ... versendet" and "Diagnose seit
//     mehr als 1 Jahr bekannt". Both are annotated "QuestionnaireResponse level ??" — i.e. it is
//     not decided whether they are form-only routing questions (no FHIR target) or reportable data.
//     NASURE: both are on the Hepatitis C page. "Bereits eine Arztmeldung": P&P see no surveillance
//     relevance, EPI still use it to remove cases reported before the 2011 anonymisation. "Seit mehr
//     als 1 Jahr bekannt (Jahr)" is in both proposals. "Diagnosedatum" is dropped (first lab report).
// =================================================================================================
