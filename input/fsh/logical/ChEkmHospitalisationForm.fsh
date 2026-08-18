// Form section "Hospitalisation". On the rendered form this section is the
// first half of the "Verlauf" tab (the second half, "Zustand" / death, is still open — see TODO.md
// #7-#9). Gonorrhoea has no Verlauf, so nothing here is assembled into the Gonorrhoea root.
//
// Everything maps onto ONE resource, the Encounter — `Composition.section[hospitalization]` has
// been dropped (see ChEkmEncounter for the reasoning and for how ja / nein / unbekannt are encoded).

Logical: ChEkmHospitalisationForm
Parent: Base
Characteristics: #can-be-target
Title: "CH EKM Form: Hospitalisation"
Description: "Logical model for the form section 'Hospitalisation' (part of the 'Verlauf' section of the reporting form). One element per form item."

// Ja / Nein / Unbekannt. This is not a field of the Encounter, it is the question whether an
// Encounter exists at all: "ja" creates one, "nein" creates none, "unbekannt" creates one whose
// `hospitalization` element carries only a data-absent-reason.
* hospitalisation 0..1 CodeableConcept "Hospitalisation"
* hospitalisation from ChEkmYesNoUnknown (required)

// Hospitalisationsgrund - only asked when the answer above is "ja".
* reason 0..1 CodeableConcept "Hospitalisationsgrund (Grund der Hospitalisation)"
* reason from ChEkmHospitalisationReasonChoice (required)

// Eintrittsdatum - only asked when the answer above is "ja".
* admissionDate 0..1 dateTime "Eintrittsdatum (Datum des Spitaleintritts)"

// NOT modelled: "Spital" (the hospital name). The FHIR target is still undecided
// between Encounter.serviceProvider (an Organization) and Encounter.location - see TODO.md #6.

Mapping: HospitalisationFormToEncounter
Source: ChEkmHospitalisationForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-encounter"
Id: hospitalisation-form-to-encounter
Title: "Hospitalisation Form to CH EKM Encounter"
* -> "Encounter" "Maps the form section to the ChEkmEncounter profile"
* hospitalisation -> "Encounter" "Answered 'ja' (373066001): an Encounter with class = IMP is created and referenced from Composition.encounter and from the diagnosis Condition.encounter. Answered 'nein' (373067005): no Encounter is created."
* hospitalisation -> "Encounter.hospitalization.extension[unknown]" "Answered 'unbekannt' (261665006): an Encounter is created whose hospitalization element carries nothing but data-absent-reason = asked-unknown"
* reason -> "Encounter.reasonReference" "Hospitalisationsgrund = the reported pathogen: a reference to the diagnosis Condition of this report"
* reason -> "Encounter.reasonCode" "Hospitalisationsgrund = 'anderer' (74964007) or 'unbekannt' (261665006): the answered SNOMED CT qualifier"
* admissionDate -> "Encounter.period.start" "Eintrittsdatum"
