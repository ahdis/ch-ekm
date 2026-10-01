// SDC template-based extraction — DOCUMENTREFERENCE TEMPLATE (disease-agnostic)
//
// The second template every CH EKM questionnaire carries (contained[1], next to the per-disease
// document Bundle template in contained[0]; wired in RuleSetQrHeader). $extract turns the two into
// ONE transaction (Profile: ChEkmExtractTransaction):
//
//   entry[0]  POST Bundle             the document, fullUrl = 'urn:uuid:' + %documentBundleId
//   entry[1]  POST DocumentReference  this template
//
// Why a DocumentReference at all: a document Bundle cannot point at the patient record it belongs to
// (Bundle has no `subject`, and the Patient inside the document is the report's own copy). Writing
// the extraction back to the SMART on FHIR server the form was launched from therefore needs an index
// entry that does — `subject` here is the QuestionnaireResponse's subject, i.e. the launch patient.
//
// The link to the document goes through the SDC `extractAllocateId` variable %documentBundleId
// (declared on the questionnaire root, one fresh UUID per extraction) — used three times:
//   * the document entry's fullUrl          (templateExtract `fullUrl`, RuleSetQrHeader)
//   * the document's Bundle.identifier       (each disease's ChEkmDocument<Disease>Template)
//   * here: content.attachment.url + masterIdentifier.
// The server rewrites attachment.url (a `url`) to the stored Bundle's location when it processes the
// transaction; masterIdentifier (a string) keeps the document's identifier, which does not change.
//
// The reference engine (@aehrc/sdc-template-extract) allocates a bare UUID, hence the 'urn:uuid:'
// prefix in every expression.

Instance: ChEkmDocumentReferenceTemplate
InstanceOf: ChEkmDocumentReference
Usage: #inline
* status = #current
* masterIdentifier.system = "urn:ietf:rfc:3986"
* masterIdentifier.value.extension[+].url = $sdc-templateExtractValue
* masterIdentifier.value.extension[=].valueString = "'urn:uuid:' + %documentBundleId"
* type = $sct#722143004 "Infectious disease diagnostic study note"
* category = $sct#423876004 "Clinical report"
// The launch patient. Smart Forms sets QuestionnaireResponse.subject from the SMART launch context;
// no subject (a form filled without a patient) leaves the DocumentReference without one, which
// ChEkmDocumentReference rejects — on purpose, such a report cannot be filed under a patient.
* subject.reference.extension[+].url = $sdc-templateExtractValue
* subject.reference.extension[=].valueString = "%resource.subject.reference"
* subject.display.extension[+].url = $sdc-templateExtractValue
* subject.display.extension[=].valueString = "%resource.subject.display"
* date.extension[+].url = $sdc-templateExtractValue
* date.extension[=].valueString = "%resource.authored"
// The treating physician's Practitioner on the launching server. QuestionnaireResponse.author is the
// SMART user, which for CH EKM is a PractitionerRole (the `user` launch context), so the Practitioner
// comes from the hidden `physicianReference` item, filled at $populate from %user.practitioner
// (ChEkmQuestionnaireTreatingPhysician). Fallback: QuestionnaireResponse.author, but only when it
// already is a Practitioner (a launch whose fhirUser is the Practitioner itself).
* author[0].reference.extension[+].url = $sdc-templateExtractValue
* author[0].reference.extension[=].valueString = "%resource.descendants().where(linkId='physicianReference').answer.value.combine(%resource.author.reference.where(startsWith('Practitioner/'))).first()"
* content[0].attachment.contentType = #application/fhir+json
* content[0].attachment.url.extension[+].url = $sdc-templateExtractValue
* content[0].attachment.url.extension[=].valueString = "'urn:uuid:' + %documentBundleId"
* content[0].attachment.creation.extension[+].url = $sdc-templateExtractValue
* content[0].attachment.creation.extension[=].valueString = "%resource.authored"
