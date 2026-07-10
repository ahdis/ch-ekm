// Modular sub-questionnaire: "Behandelnde Ärztin / behandelnder Arzt" (Treating Physician)
// Source of truth: logical models ChEkmTreatingPhysicianPractitionerForm (-> ChEkmPractitionerTreatingPhysician)
// and ChEkmTreatingPhysicianOrganizationForm (-> ChEkmOrganizationTreatingPhysician)
// in input/fsh/logical/ChEkmTreatingPhysicianForm.fsh.
//
// Two sub-groups (Practitioner + Organization). linkIds are prefixed (physician*/org*) so they
// stay unique across the assembled form — the Person sub-questionnaire already uses zipCode/city,
// and $assemble rejects duplicate linkIds.
//
// SDC pre-population: %user is the treating physician's PractitionerRole (the single `user`
// launch context declared on the modular root ChEkmQuestionnaireGonorrhoea, propagated onto the
// assembled questionnaire). Practitioner fields read %user.practitioner.resolve()...; Organization
// fields read %user.organization.resolve()... — both via the FHIRPath resolve() function, which
// requires the populate engine to be configured with a reachable FHIR server (fhirServerUrl /
// fetchResourceRequestConfig.sourceServerUrl) that can serve those references, e.g. the SMART
// launch `iss` in production, or the local HAPI instance (start_hapi.sh + load_examples.sh) for
// tests/populate-gonorrhoea.sh. Per §10 (forms-summary), extensions are read with .where(url=...)
// and HAPI-safe accessors.

Instance: ChEkmQuestionnaireGonorrhoeaTreatingPhysician
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Gonorrhoea - Behandelnde Ärztin / behandelnder Arzt"
Description: "Modular sub-questionnaire for the 'Treating Physician' section (Practitioner + Organization) of the Gonorrhoea clinical findings report. Reusable as an SDC assemble-child; supports expression-based pre-population from a single PractitionerRole (%user) launch context, resolving the practitioner and organization references it carries."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoeaTreatingPhysician"
* version = "0.0.1"
* name = "ChEkmQuestionnaireGonorrhoeaTreatingPhysician"
* status = #active
* language = #en
* experimental = false
* subjectType = #Patient
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-child

* item[+].linkId = "treatingPhysician"
* item[=].text = "Treating physician"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Behandelnde Ärztin / behandelnder Arzt"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Médecin traitant"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Medico curante"
* item[=].type = #group

// --- Practitioner -----------------------------------------------------------
* item[=].item[+].linkId = "treatingPhysicianPractitioner"
* item[=].item[=].text = "Treating physician"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Behandelnde Ärztin / behandelnder Arzt"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Médecin traitant"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Medico curante"
* item[=].item[=].type = #group
// Address to pre-populate from: prefer the work address, else fall back to the first address.
// `combine` preserves order (unlike `|`), so the work entry, when present, is first. The full
// expression (incl. %user.practitioner.resolve()) is inlined per-item below rather than hoisted
// into a group `variable`: the hosted HAPI $populate does NOT resolve item/group-level `variable`
// extensions (verified — the analogous %homeOrFirstAddress group variable in the Person form
// fails to populate too), so repeating the resolve() per item is the reliable pattern.

// Vorname
* item[=].item[=].item[+].linkId = "physicianGivenname"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.givenname"
* item[=].item[=].item[=].text = "First name"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Vorname"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Prénom"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Nome"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.practitioner.resolve().name.first().given.first()"

// Name
* item[=].item[=].item[+].linkId = "physicianSurname"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.surname"
* item[=].item[=].item[=].text = "Last name"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Name"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Nom"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Cognome"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.practitioner.resolve().name.first().family"

// Adresse (Strasse, Hausnummer)
* item[=].item[=].item[+].linkId = "physicianStreetLine"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.streetLine"
* item[=].item[=].item[=].text = "Address (street, house number)"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Adresse (Strasse, Hausnummer)"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Adresse (rue, numéro)"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Indirizzo (via, numero civico)"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.practitioner.resolve().address.where(use='work').combine(%user.practitioner.resolve().address).first().line.first()"

// PLZ
* item[=].item[=].item[+].linkId = "physicianZipCode"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.zipCode"
* item[=].item[=].item[=].text = "Postal code"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "PLZ"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "NPA"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "NAP"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.practitioner.resolve().address.where(use='work').combine(%user.practitioner.resolve().address).first().postalCode"

// Ort
* item[=].item[=].item[+].linkId = "physicianCity"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.city"
* item[=].item[=].item[=].text = "Town/city"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Ort"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Localité"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Località"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.practitioner.resolve().address.where(use='work').combine(%user.practitioner.resolve().address).first().city"

// Telefonnummer
* item[=].item[=].item[+].linkId = "physicianPhone"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.phone"
* item[=].item[=].item[=].text = "Phone number"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Telefonnummer"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Numéro de téléphone"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Numero di telefono"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.practitioner.resolve().telecom.where(system='phone').value.first()"

// E-Mail
* item[=].item[=].item[+].linkId = "physicianEmail"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.email"
* item[=].item[=].item[=].text = "Email"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "E-Mail"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "E-mail"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "E-mail"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.practitioner.resolve().telecom.where(system='email').value.first()"

// GLN
* item[=].item[=].item[+].linkId = "physicianGln"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.gln"
* item[=].item[=].item[=].text = "GLN"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "GLN"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "GLN"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "GLN"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.practitioner.resolve().identifier.where(system='urn:oid:2.51.1.3').value.first()"

// --- Organization -----------------------------------------------------------
* item[=].item[+].linkId = "treatingPhysicianOrganization"
* item[=].item[=].text = "Sending organisation"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Absendende Organisation"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Organisation émettrice"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Organizzazione mittente"
* item[=].item[=].type = #group

// Name
* item[=].item[=].item[+].linkId = "orgName"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.name"
* item[=].item[=].item[=].text = "Name"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Name"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Nom"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Nome"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.organization.resolve().name"

// Abteilung
* item[=].item[=].item[+].linkId = "orgDepartment"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.department"
* item[=].item[=].item[=].text = "Department"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Abteilung"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Service"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Reparto"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.organization.resolve().extension.where(url='http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-ext-department').valueString"

// Adresse (Strasse, Hausnummer)
* item[=].item[=].item[+].linkId = "orgStreetLine"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.streetLine"
* item[=].item[=].item[=].text = "Address (street, house number)"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Adresse (Strasse, Hausnummer)"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Adresse (rue, numéro)"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Indirizzo (via, numero civico)"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.organization.resolve().address.first().line.first()"

// PLZ
* item[=].item[=].item[+].linkId = "orgZipCode"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.zipCode"
* item[=].item[=].item[=].text = "Postal code"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "PLZ"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "NPA"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "NAP"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.organization.resolve().address.first().postalCode"

// Ort
* item[=].item[=].item[+].linkId = "orgCity"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.city"
* item[=].item[=].item[=].text = "Town/city"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Ort"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Localité"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Località"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.organization.resolve().address.first().city"

// Telefonnummer
* item[=].item[=].item[+].linkId = "orgPhone"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.phone"
* item[=].item[=].item[=].text = "Phone number"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Telefonnummer"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Numéro de téléphone"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Numero di telefono"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.organization.resolve().telecom.where(system='phone').value.first()"

// E-Mail
* item[=].item[=].item[+].linkId = "orgEmail"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.email"
* item[=].item[=].item[=].text = "Email"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "E-Mail"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "E-mail"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "E-mail"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.organization.resolve().telecom.where(system='email').value.first()"

// BUR (Betriebs- und Unternehmensregister / BER)
* item[=].item[=].item[+].linkId = "orgBer"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.ber"
* item[=].item[=].item[=].text = "BER"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "BUR"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "REE"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "RIS"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.organization.resolve().identifier.where(system='urn:oid:2.16.756.5.45').value.first()"

// GLN
* item[=].item[=].item[+].linkId = "orgGln"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.gln"
* item[=].item[=].item[=].text = "GLN"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "GLN"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "GLN"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "GLN"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.organization.resolve().identifier.where(system='urn:oid:2.51.1.3').value.first()"
