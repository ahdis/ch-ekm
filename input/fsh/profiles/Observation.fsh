Profile: ChEkmExposure
Parent: Observation
Id: ch-ekm-exposure
Title: "CH EKM Exposure"
Description: "This CH EKM base profile constrains the Observation resource to represent the exposure (Exposition): how and where the patient was most likely exposed to the infectious agent. The structure mirrors the HL7 Europe HDR 'Infectious Contact' profile (ActClassExposure category, exposure agent as value), extended with the CH EKM exposition address extension for the place of exposure. See http://hl7.eu/fhir/hdr/StructureDefinition/observation-infectious-contact-eu-hdr."
* status MS
* category 1..1
* category from ChEkmExposureClass (required)
* category ^short = "Exposure classification (acquisition / transmission / unknown)"
* code = $v3-ParticipationType#EXPAGNT "Exposure Agent"
* value[x] only CodeableConcept
* value[x] ^short = "The exposure agent, e.g. the organism the patient was exposed to"
* effective[x] only dateTime or Period
* subject 1..1
* subject only Reference(ChEkmPatient)

* extension contains ChEkmExtExpositionAddress named expositionAddress 0..1
* extension[expositionAddress] ^short = "Place/address of exposure (Wo)"

