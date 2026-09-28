For each reportable disease this guide publishes a Questionnaire that contains the same clinical content as the paper reporting form. The Questionnaires follow the HL7 FHIR [Structured Data Capture (SDC)](https://hl7.org/fhir/uv/sdc/) implementation guide, version 4.0.0. This page explains how they are built, which variants are published and what a system needs to render them. How a clinical information system uses them to produce the report (launch context, pre-population, completion, extraction) is described under [Path 2: Use the Questionnaire](index.html#path-2-use-the-questionnaire).

### New to SDC? Where to read

A FHIR [Questionnaire](https://hl7.org/fhir/R4/questionnaire.html) defines the questions of a form, and a [QuestionnaireResponse](https://hl7.org/fhir/R4/questionnaireresponse.html) holds the answers. Both are part of FHIR R4 itself. SDC adds extensions, profiles and operations to these two resources. The Questionnaires in this guide use the following parts of SDC:

{:class="table table-bordered"}
| Topic | Used in this guide for | Read in SDC |
|-------|------------------------|-------------|
| Modular forms | Reusable sub-questionnaires (person, exposure, laboratory, ...) that each disease assembles into one form | [Modular Forms](https://hl7.org/fhir/uv/sdc/modular.html), operation [`$assemble`](https://hl7.org/fhir/uv/sdc/OperationDefinition-Questionnaire-assemble.html) |
| Expressions | FHIRPath expressions for pre-population, calculated values and extraction | [Using Expressions](https://hl7.org/fhir/uv/sdc/expressions.html) |
| Form behaviour | Follow-up questions shown only when they apply (`enableWhen`), answer lists from value sets (`answerValueSet`) | [Form Behavior and Calculation](https://hl7.org/fhir/uv/sdc/behavior.html) |
| Rendering | Item controls (drop-down, radio buttons, ...) and display texts | [Advanced Form Rendering](https://hl7.org/fhir/uv/sdc/rendering.html) |
| Pre-population | Filling in data the system already holds, from the launch context `patient`, `user` and `encounter` | [Form Population](https://hl7.org/fhir/uv/sdc/populate.html), operation [`$populate`](https://hl7.org/fhir/uv/sdc/OperationDefinition-Questionnaire-populate.html) |
| Extraction | Turning the QuestionnaireResponse into the CH EKM FHIR document | [Form Data Extraction](https://hl7.org/fhir/uv/sdc/extraction.html#template-based-extraction), operation [`$extract`](https://hl7.org/fhir/uv/sdc/OperationDefinition-QuestionnaireResponse-extract.html) |

A good starting point is the SDC [Basic SDC workflow](https://hl7.org/fhir/uv/sdc/workflow.html), which shows how these parts fit together.

### Modular Questionnaires and assembly

Most sections of the reporting forms recur across diseases: the affected person, the treating physician, the exposure, the laboratory, the course of the disease. Each of them is defined once, as a **sub-questionnaire**, and each disease has a **modular (root) Questionnaire** that lists the sub-questionnaires its form needs, in form order, plus the questions that are specific to the disease.

A modular Questionnaire cannot be rendered as it is: in place of each section it contains only a placeholder item that points to the sub-questionnaire (extension [`subQuestionnaire`](https://hl7.org/fhir/uv/sdc/StructureDefinition-sdc-questionnaire-subQuestionnaire.html)). The SDC operation [`$assemble`](https://hl7.org/fhir/uv/sdc/OperationDefinition-Questionnaire-assemble.html) replaces every placeholder with the items of the sub-questionnaire and produces one complete, **assembled Questionnaire**. It also merges what the sub-questionnaires declare at the form level, such as launch contexts and variables.

This guide runs `$assemble` at build time and includes the result, so an implementer does not have to assemble the forms. The modular Questionnaires and the sub-questionnaires are published as well: they are the source the assembled forms are generated from, and show which parts are shared between diseases.

### Pre-population and extraction

Each assembled Questionnaire conforms to two SDC profiles:

- [Populatable Questionnaire – Expression](https://hl7.org/fhir/uv/sdc/StructureDefinition-sdc-questionnaire-pop-exp.html): it declares its launch context (`patient`, `user` as the treating physician's PractitionerRole and, where the form asks about the course of the disease, `encounter`) and carries an `initialExpression` on each item that can be pre-filled from it.
- [Extractable Questionnaire – Template](https://hl7.org/fhir/uv/sdc/StructureDefinition-sdc-questionnaire-extr-template.html): it contains a Bundle template shaped like the disease's FHIR document. [Template-based extraction](https://hl7.org/fhir/uv/sdc/extraction.html#template-based-extraction) fills that template with the answers of the QuestionnaireResponse, so the result is a document Bundle that conforms to the disease-specific [document profile](document.html#disease-specific-reports).

The mapping from the form to the profiles therefore ships with the Questionnaire and does not have to be implemented by the system that renders it.

### Published variants

For each disease this guide publishes three variants of the Questionnaire:

{:class="table table-bordered"}
| Variant | What it is | Answer lists | Use it for |
|---------|------------|--------------|------------|
| **Modular** | The root Questionnaire with placeholders for the sub-questionnaires | `answerValueSet` references | The source of the form; input to `$assemble`. Not renderable as it is. |
| **Assembled** | The complete form, produced by `$assemble` | `answerValueSet` references, expanded by a terminology server at render time | **Production.** Item texts are in English, with German, French and Italian carried as [translation](https://hl7.org/fhir/R4/extension-translation.html) extensions. |
| **Language specific** (de-CH, fr-CH, it-CH) | The assembled form with the texts of one language and every value set expanded in advance | Inline `answerOption`s | **Production** without a terminology server. |

All three carry the same pre-population rules and the same extraction template. The language-specific variants differ from the assembled one in these ways:

- the item texts of one language replace the English default text;
- each `answerValueSet` is replaced by the `answerOption`s of its expansion in that language, made when this guide was built;
- items shown as `autocomplete` are shown as `drop-down`, because type-ahead search needs a terminology server.

### Terminology server

In the modular and the assembled Questionnaires, coded questions reference the value sets of this guide, of [CH Term](https://fhir.ch/ig/ch-term/) and of SNOMED CT (Swiss Extension). The form renderer does not know these value sets itself: for each coded question it calls [`ValueSet/$expand`](https://hl7.org/fhir/R4/valueset-operation-expand.html) on a terminology server, with the language of the form as `displayLanguage`. The terminology server must therefore have

- the Swiss Extension of SNOMED CT,
- the CH Term package, and
- the package of this guide, including its CodeSystem supplements, which add German, French and Italian displays to external code systems.

Without such a server, the answer lists of the coded questions stay empty. **Only the language-specific Questionnaires can be rendered without a terminology server**, because their answer lists are already expanded. Their content is fixed at the time this guide was built and does not follow later changes to the value sets.

### Questionnaires in this guide

The table lists one row per disease. It is generated from the Questionnaires in this guide, so a new disease appears here as soon as its Questionnaires are added.

{% assign langs = "de-CH,fr-CH,it-CH" | split: "," -%}
<table class="table table-bordered">
  <thead>
    <tr><th>Disease</th><th>Modular</th><th>Assembled</th><th>Language specific (preview)</th></tr>
  </thead>
  <tbody>
{%- for q_hash in site.data.questionnaires -%}
{%- assign id = q_hash[0] -%}
{%- assign q = q_hash[1] -%}
{%- if id contains "Assembled" -%}
{%- assign root = id | remove: "Assembled" -%}
{%- assign rkey = "Questionnaire/" | append: id -%}
{%- assign disease = site.data.resources[rkey].title | remove: "CH EKM Questionnaire: " | remove: " (assembled)" -%}
{%- assign rq = site.data.questionnaires[root] %}
    <tr>
      <td>{{disease}}</td>
      <td>{%- if rq -%}<a href="{{rq.path}}">{{root}}</a>{%- endif -%}</td>
      <td><a href="{{q.path}}">{{id}}</a></td>
      <td>
{%- for lang in langs -%}
{%- assign lkey = root | append: "-" | append: lang -%}
{%- assign lq = site.data.questionnaires[lkey] -%}
{%- if lq %} <a href="{{lq.path}}">{{lang}}</a>{% endif -%}
{%- endfor -%}
      </td>
    </tr>
{%- endif -%}
{%- endfor %}
  </tbody>
</table>

#### Sub-questionnaires

The sub-questionnaires that the modular Questionnaires above assemble:

<table class="table table-bordered">
  <thead>
    <tr><th>Sub-questionnaire</th><th>Description</th></tr>
  </thead>
  <tbody>
{%- for q_hash in site.data.questionnaires -%}
{%- assign id = q_hash[0] -%}
{%- assign q = q_hash[1] -%}
{%- assign akey = id | append: "Assembled" -%}
{%- assign aq = site.data.questionnaires[akey] -%}
{%- unless id contains "Assembled" or id contains "-" -%}
{%- unless aq -%}
{%- assign rkey = "Questionnaire/" | append: id %}
    <tr>
      <td><a href="{{q.path}}">{{site.data.resources[rkey].title | default: id}}</a></td>
      <td>{{q.description}}</td>
    </tr>
{%- endunless -%}
{%- endunless -%}
{%- endfor %}
  </tbody>
</table>
