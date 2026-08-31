// Modular sub-questionnaire: "Impfstatus" for Mpox — the section that follows the Exposition
// section on the reporting form (https://github.com/ahdis/ch-ekm/issues/29).
//
// Source of truth: logical model ChEkmImmunizationForm (-> ChEkmImmunizationMpox), one instance of
// that model per row.
//
// This file is disease-SPECIFIC — like ChEkmQuestionnaireHepatitisCCourseOfDisease, and unlike the
// children in input/fsh/questionnnaire/ — because which vaccinations are asked about is a property
// of the disease. What is shared lives in RuleSetQrImmunizationRow: the four questions, their item
// controls, the enableWhen wiring on "yes" and all four languages. A second organism writes a file
// like this one with its own rows and inherits everything else. See the rule set's header for why
// the rows are fixed rather than a repeating "add a vaccination" group.
//
// TWO ROWS, per the issue:
//   Pockenimpfung       -> targetDisease sct#67924001  Smallpox   (the historical programmes;
//                          routine vaccination ended in Switzerland in the 1970s, so a "yes" here is
//                          typically an elderly patient with an unknown dose count)
//   Affenpockenimpfung  -> targetDisease sct#359814004 Mpox       (MVA-BN, i.e. Jynneos / Imvanex)
// The target disease codes themselves are not in this questionnaire — they are not answers, they
// identify the row, and they are supplied by the extraction template (RuleSetImmunizationRow) and
// constrained by ChEkmImmunizationMpox / ChEkmMpoxImmunizationTargetDisease.
//
// NO PRE-POPULATION. Unlike the Hospitalisation and Death children there is no initialExpression
// here: the vaccination history lives in Immunization resources, which no SDC launch context
// carries (%patient / %user / %encounter). The form asks. Should a launch context for it ever
// appear, the four items are the natural place to add one.

Instance: ChEkmQuestionnaireImmunizationMpox
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Immunization Mpox"
Description: "Modular sub-questionnaire for the 'Impfstatus' section of the Mpox report: per vaccination type asked about (smallpox vaccination, mpox vaccination) whether the affected person was vaccinated, with how many doses in total, when the last dose was given and with which product. Reusable as an SDC assemble-child."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireImmunizationMpox)

// The child's root group becomes the tab itself after $assemble replaces the level-2 placeholder in
// the root with it, so the tab label lives here (see RuleSetQrGroupImmunizationMpox).
* item[+].linkId = "immunization"
* insert RuleSetQrLevel1Text("Immunisation status", "Impfstatus", "Statut vaccinal", "Stato vaccinale")
* insert RuleSetQrLevel1ShortText("Immunisation", "Impfstatus", "Vaccination", "Vaccinazione")
* item[=].type = #group

* insert RuleSetQrImmunizationRow(Smallpox, "Smallpox vaccination — earlier smallpox vaccination programmes", "Pockenimpfung — frühere Pockenimpfprogramme", "Vaccination contre la variole — anciens programmes de vaccination", "Vaccinazione antivaiolosa — precedenti programmi di vaccinazione")

* insert RuleSetQrImmunizationRow(Mpox, "Mpox vaccination", "Affenpockenimpfung", "Vaccination contre le mpox", "Vaccinazione contro il vaiolo delle scimmie")
