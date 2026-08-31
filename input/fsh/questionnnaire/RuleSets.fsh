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
// (the "Wo" group's "unknown" box) became an open-choice option, whose label comes from the
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

// "Verlauf" — the course of the disease. Container for the Hospitalisation group and for "Zustand"
// (Tot / Todesdatum / Todesursache). Only diseases whose form has this section insert it:
// Gonorrhoea has no Verlauf.
RuleSet: RuleSetQrGroupCourse
* insert RuleSetQrLevel2Group("course", "Course of the disease", "Verlauf", "Évolution", "Decorso")
* insert RuleSetQrLevel2ShortText("Course", "Verlauf", "Évolution", "Decorso")

RuleSet: RuleSetQrHospitalisation
* insert RuleSetQrLevel3SubQuestionnaire("hospitalisationgroup", "Hospitalisation", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireHospitalisation")

RuleSet: RuleSetQrDeath
* insert RuleSetQrLevel3SubQuestionnaire("deathgroup", "Death", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireDeath")

// Third launch context, on top of the patient + user contexts every root gets from
// RuleSetQrHeaderSdc: the hospitalisation Encounter, consumed by the initialExpressions in
// ChEkmQuestionnaireHospitalisation. Inserted only by roots that assemble a "Verlauf" section —
// %encounter is not merely unused elsewhere, an expression referencing an unbound environment
// variable is an evaluation error. Insert at the END of the root instance: it appends to the
// Questionnaire's own `extension` array, not to any item.
RuleSet: RuleSetQrLaunchContextEncounter
* extension[+].url = $sdc-launchContext
* extension[=].extension[+].url = "name"
* extension[=].extension[=].valueCoding = $sdc-launchContext-cs#encounter "Encounter"
* extension[=].extension[+].url = "type"
* extension[=].extension[=].valueCode = #Encounter
* extension[=].extension[+].url = "description"
* extension[=].extension[=].valueString = "The hospitalisation Encounter to pre-populate the form with"

// The treating-physician section is a sub-questionnaire placeholder, and $assemble REPLACES the
// placeholder item with the child's items — so its tab label (shortText) cannot live here, it sits on
// the child's own root group in ChEkmQuestionnaireTreatingPhysician.
RuleSet: RuleSetQrGroupTreatingPhysician
* insert RuleSetQrLevel2SubQuestionnaire("treatingPhysician", "Treating physician", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireTreatingPhysician")

// =================================================================================================
// "Impfstatus" (issue #29) — ONE ROW OF THE VACCINATION TABLE, parameterised by vaccination type.
//
// This is the piece that makes the section modular across diseases. SDC's $assemble cannot
// parameterise a sub-questionnaire, so the reuse happens one level down, in FSH: every disease that
// asks about vaccinations builds its own small sub-questionnaire (ChEkmQuestionnaireImmunization<X>)
// by inserting this rule set once per vaccination type. Mpox inserts it twice; a future organism
// inserts it as often as its form has rows, and gets the identical four questions, item controls,
// enableWhen wiring and translations for free.
//
// FIXED ROWS, NOT A REPEATING GROUP. A `repeats = true` group would be disease-agnostic without any
// FSH machinery, but it produces a variable number of Immunization resources, and forms-summary.md
// §8 is explicit that the single-Bundle-template extraction breaks down exactly there: the
// per-instance loop applies to the whole template, not to one `entry`. Fixed rows keep every
// Immunization a plain context-gated Bundle entry, the shape that is already proven by the
// hospitalisation Encounter and the cause-of-death Observation. The paper form has a fixed list too.
//
// {suffix} is appended to all five linkIds so several rows can live in one questionnaire; it must be
// a bare word (no spaces), e.g. `Smallpox`. NOTE the FSH escaping rule for rule set arguments: `,`
// `(` and `)` must be backslash-escaped inside a parameter value, so the label parameters below use
// an en dash instead of a parenthetical.
//
// The four questions map one-to-one onto ChEkmImmunizationForm; `targetDisease` is NOT a question
// (the row heading is the vaccination type), it is supplied by the extraction template.
RuleSet: RuleSetQrImmunizationRow(suffix, text, text-de-CH, text-fr-CH, text-it-CH)
* item[=].item[+].linkId = "immunization{suffix}"
* insert RuleSetQrLevel2Text({text}, {text-de-CH}, {text-fr-CH}, {text-it-CH})
* item[=].item[=].type = #group

// 1. "Geimpft?" (vaccinated?) - yes / no / unknown. All three are real answers and all three produce an
//    Immunization — see ChEkmImmunization. The other three items are details OF the vaccination and
//    are enableWhen-gated on "yes", so an answered dose count / date / product implies "yes"; the
//    extraction template relies on that, exactly as the hospitalisation group does.
* item[=].item[=].item[+].linkId = "immunizationStatus{suffix}"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmImmunizationForm#ChEkmImmunizationForm.status"
* insert RuleSetQrLevel3Text("Vaccinated?", "Geimpft?", "Vacciné ?", "Vaccinato?")
* item[=].item[=].item[=].type = #choice
* item[=].item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmYesNoUnknown"
* item[=].item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].item[=].answerValueSet.extension[=].extension[=].valueCode = #useSupplement
* item[=].item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-snomed-language-supplement"
* item[=].item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].item[=].extension[=].valueCodeableConcept = $item-control#radio-button
* item[=].item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].item[=].extension[=].valueCode = #horizontal

// 2. "mit total ___ Dosen". A positive integer: doseNumberPositiveInt cannot be 0, and "0 Dosen"
//    is not an answer this question has — that is what "no" above is for.
* item[=].item[=].item[+].linkId = "immunizationDoses{suffix}"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmImmunizationForm#ChEkmImmunizationForm.doses"
* insert RuleSetQrLevel3Text("Total number of doses", "Total Anzahl Dosen", "Nombre total de doses", "Numero totale di dosi")
* item[=].item[=].item[=].type = #integer
* item[=].item[=].item[=].extension[+].url = $minValue
* item[=].item[=].item[=].extension[=].valueInteger = 1
* item[=].item[=].item[=].enableWhen[+].question = "immunizationStatus{suffix}"
* item[=].item[=].item[=].enableWhen[=].operator = #=
* item[=].item[=].item[=].enableWhen[=].answerCoding = $sct#373066001 "Yes (qualifier value)"

// 3. "Letzte Dosis, Datum" — the date of the LAST dose, not of a single administration.
* item[=].item[=].item[+].linkId = "immunizationLastDose{suffix}"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmImmunizationForm#ChEkmImmunizationForm.lastDoseDate"
// The comma in the German label must be backslash-escaped: this insert sits INSIDE a rule set
//    body, where `,` still separates the nested rule set's arguments.
* insert RuleSetQrLevel3Text("Date of the last dose", "Letzte Dosis\, Datum", "Date de la dernière dose", "Data dell'ultima dose")
* item[=].item[=].item[=].type = #date
* item[=].item[=].item[=].enableWhen[+].question = "immunizationStatus{suffix}"
* item[=].item[=].item[=].enableWhen[=].operator = #=
* item[=].item[=].item[=].enableWhen[=].answerCoding = $sct#373066001 "Yes (qualifier value)"

// 4. "mit Impfstoff: Markenname". OPEN choice against the Swiss vaccine (brand) list — the same
//    value set CHCoreImmunization already binds `vaccineCode` to — so a brand that is on the list
//    comes back coded, and anything else comes back as the typed string. Rendered as an
//    autocomplete rather than a drop-down: the value set holds ~215 brands, which is far too many
//    to scroll. Extraction handles both answer shapes plus "unanswered"; see RuleSetImmunizationRow.
//    (No `useSupplement` here, unlike every other coded item: these are brand names, not clinical
//    concepts, and they are not translated.)
* item[=].item[=].item[+].linkId = "immunizationVaccine{suffix}"
* item[=].item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmImmunizationForm#ChEkmImmunizationForm.vaccine"
* insert RuleSetQrLevel3Text("Vaccine — brand name", "Impfstoff — Markenname", "Vaccin — nom de marque", "Vaccino — nome commerciale")
* item[=].item[=].item[=].type = #open-choice
* item[=].item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-vacd/ValueSet/ch-vacd-vaccines-vs"
* item[=].item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].item[=].extension[=].valueCodeableConcept = $item-control#autocomplete
* item[=].item[=].item[=].enableWhen[+].question = "immunizationStatus{suffix}"
* item[=].item[=].item[=].enableWhen[=].operator = #=
* item[=].item[=].item[=].enableWhen[=].answerCoding = $sct#373066001 "Yes (qualifier value)"

// The Impfstatus tab. A LEVEL-2 placeholder (like the treating physician, unlike the two-child
// "Verlauf"): the section has exactly one sub-questionnaire, so the child's own root group can BE
// the tab once $assemble replaces the placeholder with it — which is why the tab label (shortText)
// sits on the child's root group, not here. Assembled shape:
//   mpox-form > immunization > immunizationSmallpox > immunizationStatusSmallpox …
RuleSet: RuleSetQrGroupImmunizationMpox
* insert RuleSetQrLevel2SubQuestionnaire("immunization", "Immunisation status", "http://fhir.ch/ig/ch-ekm/Questionnaire/ChEkmQuestionnaireImmunizationMpox")
