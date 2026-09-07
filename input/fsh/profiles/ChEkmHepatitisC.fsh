Profile: ChEkmDocumentHepatitisC
Parent: ChEkmDocument
Id: ch-ekm-document-hepatitisc
Title: "CH EKM-Document: Clinical findings HepatitisC"
Description: "This profile constrains the Bundle resource for the purpose of clinical findings for Hepatitis C."
* entry[Composition].resource only ChEkmCompositionHepatitisC

Profile: ChEkmCompositionHepatitisC
Parent: ChEkmComposition
Id: ch-ekm-composition-hepatitisc
Title: "CH EKM Composition: Clinical Findings HepatitisC"
Description: "This CH EKM base profile constrains the Composition resource for the purpose of clinical findings for Hepatitis C."
* subject only Reference(ChEkmPatient)
* section[diagnosis].entry[condition] only Reference(ChEkmConditionHepatitisC)
// MANDATORY for Hepatitis C (0..1 in the base ChEkmComposition). The "Krankheitsverlauf" question
// has no resource target — it is carried by the form's own QuestionnaireResponse, which therefore
// has to be part of the document. See ChEkmQuestionnaireResponseCourseOfDiseaseHepatitisC.
* section[diagnosis].entry[questionnaire-response] 1..1
* section[diagnosis].entry[questionnaire-response] only Reference(ChEkmQuestionnaireResponseCourseOfDiseaseHepatitisC)

// The QuestionnaireResponse the Hepatitis C document carries. It is the response to the WHOLE form
// (ChEkmQuestionnaireHepatitisC, or rather its $assemble output), not to a questionnaire of its
// own: since TODO.md #7 was decided, ChEkmQuestionnaireHepatitisCCourseOfDisease is an
// assemble-child of that form and no longer a standalone questionnaire.
//
// What this profile asserts is the one thing the document would otherwise lose — that the
// Krankheitsverlauf was answered. It asserts it with a FHIRPath invariant on the linkId rather than
// with a structural slice, because QuestionnaireResponse.item is not sliceable by linkId at an
// arbitrary depth.
//
// `questionnaire` is deliberately left at 0..1 and NOT fixed. Not fixed, because a sender may
// legitimately quote either the assembled canonical
// (http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireHepatitisCAssembled, which is what
// $populate and $extract use) or a versioned form of it. Not 1..1, because the $extract TEMPLATE is
// a QuestionnaireResponse that has to conform to this profile too, and it can carry neither a
// questionnaire nor an answer until extraction fills them in — see the long note on
// ExtractedQuestionnaireResponseHepatitisC in ChEkmDocumentHepatitisCTemplate.fsh for why naming a
// questionnaire in the template costs 12 validation errors. The invariant is guarded to match:
// a response that names a questionnaire (`questionnaire.hasValue()` — the template has the element
// but no value) must answer the question.
Profile: ChEkmQuestionnaireResponseCourseOfDiseaseHepatitisC
Parent: QuestionnaireResponse
Id: ch-ekm-questionnaireresponse-hepatitisc-courseofdisease
Title: "CH EKM Questionnaire Response: Course of Disease - HepatitisC"
Description: "This CH EKM base profile constrains the QuestionnaireResponse resource carried in the Hepatitis C document: it is the response to the Hepatitis C reporting form, and it must answer the 'course-of-disease' question, which has no other target in the document."
* obeys ch-ekm-qr-hepatitisc-course
* questionnaire ^short = "The Hepatitis C reporting form this is a response to (the $assemble output of ChEkmQuestionnaireHepatitisC). Present on every real response; absent only in the $extract template."
* status ^short = "A response carried in a final document is expected to be 'completed'"

Profile: ChEkmConditionHepatitisC
Parent: ChEkmCondition
Id: ch-ekm-condition-hepatitisc
Title: "CH EKM Condition: HepatitisC"
Description: "This CH EKM base profile constrains the Condition resource for the purpose of clinical findings for Hepatitis C."
* code = $sct#50711007 "Viral hepatitis type C (disorder)"
* evidence.code from ChEkmHepatitisCManifestation (required)