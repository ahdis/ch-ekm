// Modular sub-questionnaire: "Angaben zur betroffenen Person" (Gonorrhoea green section)
// Source of truth: logical model ChEkmGonorrhoeaPersonForm (-> ChEkmPatientInitials)
// Decisions (2026-06-09): pregnancy omitted; gender = administrativeGender + genderIdentity (model).
//
// SDC pre-population: each item carries an initialExpression that reads from %patient
// (the launch context declared on the modular root ChEkmQuestionnaireGonorrhoea). The host
// resolves %patient (e.g. SMART launch / $populate) before rendering.

Instance: ChEkmQuestionnaireGonorrhoeaPerson
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Gonorrhoea - Angaben zur betroffenen Person"
Description: "Modular sub-questionnaire for the 'Angaben zur betroffenen Person' section of the Gonorrhoea clinical findings report. Reusable as an SDC assemble-child; supports expression-based pre-population from a patient launch context."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoeaPerson"
* version = "0.0.1"
* name = "ChEkmQuestionnaireGonorrhoeaPerson"
* status = #active
* experimental = false
* subjectType = #Patient
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-child

// NB: dateOfBirth range validation ([1900-01-01, today()]) is authored as a Questionnaire-level
// targetConstraint on the MODULAR ROOT (ChEkmQuestionnaireGonorrhoea), not here: $assemble drops
// a sub-questionnaire's root extensions, but propagates the modular root's onto the assembled
// form (the artifact the renderer loads). See ChEkmQuestionnaireGonorrhoea.fsh.

* item[+].linkId = "person"
* item[=].text = "Angaben zur betroffenen Person"
* item[=].type = #group
// Address to pre-populate from: prefer the home address, else fall back to the first address.
// `combine` preserves order (unlike the `|` union), so the home entry, when present, is first.
// Scoped to the person group, so it is in scope for the zipCode/city/canton items below.
* item[=].extension[+].url = $variable
* item[=].extension[=].valueExpression.name = "homeOrFirstAddress"
* item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].extension[=].valueExpression.expression = "%patient.address.where(use='home').combine(%patient.address).first()"

// Initiale Name (surname initial) - required; first letter of the family name
* item[=].item[+].linkId = "surnameInitial"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.surnameInitial"
* item[=].item[=].text = "Initiale Name"
* item[=].item[=].type = #string
* item[=].item[=].required = true
// Initials are a single letter. maxLength is a NATIVE Questionnaire.item element (not an
// extension) — Smart Forms enforces qItem.maxLength, so it must be set natively here.
* item[=].item[=].maxLength = 1
* item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].extension[=].valueExpression.expression = "%patient.name.first().family.substring(0,1)"

// Initiale Vorname (given name initial) - required; first letter of the given name
* item[=].item[+].linkId = "givennameInitial"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.givennameInitial"
* item[=].item[=].text = "Initiale Vorname"
* item[=].item[=].type = #string
* item[=].item[=].required = true
* item[=].item[=].maxLength = 1
* item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].extension[=].valueExpression.expression = "%patient.name.first().given.first().substring(0,1)"

// Geburtsdatum - required
* item[=].item[+].linkId = "dateOfBirth"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.dateOfBirth"
* item[=].item[=].text = "Geburtsdatum"
* item[=].item[=].type = #date
* item[=].item[=].required = true
// Birthdate range (>= 1900-01-01 and not in the future) is enforced via a Questionnaire-level
// targetConstraint (see the $targetConstraint extension on the root above), which the Smart
// Forms renderer evaluates and surfaces as inline validation.
//
// The minValue / maxValue(cqf-expression today()) approach below is spec-valid but the Smart
// Forms renderer does NOT enforce min/maxValue on date items (getMinValue/getMaxValue only read
// valueInteger/valueDecimal, and the validation block skips valueDate answers), so it is
// commented out. Re-enable if/when targeting a renderer that honours date min/maxValue.
// * item[=].item[=].extension[+].url = $minValue
// * item[=].item[=].extension[=].valueDate = "1900-01-01"
// * item[=].item[=].extension[+].url = $maxValue
// * item[=].item[=].extension[=].valueDate.extension[+].url = $cqf-expression
// * item[=].item[=].extension[=].valueDate.extension[=].valueExpression.language = #text/fhirpath
// * item[=].item[=].extension[=].valueDate.extension[=].valueExpression.expression = "today()"
// see issue https://github.com/aehrc/smart-forms/issues/1971
* item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].extension[=].valueExpression.expression = "%patient.birthDate"

// AHV-Nummer (OASI / AHVN13) - optional free-text string.
// Pre-populated from the patient's AHV identifier (system urn:oid:2.16.756.5.32 ->
// ChEkmPatient identifier[AHVN13]). Per §10, read it with extension/identifier .where(...)
// rather than a slice name, since slices have no runtime FHIRPath representation.
* item[=].item[+].linkId = "ahvn13"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.ahvn13"
* item[=].item[=].text = "AHV-Nummer (OASI)"
* item[=].item[=].type = #string
// Format validation via the standard `regex` extension (Smart Forms reads valueString and
// surfaces it as inline validation). Mirrors the ch-core ahvn13-length invariant
// (matches('^756[0-9]{10}$') -> 756 followed by 10 digits). 13 chars total -> maxLength 13.
* item[=].item[=].maxLength = 13
* item[=].item[=].extension[+].url = $regex
* item[=].item[=].extension[=].valueString = "^756[0-9]{10}$"
* item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].extension[=].valueExpression.expression = "%patient.identifier.where(system = 'urn:oid:2.16.756.5.32').value.first()"

// Nationalität - choice (BFS country codes), autocomplete
// Pre-populated from the patient-citizenship extension's `code` Coding
// (http://hl7.org/fhir/StructureDefinition/patient-citizenship -> extension.where(url='code')).
// The source coding is ISO 3166 alpha-2 (e.g. urn:iso:std:iso:3166|CH); ChEkmCountryCodes is now
// alpha-2 too (the redundant alpha-3 codes were removed), so the prepopulated Coding matches a
// dropdown option directly — no code-system translation needed.
* item[=].item[+].linkId = "nationality"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.nationality"
* item[=].item[=].text = "Nationalität"
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmCountryCodes"
* item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "displayLanguage"
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "de-CH"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#autocomplete
* item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].extension[=].valueExpression.expression = "%patient.extension.where(url = 'http://hl7.org/fhir/StructureDefinition/patient-citizenship').extension.where(url = 'code').valueCodeableConcept.coding.first()"

// PLZ
* item[=].item[+].linkId = "zipCode"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.zipCode"
* item[=].item[=].text = "PLZ"
* item[=].item[=].type = #string
* item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].extension[=].valueExpression.expression = "%homeOrFirstAddress.postalCode"

// Wohnort
* item[=].item[+].linkId = "city"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.city"
* item[=].item[=].text = "Wohnort"
* item[=].item[=].type = #string
* item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].extension[=].valueExpression.expression = "%homeOrFirstAddress.city"

// Land - choice (BFS country codes), autocomplete
* item[=].item[+].linkId = "country"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.country"
* item[=].item[=].text = "Land"
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmCountryCodes"
* item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "displayLanguage"
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "de-CH"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#autocomplete
* item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].extension[=].valueExpression.expression = "%homeOrFirstAddress.country"

// Kanton - open-choice with a PREFERRED binding to the eCH-0007 canton abbreviations
// (http://fhir.ch/ig/ch-core/ValueSet/ech-7-cantonabbreviation, from ch-term): the renderer
// suggests the 26 canton codes but still allows a free-text string. This is the R4-idiomatic
// "preferred" binding (open-choice = options-or-string). Pre-population reads the address state
// (a plain string, e.g. "BE"), which fills the free-text part.
* item[=].item[+].linkId = "canton"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.canton"
* item[=].item[=].text = "Kanton"
* item[=].item[=].type = #open-choice
* item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].extension[=].valueExpression.expression = "%homeOrFirstAddress.state"
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-core/ValueSet/ech-7-cantonabbreviation"

// Gender - administrative gender (male/female/other), radio buttons - required
* item[=].item[+].linkId = "administrativeGender"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.administrativeGender"
* item[=].item[=].text = "Gender"
* item[=].item[=].type = #choice
* item[=].item[=].required = true
* item[=].item[=].answerValueSet = "http://hl7.org/fhir/ValueSet/administrative-gender"
// Localize the option labels: request displayLanguage de-CH via the binding-parameter extension;
// the tx server resolves the German designations from ChEkmAdministrativeGenderLanguageSupplement.
* item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "displayLanguage"
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "de-CH"
* item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "useSupplement"
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-administrative-gender-language-supplement"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#radio-button
* item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].extension[=].valueCode = #horizontal
* item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].extension[=].valueExpression.expression = "%patient.gender"

// Gender identity (transgender) - separate item per model.
// Pre-populated from the individual-genderIdentity extension's `value` Coding
// (http://hl7.org/fhir/StructureDefinition/individual-genderIdentity -> extension.where(url='value')).
// Source and form share the ChEkmGenderIdentity value set (SNOMED), so the Coding matches directly.
* item[=].item[+].linkId = "genderIdentity"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.genderIdentity"
* item[=].item[=].text = "Geschlechtsidentität (transgender)"
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmGenderIdentity"
* item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "displayLanguage"
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "de-CH"
* item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "useSupplement"
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-snomed-language-supplement"
* item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].extension[=].valueExpression.expression = "%patient.extension.where(url = 'http://hl7.org/fhir/StructureDefinition/individual-genderIdentity').extension.where(url = 'value').valueCodeableConcept.coding.first()"