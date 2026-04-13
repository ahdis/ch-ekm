- [Scenario 1 - Reporting pathway for the standard case](#scenario-1---reporting-pathway-for-the-standard-case)
  - [Treating Physician scenario](#treating-physician-scenario)
    - [Hepatitic C example](#hepatitic-c-example)
  - [Broker scenario](#broker-scenario)
    - [Invasive Pneumococcal Infection example](#invasive-pneumococcal-infection-example)

The following use cases serve to illustrate the scenarios that occur in the case of clinicians to send their clinical findings of communicable infectious diseases to the FOPH electronically. The cases are intended for structural illustration only and have not yet undergone clinical or content validation.

### Scenario 1 - Reporting pathway for the standard case

The following use case illustrate how physicians or private service providers (so-called brokers) on behalf of a treating physician. electronically transmit findings on communicable infectious diseases to the FOPH.

#### Treating Physician scenario

The treating physician directly sends the report to FOPH:
- [**Composition.author**](StructureDefinition-ch-ekm-composition.html) will be populated with the [**treating physician information**](StructureDefinition-ch-ekm-practitioner-treating-physician.html).
- **Condition.recorder** referenced in "Diagnosis section" of the Composition will be populated with the [**treating physician information**](StructureDefinition-ch-ekm-practitioner-treating-physician.html).

{% include scenario1-treating-physician.svg%}
*Fig. 1: treating Physician scenario*

##### Hepatitic C example

[Dr Monika Giacometti at the cantonal hospital](Practitioner-ChEkmPractitionerTreatingPhysicianExample.json.html) submits a [**report of clinical findings associated to Hepatitis C infection**](Bundle-ChEkmBundleHepatitisC.json.html) for the [patient Muster Beispielin](Patient-ChEkmPatientExample.json.html), born on 01.01.2020 and residing in 3097 Liebefeld (BE). This report follows a laboratory confirmation of Hepatitis C:
- Diagnosis and Clinical Findings: The patient was diagnosed with a viral Hepatitis C infection on January 29, 2026. The infection is acute in nature and presents with a manifestation of elevated transaminases>2.5. The diagnosis was not previously known to either the patient or the physician.
- [Laboratory Information](ServiceRequest-ChEkmServiceRequestExample-HepatitisC.json.html): The clinical findings are linked to a [screening sample taken on January 19, 2026](Specimen-ChEkmSpecimenExample-HepatitisC.json.html), analyzed by [LabSan GmbH](Organization-ChEkmOrganizationLabExample.json.html).
- Seroconversion: The clinician has noted that a documented seroconversion is unknown, meaning there is no available data regarding a previous negative anti-HCV serology prior to this diagnosis.
- Exposure History: The patient is a healthcare professional who recently traveled to Nepal. Their last entry into Switzerland was recorded as December 1, 2025.
- Therapeutic Plan: While the patient has not received prior antiviral therapy, the start of therapy is currently being considered.

#### Broker scenario

A private service provider (so-called brokers) who transmit the clinical findings to the reporting system of the FOPH on behalf of the treating physician:
The treating physician directly sends the report to FOPH:
- [**Composition.author**](StructureDefinition-ch-ekm-composition.html) will be populated with the [**service provider information**](StructureDefinition-ch-ekm-organization-author.html).
- **Condition.recorder** referenced in "Diagnosis section" of the Composition will be populated with the [**treating physician information**](StructureDefinition-ch-ekm-practitioner-treating-physician.html).

{% include scenario1-broker.svg%}
*Fig. 2: Broker scenario*

##### Invasive Pneumococcal Infection example

A [private service provider with GLN 7601000435333](Organization-ChEkmOrganizationAuthorExample.json.html) transmits the [**reportable clinical findings associated to invasive Streptococcus Pneuminiae infection**](Bundle-ChEkmBundleInvasiveStreptococcusPneumoniae.json.html) to the reporting system of the FOPH on behalf of the [Dr Monika Giacometti at the cantonal hospital](Practitioner-ChEkmPractitionerTreatingPhysicianExample.json.html). The report consolidates clinical findings, vaccination history, and risk factors for the [patient M.B.](Patient-ChEkmPatientInitialsExample.json.html), born on 01.01.2000 and residing in 3097 Liebefeld (BE). This report follows a laboratory confirmation of Streptococcus pneumoniae:
- Diagnosis and Clinical Findings: The patient was diagnosed with a invasive pneumococcal infection. The patient presents with Sepsis. The onset of symptoms is documented as January 27, 2026.
- Hospitalization: Due to the severity of the pneumococcal infection, the patient was hospitalized on January 27, 2026.
- [Laboratory Information](ServiceRequest-ChEkmServiceRequestExample-InvasiveStreptococcusPneumoniae.json.html): The diagnosis is supported by a [blood specimen collected on January 27, 2026](Specimen-ChEkmSpecimenExample-InvasiveStreptococcusPneumoniae.json.html), and analyzed by [LabSan GmbH](Organization-ChEkmOrganizationLabExample.json.html).
- Vaccination Status: The clinician reports that the patient was previously vaccinated against Pneumococci with a total of 2 doses of Prevenar 13. The doses were administered on March 1, 2000, and May 1, 2000.
- Risk Factors: The report identifies Immunosuppression as a pre-existing risk factor relevant to the clinical course.

