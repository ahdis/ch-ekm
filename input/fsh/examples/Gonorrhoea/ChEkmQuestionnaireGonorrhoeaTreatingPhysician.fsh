// Modular sub-questionnaire: "Behandelnde Ärztin / behandelnder Arzt" (Treating Physician)
// Source of truth: logical models ChEkmTreatingPhysicianPractitionerForm (-> ChEkmPractitionerTreatingPhysician)
// and ChEkmTreatingPhysicianOrganizationForm (-> ChEkmOrganizationTreatingPhysician)
// in input/fsh/logical/ChEkmTreatingPhysicianForm.fsh.
//
// Two sub-groups (Practitioner + Organization). linkIds are prefixed (physician*/org*) so they
// stay unique across the assembled form — the Person sub-questionnaire already uses zipCode/city,
// and $assemble rejects duplicate linkIds.
//
// SDC pre-population: each item carries an initialExpression that reads from %user (the treating
// physician Practitioner) or %organization (the sending Organization). Both launch contexts are
// declared on the modular root ChEkmQuestionnaireGonorrhoea and propagated onto the assembled
// questionnaire; the host resolves them (e.g. $populate / SMART launch) before rendering.
// Per §10 (forms-summary), extensions are read with .where(url=...) and HAPI-safe accessors.

Instance: ChEkmQuestionnaireGonorrhoeaTreatingPhysician
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Gonorrhoea - Behandelnde Ärztin / behandelnder Arzt"
Description: "Modular sub-questionnaire for the 'Treating Physician' section (Practitioner + Organization) of the Gonorrhoea clinical findings report. Reusable as an SDC assemble-child; supports expression-based pre-population from a practitioner (%user) and organization (%organization) launch context."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoeaTreatingPhysician"
* version = "0.0.1"
* name = "ChEkmQuestionnaireGonorrhoeaTreatingPhysician"
* status = #active
* experimental = false
* subjectType = #Patient
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-child

* item[+].linkId = "treatingPhysician"
* item[=].text = "Behandelnde Ärztin / behandelnder Arzt"
* item[=].type = #group

// --- Practitioner -----------------------------------------------------------
* item[=].item[+].linkId = "treatingPhysicianPractitioner"
* item[=].item[=].text = "Behandelnde Ärztin / behandelnder Arzt"
* item[=].item[=].type = #group
// Address to pre-populate from: prefer the work address, else fall back to the first address.
// `combine` preserves order (unlike `|`), so the work entry, when present, is first. The full
// expression is inlined per-item below rather than hoisted into a group `variable`: the hosted
// HAPI $populate does NOT resolve item/group-level `variable` extensions (verified — the
// analogous %homeOrFirstAddress group variable in the Person form fails to populate too), so
// referencing %user directly in each initialExpression is the reliable pattern.

// Vorname
* item[=].item[=].item[+].linkId = "physicianGivenname"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.givenname"
* item[=].item[=].item[=].text = "Vorname"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.name.first().given.first()"

// Name
* item[=].item[=].item[+].linkId = "physicianSurname"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.surname"
* item[=].item[=].item[=].text = "Name"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.name.first().family"

// Adresse (Strasse, Hausnummer)
* item[=].item[=].item[+].linkId = "physicianStreetLine"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.streetLine"
* item[=].item[=].item[=].text = "Adresse (Strasse, Hausnummer)"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.address.where(use='work').combine(%user.address).first().line.first()"

// PLZ
* item[=].item[=].item[+].linkId = "physicianZipCode"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.zipCode"
* item[=].item[=].item[=].text = "PLZ"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.address.where(use='work').combine(%user.address).first().postalCode"

// Ort
* item[=].item[=].item[+].linkId = "physicianCity"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.city"
* item[=].item[=].item[=].text = "Ort"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.address.where(use='work').combine(%user.address).first().city"

// Telefonnummer
* item[=].item[=].item[+].linkId = "physicianPhone"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.phone"
* item[=].item[=].item[=].text = "Telefonnummer"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.telecom.where(system='phone').value.first()"

// E-Mail
* item[=].item[=].item[+].linkId = "physicianEmail"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.email"
* item[=].item[=].item[=].text = "E-Mail"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.telecom.where(system='email').value.first()"

// GLN
* item[=].item[=].item[+].linkId = "physicianGln"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.gln"
* item[=].item[=].item[=].text = "GLN"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.identifier.where(system='urn:oid:2.51.1.3').value.first()"

// --- Organization -----------------------------------------------------------
* item[=].item[+].linkId = "treatingPhysicianOrganization"
* item[=].item[=].text = "Absendende Organisation"
* item[=].item[=].type = #group

// Name
* item[=].item[=].item[+].linkId = "orgName"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.name"
* item[=].item[=].item[=].text = "Name"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%organization.name"

// Abteilung
* item[=].item[=].item[+].linkId = "orgDepartment"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.department"
* item[=].item[=].item[=].text = "Abteilung"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%organization.extension.where(url='http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-ext-department').valueString"

// Adresse (Strasse, Hausnummer)
* item[=].item[=].item[+].linkId = "orgStreetLine"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.streetLine"
* item[=].item[=].item[=].text = "Adresse (Strasse, Hausnummer)"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%organization.address.first().line.first()"

// PLZ
* item[=].item[=].item[+].linkId = "orgZipCode"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.zipCode"
* item[=].item[=].item[=].text = "PLZ"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%organization.address.first().postalCode"

// Ort
* item[=].item[=].item[+].linkId = "orgCity"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.city"
* item[=].item[=].item[=].text = "Ort"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%organization.address.first().city"

// Telefonnummer
* item[=].item[=].item[+].linkId = "orgPhone"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.phone"
* item[=].item[=].item[=].text = "Telefonnummer"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%organization.telecom.where(system='phone').value.first()"

// E-Mail
* item[=].item[=].item[+].linkId = "orgEmail"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.email"
* item[=].item[=].item[=].text = "E-Mail"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%organization.telecom.where(system='email').value.first()"

// BUR (Betriebs- und Unternehmensregister / BER)
* item[=].item[=].item[+].linkId = "orgBer"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.ber"
* item[=].item[=].item[=].text = "BUR"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%organization.identifier.where(system='urn:oid:2.16.756.5.45').value.first()"

// GLN
* item[=].item[=].item[+].linkId = "orgGln"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.gln"
* item[=].item[=].item[=].text = "GLN"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%organization.identifier.where(system='urn:oid:2.51.1.3').value.first()"
