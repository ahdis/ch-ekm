// Modular sub-questionnaire: "Diagnose und Manifestation" -> Manifestationen (Gonorrhoea green section)
// Source of truth: logical model ChEkmManifestationForm (-> ChEkmConditionGonorrhoea)

Instance: ChEkmQuestionnaireManifestationBeginUnknown
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Gonorrhoea - Manifestation"
Description: "Modular sub-questionnaire for the 'Manifestationen' part of the 'Diagnose und Manifestation' section of the Gonorrhoea clinical findings report. Reusable as an SDC assemble-child."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireManifestationBeginUnknown)

// Manifestationsbeginn unbekannt - default false; when checked it disables the date below
* item[+].linkId = "manifestationBeginUnknown"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmManifestationForm#ChEkmManifestationForm.manifestationBeginUnknown"
* insert RuleSetQrLevel1Text("Onset of manifestation unknown", "Manifestationsbeginn unbekannt", "Début des manifestations inconnu", "Inizio delle manifestazioni sconosciuto")
* item[=].type = #boolean
* item[=].initial.valueBoolean = false

// Manifestationsbeginn (Datum) - only enabled while "unbekannt" is not ticked
* item[+].linkId = "manifestationBeginDate"
* item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmManifestationForm#ChEkmManifestationForm.manifestationBeginDate"
* insert RuleSetQrLevel1Text("Onset of manifestation (date\)", "Manifestationsbeginn (Datum\)", "Début des manifestations (date\)", "Inizio delle manifestazioni (data\)")
* item[=].type = #date
* item[=].enableWhen[+].question = "manifestationBeginUnknown"
* item[=].enableWhen[=].operator = #=
* item[=].enableWhen[=].answerBoolean = false
