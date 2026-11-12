<div markdown="1" class="dragon">

The API for sending a report to the FOPH may change once the NASURE / SwissHDS API is defined. Until then, CH EKM follows the [CH ELM API](http://fhir.ch/ig/ch-elm/api.html), so that laboratory reports (eLM) and clinical reports (eKM) are sent to the FOPH in the same way.

</div>

CH EKM uses the RESTful web API that [CH ELM](http://fhir.ch/ig/ch-elm/api.html) defines for laboratories. The treating physician, or a broker on their behalf, sends the report with it and verifies that it has been processed. This page describes what is specific to CH EKM; for everything else, the CH ELM API applies unchanged, with *laboratory* read as *treating physician or broker*.

### Actor Roles
**Actor:** Treating physician or broker (clinical information system)
**Role:** Sends a report as a [CH EKM FHIR document](document.html) to the FOPH and verifies that the report has been successfully processed.

**Actor:** FOPH
**Role:** Accepts the report and processes it in a later stage.

The FOPH server is described by the [CapabilityStatement of the CH ELM document recipient](http://fhir.ch/ig/ch-elm/CapabilityStatement-ch-elm-documentrecipient.html); CH EKM defines none of its own.

### Send Report transaction

The report is sent with an HTTP `POST` of a [CH EKM Publish DocumentReference](StructureDefinition-ch-ekm-publish-documentreference.html) to the DocumentReference endpoint of the FOPH:

- the CH EKM document Bundle is a `contained` resource of the DocumentReference and is validated against the [CH EKM Document](StructureDefinition-ch-ekm-document.html) profile (in practice, against the disease-specific document profile, e.g. [Gonorrhoea](StructureDefinition-ch-ekm-document-gonorrhoea.html));
- `content.attachment.url` references it as `#<Bundle.id>`;
- `status` is `current`;
- `identifier` holds exactly one identifier, the identifier of the document Bundle (`Bundle.identifier`).

The media type of the HTTP body shall be either `application/fhir+json` or `application/fhir+xml`.

```http
POST http://[base]/DocumentReference HTTP/1.1
Content-Type: application/fhir+json
Accept: application/fhir+json

{
  "resourceType" : "DocumentReference",
  "contained" : [
    {
      "resourceType" : "Bundle",
      "id" : "ChEkmBundleGonorrhoea",
      "identifier" : {
        "system" : "urn:ietf:rfc:3986",
        "value" : "urn:uuid:c376a38a-61b9-4a79-8722-12c75bacf927"
      },
      "type" : "document"
      // snip the rest of the bundle
    }
  ],
  "identifier" : [
    {
      "system" : "urn:ietf:rfc:3986",
      "value" : "urn:uuid:c376a38a-61b9-4a79-8722-12c75bacf927"
    }
  ],
  "status" : "current",
  "content" : [
    {
      "attachment" : {
        "language" : "de-CH",
        "url" : "#ChEkmBundleGonorrhoea"
      }
    }
  ]
}
```

See the complete [example](DocumentReference-ChEkmPublishDocumentReferenceGonorrhoea.html), which contains the [Gonorrhoea example document](Bundle-ChEkmBundleGonorrhoea.html).

The DocumentReference sent to the FOPH is not the [CH EKM DocumentReference](StructureDefinition-ch-ekm-documentreference.html): that one indexes a document stored on the server the form was launched from, by reference and linked to the patient record there (the second entry of the [`$extract` transaction](StructureDefinition-ch-ekm-extract-transaction.html)). The Publish DocumentReference carries the document itself and has no `subject`.

`meta.profile` is not required, neither on the DocumentReference nor on the contained document and its entries: the FOPH validates the DocumentReference against the Publish DocumentReference profile and the contained document against the CH EKM document profile of the reported disease. The example does not declare it either.

### Send Report Response

The response is the one of the CH ELM API (see [Send Report Response Message](http://fhir.ch/ig/ch-elm/api.html#send-report-response-message)):

- If the document is valid, the FOPH returns the DocumentReference as created, conforming to CH ELM's [Publish DocumentReference Response](http://fhir.ch/ig/ch-elm/StructureDefinition-PublishDocumentReferenceResponse.html), with the FOPH-assigned id and the processing status in the [`ch-ext-elm-status`](http://fhir.ch/ig/ch-elm/StructureDefinition-ch-ext-elm-status.html) extension: [in-progress](http://fhir.ch/ig/ch-elm/DocumentReference-1-DocumentReferenceResponseInProgress.html), later [completed](http://fhir.ch/ig/ch-elm/DocumentReference-1-DocumentReferenceResponseCompleted.html) or [failed](http://fhir.ch/ig/ch-elm/DocumentReference-1-DocumentReferenceResponseFailed.html).
- If the document is not valid, the FOPH returns an OperationOutcome with the validation errors.

### Verifying processing state

The sender shall verify that the report has been processed, by reading the DocumentReference by its id or by searching for it, exactly as described in [Verifying processing state](http://fhir.ch/ig/ch-elm/api.html#verifying-processing-state) of the CH ELM API (search parameters `date`, `_lastUpdated`, `identifier` and [`elm-status`](http://fhir.ch/ig/ch-elm/SearchParameter-SearchParameter-ch-elm-status.html)).
