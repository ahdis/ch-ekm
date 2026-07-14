// Modular ROOT questionnaire for the Mpox clinical findings report (green form sections).
// Assembles the Person, Manifestation and Exposition sub-questionnaires via the SDC $assemble operation.
// Render the assembled output in Smart Forms (../smart-forms).

Instance: ChEkmQuestionnaireMpox
InstanceOf: Questionnaire
Usage: #example
Title: "CH EKM Questionnaire: Mpox (modular)"
Description: "Modular root questionnaire for the Mpox clinical findings report. References the Person, Manifestation and Exposition sub-questionnaires; run Questionnaire/$assemble to produce the renderable form."
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireMpox"
* version = "0.0.1"
* name = "ChEkmQuestionnaireMpox"
* status = #active
* language = #en
* experimental = false
* meta.profile[+] = $sdc-modular
* meta.profile[+] = $sdc-pop-exp
// Declares that this questionnaire supports SDC template-based extraction (contained Bundle
// template + sdc-questionnaire-templateExtract). Required element: contained 1..* (satisfied).
// TODO* meta.profile[+] = $sdc-extr-template
* subjectType = #Patient

// SDC template-based extraction: the document Bundle template is carried as a contained
// resource and referenced from the form group via sdc-questionnaire-templateExtract, so a
// renderer (e.g. Smart Forms) can run $extract on the filled QuestionnaireResponse to
// produce a ChEkmDocumentMpox Bundle. tests/assemble-mpox.sh re-attaches both
// onto the assembled questionnaire (the artifact the renderer loads).
// TODO * contained[0] = ChEkmDocumentMpoxTemplate

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
// ChEkmQuestionnaireTreatingPhysician). This also matches what a real SMART
// launch typically hands back as `fhirUser`/`user` for clinical users.
* extension[+].url = $sdc-launchContext
* extension[=].extension[+].url = "name"
* extension[=].extension[=].valueCoding = $sdc-launchContext-cs#user "User"
* extension[=].extension[+].url = "type"
* extension[=].extension[=].valueCode = #PractitionerRole
* extension[=].extension[+].url = "description"
* extension[=].extension[=].valueString = "The treating physician's PractitionerRole (practitioner + sending organization) to pre-populate the form with"

* item[+].linkId = "mpox-form"
* item[=].type = #group
* item[=].text = "Clinical findings report: mpox"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Meldung zum klinischen Befund: Mpox"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Déclaration de résultat clinique : Mpox"
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = "Notifica del referto clinico: Mpox"
// Drives template-based $extract: one instance of the contained Bundle template per
// mpox-form group (i.e. one document Bundle per filled form).
// TODO * item[=].extension[+].url = $sdc-templateExtract
// * item[=].extension[=].extension[+].url = "template"
// * item[=].extension[=].extension[=].valueReference = Reference(ChEkmDocumentMpoxTemplate)


* item[=].item[+].linkId = "person"
* item[=].item[=].type = #group
* item[=].item[=].text = "Affected person's details"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Angaben zur betroffenen Person"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Données relatives à la personne concernée"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Dati relativi alla persona interessata"

// Namensinitialen
* item[=].item[=].item[+].linkId = "personName"
* item[=].item[=].item[=].type = #display
* item[=].item[=].item[=].text = "Name"
* item[=].item[=].item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].item[=].item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnairePersonName"

// Allgemeine Angaben
* item[=].item[=].item[+].linkId = "personGeneral"
* item[=].item[=].item[=].type = #display
* item[=].item[=].item[=].text = "General information"
* item[=].item[=].item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].item[=].item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnairePersonGeneral"

// Diagnose und Manifestation
* item[=].item[+].linkId = "manifestation-group"
* item[=].item[=].text = "Diagnosis and manifestation"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Diagnose und Manifestation"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Diagnostic et manifestation"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Diagnosi e manifestazione"
* item[=].item[=].type = #group

// Manifestationen - single-choice (symptomatic / asymptomatic), radio buttons
* item[=].item[=].item[+].linkId = "manifestation"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmMpoxManifestationForm#ChEkmMpoxManifestationForm.manifestation"
* item[=].item[=].item[=].text = "Manifestations"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Manifestationen"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Manifestations"
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = "Manifestazioni"
* item[=].item[=].item[=].type = #choice
* item[=].item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].item[=].extension[=].valueCode = #horizontal
* item[=].item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmMpoxManifestation"
* item[=].item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].item[=].answerValueSet.extension[=].extension[=].valueCode = #useSupplement
* item[=].item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-snomed-language-supplement"
* item[=].item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].item[=].extension[=].valueCodeableConcept = $item-control#radio-button

// Subquestionnaire: Manifestationsbeginn unbekannt (Manifestation begin unknown) - checkbox + date
* item[=].item[=].item[+].linkId = "manifestationBeginUnknown"
* item[=].item[=].item[=].type = #display
* item[=].item[=].item[=].text = "Onset of manifestation unknown"
* item[=].item[=].item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].item[=].item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireManifestationBeginUnknown"

// Exposition
* item[=].item[+].linkId = "exposure"
* item[=].item[=].type = #display
* item[=].item[=].text = "Exposure"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Exposition"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Exposition"
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = "Esposizione"
* item[=].item[=].type = #group

// TODO Exposition where

// TODO Exposition when


// Exposition (Wie / Übertragungsweg) -> subQuestionnaire ChEkmQuestionnaireTransmissionHow
* item[=].item[=].item[+].linkId = "transmissionhow"
* item[=].item[=].item[=].type = #display
* item[=].item[=].item[=].text = "Exposition (how)"
* item[=].item[=].item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].item[=].item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireTransmissionHow"

// Behandelnde Ärztin / behandelnder Arzt (Practitioner + Organization)
* item[=].item[+].linkId = "treatingPhysician"
* item[=].item[=].type = #display
* item[=].item[=].text = "Treating physician"
* item[=].item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].item[=].extension[=].valueCanonical = "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireTreatingPhysician"
