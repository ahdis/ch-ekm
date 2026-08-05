RuleSet: RuleSetQrHeaderSdc
* status = #active
* language = #en
* experimental = false
* meta.profile[+] = $sdc-modular
* meta.profile[+] = $sdc-pop-exp
* meta.profile[+] = $sdc-extr-template
* subjectType = #Patient

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

RuleSet: RuleSetQrHeader(linkId, text, text-de-CH, text-fr-CH, text-it-CH, extractTemplate)

* insert RuleSetQrHeaderSdc
* contained[0] = {extractTemplate}

* item[+].linkId = {linkId}
* item[=].type = #group
* item[=].text = {text}
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = {text-de-CH}
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = {text-fr-CH} 
* item[=].text.extension[+].url = $translation
* item[=].text.extension[=].extension[+].url = "lang"
* item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].text.extension[=].extension[+].url = "content"
* item[=].text.extension[=].extension[=].valueString = {text-it-CH}

// Drives template-based $extract: one instance of the contained Bundle template per
* item[=].extension[+].url = $sdc-templateExtract
* item[=].extension[=].extension[+].url = "template"
* item[=].extension[=].extension[=].valueReference = Reference({extractTemplate})

RuleSet: RuleSetQrLevel2Group(linkId, text, text-de-CH, text-fr-CH, text-it-CH)
* item[=].item[+].linkId = {linkId}
* item[=].item[=].type = #group
* item[=].item[=].text = {text}
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = {text-de-CH}
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = {text-fr-CH}
* item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].text.extension[=].extension[=].valueString = {text-it-CH}

RuleSet: RuleSetQrLevel2SubQuestionnaire(linkId, text, url)
* item[=].item[+].linkId = {linkId}
* item[=].item[=].type = #display
* item[=].item[=].text = {text}
* item[=].item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].item[=].extension[=].valueCanonical = {url}

RuleSet: RuleSetQrLevel3SubQuestionnaire(linkId, text, url)
* item[=].item[=].item[+].linkId = {linkId}
* item[=].item[=].item[=].type = #display
* item[=].item[=].item[=].text = {text}
* item[=].item[=].item[=].extension[+].url = $sdc-subQuestionnaire
* item[=].item[=].item[=].extension[=].valueCanonical = {url}

RuleSet: RuleSetQrLevel3Item(linkId, text, text-de-CH, text-fr-CH, text-it-CH)
* item[=].item[=].item[+].linkId = {linkId}
* item[=].item[=].item[=].text = {text}
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = {text-de-CH}
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = {text-fr-CH}
* item[=].item[=].item[=].text.extension[+].url = $translation
* item[=].item[=].item[=].text.extension[=].extension[+].url = "lang"
* item[=].item[=].item[=].text.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].item[=].text.extension[=].extension[+].url = "content"
* item[=].item[=].item[=].text.extension[=].extension[=].valueString = {text-it-CH}


RuleSet: RuleSetQrGroupPerson
* insert RuleSetQrLevel2Group("person", "Affected person's details", "Angaben zur betroffenen Person", "Données relatives à la personne concernée", "Dati relativi alla persona interessata")

RuleSet: RuleSetQrPersonName
* insert RuleSetQrLevel3SubQuestionnaire("personName", "Name", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnairePersonName")

RuleSet: RuleSetQrPersonInitials
* insert RuleSetQrLevel3SubQuestionnaire("personInitials", "Name initials", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnairePersonInitials")

RuleSet: RuleSetQrPersonGeneral
* insert RuleSetQrLevel3SubQuestionnaire("personGeneral", "General information", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnairePersonGeneral")

RuleSet: RuleSetQrPersonGenderIdentity
* insert RuleSetQrLevel3SubQuestionnaire("personGenderIdentity", "Gender identity", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnairePersonGenderIdentity")

RuleSet: RuleSetQrGroupManifestation
* insert RuleSetQrLevel2Group("manifestation-group", "Diagnosis and manifestation", "Diagnose und Manifestation", "Diagnostic et manifestation", "Diagnosi e manifestazione")

RuleSet: RuleSetQrManifestationBeginUnknown
* insert RuleSetQrLevel3SubQuestionnaire("manifestationBeginUnknown", "Onset of manifestation unknown", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireManifestationBeginUnknown")

RuleSet: RuleSetQrGroupExposure
* insert RuleSetQrLevel2Group("exposure", "Exposure details", "Angaben zur Exposition", "Données relatives à l'exposition", "Dati relativi all'esposizione")

RuleSet: RuleSetQrExposureHow
* insert RuleSetQrLevel3SubQuestionnaire("transmissionhow", "Exposition: how", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireTransmissionHow") 

RuleSet: RuleSetQrGroupTreatingPhysician
* insert RuleSetQrLevel2SubQuestionnaire("treatingPhysician", "Treating physician", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireTreatingPhysician")
