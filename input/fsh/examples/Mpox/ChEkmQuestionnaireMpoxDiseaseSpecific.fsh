// Modular ROOT of the DISEASE-SPECIFIC questionnaire for Mpox: the questions of the form that have no
// FHIR target, and nothing else. Today one module, the close contact after the onset of the
// manifestation (issue #43, ChEkmQuestionnaireMpoxCloseContact).
//
// Same construction as ChEkmQuestionnaireHepatitisCDiseaseSpecific — read its header for the why:
// the response in the document holds only these items, so it cannot name the reporting form
// (every required question elsewhere would be missing); it names THIS questionnaire's assembled
// form, ChEkmQuestionnaireMpoxDiseaseSpecificAssembled, instead. It assembles the SAME module the
// reporting form assembles, inside ONE group (`mpox-disease-specific`), so the question is defined
// once.
//
// ADDING A MODULE = its insert here AND in the form, at the same relative position, and its linkId
// in the extraction template (ExtractedQuestionnaireResponseMpox and the two gates in
// ChEkmDocumentMpoxTemplate.fsh).
//
// NOT A FORM ANYONE FILLS IN. No launch context, no extraction template, no tabs, and therefore
// not uploaded to the Forms Server by `assemble.sh --upload`.

Instance: ChEkmQuestionnaireMpoxDiseaseSpecific
InstanceOf: Questionnaire
Usage: #example
Title: "EKM: Mpox disease-specific questions (modular)"
Description: "Modular root of the disease-specific Mpox questionnaire: the form questions without a FHIR target, assembled from the same modules as the reporting form. The QuestionnaireResponse carried in the Mpox document answers its $assemble output."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireMpoxDiseaseSpecific"
* name = "ChEkmQuestionnaireMpoxDiseaseSpecific"
* title = "EKM: Mpox disease-specific questions (modular)"
* status = #active
* language = #en
* experimental = false
* meta.profile[+] = $sdc-modular
* subjectType = #Patient
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-root
* extension[+].url = $artifact-versionAlgorithm
* extension[=].valueCoding = $version-algorithm#semver

* item[+].linkId = "mpox-disease-specific"
* insert RuleSetQrLevel1Text("Mpox: disease-specific questions", "Mpox: krankheitsspezifische Fragen", "Mpox : questions spécifiques à la maladie", "Mpox: domande specifiche della malattia")
* item[=].type = #group
* insert RuleSetQrLevel2SubQuestionnaire("closecontact", "Close contact after the onset of the manifestation", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireMpoxCloseContact")
