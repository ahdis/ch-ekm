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

Instance: ChEkmQuestionnaireTreatingPhysician
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Treating Physician"
Description: "Modular sub-questionnaire for the 'Treating Physician' section (Practitioner + Organization) of the clinical findings report. Reusable as an SDC assemble-child; supports expression-based pre-population from a single PractitionerRole (%user) launch context, resolving the practitioner and organization references it carries."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireTreatingPhysician)

* item[+].linkId = "treatingPhysician"
* insert RuleSetQrLevel1Text("Treating physician", "Behandelnde Ärztin / behandelnder Arzt", "Médecin traitant", "Medico curante")
* item[=].type = #group
// Tab label in the assembled root form (tab-container): this group replaces the root's
// subQuestionnaire placeholder, so the shortText has to be authored here, not on the placeholder.
* insert RuleSetQrLevel1ShortText("Physician", "Arzt/Ärztin", "Médecin", "Medico")

// --- Practitioner -----------------------------------------------------------
* item[=].item[+].linkId = "treatingPhysicianPractitioner"
* insert RuleSetQrLevel2Text("Treating physician", "Behandelnde Ärztin / behandelnder Arzt", "Médecin traitant", "Medico curante")
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
* insert RuleSetQrLevel3Text("First name", "Vorname", "Prénom", "Nome")
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.practitioner.resolve().name.first().given.first()"

// Name
* item[=].item[=].item[+].linkId = "physicianSurname"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.surname"
* insert RuleSetQrLevel3Text("Last name", "Name", "Nom", "Cognome")
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.practitioner.resolve().name.first().family"

// Adresse (Strasse, Hausnummer)
* item[=].item[=].item[+].linkId = "physicianStreetLine"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.streetLine"
* insert RuleSetQrLevel3Text("Address (street\, house number\)", "Adresse (Strasse\, Hausnummer\)", "Adresse (rue\, numéro\)", "Indirizzo (via\, numero civico\)")
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.practitioner.resolve().address.where(use='work').combine(%user.practitioner.resolve().address).first().line.first()"

// PLZ
* item[=].item[=].item[+].linkId = "physicianZipCode"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.zipCode"
* insert RuleSetQrLevel3Text("Postal code", "PLZ", "NPA", "NAP")
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.practitioner.resolve().address.where(use='work').combine(%user.practitioner.resolve().address).first().postalCode"

// Ort
* item[=].item[=].item[+].linkId = "physicianCity"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.city"
* insert RuleSetQrLevel3Text("Town/city", "Ort", "Localité", "Località")
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.practitioner.resolve().address.where(use='work').combine(%user.practitioner.resolve().address).first().city"

// Telefonnummer
* item[=].item[=].item[+].linkId = "physicianPhone"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.phone"
* insert RuleSetQrLevel3Text("Phone number", "Telefonnummer", "Numéro de téléphone", "Numero di telefono")
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.practitioner.resolve().telecom.where(system='phone').value.first()"

// E-Mail
* item[=].item[=].item[+].linkId = "physicianEmail"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.email"
* insert RuleSetQrLevel3Text("Email", "E-Mail", "E-mail", "E-mail")
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.practitioner.resolve().telecom.where(system='email').value.first()"

// GLN
* item[=].item[=].item[+].linkId = "physicianGln"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianPractitionerForm#ChEkmTreatingPhysicianPractitionerForm.gln"
* insert RuleSetQrLevel3Text("GLN", "GLN", "GLN", "GLN")
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.practitioner.resolve().identifier.where(system='urn:oid:2.51.1.3').value.first()"

// The Practitioner's reference ON THE LAUNCHING SERVER (e.g. "Practitioner/123") — not a form question,
// so hidden and without a logical-model `definition`. $extract has only the QuestionnaireResponse to
// read: QuestionnaireResponse.author is the SMART user, i.e. the PractitionerRole, and the launch
// contexts (%user) are gone by then. Capturing the reference here at $populate time is what lets the
// DocumentReference (ChEkmDocumentReferenceTemplate) name the Practitioner as its author.
// A `string`, not a `reference` item: Smart Forms' $populate turns a Reference result into a
// valueString of its display (sdc-populate parseValueToAnswer has no valueReference branch). Smart Forms
// keeps answers of questionnaire-hidden items in the response (removeEmptyAnswersFromResponse).
* item[=].item[=].item[+].linkId = "physicianReference"
* item[=].item[=].item[=].text = "Practitioner reference (system)"
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].readOnly = true
* item[=].item[=].item[=].extension[+].url = $questionnaire-hidden
* item[=].item[=].item[=].extension[=].valueBoolean = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.practitioner.reference"

// --- Organization -----------------------------------------------------------
* item[=].item[+].linkId = "treatingPhysicianOrganization"
* insert RuleSetQrLevel2Text("Sending organisation", "Absendende Organisation", "Organisation émettrice", "Organizzazione mittente")
* item[=].item[=].type = #group

// Name
* item[=].item[=].item[+].linkId = "orgName"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.name"
* insert RuleSetQrLevel3Text("Name", "Name", "Nom", "Nome")
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.organization.resolve().name"

// Abteilung
* item[=].item[=].item[+].linkId = "orgDepartment"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.department"
* insert RuleSetQrLevel3Text("Department", "Abteilung", "Service", "Reparto")
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.organization.resolve().extension.where(url='http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-ext-department').valueString"

// Adresse (Strasse, Hausnummer)
* item[=].item[=].item[+].linkId = "orgStreetLine"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.streetLine"
* insert RuleSetQrLevel3Text("Address (street\, house number\)", "Adresse (Strasse\, Hausnummer\)", "Adresse (rue\, numéro\)", "Indirizzo (via\, numero civico\)")
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.organization.resolve().address.first().line.first()"

// PLZ
* item[=].item[=].item[+].linkId = "orgZipCode"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.zipCode"
* insert RuleSetQrLevel3Text("Postal code", "PLZ", "NPA", "NAP")
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.organization.resolve().address.first().postalCode"

// Ort
* item[=].item[=].item[+].linkId = "orgCity"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.city"
* insert RuleSetQrLevel3Text("Town/city", "Ort", "Localité", "Località")
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.organization.resolve().address.first().city"

// Telefonnummer
* item[=].item[=].item[+].linkId = "orgPhone"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.phone"
* insert RuleSetQrLevel3Text("Phone number", "Telefonnummer", "Numéro de téléphone", "Numero di telefono")
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].required = true
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.organization.resolve().telecom.where(system='phone').value.first()"

// E-Mail
* item[=].item[=].item[+].linkId = "orgEmail"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.email"
* insert RuleSetQrLevel3Text("Email", "E-Mail", "E-mail", "E-mail")
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.organization.resolve().telecom.where(system='email').value.first()"

// BUR (Betriebs- und Unternehmensregister / BER)
* item[=].item[=].item[+].linkId = "orgBer"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.ber"
* insert RuleSetQrLevel3Text("BER", "BUR", "REE", "RIS")
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.organization.resolve().identifier.where(system='urn:oid:2.16.756.5.45').value.first()"

// GLN
* item[=].item[=].item[+].linkId = "orgGln"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmTreatingPhysicianOrganizationForm#ChEkmTreatingPhysicianOrganizationForm.gln"
* insert RuleSetQrLevel3Text("GLN", "GLN", "GLN", "GLN")
* item[=].item[=].item[=].type = #string
* item[=].item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].item[=].extension[=].valueExpression.expression = "%user.organization.resolve().identifier.where(system='urn:oid:2.51.1.3').value.first()"
