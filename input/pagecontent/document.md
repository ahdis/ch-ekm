The CH EKM exchange format defines a FHIR document representing a coherent set of information specific to the transmission of a clinical findings report for a communicable infectious disease. This FHIR document is based on the [CH EKM-Document](StructureDefinition-ch-ekm-document.html) profile.

The exchange format expects a separate FHIR document per patient, disease, and report.

The FHIR document consists of a bundle-resource of type "document" (the terms "FHIR document" and "Bundle" are synonymous in the context of the CH EKM project).

The bundle resource contains a consistent set of entries representing FHIR resources specific for the transmission of a clinical findings report. The [CH EKM-Composition](StructureDefinition-ch-ekm-composition.html) is the first entry of the bundle and structures the report into sections (diagnosis, laboratory, medication, immunization, risk factors, social history, cause of death), each of which references the resources carrying the relevant data; a hospitalisation is referenced from `Composition.encounter`:

<div><img src="ekm-document-bundle.svg" alt="Schematic overview of a CH EKM FHIR Document: the Bundle (type document) contains the Composition entry with subject (Patient), author (PractitionerRole), encounter (Encounter, only if hospitalised) and the sections diagnosis, laboratory, immunization, social-history and cause-death with their entries, followed by the Patient, PractitionerRole, Practitioner, Organization and Condition entries that every document has and the entries that only some answers produce." style="width:100%; max-width:900px"/></div>

Starting from the Composition, the resources reference each other as follows:

<div><img src="ekm-resource-relationships.svg" alt="Resource relationships: the Composition references the Patient (subject), the author PractitionerRole (which references the Practitioner and Organization of the treating physician or broker) and the hospitalisation Encounter. Its sections reference the diagnosis Condition (and a disease-specific QuestionnaireResponse), the cause of death Observation, the exposure and transgender status Observations, the Immunization or vaccination status Observation, and the laboratory ServiceRequest with its Specimen and laboratory Organization. Condition and Encounter reference each other, the cause of death Observation has the Condition as focus." style="width:100%; max-width:900px"/></div>

The FHIR document is generic and applicable for the different communicable infectious diseases in scope of the CH EKM project. For each resource within the FHIR document, a resource profile is defined to meet specific data needs depending on the context and the reported disease.

### Resource profiles

Resource profiles are a way to customize and constrain FHIR resources to meet specific requirements depending on a particular context. These rules might restrict the allowable values for certain elements, specify additional mandatory elements, or define extensions to capture additional data beyond the standard FHIR resources. In the CH EKM Implementation Guide multiple profiles can exist based on the same FHIR resource.

Example: the FHIR resource «Organization» is used to map the organization of the treating physician, the organization of the broker, and the performing laboratory – each of which having its own profile.

### Disease specific reports

Disease-specific profiles for the [CH EKM-Document](StructureDefinition-ch-ekm-document.html), [Composition](StructureDefinition-ch-ekm-composition.html) and [Condition](StructureDefinition-ch-ekm-condition.html) further constrain these base profiles, e.g. fixing the diagnosis code or required sections for a particular disease. The following disease-specific document profiles are derived from the [CH EKM-Document](StructureDefinition-ch-ekm-document.html):

<ul>
{%- for sd_hash in site.data.structuredefinitions -%}
{%- assign sd = sd_hash[1] -%}
{%- if sd.base == "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-document" %}
  <li><a href="{{sd.path}}">{{sd.title}}</a></li>
{%- endif -%}
{%- endfor %}
</ul>

See the [profiles](profiles.html) page for the full resource overview, and the [examples](examples.html) page for example FHIR documents per disease.
