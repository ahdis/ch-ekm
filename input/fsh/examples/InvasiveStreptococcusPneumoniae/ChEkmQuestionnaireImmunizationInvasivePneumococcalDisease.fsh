// Modular sub-questionnaire: "Impfstatus" for invasive pneumococcal disease — the section that
// follows the Exposition section on the reporting form (https://github.com/ahdis/ch-ekm/issues/29).
//
// Source of truth: logical model ChEkmImmunizationForm (-> ChEkmImmunizationInvasivePneumococcalDisease),
// one instance of that model per row.
//
// This file is disease-SPECIFIC — like examples/Mpox/ChEkmQuestionnaireImmunizationMpox.fsh, and
// unlike the children in input/fsh/questionnnaire/ — because which vaccinations are asked about is
// a property of the disease. What is shared lives in RuleSetQrImmunizationRow: the four questions,
// their item controls, the enableWhen wiring on "yes" and all four languages. This organism is the
// second one to use it, and it needed no change to do so.
//
// ONE ROW, per the CSV ("targetDisease = gemeldete Erreger", example "Prevenar 13", "ja, mit total
// 2 Dosen"):
//   Pneumokokkenimpfung -> targetDisease sct#16814004 Pneumococcal infectious disease
// The target disease code itself is not in this questionnaire — it is not an answer, it identifies
// the row, and it is supplied by the extraction template (RuleSetImmunization*) and constrained by
// ChEkmImmunizationInvasivePneumococcalDisease /
// ChEkmInvasivePneumococcalDiseaseImmunizationTargetDisease.
//
// ONE ROW COVERS BOTH VACCINE FAMILIES. The conjugate vaccines (Prevenar 13/20) and the
// polysaccharide one (Pneumovax 23) are not separate rows: the form asks "vaccinated against
// pneumococci?", and which product it was is the fourth question (an open choice against the Swiss
// vaccine list). Splitting the row would mean asking the dose count twice for one vaccination
// history.
//
// TOTAL DOSES, NOT ONE RESOURCE PER DOSE. "mit total ___ Dosen" is one number and the date is the
// date of the LAST dose, so one answered row extracts to exactly ONE Immunization with
// protocolApplied.doseNumberPositiveInt = the total. The example Bundle
// ChEkmBundleInvasiveStreptococcusPneumoniae carries one Immunization per dose instead; see the
// note on ChEkmImmunizationInvasivePneumococcalDisease for why the form cannot produce that shape.
//
// NOT ASKED: "Gemäss: Impfausweis / Hausarzt / Anamnese" (the source of the vaccination
// information). The CSV annotates it "Questionnaire Response level", i.e. it has no FHIR target,
// and it is deliberately left out of this form.
//
// NO PRE-POPULATION. Unlike the Hospitalisation and Death children there is no initialExpression
// here: the vaccination history lives in Immunization resources, which no SDC launch context
// carries (%patient / %user / %encounter). The form asks.

Instance: ChEkmQuestionnaireImmunizationInvasivePneumococcalDisease
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Immunization invasive pneumococcal disease"
Description: "Modular sub-questionnaire for the 'Impfstatus' section of the invasive pneumococcal disease report: for the pneumococcal vaccination, whether the affected person was vaccinated, with how many doses in total, when the last dose was given and with which product. Reusable as an SDC assemble-child."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireImmunizationInvasivePneumococcalDisease)

// The child's root group becomes the tab itself after $assemble replaces the level-2 placeholder in
// the root with it, so the tab label lives here (see
// RuleSetQrGroupImmunizationInvasivePneumococcalDisease).
* item[+].linkId = "immunization"
* insert RuleSetQrLevel1Text("Immunisation status", "Impfstatus", "Statut vaccinal", "Stato vaccinale")
* insert RuleSetQrLevel1ShortText("Immunisation", "Impfstatus", "Vaccination", "Vaccinazione")
* item[=].type = #group

* insert RuleSetQrImmunizationRow(Pneumococcal, "Pneumococcal vaccination", "Pneumokokkenimpfung", "Vaccination contre les pneumocoques", "Vaccinazione antipneumococcica")
