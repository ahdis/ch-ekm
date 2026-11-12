// Sending a report to the FOPH (issue #46): the same submission API as CH ELM
// (http://fhir.ch/ig/ch-elm/api.html), so eLM and eKM reports reach the FOPH the same way.
//
// A copy of CH ELM's PublishDocumentReference, not a profile on it: its contained[document] slice is
// typed to ch-elm-document, and a CH EKM document is not one. Everything else is the same, element
// by element. The response (PublishDocumentReferenceResponse, the ch-ext-elm-status extension) and
// the CapabilityStatement of the document recipient are CH ELM's and are only referenced from api.md.
//
// Not to be confused with ChEkmDocumentReference (DocumentReference.fsh): that one INDEXES a document
// stored on the server the form was launched from (by reference, with a subject), this one CARRIES
// the document to the FOPH (contained, no subject).

Profile: ChEkmPublishDocumentReference
Parent: DocumentReference
Id: ch-ekm-publish-documentreference
Title: "CH EKM Publish DocumentReference"
Description: """
DocumentReference for sending a CH EKM report to the FOPH, following the [CH ELM API](http://fhir.ch/ig/ch-elm/api.html) and its [PublishDocumentReference](http://fhir.ch/ig/ch-elm/StructureDefinition-PublishDocumentReference.html) profile:
- must be status current
- must have an identifier (the identifier of the document Bundle)
- uses attachment.url to carry the document as a contained resource
- validation of the contained document according to [CH EKM Document](StructureDefinition-ch-ekm-document.html)
"""
* . ^short = "CH EKM Publish DocumentReference: sends a clinical findings report to the FOPH"
* contained 1..
* contained ^slicing.discriminator.type = #profile
* contained ^slicing.discriminator.path = "$this"
* contained ^slicing.rules = #open
* contained contains document 1..1 MS
* contained[document] ^type.profile = Canonical(ChEkmDocument)
* contained[document] ^short = "The CH EKM document Bundle (ChEkmDocument or one of its disease-specific profiles)"
* modifierExtension 0..0
* identifier 1..1
* identifier ^short = "The identifier of the contained document Bundle (Bundle.identifier)"
* status 1..1
* status = http://hl7.org/fhir/document-reference-status#current
* docStatus 0..0
* date 0..1 MS
* authenticator 0..1
* relatesTo 0..* MS
* description 0..1
* securityLabel 0..* MS
* content 1..1
* content ^definition = "The document and format referenced"
* content.attachment 1..1
* content.attachment obeys ch-ekm-resolveableurl
* content.attachment.language 0..1 MS
* content.attachment.url 1..1
* content.attachment.url ^short = "The document is referenced by this url (#<Bundle.id>), contained in the DocumentReference"
* content.attachment.creation 0..1 MS
