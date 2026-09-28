### Introduction
CH EKM (Elektronische klinische Meldung) is a project of the Swiss Federal Office of Public Health (FOPH), Communicable Diseases Division, to enable clinicians to send their clinical findings of communicable infectious diseases to the FOPH electronically. CH EKM derives from the [Swiss implementation guides](https://fhir.ch/).

A report is sent to the FOPH as a [FHIR document](document.html) based on the HL7® FHIR® standard. For each reportable disease, this guide provides two complementary definitions of that report:

- **Profiles** define the FHIR document itself: which resources it contains, which codes are fixed and which value sets apply.
- **A Questionnaire** ([HL7 FHIR SDC](https://hl7.org/fhir/uv/sdc/)) contains the same clinical content as a form, modelled on the paper reporting form. It carries rules to pre-populate the form with data already on file and a template that turns the completed form into the FHIR document.

A clinical information system can therefore either build the FHIR document directly from the profiles, or render the Questionnaire and extract the document from the completed form. Both ways are described in [Implementation Support for Clinical Information Systems](#implementation-support-for-clinical-information-systems).

[//]: # (// TODO and the [European laboratory project](https://hl7.eu/fhir/laboratory/) (see [graphical overview](#dependency-overview)).)

[//]: # (// TODO The expected content of the FHIR document, based on the ordinance of the Federal Office of Public Health ([DE](https://www.fedlex.admin.ch/eli/cc/2015/892/de), [FR](https://www.fedlex.admin.ch/eli/cc/2015/892/fr), [IT](https://www.fedlex.admin.ch/eli/cc/2015/892/it)), is defined in the [logical model](StructureDefinition-LaboratoryReport.html). A [mapping](StructureDefinition-LaboratoryReport-mappings.html) shows how to access the data from the FHIR document. In addition, further documentation for specific topics can be found on the [guidance](guidance.html) page and the [use cases](usecase.html) describe the different scenarios with respective examples for specific organisms.)).)


<div markdown="1" class="stu-note">

The specification herewith documented is work in progress. No liability can be inferred from the use or misuse of this specification, or its consequences.

[//]: # ([Changelog](changelog.html) with significant changes, open and closed issues.)


</div>

**Download**: You can download this implementation guide in [npm format](https://confluence.hl7.org/display/FHIR/NPM+Package+Specification) from [here](../package.tgz).

### Implementation Support for Clinical Information Systems

A clinical information system (EHR, e.g. hospital or practice software) can produce the FHIR document in two ways:

1. **Build the FHIR Document directly.** The EHR maps its own data onto the [profiles](profiles.html) and assembles the document Bundle itself, following the rules defined per profile.
2. **Use the Questionnaire.** For each disease this guide also publishes an [SDC](https://hl7.org/fhir/uv/sdc/) Questionnaire that contains all the clinical content of the report. A form renderer in the EHR displays it, pre-populates it with data the EHR already holds, lets the clinician complete it and then generates the FHIR Document from the answers, using an extraction template embedded in the Questionnaire.

<div><img src="ekm-implementation-paths.svg" alt="Two implementation paths: the EHR either maps its data to the profiles and builds the FHIR Document itself, or renders the Questionnaire from this guide, pre-populates it, has the clinician complete it and extracts the FHIR Document. Both paths produce the same document, which is sent to the FOPH." style="width:100%; max-width:900px"/></div>

*Fig. 1: Two ways to produce the CH EKM FHIR Document*

Both paths produce the same document and are validated against the same profiles, so for the FOPH it makes no difference which path a report took.

#### Path 1: Build the FHIR Document from the profiles

The EHR implements the mapping from its own data model to the profiles: the [document Bundle](document.html), the Composition and its sections, and the resources they reference (Patient, Condition, Observation, Encounter, Immunization, PractitionerRole, …). The disease-specific profiles fix the codes and bind the value sets, and the [examples](examples.html) show a complete document per disease.

This path suits an EHR that already holds the reported information in structured form and wants the report to be generated without anyone filling in a form. The EHR takes full responsibility for applying every rule of the profiles.

#### Path 2: Use the Questionnaire

The Questionnaires follow the paper reporting forms and are listed on the [Questionnaires](questionnaire.html) page, which also explains how they are assembled from modular parts, which variants are published and why rendering them needs a terminology server. Besides the questions, each one carries the pre-population rules and the template for extraction, so the knowledge of how answers map to the profiles ships with the form rather than having to be implemented in the EHR. A report built from a Questionnaire goes through four phases:

<div><img src="ekm-form-phases.svg" alt="The four phases of a form: 1. launch context (Patient, treating physician as PractitionerRole, hospitalisation Encounter), 2. pre-population with initialExpression, 3. completion by the clinician, 4. template-based extraction. The Gonorrhoea example shows a completed form, the Bundle template with Patient, Condition and exposure Observation, and the resulting FHIR Document." style="width:100%; max-width:900px"/></div>

*Fig. 2: From the form to the FHIR Document, shown for Gonorrhoea*

**Phase 1: Launch context.** When the form is opened, the EHR passes the resources the report is about as [launch context](https://hl7.org/fhir/uv/sdc/populate.html): `patient` (the Patient), `user` (the treating physician as a **PractitionerRole**, which links the Practitioner to their Organization) and, for diseases whose form asks about the course of the disease (hospitalisation, death), `encounter` (the hospitalisation Encounter).

**Phase 2: Pre-population.** The form fills in what the EHR already knows, using FHIRPath expressions (`initialExpression`) on the launch context: the person's name or initials, date of birth, AHV number, nationality and address, the treating physician and their organisation, and, where the form asks, the hospitalisation and the date of death. This avoids typing the same data twice and keeps the report consistent with the patient record. The SDC [`$populate`](https://hl7.org/fhir/uv/sdc/populate.html) operation describes this step.

**Phase 3: Completion.** The clinician answers the remaining disease-specific questions and checks the pre-filled ones. Follow-up questions appear only when they apply (`enableWhen`), and coded answers come from the value sets of this guide (`answerValueSet`), with display texts in German, French and Italian.

**Phase 4: Extraction.** On submission, the answers in the QuestionnaireResponse are turned into the FHIR Document by [template-based extraction](https://hl7.org/fhir/uv/sdc/extraction.html#template-based-extraction). Each Questionnaire contains one Bundle template shaped like the target document: fixed content such as the disease code is already in place, and placeholders (`templateExtractValue`) are replaced with the answers. The result is a document Bundle shaped like the one built on path 1.

The Questionnaires are tested with open source SDC implementations: the [Smart Forms](https://smartforms.csiro.au/) renderer and its [`@aehrc/sdc-populate`](https://www.npmjs.com/package/@aehrc/sdc-populate) and [`@aehrc/sdc-template-extract`](https://www.npmjs.com/package/@aehrc/sdc-template-extract) libraries, which were also used to produce the extracted example documents in this guide.

#### Validate before sending

Whichever path is used, validate each report against the disease-specific document profile before it is sent. On path 1 the EHR's own mapping has to be checked. On path 2 the template does most of the work, but extraction alone cannot guarantee a fully compliant document: the result also depends on the answers given, on the renderer and on the extraction engine. Run the [FHIR Validator](https://confluence.hl7.org/display/FHIR/Using+the+FHIR+Validator) with this guide's [package](../package.tgz) as a parameter and the document profile of the disease, e.g. `http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-document-gonorrhoea`.

### Must Support
For the CH EKM exchange format, the [mustSupport](https://www.hl7.org/fhir/profiling.html#mustsupport) flag set to `true` has the following meaning:   
If the sending application has data for the element, it is required to populate the element with a non-empty value. If the value is not known, the element may be omitted.

### IP Statements
HL7®, HEALTH LEVEL SEVEN®, FHIR® and the FHIR <img src="icon-fhir-16.png" style="float: none; margin: 0px; padding: 0px; vertical-align: bottom"/>&reg; are trademarks owned by Health Level Seven International, registered with the United States Patent and Trademark Office.

{% include ip-statements.xhtml %}

### Cross Version Analysis

{% include cross-version-analysis.xhtml %}

### Dependencies

#### Dependency Overview


#### Dependency Table

{% include dependency-table.xhtml %}

### Globals Table

{% include globals-table.xhtml %}