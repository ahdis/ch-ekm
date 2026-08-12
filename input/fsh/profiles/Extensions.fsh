Extension: ChEkmExtHivCode
Id: ch-ekm-ext-hiv-code
Title: "CH EKM Extension: HIV code"
Description: "This CH EKM extension enables to provide the HIV Code."
* ^context[+].type = #element
* ^context[=].expression = "HumanName"
* . ^short = "CH EKM Extension: HIV Code"
* obeys ch-ekm-hiv-check
* value[x] 1..
* value[x] only string
* valueString ^short = "Name of the HIV code"
* valueString ^maxLength = 2

Extension: ChEkmExtExposureAddress
Id: ch-ekm-ext-exposure-address
Title: "CH EKM Extension: Exposure Address"
Description: "This CH EKM extension enables to provide the exposure address (the place where the patient was most likely exposed, form item 'Exposition: wo'). The country is given as an ISO 3166 code in Address.country plus the coded country in the iso21090-codedString extension; the precise location goes into Address.city. When the place of exposure is reported as unknown, the Address carries a data-absent-reason - on its own if nothing else was reported, or alongside a country/location that was reported as well (the form's 'Unbekannt' box does not suppress the other answers, see issue #26)."
* ^context[+].type = #element
* ^context[=].expression = "Observation"
* . ^short = "CH EKM Extension: Exposure Address"
* value[x] 1..
* value[x] only Address
* valueAddress ^short = "Exposure address"
// Unbekannt (https://github.com/ahdis/ch-ekm/issues/26): the place of exposure is reported as
// unknown. The extension's value is required (value[x] 1..) and an Extension may not carry both a
// value and sub-extensions, so the "unknown" answer is recorded as a data-absent-reason INSIDE the
// Address.
// Open point: the form has a single "Unbekannt" box and it is not yet defined whether it refers to
// the country, the precise location or both - the data-absent-reason is therefore placed on the
// whole Address (= the whole "wo" is unknown). Until that is decided, ticking the box does NOT
// discard the other answers: an Address may carry the data-absent-reason AND a country/city that
// were reported alongside it, so no reported data is lost. See issue #26.
* valueAddress.extension contains $data-absent-reason named unknown 0..1
* valueAddress.extension[unknown] ^short = "Place of exposure unknown (e.g. asked-unknown)"
// Land: Address.country is a plain string, so the answered country code is additionally carried as
// a Coding - the same pattern CH ELM requires on Patient.address.country
// (ch-elm-patient-address-require-countrycode).
* valueAddress.country.extension contains $iso21090-codedString named countryCoding 0..1
* valueAddress.country.extension[countryCoding] ^short = "Country of exposure as a Coding (ISO 3166)"
* valueAddress.city ^short = "Precise location of exposure (Genauer Ort), in Switzerland/Liechtenstein or abroad"

Extension: ChEkmExtDepartment
Id: ch-ekm-ext-department
Title: "CH EKM Extension: Department"
Description: "This CH EKM extension enables the representation of a department (name) of an organization directly in the resource Organization itself."
* ^context[+].type = #element
* ^context[=].expression = "Organization"
* . ^short = "CH EKM Extension: Department"
* value[x] 1..
* value[x] only string
* valueString ^short = "Name of the department"

// -----------------------------------------------------------------------------------------------
// Carrier extension for SDC template-based $extract.
//
// Used ONLY inside an extraction template, at a location where a `templateExtractValue` on the
// element itself cannot produce the wanted result — most notably a primitive element's
// `_element.extension` slot: a value directive there sets the primitive's value[x], not a sibling
// extension. This carrier holds the SDC `templateExtractContext` (optional gate) and
// `templateExtractValue` directives; the latter's `%factory.Extension(url, value)` builds a whole
// FHIR Extension, whose result deep-merges onto this carrier during extraction — overwriting the
// carrier url and stripping the directives. The carrier therefore appears ONLY in the template and
// never in extracted output. It is defined here purely so the template Bundle validates as FHIR
// (an otherwise-undefined ch-ekm extension url would be flagged by the IG Publisher).
// Example: ChEkmDocumentGonorrhoeaTemplate onsetDateTime data-absent-reason.
Extension: SdcTemplateExtractExtension
Id: sdc-templateExtractExtension
Title: "SDC Template Extract Extension (carrier)"
Description: "Carrier/placeholder extension used only inside an SDC template-based $extract template to build a whole FHIR Extension via %factory.Extension at a location a value directive cannot reach (e.g. a primitive element's _element.extension). Its %factory.Extension result replaces this carrier during extraction, so it never appears in extracted output."
* ^context[+].type = #element
* ^context[=].expression = "Element"
* . ^short = "Template-extract carrier that builds a whole Extension via %factory.Extension"
* value[x] 0..0
* extension contains
    $sdc-templateExtractContext named context 0..1 and
    $sdc-templateExtractValue named value 0..*