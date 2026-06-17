// External Code Systems
Alias: $loinc =                         http://loinc.org
Alias: $sct =                           http://snomed.info/sct
Alias: $sct-ch =                        http://snomed.info/sct|http://snomed.info/sct/2011000195101
Alias: $icd10 =                         http://fhir.de/CodeSystem/bfarm/icd-10-gm
Alias: $ucum =                          http://unitsofmeasure.org
Alias: $standardterms =                 http://standardterms.edqm.eu
Alias: $ch-vacd-swissmedic-cs =         http://fhir.ch/ig/ch-vacd/CodeSystem/ch-vacd-swissmedic-cs
Alias: $condition-category =            http://terminology.hl7.org/CodeSystem/condition-category
Alias: $observation-category =          http://terminology.hl7.org/CodeSystem/observation-category
Alias: $v3-ObservationInterpretation =  http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation
Alias: $v3-ActClass =                   http://terminology.hl7.org/CodeSystem/v3-ActClass
Alias: $v3-ActCode =                                http://terminology.hl7.org/CodeSystem/v3-ActCode
Alias: $v3-ParticipationType =          http://terminology.hl7.org/CodeSystem/v3-ParticipationType
Alias: $v2-0203 = http://terminology.hl7.org/CodeSystem/v2-0203

// SDC (Structured Data Capture) - Questionnaire
Alias: $sdc-modular =               http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-modular
Alias: $sdc-assemble-expectation =  http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-assemble-expectation
Alias: $sdc-subQuestionnaire =      http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-subQuestionnaire
Alias: $questionnaire-itemControl = http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl
Alias: $choiceOrientation =         http://hl7.org/fhir/StructureDefinition/questionnaire-choiceOrientation
Alias: $binding-parameter =         http://hl7.org/fhir/tools/StructureDefinition/binding-parameter
Alias: $minLength =                 http://hl7.org/fhir/StructureDefinition/minLength
Alias: $minValue =                  http://hl7.org/fhir/StructureDefinition/minValue
Alias: $maxValue =                  http://hl7.org/fhir/StructureDefinition/maxValue
Alias: $cqf-expression =            http://hl7.org/fhir/StructureDefinition/cqf-expression
// Cross-version targetConstraint (the URL the Smart Forms renderer recognises; NOT the
// uv/sdc sdc-questionnaire-targetConstraint variant).
Alias: $targetConstraint =          http://hl7.org/fhir/StructureDefinition/targetConstraint
Alias: $item-control =              http://hl7.org/fhir/questionnaire-item-control
Alias: $artifact-versionAlgorithm = http://hl7.org/fhir/StructureDefinition/artifact-versionAlgorithm
Alias: $version-algorithm =         http://hl7.org/fhir/version-algorithm
// SDC pre-population (expression-based)
Alias: $sdc-pop-exp =               http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-pop-exp
Alias: $sdc-launchContext =         http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-launchContext
Alias: $sdc-launchContext-cs =      http://hl7.org/fhir/uv/sdc/CodeSystem/launchContext
Alias: $sdc-initialExpression =     http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-initialExpression
Alias: $variable =                  http://hl7.org/fhir/StructureDefinition/variable
// SDC template-based extraction
Alias: $sdc-extr-template =          http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-extr-template
Alias: $sdc-templateExtract =        http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-templateExtract
Alias: $sdc-templateExtractValue =   http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-templateExtractValue
Alias: $sdc-templateExtractContext = http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-templateExtractContext

//External Extensions
Alias: $individual-genderIdentity =      http://hl7.org/fhir/StructureDefinition/individual-genderIdentity
Alias: $individual-recordedSexOrGender = http://hl7.org/fhir/StructureDefinition/individual-recordedSexOrGender
Alias: $patient-citizenship =            http://hl7.org/fhir/StructureDefinition/patient-citizenship
Alias: $regex =                          http://hl7.org/fhir/StructureDefinition/regex

//Identifier systems
Alias: $ahvn13-system =                  urn:oid:2.16.756.5.32
Alias: $iso21090-ADXP-streetName =       http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName
Alias: $iso21090-ADXP-houseNumber =      http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber

//External Value Sets
Alias: $gender-identity =               http://terminology.hl7.org/ValueSet/gender-identity
Alias: $administrative-gender =         http://hl7.org/fhir/administrative-gender

// CH Core & CH EPR Term
Alias: $bfs-country-codes = http://fhir.ch/ig/ch-term/ValueSet/bfs-country-codes
Alias: $iso3166 = urn:iso:std:iso:3166
Alias: $data-absent-reason = http://hl7.org/fhir/StructureDefinition/data-absent-reason
Alias: $ch-core-organization = http://fhir.ch/ig/ch-core/StructureDefinition/ch-core-organization
Alias: $ch-core-practitioner = http://fhir.ch/ig/ch-core/StructureDefinition/ch-core-practitioner
Alias: $ch-core-practitioner-role = http://fhir.ch/ig/ch-core/StructureDefinition/ch-core-practitionerrole
Alias: $ch-core-patient =  http://fhir.ch/ig/ch-elm/ValueSet/ch-elm-results-complete-spec
Alias: $ch-elm-results-complete-spec = http://fhir.ch/ig/ch-elm/ValueSet/ch-elm-results-complete-spec