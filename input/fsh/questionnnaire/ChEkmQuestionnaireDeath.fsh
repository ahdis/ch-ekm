// Modular sub-questionnaire: "Zustand" (death) — the second half of the "Verlauf" (course) section,
// assembled next to ChEkmQuestionnaireHospitalisation. Gonorrhoea has no Verlauf, so this child is
// assembled into the Mpox root only.
//
// Source of truth: logical model ChEkmDeathForm (-> ChEkmPatient + ChEkmObservationCauseOfDeath).
//
// THREE items, one question each:
//   1. deceased    Did the person die?   -> whether Patient.deceasedDateTime exists at all
//   2. deathDate   Date of death         -> Patient.deceasedDateTime (or its data-absent-reason)
//   3. deathCause  Cause of death        -> ChEkmObservationCauseOfDeath value / focus / dataAbsentReason
// (2) and (3) are only enabled while (1) is ticked — they are details OF the death. The extraction
// template relies on that: an answered date or cause implies the person died.
//
// Note the asymmetry with the Hospitalisation group, which is deliberate: hospitalisation is a
// ja/nein/unbekannt choice because the paper form offers "unbekannt" there, whereas the death is a
// plain check-box — a reporting physician either knows of a death or does not report one. Where
// "unknown" DOES apply here is one level down, on the cause (item 3), and on a missing date, which
// becomes a data-absent-reason rather than a missing death.
//
// SDC pre-population reads the standard `patient` launch context (%patient), which every root
// already declares — unlike the Hospitalisation group, this section needs no extra context. The
// cause of death cannot be pre-populated: it lives in an Observation that the launch context does
// not carry, so the form asks it. Same note as elsewhere on coded items: the initialExpression
// yields a code as a string, which the host turns into a valueCoding by matching it against the
// item's options.

Instance: ChEkmQuestionnaireDeath
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Death"
Description: "Modular sub-questionnaire for the 'Zustand' (death) group of the 'Verlauf' section: whether the affected person died, the date of death and whether the cause of death was the reported pathogen. Reusable as an SDC assemble-child; supports expression-based pre-population from a patient launch context."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireDeath)

* item[+].linkId = "death"
* insert RuleSetQrLevel1Text("Death", "Zustand", "État", "Stato")
* item[=].type = #group

// 1. Has the person died? A check-box, defaulting to false so the two items below start disabled.
//    Pre-population: a patient in context carrying deceasedDateTime — with or without a value —
//    has died.
* item[=].item[+].linkId = "deceased"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmDeathForm#ChEkmDeathForm.deceased"
* insert RuleSetQrLevel2Text("Has the affected person died?", "Ist die betroffene Person verstorben?", "La personne concernée est-elle décédée ?", "La persona interessata è deceduta?")
* item[=].item[=].type = #boolean
* item[=].item[=].initial.valueBoolean = false
* item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].extension[=].valueExpression.expression = "%patient.deceasedDateTime.exists() or %patient.deceasedDateTime.extension.exists()"

// 2. Date of death. Optional even when the person died: leaving it blank is how "died, date not
//    known" is reported, and extraction turns that into a data-absent-reason on
//    Patient.deceasedDateTime rather than dropping the death.
* item[=].item[+].linkId = "deathDate"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmDeathForm#ChEkmDeathForm.deathDate"
* insert RuleSetQrLevel2Text("Date of death", "Todesdatum", "Date du décès", "Data del decesso")
* item[=].item[=].type = #date
* item[=].item[=].enableWhen[+].question = "deceased"
* item[=].item[=].enableWhen[=].operator = #=
* item[=].item[=].enableWhen[=].answerBoolean = true
* item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].extension[=].valueExpression.expression = "%patient.deceasedDateTime"

// 3. Cause of death — the reported pathogen / another cause / unknown. "Unknown" is a real answer
//    here rather than a blank field, and it is the answer that becomes Observation.dataAbsentReason
//    instead of a value (see RuleSetObservationCauseOfDeath).
* item[=].item[+].linkId = "deathCause"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmDeathForm#ChEkmDeathForm.causeOfDeath"
* insert RuleSetQrLevel2Text("Cause of death", "Todesursache", "Cause du décès", "Causa del decesso")
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmCauseOfDeathChoice"
* item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueCode = #useSupplement
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-snomed-language-supplement"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#radio-button
* item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].extension[=].valueCode = #vertical
* item[=].item[=].enableWhen[+].question = "deceased"
* item[=].item[=].enableWhen[=].operator = #=
* item[=].item[=].enableWhen[=].answerBoolean = true
