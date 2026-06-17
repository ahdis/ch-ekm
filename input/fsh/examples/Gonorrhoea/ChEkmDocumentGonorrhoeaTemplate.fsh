// SDC template-based extraction — BUNDLE TEMPLATE for Gonorrhoea.
//
// This is a single "Bundle template" (SDC template-based extraction,
// http://hl7.org/fhir/uv/sdc/extraction.html#template-based-extraction). It is shaped
// exactly like the target document Bundle (Profile: ChEkmDocumentGonorrhoea). The parts
// that vary per report carry sdc-questionnaire-templateExtractValue / -templateExtractContext
// FHIRPath expressions that read the answers from a QuestionnaireResponse (%resource).
//
// At $extract time the engine deep-copies this Bundle, evaluates each expression against the
// QR, writes the result into the annotated field, strips the template extensions, and returns
// the populated Bundle (wrapped in an outer transaction Bundle — tests/extract/extract.mjs
// unwraps entry[0].resource).
//
// Conventions used here (see the smart-forms reference impl, ../smart-forms/packages/sdc-template-extract):
//  * primitive value  -> templateExtractValue on the element (FSH `x.extension` => the `_x` sibling);
//                        an empty FHIRPath result simply omits the field (conditional).
//  * Coding/CodeableConcept -> templateExtractContext on the CodeableConcept (sets the answer.value
//                        scope) + templateExtractValue `ofType(Coding)` on coding[0].
//  * cross-references (Composition -> Patient/Condition/Observation) are static here: because the
//                        whole document is one template we own all the fullUrls and references,
//                        so nothing has to be re-wired after extraction.
//  * static system metadata (Broker PractitionerRole/Practitioner/Organization) is reused verbatim
//                        from the existing examples — it is supplied by the transmitting system,
//                        not by the form.
//
// Run:  ./tests/extract-gonorrhoea.sh   (sushi . first to (re)generate this Bundle JSON)

// ---------------------------------------------------------------------------
// Patient (ChEkmPatientInitials) — initials, DOB, gender, address from the `person` group
// ---------------------------------------------------------------------------
Instance: GonExtractPatient
InstanceOf: Patient
Usage: #inline
// * meta.profile = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-patient-initials"
// Nationalität -> patient-citizenship.code (identity pass-through of the answered Coding).
// Same Coding idiom as evidence.code: templateExtractContext on the value CodeableConcept sets the
// answer.value scope, templateExtractValue `ofType(Coding)` on coding[0] writes the Coding. If
// nationality is unanswered the context is empty and the CodeableConcept (hence the citizenship
// extension) is omitted.
* extension[0].url = $patient-citizenship
* extension[0].extension[0].url = "code"
* extension[0].extension[0].valueCodeableConcept.extension[+].url = $sdc-templateExtractContext
* extension[0].extension[0].valueCodeableConcept.extension[=].valueString = "%resource.descendants().where(linkId='nationality').answer.value"
* extension[0].extension[0].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* extension[0].extension[0].valueCodeableConcept.coding[0].extension[=].valueString = "ofType(Coding)"
// Geschlechtsidentität -> individual-genderIdentity.value (identity pass-through of the answered
// Coding). Same Coding idiom; if genderIdentity is unanswered the context is empty and the
// extension is omitted.
* extension[1].url = $individual-genderIdentity
* extension[1].extension[0].url = "value"
* extension[1].extension[0].valueCodeableConcept.extension[+].url = $sdc-templateExtractContext
* extension[1].extension[0].valueCodeableConcept.extension[=].valueString = "%resource.descendants().where(linkId='genderIdentity').answer.value"
* extension[1].extension[0].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* extension[1].extension[0].valueCodeableConcept.coding[0].extension[=].valueString = "ofType(Coding)"
// Context on name[0] (the person group) so the array-primitive `given` maps correctly into
// given[*] — the same idiom the SDC reference patient template uses for repeating names.
* name[0].extension[+].url = $sdc-templateExtractContext
* name[0].extension[=].valueString = "%resource.descendants().where(linkId='person')"
* name[0].family.extension[+].url = $sdc-templateExtractValue
* name[0].family.extension[=].valueString = "item.where(linkId='surnameInitial').answer.value.first()"
* name[0].given[0].extension[+].url = $sdc-templateExtractValue
* name[0].given[0].extension[=].valueString = "item.where(linkId='givennameInitial').answer.value"
* gender.extension[+].url = $sdc-templateExtractValue
* gender.extension[=].valueString = "%resource.descendants().where(linkId='administrativeGender').answer.value.code.first()"
* birthDate.extension[+].url = $sdc-templateExtractValue
* birthDate.extension[=].valueString = "%resource.descendants().where(linkId='dateOfBirth').answer.value.first()"
* address[0].use = #home
* address[0].postalCode.extension[+].url = $sdc-templateExtractValue
* address[0].postalCode.extension[=].valueString = "%resource.descendants().where(linkId='zipCode').answer.value.first()"
* address[0].city.extension[+].url = $sdc-templateExtractValue
* address[0].city.extension[=].valueString = "%resource.descendants().where(linkId='city').answer.value.first()"
* address[0].state.extension[+].url = $sdc-templateExtractValue
* address[0].state.extension[=].valueString = "%resource.descendants().where(linkId='canton').answer.value.first()"

// ---------------------------------------------------------------------------
// Condition (ChEkmConditionGonorrhoea) — fixed disease code; manifestation -> evidence.code;
// manifestation begin date -> onset (omitted when "unbekannt" is ticked)
// ---------------------------------------------------------------------------
Instance: GonExtractCondition
InstanceOf: Condition
Usage: #inline
// * meta.profile = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-condition-gonorrhoea"
* category = $condition-category#encounter-diagnosis
* code = $sct#15628003 "Gonorrhea (disorder)"
* subject.reference = "Patient/GonExtractPatient"
// Manifestationsbeginn:
//  - known   -> onsetDateTime = the answered date.
//  - unbekannt -> no value; onsetDateTime.extension[data-absent-reason] = asked-unknown.
//
// extension[0] is the data-absent-reason extension, gated by a templateExtractContext that is
// non-empty only when manifestationBeginUnknown = true (empty context -> element excluded), with
// its valueCode set by a templateExtractValue inside that context scope.
// extension[1] is the onset value (iif -> {} when unbekannt, so onsetDateTime is omitted then).
//
// ORDER MATTERS: the context-gated extension MUST come before the plain onset value extension.
// The reference engine's array index bookkeeping mis-handles the reverse order (the gated element
// is not deleted and the valueCode splits into a stray entry). See forms-summary.md §8.
* onsetDateTime.extension[0].url = $data-absent-reason
* onsetDateTime.extension[0].extension[0].url = $sdc-templateExtractContext
* onsetDateTime.extension[0].extension[0].valueString = "%resource.descendants().where(linkId='manifestationBeginUnknown').answer.value.where($this = true)"
* onsetDateTime.extension[0].valueCode.extension[0].url = $sdc-templateExtractValue
* onsetDateTime.extension[0].valueCode.extension[0].valueString = "'asked-unknown'"
* onsetDateTime.extension[1].url = $sdc-templateExtractValue
* onsetDateTime.extension[1].valueString = "iif(%resource.descendants().where(linkId='manifestationBeginUnknown').answer.value.first() = true, {}, %resource.descendants().where(linkId='manifestationBeginDate').answer.value.first())"
// Manifestation -> evidence.code (identity pass-through of the answered Coding)
* evidence[0].code[0].extension[+].url = $sdc-templateExtractContext
* evidence[0].code[0].extension[=].valueString = "%resource.descendants().where(linkId='manifestation').answer.value"
* evidence[0].code[0].coding[0].extension[+].url = $sdc-templateExtractValue
* evidence[0].code[0].coding[0].extension[=].valueString = "ofType(Coding)"

// ---------------------------------------------------------------------------
// Exposure (ChEkmExposureGonorrhoea) — fixed component codes; sex & relationship from `transmission`
// ---------------------------------------------------------------------------
Instance: GonExtractExposure
InstanceOf: Observation
Usage: #inline
// * meta.profile = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-exposure-gonorrhoea"
* status = #final
* category = $v3-ActClass#AEXPOS "acquisition exposure"
* code = $v3-ParticipationType#EXPAGNT "Exposure Agent"
* subject.reference = "Patient/GonExtractPatient"
// Sexualkontakt mit infizierter Person (Geschlecht)
* component[0].code = ChEkmExposureComponent#sexual-contact-partner
* component[0].valueCodeableConcept.extension[+].url = $sdc-templateExtractContext
* component[0].valueCodeableConcept.extension[=].valueString = "%resource.descendants().where(linkId='sexualContactPartner').answer.value"
* component[0].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[0].valueCodeableConcept.coding[0].extension[=].valueString = "ofType(Coding)"
// Art der Beziehung
* component[1].code = $sct#228465009 "Sexual relationship details (observable entity)"
* component[1].valueCodeableConcept.extension[+].url = $sdc-templateExtractContext
* component[1].valueCodeableConcept.extension[=].valueString = "%resource.descendants().where(linkId='relationshipType').answer.value"
* component[1].valueCodeableConcept.coding[0].extension[+].url = $sdc-templateExtractValue
* component[1].valueCodeableConcept.coding[0].extension[=].valueString = "ofType(Coding)"

// ---------------------------------------------------------------------------
// Composition (ChEkmCompositionGonorrhoea) — static structure, references the entries above,
// author = Broker, date taken from QR.authored
// ---------------------------------------------------------------------------
Instance: GonExtractComposition
InstanceOf: Composition
Usage: #inline
// * meta.profile = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-composition-gonorrhoea"
* status = #final
* type = $sct#722143004 "Infectious disease diagnostic study note"
* category = $sct#423876004 "Clinical report"
* subject.reference = "Patient/GonExtractPatient"
* date.extension[+].url = $sdc-templateExtractValue
* date.extension[=].valueString = "%resource.authored"
* author.reference = "PractitionerRole/ChEkmPractitionerRoleBrokerExample"
* title = "Meldung zum klinischen Befund Infektionskrankheit"
* section[0].title = "Diagnosis section"
* section[0].code = $loinc#29308-4
* section[0].entry.reference = "Condition/GonExtractCondition"
* section[1].title = "Social history section"
* section[1].code = $loinc#29762-2
* section[1].entry.reference = "Observation/GonExtractExposure"

// ---------------------------------------------------------------------------
// The Bundle template itself (ChEkmDocumentGonorrhoea shape)
// ---------------------------------------------------------------------------
Instance: ChEkmDocumentGonorrhoeaTemplate
InstanceOf: Bundle
Usage: #example
Title: "CH EKM $extract template: Gonorrhoea document Bundle"
Description: "SDC template-based extraction template. Shaped like ChEkmDocumentGonorrhoea; the per-report fields carry sdc-questionnaire-templateExtractValue/-Context FHIRPath expressions that read a Gonorrhoea QuestionnaireResponse. Used by tests/extract-gonorrhoea.sh; not a normal example."
// * meta.profile = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-document-gonorrhoea"
* type = #document
* identifier.system = "urn:ietf:rfc:3986"
* identifier.value = "urn:uuid:c376a38a-61b9-4a79-8722-12c75bacf927"
* timestamp.extension[+].url = $sdc-templateExtractValue
* timestamp.extension[=].valueString = "%resource.authored"
* entry[+].fullUrl = "http://test.fhir.ch/r4/Composition/GonExtractComposition"
* entry[=].resource = GonExtractComposition
* entry[+].fullUrl = "http://test.fhir.ch/r4/Patient/GonExtractPatient"
* entry[=].resource = GonExtractPatient
* entry[+].fullUrl = "http://test.fhir.ch/r4/PractitionerRole/ChEkmPractitionerRoleBrokerExample"
* entry[=].resource = ChEkmPractitionerRoleBrokerExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/Practitioner/ChEkmPractitionerBrokerExample"
* entry[=].resource = ChEkmPractitionerBrokerExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/Organization/ChEkmOrganizationBrokerExample"
* entry[=].resource = ChEkmOrganizationBrokerExample
* entry[+].fullUrl = "http://test.fhir.ch/r4/Condition/GonExtractCondition"
* entry[=].resource = GonExtractCondition
* entry[+].fullUrl = "http://test.fhir.ch/r4/Observation/GonExtractExposure"
* entry[=].resource = GonExtractExposure
