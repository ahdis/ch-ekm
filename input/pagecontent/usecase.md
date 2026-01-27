- [Scenario 1 - Reporting pathway for the standard case](#scenario-1---reporting-pathway-for-the-standard-case)
- [Scenario 2 - Reporting pathway for confirmation tests](#scenario-2---reporting-pathway-for-confirmation-tests)
- [Scenario 3 - Reporting pathway when passing on a laboratory order](#scenario-3---reporting-pathway-when-passing-on-a-laboratory-order)

The following use cases serve to illustrate the scenarios that occur in the case of reportable laboratory results that are transmitted to the Federal Office of Public Health. The cases are intended as examples of the representation of laboratory reports. They have not yet been validated in terms of their content and clinical aspects.

### Scenario 1 - Reporting pathway for the standard case

This reporting pathway applies to pathogens such as [Neisseria gonorrhoeae](#neisseria-gonorrhoeae), [Chlamydia trachomatis](#chlamydia-trachomatis) and others.

{% include img.html img="scenario1.png" caption="Fig. 1: Reporting pathway for the standard case" width="60%" %}

#### Neisseria gonorrhoeae

[Mr Daniel Meier](Patient-Pat-001.html), born on 22.08.1960, resident in 3000 Bern, consults [Dr Monika Giacometti at the cantonal hospital](PractitionerRole-1PR-KsAbc.html) on 11.07.2023. Mr Meier complained of itching of the urethra and pain when urinating. As a urinary tract infection is suspected, a [swab](Specimen-1Spec-Specimen.html) is taken and sent to the [laboratory](Organization-1Org-Labor.html) for analysis. By means of isolation in culture, [Neisseria gonorrhoeae detected (LOINC 697-3)](Observation-1Obs-NeisseriaGonorrhoeae.html) is on 14 July 2023 . The laboratory reports the [**notifiable laboratory finding**](Bundle-1Doc-NeisseriaGonorrhoeae.html) to the reporting system of the Federal Office of Public Health.

#### Broker scenario

[Private service providers (so-called brokers)](Organization-1bOrg-Broker.html) who transmit the [**reportable laboratory findings**](Bundle-1bDoc-NeisseriaGonorrhoeae.html) to the reporting system of the Federal Office of Public Health on behalf of the [laboratory](Organization-1bOrg-Labor.html) are shown in the FHIR document as the author of the document.

#### Chlamydia trachomatis

Mrs Hanna Felber, born on 17.10.1985, resident in 4552 Derendingen, consults her family doctor Dr Peter Hauser at his practice in Solothurn on 29.7.2023. Mrs Felber complains of burning when urinating and vaginal discharge. As a urinary tract infection is suspected, a urethral sample is taken using a sterile procedure and sent to the laboratory. Chlamydia trachomatis (LOINC 6349-5) is detected by culture on 4 August 2023. The laboratory reports the positive [**reportable laboratory result**](Bundle-2Doc-ChlamydiaTrachomatis.html) to the Federal Office of Public Health, stating the sample material used (SNOMED CT 119393003).

### Scenario 2 - Reporting pathway for confirmation tests

This reporting pathway applies to pathogens such as [Salmonella spp.](#salmonella-spp), [Neisseria meningitidis](#neisseria-meningitidis) and others.

{% include img.html img="scenario2.png" caption="Fig. 2: Reporting pathway for confirmation tests" width="60%" %}

Secondary Laboratories reporting to the FOPH shall include the ordering id and the orderer (name, contact information) of the Primary Laboratory in their report.

#### Salmonella spp.

Salmonella spp. was found in a blood sample. A report of the findings is sent to the ordering party (practice/clinic); a first report is sent to the FOPH (stating the order number and the ordering doctor/clinic). As it is not the S. enteritidis type, the sample is sent to the National Centre for Enteropathogenic Bacteria and Listeria ("NENT", secondary laboratory) for precise typing. The secondary laboratory requires master data on the client and the patient, information on the origin of the sample (food, faeces, blood, urine, etc.), the desired typing and the previous results. Once typing has been completed, the secondary laboratory sends its findings (the 2nd report) together with the order number of the referring laboratory to the FOPH.

#### Neisseria meningitidis

A cerebrospinal fluid sample was sent by the district hospital on an emergency basis and examined directly under the microscope. Gram-negative diplococci were found. This finding of an infection with Neisseria meningitidis must be reported within one day [JSON](Bundle-17Doc-Neisseria.json.html). Further processing (culture, genome sequence) is carried out by the National Centre for Meningococci (secondary laboratory), which in turn sends a complete report together with the information of the primary laboratory, including the order number (50002610 in the example) to the Reporting Systems Section of the FOPH [JSON](Bundle-14Doc-Neisseriameningitidis-confirmationtest-originalorder.json.html). It is important to note that in this example, the information on the original orderer of the lab result (the specific department of the district hospital) should still be included in the document, as this information is of central importance for the cantonal physician. If it is not possible to include this information, a document can be sent with only the information of the primary laboratory [JSON](Bundle-14Doc-Neisseriameningitidis-confirmationtest.json.html).

### Scenario 3 - Reporting pathway when passing on a laboratory order

If a Primary Laboratory is not capable of performing an analysis ordered by a Practice/clinic, the Primary laboratory passes on the order to another laboratory. In this scenario only the Secondary Laboratory generates test results and therefore only the Secondary Laboratory reports to the FOPH.

{% include img.html img="scenario3.png" caption="Fig. 3: Reporting pathway when passing on a laboratory order" width="55%" %}
