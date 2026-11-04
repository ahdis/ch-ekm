// Modular sub-questionnaire: "Wie (Übertragungsweg)" for Mpox (issue #44).
//
// The shared "Wie" (ChEkmQuestionnaireExposureHow) plus three contact questions, each ja / nein /
// unbekannt, asked ABOVE "Anderer Übertragungsweg":
//   Kontakt als Medizinal- / Pflegepersonal
//   Kontakt im Haushalt
//   Kontakt mit laborbestätigtem Mpox-Fall
// Disease-specific only in its arrangement and in the word "Mpox": every item comes from the shared
// rule sets in ChEkmQuestionnaireExposureHow.fsh (read its header for why this needs a module of its
// own), and the answers extract into the shared component slices of the base ChEkmExposure
// (RuleSetComponentExposureContacts). A second disease asking the same questions writes a file like
// this one, with its own form model and case label.
//
// Same group linkId (`exposureHow`) and the same item linkIds as the shared module, so every
// extraction rule for "Wie" applies unchanged.

Instance: ChEkmQuestionnaireExposureHowMpox
InstanceOf: Questionnaire
Usage: #definition
Title: "EKM: Exposure - How (route of transmission) - Mpox"
Description: "Modular sub-questionnaire for the 'Wie (Übertragungsweg)' (route of transmission) group of the Mpox report: sexual-contact partner sex, relationship type, contact as medical / nursing staff, contact in the household, contact with a laboratory-confirmed mpox case, other route, unknown. Reusable as an SDC assemble-child."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireExposureHowMpox)

* item[+].linkId = "exposureHow"
* insert RuleSetQrLevel1Text("How (route of transmission\)", "Wie (Übertragungsweg\)", "Comment (voie de transmission\)", "Come (via di trasmissione\)")
* item[=].type = #group
* insert RuleSetQrExposureHowSexualContact
* insert RuleSetQrExposureHowContacts(ChEkmMpoxExposureForm, "Contact with a laboratory-confirmed mpox case", "Kontakt mit laborbestätigtem Mpox-Fall", "Contact avec un cas de mpox confirmé en laboratoire", "Contatto con un caso di mpox confermato in laboratorio")
* insert RuleSetQrExposureHowOtherUnknown
