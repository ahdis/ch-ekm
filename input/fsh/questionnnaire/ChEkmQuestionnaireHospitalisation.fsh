// Modular sub-questionnaire: "Hospitalisation" — the first half of the "Verlauf" section of the
// reporting form. The second half, "Zustand" (Tot / Todesdatum /
// Todesursache), is not built yet: it still needs the cause-of-death Condition profile and the
// Patient.deceased[x] decision (TODO.md #7-#9).
//
// Source of truth: logical model ChEkmHospitalisationForm (-> ChEkmEncounter).
//
// THREE items, one question each:
//   1. hospitalisationStatus        Ja / Nein / Unbekannt        -> whether an Encounter exists
//   2. hospitalisationReason        Hospitalisationsgrund        -> Encounter.reasonReference / .reasonCode
//   3. hospitalisationAdmissionDate Eintrittsdatum               -> Encounter.period.start
// (2) and (3) are only enabled while (1) is answered "ja" — they are details OF the stay, so asking
// them after "nein"/"unbekannt" would be contradictory. The extraction template relies on this:
// an answered admission date implies the "ja" branch.
//
// The whole ja/nein/unbekannt answer is a form-level question, not a field of the Encounter:
// "ja" creates the Encounter, "nein" creates none, "unbekannt" creates one carrying only
// hospitalization.extension[data-absent-reason]. See ChEkmEncounter and RuleSetEncounterHospitalisation.
//
// SDC pre-population reads the `encounter` launch context (%encounter), declared on the modular root
// via RuleSetQrLaunchContextEncounter. Note on coded items: the initialExpression yields the answer
// CODE as a string, which the host turns into a valueCoding by matching it against the item's
// options. That match needs the answer value set to be expandable at runtime — the same condition
// the existing `administrativeGender` item depends on. Where the ChEkm* canonicals cannot be
// resolved (any public tx), the answer arrives as the bare code and is normalised by the renderer
// when the form is loaded.

Instance: ChEkmQuestionnaireHospitalisation
InstanceOf: Questionnaire
Usage: #definition
Title: "CH EKM Questionnaire: Hospitalisation"
Description: "Modular sub-questionnaire for the 'Hospitalisation' group of the 'Verlauf' section: whether the affected person was hospitalised, the reason for the stay and the admission date. Reusable as an SDC assemble-child; supports expression-based pre-population from an encounter launch context."
* insert RuleSetQrHeaderSubSdc(ChEkmQuestionnaireHospitalisation)

* item[+].linkId = "hospitalisation"
* insert RuleSetQrLevel1Text("Hospitalisation", "Hospitalisation", "Hospitalisation", "Ospedalizzazione")
* item[=].type = #group

// 1. Hospitalisation - Ja / Nein / Unbekannt (radio buttons; "unbekannt" is a real answer, not a
//    blank field, which is why it is in the value set rather than being left empty).
//    Pre-population: an Encounter in context whose `hospitalization` element carries a
//    data-absent-reason means the source system itself recorded "unbekannt"; any other Encounter
//    means "ja". No Encounter -> nothing pre-filled (the form asks).
* item[=].item[+].linkId = "hospitalisationStatus"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmHospitalisationForm#ChEkmHospitalisationForm.hospitalisation"
* insert RuleSetQrLevel2Text("Was the affected person hospitalised?", "Wurde die betroffene Person hospitalisiert?", "La personne concernée a-t-elle été hospitalisée ?", "La persona interessata è stata ospedalizzata?")
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmYesNoUnknown"
* item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueCode = #useSupplement
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-snomed-language-supplement"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#radio-button
* item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].extension[=].valueCode = #horizontal
* item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].extension[=].valueExpression.expression = "iif(%encounter.hospitalization.extension.where(url = 'http://hl7.org/fhir/StructureDefinition/data-absent-reason').exists(), '261665006', iif(%encounter.exists(), '373066001', {}))"

// 2. Hospitalisationsgrund - the reported pathogen / another reason / unknown. Only asked when the
//    person WAS hospitalised.
//    Pre-population: an Encounter that points at a Condition (reasonReference) was entered because
//    of the reported disease -> the local `reported-pathogen` answer; otherwise pass the recorded
//    reasonCode Coding through unchanged (it is already one of the two SNOMED qualifiers).
* item[=].item[+].linkId = "hospitalisationReason"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmHospitalisationForm#ChEkmHospitalisationForm.reason"
* insert RuleSetQrLevel2Text("Reason for the hospitalisation", "Hospitalisationsgrund", "Motif de l'hospitalisation", "Motivo dell'ospedalizzazione")
* item[=].item[=].type = #choice
* item[=].item[=].answerValueSet = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmHospitalisationReasonChoice"
* item[=].item[=].answerValueSet.extension[+].url = $binding-parameter
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "name"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueCode = #useSupplement
* item[=].item[=].answerValueSet.extension[=].extension[+].url = "expression"
* item[=].item[=].answerValueSet.extension[=].extension[=].valueString = "http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-snomed-language-supplement"
* item[=].item[=].extension[+].url = $questionnaire-itemControl
* item[=].item[=].extension[=].valueCodeableConcept = $item-control#radio-button
* item[=].item[=].extension[+].url = $choiceOrientation
* item[=].item[=].extension[=].valueCode = #vertical
* item[=].item[=].enableWhen[+].question = "hospitalisationStatus"
* item[=].item[=].enableWhen[=].operator = #=
* item[=].item[=].enableWhen[=].answerCoding = $sct#373066001 "Yes (qualifier value)"
* item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].extension[=].valueExpression.expression = "iif(%encounter.reasonReference.exists(), 'reported-pathogen', %encounter.reasonCode.coding.first())"

// 3. Eintrittsdatum. Only asked when the person WAS hospitalised; a partial date is acceptable
//    (Encounter.period.start is a dateTime).
* item[=].item[+].linkId = "hospitalisationAdmissionDate"
* item[=].item[=].definition = "http://fhir.ch/ig/ch-ekm/StructureDefinition/ChEkmHospitalisationForm#ChEkmHospitalisationForm.admissionDate"
* insert RuleSetQrLevel2Text("Admission date", "Eintrittsdatum", "Date d'admission", "Data di ricovero")
* item[=].item[=].type = #date
* item[=].item[=].enableWhen[+].question = "hospitalisationStatus"
* item[=].item[=].enableWhen[=].operator = #=
* item[=].item[=].enableWhen[=].answerCoding = $sct#373066001 "Yes (qualifier value)"
* item[=].item[=].extension[+].url = $sdc-initialExpression
* item[=].item[=].extension[=].valueExpression.language = #text/fhirpath
* item[=].item[=].extension[=].valueExpression.expression = "%encounter.period.start"
