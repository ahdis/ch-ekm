The CH EKM exchange format defines a FHIR document representing a coherent set of information specific to the transmission of a clinical findings report for a communicable infectious disease. This FHIR document is based on the [CH EKM-Document](StructureDefinition-ch-ekm-document.html) profile.

The exchange format expects a separate FHIR document per patient, disease, and report.

The FHIR document consists of a bundle-resource of type "document" (the terms "FHIR document" and "Bundle" are synonymous in the context of the CH EKM project).

The bundle resource contains a consistent set of entries representing FHIR resources specific for the transmission of a clinical findings report. The [CH EKM-Composition](StructureDefinition-ch-ekm-composition.html) is the first entry of the bundle and structures the report into sections (diagnosis, laboratory, hospitalization, medication, immunization, risk factors, social history, cause of death), each of which references the resources carrying the relevant data:

<style>

   .first-table {
       width: 85%;  
       td:first-child {
       width: 1%;
       white-space: pre; 
}  
    }
    table {
        width: 100%;
        border-collapse: collapse;
        margin: 20px 0;
    }
    
    table, th, td {
         border: 1px solid silver;
         font-size: 12px;
         line-height: 1.4em;
         font-family: verdana;
         font-weight: normal;
         padding: 3px;
         vertical-align: top;
         overflow-wrap: break-word; 
    }

    th, td {
        text-align: left;
        vertical-align: top;
    }

    th {
        font-weight: bold;
        width: 25%; 
    }

    td {
        width: 25%; 
    }

</style>

<table class="first-table">
    <tr>
    <td colspan="2">{</td>
  </tr>
  <tr>
    <td colspan="2">"resourceType": "Bundle",</td>
  </tr>
<tr>
    <td colspan="2">"entry": [</td>
  </tr>
  <tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "<a href="StructureDefinition-ch-ekm-composition.html">Composition</a>"<br>&nbsp;&nbsp;&nbsp;&nbsp;},</td>
    <td>the report itself: parameters like date, language, title, author, and sections referencing the different resources</td>
  </tr>
  <tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "<a href="StructureDefinition-ch-ekm-patient.html">Patient</a>"<br>&nbsp;&nbsp;&nbsp;&nbsp;},</td>
    <td>the person affected by the communicable infectious disease (referenced by <code>Composition.subject</code>)</td>
 </tr>
  <tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "<a href="StructureDefinition-ch-ekm-practitionerrole.html">PractitionerRole</a>"<br>&nbsp;&nbsp;&nbsp;&nbsp;},</td>
    <td>the author of the report (referenced by <code>Composition.author</code>): either the treating physician or a private service provider ("broker") who transmits the report on behalf of the treating physician</td>
 </tr>
  <tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "<a href="StructureDefinition-ch-ekm-practitioner-treating-physician.html">Practitioner</a>"<br>&nbsp;&nbsp;&nbsp;&nbsp;},</td>
    <td>the treating physician, referenced by the author's PractitionerRole</td>
</tr>
<tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "<a href="StructureDefinition-ch-ekm-practitioner-broker.html">Practitioner</a>"<br>&nbsp;&nbsp;&nbsp;&nbsp;},</td>
    <td>alternatively, the broker submitting the report on behalf of the treating physician, referenced by the author's PractitionerRole</td>
</tr>
<tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "<a href="StructureDefinition-ch-ekm-organization-treating-physician.html">Organization</a>"<br>&nbsp;&nbsp;&nbsp;&nbsp;},</td>
    <td>the organization of the treating physician (e.g. the practice or hospital)</td>
</tr>
<tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "<a href="StructureDefinition-ch-ekm-organization-author.html">Organization</a>"<br>&nbsp;&nbsp;&nbsp;&nbsp;},</td>
    <td>alternatively, the organization of the broker submitting the report</td>
</tr>
<tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "<a href="StructureDefinition-ch-ekm-condition.html">Condition</a>"<br>&nbsp;&nbsp;&nbsp;&nbsp;},</td>
    <td>the diagnosed communicable infectious disease ("diagnosis" section), with onset date and supporting evidence</td>
</tr>
<tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "QuestionnaireResponse"<br>&nbsp;&nbsp;&nbsp;&nbsp;},</td>
    <td>optional, structured answers complementing the diagnosis (e.g. course of disease) ("diagnosis" section)</td>
</tr>
<tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "<a href="StructureDefinition-ch-ekm-servicerequest.html">ServiceRequest</a>"<br>&nbsp;&nbsp;&nbsp;&nbsp;},</td>
    <td>the laboratory order ("laboratory" section), with the laboratory order ID, the requester, and the performing laboratory</td>
</tr>
<tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "<a href="StructureDefinition-ch-ekm-organization-lab.html">Organization</a>"<br>&nbsp;&nbsp;&nbsp;&nbsp;},</td>
    <td>the performing laboratory, referenced by the ServiceRequest</td>
</tr>
<tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "<a href="StructureDefinition-ch-ekm-specimen.html">Specimen</a>"<br>&nbsp;&nbsp;&nbsp;&nbsp;},</td>
    <td>the specimen material with collection date, referenced by the ServiceRequest</td>
</tr>
<tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "Observation"<br>&nbsp;&nbsp;&nbsp;&nbsp;},</td>
    <td>laboratory result values, e.g. a seroconversion ("laboratory" section)</td>
</tr>
<tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "Encounter"<br>&nbsp;&nbsp;&nbsp;&nbsp;},</td>
    <td>a hospitalization or outpatient visit related to the disease ("hospitalization" section)</td>
</tr>
<tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "Observation"<br>&nbsp;&nbsp;&nbsp;&nbsp;},</td>
    <td>medication relevant to the disease, e.g. antiviral therapy ("medication" section)</td>
</tr>
<tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "Immunization"<br>&nbsp;&nbsp;&nbsp;&nbsp;},</td>
    <td>one or more vaccine doses relevant to the disease ("immunization" section)</td>
</tr>
<tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "Condition"<br>&nbsp;&nbsp;&nbsp;&nbsp;},</td>
    <td>a risk factor relevant to the disease, e.g. immunosuppression ("risk-factors" section)</td>
</tr>
<tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "<a href="StructureDefinition-ch-ekm-exposure.html">Observation</a>"<br>&nbsp;&nbsp;&nbsp;&nbsp;},</td>
    <td>an exposure to the infectious disease, e.g. sexual contact or travel abroad ("social-history" section)</td>
</tr>
<tr>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"resourceType": "Condition"<br>&nbsp;&nbsp;&nbsp;&nbsp;}</td>
    <td>the cause of death, if applicable ("cause-death" section)</td>
</tr>
  <tr>
    <td colspan="6">]</td>
  </tr>
   <tr>
    <td colspan="7">}</td>
  </tr>
</table>

The FHIR document is generic and applicable for the different communicable infectious diseases in scope of the CH EKM project. For each resource within the FHIR document, a resource profile is defined to meet specific data needs depending on the context and the reported disease.

### Resource profiles

Resource profiles are a way to customize and constrain FHIR resources to meet specific requirements depending on a particular context. These rules might restrict the allowable values for certain elements, specify additional mandatory elements, or define extensions to capture additional data beyond the standard FHIR resources. In the CH EKM Implementation Guide multiple profiles can exist based on the same FHIR resource.

Example: the FHIR resource «Organization» is used to map the organization of the treating physician, the organization of the broker, and the performing laboratory – each of which having its own profile.

Disease-specific profiles for the [CH EKM-Document](StructureDefinition-ch-ekm-document.html), [Composition](StructureDefinition-ch-ekm-composition.html) and [Condition](StructureDefinition-ch-ekm-condition.html) further constrain these base profiles, e.g. fixing the diagnosis code or required sections for a particular disease (see [Gonorrhoea](StructureDefinition-ch-ekm-document-gonorrhoea.html), [Hepatitis C](StructureDefinition-ch-ekm-document-hepatitisc.html) and [Invasive Pneumococcal Disease](StructureDefinition-ch-ekm-document-invasivepneumococcaldisease.html)).

See the [profiles](profiles.html) page for the full resource overview, and the [examples](examples.html) page for example FHIR documents per disease.

### Example FHIR documents

See the [examples](examples.html) page for the list of example FHIR documents (one per supported disease), together with the diagnosed condition, the document profile they conform to, the related logical models (forms) and questionnaires.
