Logical: ChEkmExpositionForm
Parent: Base
Id: ch-ekm-exposition-form
Title: "CH EKM Form: Exposition"
Description: "Logical model for the form section 'Exposition'. One element per form item."

// Wo on the structured level we will not have inland/ausland as separate checkbox items (discussed June 1st)
* where 0..1 Base "Wo"
  * country 0..1 CodeableConcept "Land"
  * country from $bfs-country-codes (required)
  * preciseLocation 0..1 string "Genauer Ort (CH/LI und Ausland)"
  * unknown 0..1 boolean "unbekannt"

Mapping: ExpositionToExposure
Source: ChEkmExpositionForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-exposure"
Id: exposition-to-exposure
Title: "Exposition Form to CH EKM Exposure"
* -> "Observation" "Maps the form section to the ChEkmExposure profile"
* where.country -> "Observation.extension[expositionAddress].valueAddress.country" "Wo - CH/LI oder Ausland (Exposition Address Extension)"
* where.preciseLocation -> "Observation.extension[expositionAddress].valueAddress.city" "Genauer Ort"
* where.unknown -> "Observation.extension[expositionAddress]" "unbekannt -> extension with data-absent-reason"
