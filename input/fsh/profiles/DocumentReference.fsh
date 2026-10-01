// Storing an extracted report on the SMART on FHIR server the form was launched from.
//
// A document Bundle cannot be linked to the patient it is about: `Bundle` has no `subject`, and the
// Patient INSIDE the document is the report's own (masked, initials-only for some organisms) copy,
// not the patient record on the launching server. So the $extract output is a TRANSACTION of two
// entries — the document Bundle and a DocumentReference that indexes it — and the DocumentReference
// carries the link to the launching server's patient (`subject` = QuestionnaireResponse.subject).

Profile: ChEkmDocumentReference
Parent: CHCoreDocumentReference
Id: ch-ekm-documentreference
Title: "CH EKM DocumentReference"
Description: "Indexes a CH EKM document Bundle stored on a FHIR server and links it to the patient record on that server. Created by $extract together with the document (see ChEkmExtractTransaction)."
* . ^short = "CH EKM DocumentReference: index entry for a stored clinical findings report"
* status = #current
* masterIdentifier 1..1
* masterIdentifier ^short = "The document Bundle's identifier (Bundle.identifier)"
* masterIdentifier.system 1..1
* masterIdentifier.system = "urn:ietf:rfc:3986"
* masterIdentifier.value 1..1
// Same type / category as the Composition (ChEkmComposition), so a search on the DocumentReference
// finds the same reports as one on the documents.
* type 1..1
* type = $sct#722143004 "Infectious disease diagnostic study note"
* category 1..1
* category = $sct#423876004 "Clinical report"
* subject 1..1
* subject only Reference(CHCorePatient)
* subject obeys ch-ekm-docref-subject-patient
* subject ^short = "The patient record on the server the report is stored on (QuestionnaireResponse.subject), NOT the Patient inside the document"
* author 1..1
* author only Reference(CHCorePractitioner)
* author obeys ch-ekm-docref-author-practitioner
* author ^short = "The treating physician: the Practitioner on the server the report is stored on, NOT the copy inside the document"
* content 1..1
* content.attachment.contentType 1..1
* content.attachment.contentType = #application/fhir+json
// By reference only: the document is a resource of its own on the same server.
* content.attachment.url 1..1
* content.attachment.url ^short = "Location of the document Bundle (in the transaction: the document entry's fullUrl)"
* content.attachment.data 0..0

Profile: ChEkmExtractTransaction
Parent: Bundle
Id: ch-ekm-extract-transaction
Title: "CH EKM Extract Transaction"
Description: "The output of SDC template-based $extract on a CH EKM questionnaire: a transaction that stores the document Bundle (ChEkmDocument) and a DocumentReference (ChEkmDocumentReference) linking it to the patient record on the server."
* . ^short = "CH EKM Extract Transaction: document Bundle + DocumentReference"
* obeys ch-ekm-docref-document
* type = #transaction
* entry 2..2
* entry ^slicing.discriminator.type = #type
* entry ^slicing.discriminator.path = "resource"
* entry ^slicing.rules = #closed
* entry ^slicing.description = "Slice by resource type"
* entry contains document 1..1 and documentReference 1..1
* entry[document].fullUrl 1..1
* entry[document].resource 1..1
* entry[document].resource only ChEkmDocument
* entry[document].request 1..1
* entry[documentReference].resource 1..1
* entry[documentReference].resource only ChEkmDocumentReference
* entry[documentReference].request 1..1
