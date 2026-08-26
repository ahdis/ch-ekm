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
Description: "This CH EKM extension enables to provide the exposure address (the place where the patient was most likely exposed, form item 'Exposition: wo'). The country is given as an ISO 3166 code in Address.country plus the coded country in the iso21090-codedString extension; the precise location goes into Address.city. Country and precise location are answered independently, and each carries its own 'unknown': the element it belongs to is then left without a value and carries a data-absent-reason instead (Address.country / Address.city, see issue #26)."
* ^context[+].type = #element
* ^context[=].expression = "Observation"
* . ^short = "CH EKM Extension: Exposure Address"
* value[x] 1..
* value[x] only Address
* valueAddress ^short = "Exposure address"
// Unbekannt (https://github.com/ahdis/ch-ekm/issues/26): the "unknown" answer is recorded as a
// data-absent-reason INSIDE the Address - the extension's value is required (value[x] 1..) and an
// Extension may not carry both a value and sub-extensions, so there is nowhere else to put it.
//
// NO ADDRESS-LEVEL data-absent-reason. The form resolved the open point from #26 by asking TWO
// independent questions, and each carries its own "Unbekannt" option, so the data-absent-reason
// belongs on the element that was answered that way - `Address.country` or `Address.city` - and
// never on the Address as a whole. "Land unbekannt, genauer Ort Zurich" and "Land CH, genauer Ort
// unbekannt" are therefore both reportable, which an Address-level marker could not express. The
// slice that used to sit here (for the single "Unbekannt" box the paper form was assumed to have)
// was never emitted by extraction and has been removed; see RuleSetExposureWhere and
// forms-summary.md section 12.
//
// The two per-element data-absent-reasons are NOT declared as named slices: `extension` slicing is
// open, so the extension the extract engine builds validates as-is. They are named in the
// ChEkmExposureForm mappings.
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

// -----------------------------------------------------------------------------------------------
// "Unbekannt" for a vaccination — a MODIFIER extension, and deliberately so.
//
// The form asks, per vaccination type, "geimpft? ja / nein / unbekannt". Two of the three answers
// fit R4 `Immunization.status` (itself a modifier element): "ja" is `completed`, "nein" is
// `not-done`. The third does not fit anywhere — the required binding
// (http://hl7.org/fhir/ValueSet/immunization-status) has no "unknown" concept, and `status` is 1..1.
//
// Neither escape hatch works here:
//   * `status = not-done` alone would ASSERT that the vaccination did not happen, which is not what
//     the reporting physician said.
//   * `status` left valueless with a plain `data-absent-reason` puts the correction in an IGNORABLE
//     extension hanging off a modifier element — a consumer is free to skip it — and leaves a
//     required-bound 1..1 code without a value.
//
// A modifier extension is exactly the right tool: a consumer that does not understand it MUST
// reject the resource rather than silently read `not-done` as "definitely not vaccinated". It is
// present ONLY on the "unbekannt" rows, so a generic consumer still processes every plain
// "ja"/"nein" row untouched (see ch-ekm-immunization-unknown for the status pairing).
//
// The value follows the IG's own "unbekannt" rule (forms-summary.md §12): the extension CAN hold a
// code, so it carries the code — sct#261665006, the same qualifier that reaches
// `Encounter.reasonCode` and `Observation.valueCodeableConcept` elsewhere in this IG — rather than
// a bare boolean flag.
Extension: ChEkmExtImmunizationUnknown
Id: ch-ekm-ext-immunization-unknown
Title: "CH EKM Extension: Immunization unknown"
Description: "This CH EKM modifier extension records that it is NOT KNOWN whether the vaccination described by this Immunization took place ('unbekannt' on the reporting form), as opposed to it being known not to have taken place. It is a modifier extension because the resource carries status = not-done, which without this extension would assert that the vaccination did not happen."
* ^context[+].type = #element
* ^context[=].expression = "Immunization"
* . ^short = "It is unknown whether this vaccination took place"
* . ^isModifier = true
* . ^isModifierReason = "Changes the meaning of Immunization.status: the record states that it is unknown whether the vaccination took place, not that it did not take place. A consumer that ignores this extension would read status = not-done as an assertion that the person was not vaccinated."
* value[x] 1..
* value[x] only CodeableConcept
* valueCodeableConcept = $sct#261665006 "Unknown (qualifier value)"
* valueCodeableConcept ^short = "Always sct#261665006 'Unknown' — the extension's presence is the statement"

