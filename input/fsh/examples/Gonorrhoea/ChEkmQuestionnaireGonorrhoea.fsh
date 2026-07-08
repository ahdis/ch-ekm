// Modular ROOT questionnaire for the Gonorrhoea clinical findings report (green form sections).
// Assembles the Person, Manifestation and Exposition sub-questionnaires via the SDC $assemble operation.
// Render the assembled output in Smart Forms (../smart-forms).

Instance: ChEkmQuestionnaireGonorrhoea
InstanceOf: Questionnaire
Usage: #example
Title: "CH EKM Questionnaire: Gonorrhoea (modular)"
Description: "Modular root questionnaire for the Gonorrhoea clinical findings report. References the Person, Manifestation and Exposition sub-questionnaires; run Questionnaire/$assemble to produce the renderable form."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoea"
* version = "0.0.1"
* name = "ChEkmQuestionnaireGonorrhoea"
* status = #active
* experimental = false
* meta.profile[+] = $sdc-modular
* meta.profile[+] = $sdc-pop-exp
// Declares that this questionnaire supports SDC template-based extraction (contained Bundle
// template + sdc-questionnaire-templateExtract). Required element: contained 1..* (satisfied).
* meta.profile[+] = $sdc-extr-template
* subjectType = #Patient

// SDC template-based extraction: the document Bundle template is carried as a contained
// resource and referenced from the form group via sdc-questionnaire-templateExtract, so a
// renderer (e.g. Smart Forms) can run $extract on the filled QuestionnaireResponse to
// produce a ChEkmDocumentGonorrhoea Bundle. tests/assemble-gonorrhoea.sh re-attaches both
// onto the assembled questionnaire (the artifact the renderer loads).
* contained[0] = ChEkmDocumentGonorrhoeaTemplate

// Required by sdc-questionnaire-modular 4.0.0: the root must declare assemble-root.
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-root
// Required by sdc-2 (sdc-questionnairecommon): version present implies versionAlgorithm.
* extension[+].url = $artifact-versionAlgorithm
* extension[=].valueCoding = $version-algorithm#semver

// SDC pre-population: declare the patient launch context. The %patient resource is
// resolved by the host (e.g. SMART launch) and consumed by the initialExpression
// extensions on the sub-questionnaire items. Propagated onto the assembled questionnaire.
* extension[+].url = $sdc-launchContext
* extension[=].extension[+].url = "name"
* extension[=].extension[=].valueCoding = $sdc-launchContext-cs#patient "Patient"
* extension[=].extension[+].url = "type"
* extension[=].extension[=].valueCode = #Patient
* extension[=].extension[+].url = "description"
* extension[=].extension[=].valueString = "The patient to pre-populate the form with"

// Treating physician launch context — the standard SDC `user` context, typed as
// PractitionerRole rather than Practitioner: the clinician authoring/using the form is
// represented by their role at the sending organization, so %user.practitioner.resolve()
// and %user.organization.resolve() both come from this single context (see
// ChEkmQuestionnaireGonorrhoeaTreatingPhysician). This also matches what a real SMART
// launch typically hands back as `fhirUser`/`user` for clinical users.
* extension[+].url = $sdc-launchContext
* extension[=].extension[+].url = "name"
* extension[=].extension[=].valueCoding = $sdc-launchContext-cs#user "User"
* extension[=].extension[+].url = "type"
* extension[=].extension[=].valueCode = #PractitionerRole
* extension[=].extension[+].url = "description"
* extension[=].extension[=].valueString = "The treating physician's PractitionerRole (practitioner + sending organization) to pre-populate the form with"

// Birthdate validation: dateOfBirth (defined in the Person sub-questionnaire) must be in
// [1900-01-01, today()]. Authored as a Questionnaire-level targetConstraint here on the modular
// root so it propagates onto the assembled form the renderer loads ($assemble drops a child's
// root extensions but keeps the root's). Smart Forms binds it to the item via the `location`
// FHIRPath; the `expression` evaluates TRUE when the value is INVALID (out of range), so the
// renderer would show `human` and (severity=error) blocks submission. `today()` is the dynamic bound.
// see issue https://github.com/aehrc/smart-forms/issues/1971
// * extension[+].url = $targetConstraint
// * extension[=].extension[+].url = "key"
// * extension[=].extension[=].valueId = "dateOfBirthRange"
// * extension[=].extension[+].url = "severity"
// * extension[=].extension[=].valueCode = #error
// * extension[=].extension[+].url = "expression"
// * extension[=].extension[=].valueExpression.language = #text/fhirpath
// * extension[=].extension[=].valueExpression.expression = "%resource.descendants().where(linkId='dateOfBirth').answer.value.where($this < @1900-01-01 or $this > today()).exists()"
// * extension[=].extension[+].url = "human"
// * extension[=].extension[=].valueString = "Geburtsdatum muss zwischen dem 01.01.1900 und heute liegen."
// * extension[=].extension[+].url = "location"
// * extension[=].extension[=].valueString = "Questionnaire.descendants().where(linkId='dateOfBirth')"

// Top-level form group. The SDC subQuestionnaire placeholders are nested one level
// under this group (item[0].item[x]) — required by the CSIRO/aehrc sdc-assemble
// reference implementation, and also accepted by matchbox.
* item[+].linkId = "gonorrhoea-form"
* item[=].type = #group
* item[=].text = "Meldung zum klinischen Befund: Gonorrhoea"
// Drives template-based $extract: one instance of the contained Bundle template per
// gonorrhoea-form group (i.e. one document Bundle per filled form).
* item[=].extension[+].url = $sdc-templateExtract
* item[=].extension[=].extension[+].url = "template"
* item[=].extension[=].extension[=].valueReference = Reference(ChEkmDocumentGonorrhoeaTemplate)

// Angaben zur betroffenen Person — a single subQuestionnaire placeholder to the aggregator
// ChEkmQuestionnaireGonorrhoeaPerson, which itself references the three person leaf
// sub-questionnaires (Namensinitialen / allgemeine Angaben / Geschlechtsidentität). $assemble
// recurses (root -> aggregator -> three leaves) into one flat `person` group. NB: each
// questionnaire's subQuestionnaire placeholders must be direct children of item[0]; nested
// recursion relies on the patched @aehrc/sdc-assemble (see tests/assemble/patches, forms-summary §1).

// Person
* item[=].item[+].linkId = "person"
* item[=].item[=].type = #display
* item[=].item[=].text = "Angaben zur betroffenen Person"
* item[=].item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoeaPerson"

// Diagnose und Manifestation
* item[=].item[+].linkId = "manifestation"
* item[=].item[=].type = #display
* item[=].item[=].text = "Diagnose und Manifestation"
* item[=].item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoeaManifestation"

// Exposition (Wie / Übertragungsweg)
* item[=].item[+].linkId = "exposition"
* item[=].item[=].type = #display
* item[=].item[=].text = "Exposition (Übertragungsweg)"
* item[=].item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoeaExposition"

// Behandelnde Ärztin / behandelnder Arzt (Practitioner + Organization)
* item[=].item[+].linkId = "treatingPhysician"
* item[=].item[=].type = #display
* item[=].item[=].text = "Behandelnde Ärztin / behandelnder Arzt"
* item[=].item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireGonorrhoeaTreatingPhysician"
