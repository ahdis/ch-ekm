// Issue #46: the Gonorrhoea example document, submitted to the FOPH as CH ELM laboratories submit
// theirs (http://fhir.ch/ig/ch-elm/api.html). No meta.profile, neither here nor on the contained
// document and its entries (setMetaProfile: never in sushi-config.yaml): the IG Publisher validates
// the DocumentReference against ChEkmPublishDocumentReference, and through its contained[document]
// slice the Bundle against ChEkmDocument, without the instance having to declare either.
Instance: ChEkmPublishDocumentReferenceGonorrhoea
InstanceOf: ChEkmPublishDocumentReference
Usage: #example
Title: "Publish DocumentReference: Gonorrhoea"
Description: "Example for sending a CH EKM report to the FOPH: the Gonorrhoea document (ChEkmBundleGonorrhoea) contained in a DocumentReference, as in the CH ELM API."
* contained = ChEkmBundleGonorrhoea
* status = #current
* identifier.system = "urn:ietf:rfc:3986"
* identifier.value = "urn:uuid:c376a38a-61b9-4a79-8722-12c75bacf927"
* content.attachment.language = #de-CH
* content.attachment.url = "#ChEkmBundleGonorrhoea"
// Hand-written narrative: the generated one renders the attachment as an <h4> directly under the
// page's <h2>, which the IG Publisher's WCAG check reports as an error (skipped heading level).
* text.status = #generated
* text.div = "<div xmlns=\"http://www.w3.org/1999/xhtml\"><p><b>Publish DocumentReference</b> (status: current), identifier urn:ietf:rfc:3986 urn:uuid:c376a38a-61b9-4a79-8722-12c75bacf927</p><p>Content (de-CH): the contained Gonorrhoea document (attachment url #ChEkmBundleGonorrhoea)</p></div>"
