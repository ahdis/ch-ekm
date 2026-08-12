Logical: ChEkmExposureForm
Parent: Base
Title: "CH EKM Form: Exposure"
Description: "Logical model for the form section 'Exposure' (German form: 'Exposition'). One element per form item."

// Wo on the structured level we will not have inland/ausland as separate checkbox items (discussed June 1st)
// The RENDERED form still mirrors the paper form (https://github.com/ahdis/ch-ekm/issues/26) and
// offers a "CH/LI" check-box next to the "Ausland" country dropdown; that check-box is form-only
// (linkId exposureWhereChLi, no element here) and is collapsed to country = CH on extraction.
* where 0..1 Base "Wo"
  * country 0..1 CodeableConcept "Land"
  * country from ChEkmCountryCodes (required)
  * preciseLocation 0..1 string "Precise location (Switzerland/Liechtenstein and abroad)"
  * unknown 0..1 boolean "Unknown - the place of exposure is explicitly reported as unknown. Open point (issue #26): not yet defined whether this refers to the country, the precise location or both; modelled as 'the whole where is unknown'."

// Wann - two form items (see https://github.com/ahdis/ch-ekm/issues/25). The second one is only
// asked when the first is unanswered: the last entry into Switzerland is a proxy for the exposure
// window (the person was abroad up to that date), not the point of infection itself, hence a
// separate element rather than a second way to fill `exposureDate`.
* when 0..1 Base "Wann"
  * exposureDate 0..1 dateTime "Most probable point in time of infection. May be a partial date (year / year-month)."
  * lastEntryDate 0..1 dateTime "Date of the last entry into Switzerland - only asked when the most probable point in time of infection is unknown"

Mapping: ExposureFormToExposure
Source: ChEkmExposureForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-exposure"
Id: exposure-form-to-exposure
Title: "Exposure Form to CH EKM Exposure"
* -> "Observation" "Maps the form section to the ChEkmExposure profile"
* where.country -> "Observation.extension[exposureAddress].valueAddress.country" "Where - Switzerland/Liechtenstein or abroad, as an ISO 3166 code (Exposure Address Extension)"
* where.country -> "Observation.extension[exposureAddress].valueAddress.country.extension[countryCoding]" "Where - the same country as a Coding (iso21090-codedString), Address.country itself being a plain string"
* where.preciseLocation -> "Observation.extension[exposureAddress].valueAddress.city" "Precise location"
* where.unknown -> "Observation.extension[exposureAddress].valueAddress.extension[unknown]" "unknown -> the Address carries a data-absent-reason (asked-unknown); reported country/location are kept alongside it (issue #26)"
* when.exposureDate -> "Observation.effectiveDateTime" "When - most probable point in time of infection"
* when.lastEntryDate -> "Observation.component[dateOfEntry].valueDateTime" "When the point in time of infection is unknown - date of the last entry into Switzerland (sct#161097008 'Date of return from travel')"
