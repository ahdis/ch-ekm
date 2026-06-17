Logical: ChEkmExpositionForm
Parent: Base
Title: "CH EKM Form: Exposition"
Description: "Logical model for the form section 'Exposition'. One element per form item."

// Wo on the structured level we will not have inland/ausland as separate checkbox items (discussed June 1st)
* where 0..1 Base "Wo"
  * country 0..1 CodeableConcept "Land"
  * country from ChEkmCountryCodes (required)
  * preciseLocation 0..1 string "Precise location (Switzerland/Liechtenstein and abroad)"
  * unknown 0..1 boolean "Unknown"

Mapping: ExpositionToExposure
Source: ChEkmExpositionForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-exposure"
Id: exposition-to-exposure
Title: "Exposition Form to CH EKM Exposure"
* -> "Observation" "Maps the form section to the ChEkmExposure profile"
* where.country -> "Observation.extension[expositionAddress].valueAddress.country" "Where - Switzerland/Liechtenstein or abroad (Exposition Address Extension)"
* where.preciseLocation -> "Observation.extension[expositionAddress].valueAddress.city" "Precise location"
* where.unknown -> "Observation.extension[expositionAddress]" "unknown -> extension with data-absent-reason"
