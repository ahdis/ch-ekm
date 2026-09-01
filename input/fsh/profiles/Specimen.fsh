Profile: ChEkmSpecimen
Parent: Specimen
Id: ch-ekm-specimen
Title: "CH EKM Specimen: Laboratory"
Description: "This CH EKM base profile constrains the Specimen resource for the purpose of clinical finding reports associated to a infectious disease."
* . ^short = "CH Lab Specimen: Laboratory"

// Bound DIRECTLY to the CH ELM specimen value set rather than through a local wrapper. A CH EKM
// value set whose only content was `include codes from valueset ch-elm-results-complete-spec` added
// no concepts and no curation — but the nested include cost real behaviour: tx.fhir.ch refuses
// `useSupplement` on a value set that pulls its codes in that way ("Required supplement not found",
// HTTP 422), which broke the questionnaire language previews. Referencing the ELM canonical directly
// expands cleanly, supplement and all.
* type.coding ..1
* type.coding from $ch-elm-results-complete-spec (required)

* subject 1..
* subject only Reference(ChEkmPatient)

* collection MS
* collection.collectedDateTime obeys ch-ekm-dateTime
* collection.collectedDateTime MS

