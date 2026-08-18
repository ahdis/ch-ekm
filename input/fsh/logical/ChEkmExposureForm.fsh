Logical: ChEkmExposureForm
Parent: Base
Title: "CH EKM Form: Exposure"
Description: "Logical model for the form section 'Exposure' (German form: 'Exposition'). One element per form item."

// Wo on the structured level we will not have inland/ausland as separate checkbox items (discussed June 1st)
// The RENDERED form follows suit (https://github.com/ahdis/ch-ekm/issues/26): a single mandatory
// country dropdown with Switzerland and Liechtenstein at the top - no "CH/LI" check-box next to an
// "Ausland" dropdown, and never a combination of two countries. The place is always a country CODE.
* where 0..1 Base "Wo"
  * country 0..1 CodeableConcept "Land"
  // The value set carries sct#261665006 "Unknown" alongside the ISO 3166 countries because the form
  // field is mandatory. That answer is not a country: on extraction it leaves Address.country empty
  // and puts a data-absent-reason on the `_country` element (see RuleSetExposureWhere).
  * country from ChEkmCountryCodesInclUnknown (required)
  // Rendered as ONE `open-choice` widget: a free text entry whose only predefined option is
  // sct#261665006 "Unknown". There is deliberately NO separate `unknown` element next to it - each
  // of the two "Wo" questions carries its own unknown answer, and both are expressed as a
  // data-absent-reason on the element they belong to (here `_city`, see RuleSetExposureWhere).
  * preciseLocation 0..1 string "Precise location (in Switzerland/Liechtenstein or abroad), or explicitly reported as unknown"

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
* where.country -> "Observation.extension[exposureAddress].valueAddress.country" "Where - the answered country as an ISO 3166 code (Exposure Address Extension)"
* where.country -> "Observation.extension[exposureAddress].valueAddress.country.extension[countryCoding]" "Where - the same country as a Coding (iso21090-codedString), Address.country itself being a plain string"
* where.country -> "Observation.extension[exposureAddress].valueAddress.country.extension[unknown]" "Where - country answered as sct#261665006 'Unknown': no country string is written, the country element carries a data-absent-reason (asked-unknown) instead"
* where.preciseLocation -> "Observation.extension[exposureAddress].valueAddress.city" "Precise location - the entered free text"
* where.preciseLocation -> "Observation.extension[exposureAddress].valueAddress.city.extension[unknown]" "Precise location answered as sct#261665006 'Unknown': no city string is written, the city element carries a data-absent-reason (asked-unknown) instead; the answered country is kept alongside it"
* when.exposureDate -> "Observation.effectiveDateTime" "When - most probable point in time of infection"
* when.lastEntryDate -> "Observation.component[dateOfEntry].valueDateTime" "When the point in time of infection is unknown - date of the last entry into Switzerland (sct#161097008 'Date of return from travel')"
