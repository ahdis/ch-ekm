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

// Header shared by every modular SUB-questionnaire (assemble-child). `name` doubles as the
// canonical's last path segment, so the two can never drift apart.
RuleSet: RuleSetQrHeaderSubSdc(name)
* url = "http://fhir.ch/ig/ch-ekm/Questionnaire/{name}"
* version = "0.0.1"
* name = "{name}"
* status = #active
* language = #en
* experimental = false
* subjectType = #Patient
* extension[+].url = $sdc-assemble-expectation
* extension[=].valueCode = #assemble-child

// item.text + de-CH/fr-CH/it-CH translations, one rule set per nesting level. These set ONLY
// `text`, so the caller keeps full control over where `linkId`, `definition` and `type` go
// (`definition` sits between linkId and text on most items).
RuleSet: RuleSetQrLevel1Text(text, text-de-CH, text-fr-CH, text-it-CH)
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

RuleSet: RuleSetQrLevel2Text(text, text-de-CH, text-fr-CH, text-it-CH)
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

RuleSet: RuleSetQrLevel3Text(text, text-de-CH, text-fr-CH, text-it-CH)
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

// Short tab labels: sdc-questionnaire-shortText + de-CH/fr-CH/it-CH translations, one rule set per
// nesting level. The renderer falls back to item.text when no shortText is present, so this is
// purely about keeping the tab strip narrow — the full heading stays on item.text.
// (https://smartforms.csiro.au/storybook/?path=/story/sdc-9-1-2-rendering-control-appearance-itemcontrol-group--tab-container)
RuleSet: RuleSetQrLevel1ShortText(text, text-de-CH, text-fr-CH, text-it-CH)
* item[=].extension[+].url = $sdc-shortText
* item[=].extension[=].valueString = {text}
* item[=].extension[=].valueString.extension[+].url = $translation
* item[=].extension[=].valueString.extension[=].extension[+].url = "lang"
* item[=].extension[=].valueString.extension[=].extension[=].valueCode = #de-CH
* item[=].extension[=].valueString.extension[=].extension[+].url = "content"
* item[=].extension[=].valueString.extension[=].extension[=].valueString = {text-de-CH}
* item[=].extension[=].valueString.extension[+].url = $translation
* item[=].extension[=].valueString.extension[=].extension[+].url = "lang"
* item[=].extension[=].valueString.extension[=].extension[=].valueCode = #fr-CH
* item[=].extension[=].valueString.extension[=].extension[+].url = "content"
* item[=].extension[=].valueString.extension[=].extension[=].valueString = {text-fr-CH}
* item[=].extension[=].valueString.extension[+].url = $translation
* item[=].extension[=].valueString.extension[=].extension[+].url = "lang"
* item[=].extension[=].valueString.extension[=].extension[=].valueCode = #it-CH
* item[=].extension[=].valueString.extension[=].extension[+].url = "content"
* item[=].extension[=].valueString.extension[=].extension[=].valueString = {text-it-CH}

RuleSet: RuleSetQrLevel2ShortText(text, text-de-CH, text-fr-CH, text-it-CH)
* item[=].item[=].extension[+].url = $sdc-shortText
* item[=].item[=].extension[=].valueString = {text}
* item[=].item[=].extension[=].valueString.extension[+].url = $translation
* item[=].item[=].extension[=].valueString.extension[=].extension[+].url = "lang"
* item[=].item[=].extension[=].valueString.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].extension[=].valueString.extension[=].extension[+].url = "content"
* item[=].item[=].extension[=].valueString.extension[=].extension[=].valueString = {text-de-CH}
* item[=].item[=].extension[=].valueString.extension[+].url = $translation
* item[=].item[=].extension[=].valueString.extension[=].extension[+].url = "lang"
* item[=].item[=].extension[=].valueString.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].extension[=].valueString.extension[=].extension[+].url = "content"
* item[=].item[=].extension[=].valueString.extension[=].extension[=].valueString = {text-fr-CH}
* item[=].item[=].extension[=].valueString.extension[+].url = $translation
* item[=].item[=].extension[=].valueString.extension[=].extension[+].url = "lang"
* item[=].item[=].extension[=].valueString.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].extension[=].valueString.extension[=].extension[+].url = "content"
* item[=].item[=].extension[=].valueString.extension[=].extension[=].valueString = {text-it-CH}

// Single-option check-box items carry their visible label on answerOption[0].valueString instead of
// item.text, but need the same four languages. Currently unused: the one item that used this shape
// (the "Wo" group's Unbekannt box) became an open-choice option, whose label comes from the
// terminology. Kept for the next check-box whose label is a form string rather than a coded concept.
RuleSet: RuleSetQrLevel2AnswerOptionText(text, text-de-CH, text-fr-CH, text-it-CH)
* item[=].item[=].answerOption[0].valueString = {text}
* item[=].item[=].answerOption[0].valueString.extension[+].url = $translation
* item[=].item[=].answerOption[0].valueString.extension[=].extension[+].url = "lang"
* item[=].item[=].answerOption[0].valueString.extension[=].extension[=].valueCode = #de-CH
* item[=].item[=].answerOption[0].valueString.extension[=].extension[+].url = "content"
* item[=].item[=].answerOption[0].valueString.extension[=].extension[=].valueString = {text-de-CH}
* item[=].item[=].answerOption[0].valueString.extension[+].url = $translation
* item[=].item[=].answerOption[0].valueString.extension[=].extension[+].url = "lang"
* item[=].item[=].answerOption[0].valueString.extension[=].extension[=].valueCode = #fr-CH
* item[=].item[=].answerOption[0].valueString.extension[=].extension[+].url = "content"
* item[=].item[=].answerOption[0].valueString.extension[=].extension[=].valueString = {text-fr-CH}
* item[=].item[=].answerOption[0].valueString.extension[+].url = $translation
* item[=].item[=].answerOption[0].valueString.extension[=].extension[+].url = "lang"
* item[=].item[=].answerOption[0].valueString.extension[=].extension[=].valueCode = #it-CH
* item[=].item[=].answerOption[0].valueString.extension[=].extension[+].url = "content"
* item[=].item[=].answerOption[0].valueString.extension[=].extension[=].valueString = {text-it-CH}

// NB: the initialExpression triples (extension url / valueExpression.language / .expression) are
// deliberately NOT wrapped in a rule set. FSH rule-set parameters require `,` and `)` to be
// backslash-escaped, which would turn every FHIRPath into `resolve\(\).where\(use='work'\)` —
// unreadable, and the point of these expressions is that they can be read and reviewed.

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

// Renders the form group (item[0], the one RuleSetQrHeader creates) as a TAB CONTAINER: each of its
// children — after $assemble these are the section groups person / manifestation-group / exposure /
// treatingPhysician — becomes one tab. Insert directly after RuleSetQrHeader, while item[=] is still
// the form group. Tab labels come from each child's sdc-questionnaire-shortText (RuleSetQrLevel*ShortText),
// falling back to its item.text.
// Note: `tab-container` is not in the R4 questionnaire-item-control code system (it was added in a
// later version of the extension), so the IG publisher flags it as an extensible-binding warning.
RuleSet: RuleSetQrLevel1TabContainer
* item[=].extension[+].url = $questionnaire-itemControl
* item[=].extension[=].valueCodeableConcept = $item-control#tab-container

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
* insert RuleSetQrLevel2ShortText("Person", "Person", "Personne", "Persona")

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
* insert RuleSetQrLevel2ShortText("Diagnosis", "Diagnose", "Diagnostic", "Diagnosi")

RuleSet: RuleSetQrManifestationBeginUnknown
* insert RuleSetQrLevel3SubQuestionnaire("manifestationBeginUnknown", "Onset of manifestation unknown", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireManifestationBeginUnknown")

RuleSet: RuleSetQrGroupExposure
* insert RuleSetQrLevel2Group("exposure", "Exposure details", "Angaben zur Exposition", "Données relatives à l'exposition", "Dati relativi all'esposizione")
* insert RuleSetQrLevel2ShortText("Exposure", "Exposition", "Exposition", "Esposizione")

RuleSet: RuleSetQrExposureWhere
* insert RuleSetQrLevel3SubQuestionnaire("exposurewhere", "Exposure: where", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireExposureWhere")

RuleSet: RuleSetQrExposureWhen
* insert RuleSetQrLevel3SubQuestionnaire("exposurewhen", "Exposure: when", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireExposureWhen")

RuleSet: RuleSetQrExposureHow
* insert RuleSetQrLevel3SubQuestionnaire("exposurehow", "Exposure: how", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireExposureHow") 

// The treating-physician section is a sub-questionnaire placeholder, and $assemble REPLACES the
// placeholder item with the child's items — so its tab label (shortText) cannot live here, it sits on
// the child's own root group in ChEkmQuestionnaireTreatingPhysician.
RuleSet: RuleSetQrGroupTreatingPhysician
* insert RuleSetQrLevel2SubQuestionnaire("treatingPhysician", "Treating physician", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireTreatingPhysician")
