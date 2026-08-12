Profile: ChEkmExposure
Parent: Observation
Id: ch-ekm-exposure
Title: "CH EKM Exposure"
Description: "This CH EKM base profile constrains the Observation resource to represent the exposure (Exposition): how and where the patient was most likely exposed to the infectious agent. The structure mirrors the HL7 Europe HDR 'Infectious Contact' profile (ActClassExposure category, exposure agent as value), extended with the CH EKM exposure address extension for the place of exposure. See http://hl7.eu/fhir/hdr/StructureDefinition/observation-infectious-contact-eu-hdr."
* status MS
* category 1..1
* category from ChEkmExposureClass (required)
* category ^short = "Exposure classification (acquisition / transmission / unknown)"
* code = $v3-ParticipationType#EXPAGNT "Exposure Agent"
* value[x] only CodeableConcept
* value[x] ^short = "The exposure agent, e.g. the organism the patient was exposed to"
* effective[x] only dateTime or Period
* effective[x] ^short = "When the exposure took place (Wann) - the most probable point in time of infection; a Period when only a time window is known"
* subject 1..1
* subject only Reference(ChEkmPatient)

* extension contains ChEkmExtExposureAddress named exposureAddress 0..1
* extension[exposureAddress] ^short = "Place/address of exposure (Wo)"

// Wann - the form asks for the date of the last entry into Switzerland when the point in time of
// infection itself is unknown. That date is NOT the exposure time (it only bounds the window in
// which the exposure abroad must have happened), so it is recorded as its own component instead of
// as effective[x]. Sliced here on the base profile: every organism asking "Wann" reuses this slice.
* component ^slicing.discriminator.type = #pattern
* component ^slicing.discriminator.path = "code"
* component ^slicing.rules = #open
* component contains dateOfEntry 0..1 MS
* component[dateOfEntry] ^short = "Date of the last entry into Switzerland (Wann - only when the point in time of infection is unknown)"
* component[dateOfEntry].code = $sct#161097008 "Date of return from travel"
* component[dateOfEntry].value[x] only dateTime

