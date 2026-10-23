### Overview

A CH EKM report is a FHIR Document: a `Bundle` of type `document` whose first entry is the
`Composition`, followed by every resource the Composition references.

<div><img src="ekm-document-bundle.svg" alt="Schematic overview of a CH EKM FHIR Document: the Bundle (type document) contains the Composition entry with subject (Patient), author (PractitionerRole), encounter (Encounter, only if hospitalised) and the sections diagnosis, laboratory, immunization, social-history and cause-death with their entries, followed by the Patient, PractitionerRole, Practitioner, Organization and Condition entries that every document has and the entries that only some answers produce." style="width:100%; max-width:900px"/></div>

Starting from the Composition, the resources reference each other as follows:

<div><img src="ekm-resource-relationships.svg" alt="Resource relationships: the Composition references the Patient (subject), the author PractitionerRole (which references the Practitioner and Organization of the treating physician or broker) and the hospitalisation Encounter. Its sections reference the diagnosis Condition (and a disease-specific QuestionnaireResponse), the cause of death Observation, the exposure and transgender status Observations, the Immunization or vaccination status Observation, and the laboratory ServiceRequest with its Specimen and laboratory Organization. Condition and Encounter reference each other, the cause of death Observation has the Condition as focus." style="width:100%; max-width:900px"/></div>

### Resource Profiles

{% include list-profiles.xhtml %}

### Data Type Profiles

{% for sd_hash in site.data.structuredefinitions -%} {%- assign sd = sd_hash[1] -%} {%- if sd.kind == "complex-type" and sd.type != "Extension" -%}

<li>
    <a href="{{sd.path}}">{{sd.title}}</a>
</li>
{%- endif -%} {%- endfor -%}
