// Modular sub-questionnaire: "Angaben zur betroffenen Person" (general person data).
// Split out of the former ChEkmQuestionnaireGonorrhoeaPerson: holds everything about the
// affected person EXCEPT the name initials (-> ChEkmQuestionnairePersonInitials) and the
// gender identity (-> ChEkmQuestionnairePersonGenderIdentity).
// Source of truth: logical model ChEkmGonorrhoeaPersonForm (-> ChEkmPatientInitials).
//
// The items are top-level (no wrapping group), so on assembly they merge directly into the
// referencing root's group without an extra nesting level.
//
// SDC pre-population: each item carries an initialExpression that reads from %patient
// (the launch context declared on the modular root ChEkmQuestionnaireGonorrhoea). The host
// resolves %patient (e.g. SMART launch / $populate) before rendering.

Instance: ChEkmQuestionnairePersonGeneral
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Angaben zur betroffenen Person"
Description: "Modular sub-questionnaire for the general data of the affected person (birth date, AHVN13, nationality, address, canton, administrative gender). Reusable as an SDC assemble-child; supports expression-based pre-population from a patient launch context."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnairePersonGeneral"
* version = "0.0.1"
* name = "ChEkmQuestionnairePersonGeneral"
* status = #active
* language = #en
* experimental = false
* subjectType = #Patient
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-child

// Address to pre-populate from: prefer the home address, else fall back to the first address.
// `combine` preserves order (unlike the `|` union), so the home entry, when present, is first.
// Declared at the Questionnaire (root) level so it is in scope for the zipCode/city/canton items
// below now that they are no longer wrapped in a group. A questionnaire-level `variable` is
// propagated onto the assembled form.
* extension[+].url = $variable
* extension[=].valueExpression.name = "homeOrFirstAddress"
* extension[=].valueExpression.language = #text/fhirpath
* extension[=].valueExpression.expression = "%patient.address.where(use='home').combine(%patient.address).first()"

// NB: dateOfBirth range validation ([1900-01-01, today()]) is authored as a Questionnaire-level
// targetConstraint on the MODULAR ROOT (ChEkmQuestionnaireGonorrhoea), not here: $assemble drops
// a sub-questionnaire's root extensions, but propagates the modular root's onto the assembled
// form (the artifact the renderer loads). See ChEkmQuestionnaireGonorrhoea.fsh.

// Geburtsdatum - required
* item[+].linkId = "dateOfBirth"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.dateOfBirth"
* item[=].text = "Date of birth"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Geburtsdatum"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Date de naissance"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Data di nascita"
* item[=].type = #date
* item[=].required = true
// Birthdate range (>= 1900-01-01 and not in the future) is enforced via a Questionnaire-level
// targetConstraint (see the $targetConstraint extension on the root above), which the Smart
// Forms renderer evaluates and surfaces as inline validation.
//
// The minValue / maxValue(cqf-expression today()) approach below is spec-valid but the Smart
// Forms renderer does NOT enforce min/maxValue on date items (getMinValue/getMaxValue only read
// valueInteger/valueDecimal, and the validation block skips valueDate answers), so it is
// commented out. Re-enable if/when targeting a renderer that honours date min/maxValue.
// * item[=].extension[+].url = $minValue
// * item[=].extension[=].valueDate = "1900-01-01"
// * item[=].extension[+].url = $maxValue
// * item[=].extension[=].valueDate.extension[+].url = $cqf-expression
// * item[=].extension[=].valueDate.extension[=].valueExpression.language = #text/fhirpath
// * item[=].extension[=].valueDate.extension[=].valueExpression.expression = "today()"
// see issue https://github.com/aehrc/smart-forms/issues/1971
* item[=].extension[+].url = $sdc-initialExpression
* item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].extension[=].valueExpression.expression = "%patient.birthDate"

// AHV-Nummer (OASI / AHVN13) - optional free-text string.
// Pre-populated from the patient's AHV identifier (system urn:oid:2.16.756.5.32 ->
// ChEkmPatient identifier[AHVN13]). Per §10, read it with extension/identifier .where(...)
// rather than a slice name, since slices have no runtime FHIRPath representation.
* item[+].linkId = "ahvn13"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.ahvn13"
* item[=].text = "OASI number (AHV)"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "AHV-Nummer (OASI)"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Numéro AVS (OASI)"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Numero AVS (OASI)"
* item[=].type = #string
// Format validation via the standard `regex` extension (Smart Forms reads valueString and
// surfaces it as inline validation). Mirrors the ch-core ahvn13-length invariant
// (matches('^756[0-9]{10}$') -> 756 followed by 10 digits). 13 chars total -> maxLength 13.
* item[=].maxLength = 13
* item[=].extension[+].url = $regex
* item[=].extension[=].valueString = "^756[0-9]{10}$"
* item[=].extension[+].url = $sdc-initialExpression
* item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].extension[=].valueExpression.expression = "%patient.identifier.where(system = 'urn:oid:2.16.756.5.32').value.first()"

// Nationalität - choice (BFS country codes), autocomplete
// Pre-populated from the patient-citizenship extension's `code` Coding
// (http://hl7.org/fhir/StructureDefinition/patient-citizenship -> extension.where(url='code')).
// The source coding is ISO 3166 alpha-2 (e.g. urn:iso:std:iso:3166|CH); ChEkmCountryCodes is now
// alpha-2 too (the redundant alpha-3 codes were removed), so the prepopulated Coding matches a
// dropdown option directly — no code-system translation needed.
* item[+].linkId = "nationality"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.nationality"
* item[=].text = "Nationality"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Nationalität"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Nationalité"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Nazionalità"
* item[=].type = #choice
* item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmCountryCodes"
* item[=].extension[+].url = $questionnaire-itemControl
* item[=].extension[=].valueCodeableConcept = $item-control#autocomplete
* item[=].extension[+].url = $sdc-initialExpression
* item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].extension[=].valueExpression.expression = "%patient.extension.where(url = 'http://hl7.org/fhir/StructureDefinition/patient-citizenship').extension.where(url = 'code').valueCodeableConcept.coding.first()"

// PLZ
* item[+].linkId = "zipCode"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.zipCode"
* item[=].text = "Postal code"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "PLZ"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "NPA"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "NAP"
* item[=].type = #string
* item[=].extension[+].url = $sdc-initialExpression
* item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].extension[=].valueExpression.expression = "%homeOrFirstAddress.postalCode"

// Wohnort
* item[+].linkId = "city"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.city"
* item[=].text = "Place of residence"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Wohnort"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Localité"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Località"
* item[=].type = #string
* item[=].extension[+].url = $sdc-initialExpression
* item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].extension[=].valueExpression.expression = "%homeOrFirstAddress.city"

// Land - choice (BFS country codes), autocomplete
* item[+].linkId = "country"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.country"
* item[=].text = "Country"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Land"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Pays"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Paese"
* item[=].type = #choice
* item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmCountryCodes"
* item[=].extension[+].url = $questionnaire-itemControl
* item[=].extension[=].valueCodeableConcept = $item-control#autocomplete
* item[=].extension[+].url = $sdc-initialExpression
* item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].extension[=].valueExpression.expression = "%homeOrFirstAddress.country"

// Kanton - open-choice with a PREFERRED binding to the eCH-0007 canton abbreviations
// (http://fhir.ch/ig/ch-core/ValueSet/ech-7-cantonabbreviation, from ch-term): the renderer
// suggests the 26 canton codes but still allows a free-text string. This is the R4-idiomatic
// "preferred" binding (open-choice = options-or-string). Pre-population reads the address state
// (a plain string, e.g. "BE"), which fills the free-text part.
* item[+].linkId = "canton"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.canton"
* item[=].text = "Canton"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Kanton"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Canton"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Cantone"
* item[=].type = #open-choice
* item[=].extension[+].url = $sdc-initialExpression
* item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].extension[=].valueExpression.expression = "%homeOrFirstAddress.state"
* item[=].answerValueSet = "http://fhir.ch/ig/ch-core/ValueSet/ech-7-cantonabbreviation"

// Gender - administrative gender (male/female/other), radio buttons - required
* item[+].linkId = "administrativeGender"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmGonorrhoeaPersonForm#ChEkmGonorrhoeaPersonForm.administrativeGender"
* item[=].text = "Gender"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Geschlecht"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Sexe"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Sesso"
* item[=].type = #choice
* item[=].required = true
* item[=].answerValueSet = "http://hl7.org/fhir/ValueSet/administrative-gender"
// Localize the option labels: request displayLanguage de-CH via the binding-parameter extension;
// the tx server resolves the German designations from ChEkmAdministrativeGenderLanguageSupplement.
* item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].answerValueSet.extension[=].extension[=].valueString = "useSupplement"
* item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-administrative-gender-language-supplement"
* item[=].extension[+].url = $questionnaire-itemControl
* item[=].extension[=].valueCodeableConcept = $item-control#radio-button
* item[=].extension[+].url = $choiceOrientation
* item[=].extension[=].valueCode = #horizontal
* item[=].extension[+].url = $sdc-initialExpression
* item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].extension[=].valueExpression.expression = "%patient.gender"
