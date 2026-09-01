// Modular sub-questionnaire: "Hospitalisation" — the first half of the "Verlauf" section of the
// reporting form. The second half, "Zustand" (Tot / Todesdatum / Todesursache), is the sibling
// ChEkmQuestionnaireDeath.
//
// Source of truth: logical model ChEkmHospitalisationForm (-> ChEkmEncounter).
//
// THREE items, one question each:
//   1. hospitalisationStatus        Yes / No / Unknown           -> whether an Encounter exists
//   2. hospitalisationReason        Hospitalisationsgrund        -> Encounter.reasonReference / .reasonCode
//   3. hospitalisationAdmissionDate Eintrittsdatum               -> Encounter.period.start
// (2) and (3) are only enabled while (1) is answered "yes" — they are details OF the stay, so asking
// them after "no"/"unknown" would be contradictory. The extraction template relies on this:
// an answered admission date implies the "yes" branch.
//
// The whole yes/no/unknown answer is a form-level question, not a field of the Encounter:
// "yes" creates the Encounter, "no" creates none, "unknown" creates one carrying only
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

// 1. Hospitalisation - Yes / No / Unknown (radio buttons; "unknown" is a real answer, not a
//    blank field, which is why it is in the value set rather than being left empty).
//    Pre-population: an Encounter in context whose `hospitalization` element carries a
//    data-absent-reason means the source system itself recorded "unknown"; any other Encounter
//    means "yes". No Encounter -> nothing pre-filled (the form asks).
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
// The branches yield a CODING, not a bare code string. A `choice` item's answer must be a
//    valueCoding, and $extract only ever tests `answer.value.ofType(Coding).where(system=… and
//    code=…)` — a valueString answer is invisible to it and the hospitalisation Encounter is then
//    silently dropped from the extracted document. @aehrc/sdc-populate does try to repair a string
//    (parseStringToCoding looks it up in the expanded answerValueSet), but only when it could expand
//    that value set; building the Coding here removes the dependency on terminology being reachable.
//    `%factory.Coding(system, code)` omits `display` on purpose: the label is resolved from the value
//    set (incl. the de/fr/it supplement), and populate fills it in when it can.
* item[=].item[=].extension[=].valueExpression.expression = "iif(%encounter.hospitalization.extension.where(url = 'http://hl7.org/fhir/StructureDefinition/data-absent-reason').exists(), %factory.Coding('http://snomed.info/sct', '261665006'), iif(%encounter.exists(), %factory.Coding('http://snomed.info/sct', '373066001'), {}))"

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
// Same Coding rule as hospitalisationStatus above. Only the reported-pathogen branch has to be
//    built: the else branch already passes a real Coding through.
//    This one DOES carry a `display`, unlike the SNOMED codes above: `ch-ekm-reported-pathogen` is
//    an IG-LOCAL code system, so no terminology server can $lookup it and populate would otherwise
//    leave the Coding display-less after a failed (and logged) lookup.
* item[=].item[=].extension[=].valueExpression.expression = "iif(%encounter.reasonReference.exists(), %factory.Coding('http://fhir.ch/ig/ch-ekm/CodeSystem/ch-ekm-reported-pathogen', 'reported-pathogen', 'Reported pathogen'), %encounter.reasonCode.coding.first())"

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
