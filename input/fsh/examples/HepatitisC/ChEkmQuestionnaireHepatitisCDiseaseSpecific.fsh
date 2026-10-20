// Modular ROOT of the DISEASE-SPECIFIC questionnaire for Hepatitis C: the questions of the form that
// have no FHIR target, and nothing else.
//
// WHY IT EXISTS. Most of the Hepatitis C form is extracted into profiled resources. What cannot be
// — today the Krankheitsverlauf and the blood-donation question — travels in the document as a
// QuestionnaireResponse (Composition.section[diagnosis].entry[questionnaire-response]). That response
// must name a questionnaire its items can be validated against, and the reporting form itself is the
// wrong one: the response holds only these few items, so against the full form every required
// question elsewhere would be reported missing. This questionnaire is the right one — the response
// names its assembled form, ChEkmQuestionnaireHepatitisCDiseaseSpecificAssembled.
//
// NOTHING IS WRITTEN TWICE. It holds no questions of its own: it assembles the SAME modules the
// reporting form assembles (ChEkmQuestionnaireHepatitisCBloodDonation,
// ChEkmQuestionnaireHepatitisCCourseOfDisease), so a question is defined once and the two
// questionnaires cannot drift apart. On the form the modules sit where they belong, in different
// places; here they are simply listed, in an order of their own, inside ONE group
// (`hepatitisc-disease-specific`) — $assemble only resolves sub-questionnaires nested in a group.
// The extraction template copies the items in THIS order (QuestionnaireResponse validation checks
// the order), so a new module is added here AND as a placeholder in ExtractedQuestionnaireResponse-
// HepatitisC (ChEkmDocumentHepatitisCTemplate.fsh), at the same position.
//
// NOT A FORM ANYONE FILLS IN. No launch context, no extraction template, no tabs. It is still a
// modular root (assemble-root), so scripts/assemble.sh finds and assembles it like the others.
// It does NOT use RuleSetQrHeaderSdc: that header claims the extraction-template profile, which a
// questionnaire without a contained template must not claim.

Instance: ChEkmQuestionnaireHepatitisCDiseaseSpecific
InstanceOf: Questionnaire
Usage: #example
Title: "EKM: Hepatitis C disease-specific questions (modular)"
Description: "Modular root of the disease-specific Hepatitis C questionnaire: the form questions without a FHIR target, assembled from the same modules as the reporting form. The QuestionnaireResponse carried in the Hepatitis C document answers its $assemble output."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireHepatitisCDiseaseSpecific"
* name = "ChEkmQuestionnaireHepatitisCDiseaseSpecific"
* title = "EKM: Hepatitis C disease-specific questions (modular)"
* status = #active
* language = #en
* experimental = false
* meta.profile[+] = $sdc-modular
* subjectType = #Patient
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-root
* extension[+].url = $artifact-versionAlgorithm
* extension[=].valueCoding = $version-algorithm#semver

* item[+].linkId = "hepatitisc-disease-specific"
* insert RuleSetQrLevel1Text("Hepatitis C: disease-specific questions", "Hepatitis C: krankheitsspezifische Fragen", "Hépatite C : questions spécifiques à la maladie", "Epatite C: domande specifiche della malattia")
* item[=].type = #group
* insert RuleSetQrLevel2SubQuestionnaire("blooddonation", "Diagnosis from blood donation", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireHepatitisCBloodDonation")
* insert RuleSetQrLevel2SubQuestionnaire("courseofdisease", "Course of the disease", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireHepatitisCCourseOfDisease")
