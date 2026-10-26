Profile: ChEkmDocumentHepatitisC
Parent: ChEkmDocument
Id: ch-ekm-document-hepatitisc
Title: "CH EKM-Document: Clinical findings Hepatitis C"
Description: "This profile constrains the Bundle resource for the purpose of clinical findings for Hepatitis C."
* entry[Composition].resource only ChEkmCompositionHepatitisC

Profile: ChEkmCompositionHepatitisC
Parent: ChEkmComposition
Id: ch-ekm-composition-hepatitisc
Title: "CH EKM Composition: Clinical Findings Hepatitis C"
Description: "This CH EKM base profile constrains the Composition resource for the purpose of clinical findings for Hepatitis C."
* subject only Reference(ChEkmPatient)
* section[diagnosis].entry[condition] only Reference(ChEkmConditionHepatitisC)
// The disease-specific questions (Krankheitsverlauf, Diagnose im Rahmen einer Blutspende) have no
// resource target — they are carried by the disease-specific QuestionnaireResponse. Both are optional
// on the form, so the entry keeps the 0..1 of the base ChEkmComposition: a report that answers
// neither carries no response. See ChEkmQuestionnaireResponseDiseaseSpecificHepatitisC.
* section[diagnosis].entry[questionnaire-response] only Reference(ChEkmQuestionnaireResponseDiseaseSpecificHepatitisC)

// The QuestionnaireResponse the Hepatitis C document carries: the answers to the form questions that
// have no FHIR target, and ONLY those. It is the response to the DISEASE-SPECIFIC questionnaire
// (ChEkmQuestionnaireHepatitisCDiseaseSpecificAssembled), which assembles the same modules as the
// reporting form; $extract copies those modules' items out of the form's response. So every answer
// is sent once: as a resource if it has a FHIR target, as an item of this response if it has not.
//
// What this profile asserts, with a FHIRPath invariant rather than a fixed value:
//   * ch-ekm-qr-hepatitisc-questionnaire: it answers the disease-specific questionnaire, not the
//     reporting form — against the form, every required question it does not hold would be missing.
// It does NOT require any particular answer: both questions are optional on the form
// (ChEkmHepatitisCManifestationForm). The item tree itself is validated against the questionnaire it
// names, by the validator's QuestionnaireResponse checks (linkIds, types, answer value sets, order).
//
// `questionnaire` is deliberately left at 0..1 and NOT fixed, and the invariant is guarded on
// `questionnaire.hasValue()`: the $extract TEMPLATE is a QuestionnaireResponse that has to conform to
// this profile too, and it can carry neither a questionnaire value nor an answer until extraction
// fills them in — see the long note on ExtractedQuestionnaireResponseHepatitisC in
// ChEkmDocumentHepatitisCTemplate.fsh for why naming a questionnaire in the template costs 12
// validation errors. The template has the element but no value; a real response has both.
Profile: ChEkmQuestionnaireResponseDiseaseSpecificHepatitisC
Parent: QuestionnaireResponse
Id: ch-ekm-questionnaireresponse-hepatitisc-diseasespecific
Title: "CH EKM Questionnaire Response: Disease-specific questions - Hepatitis C"
Description: "This CH EKM base profile constrains the QuestionnaireResponse resource carried in the Hepatitis C document: the answers to the form questions that have no FHIR target (Krankheitsverlauf, diagnosis from blood donation). It is the response to the disease-specific questionnaire ChEkmQuestionnaireHepatitisCDiseaseSpecificAssembled, or to its language variant matching the form that was filled in. It is carried in the document only when at least one of these questions was answered."
* obeys ch-ekm-qr-hepatitisc-questionnaire
* questionnaire ^short = "The disease-specific Hepatitis C questionnaire this is a response to (ChEkmQuestionnaireHepatitisCDiseaseSpecificAssembled or its -de-CH / -fr-CH / -it-CH variant, as the form that was filled in). Present on every real response; absent only in the $extract template."
* status ^short = "A response carried in a final document is expected to be 'completed'"

Profile: ChEkmConditionHepatitisC
Parent: ChEkmCondition
Id: ch-ekm-condition-hepatitisc
Title: "CH EKM Condition: Hepatitis C"
Description: "This CH EKM base profile constrains the Condition resource for the purpose of clinical findings for Hepatitis C."
* code = $sct#50711007 "Viral hepatitis type C (disorder)"
* evidence.code from ChEkmHepatitisCManifestation (required)