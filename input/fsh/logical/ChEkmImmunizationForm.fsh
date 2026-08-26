// Form section "Impfstatus" (https://github.com/ahdis/ch-ekm/issues/29). On the rendered form this
// is its own tab, placed after the Exposition section.
//
// ONE INSTANCE OF THIS MODEL PER VACCINATION TYPE THE FORM ASKS ABOUT. The model is disease-
// agnostic — it describes a single row ("Wurde gegen X geimpft? ja mit N Dosen / nein / unbekannt,
// letzte Dosis am …, Impfstoff …") — and the disease decides how many rows there are and which
// target disease each carries. Mpox has two: the historical smallpox vaccination and the mpox
// vaccination. That is also why `targetDisease` is part of the model rather than of the
// questionnaire only: it is what tells the rows apart on the wire.
//
// Everything maps onto ONE resource per row, ChEkmImmunization, referenced from
// Composition.section[immunization].

Logical: ChEkmImmunizationForm
Parent: Base
Characteristics: #can-be-target
Title: "CH EKM Form: Immunization"
Description: "Logical model for one row of the form section 'Impfstatus' (vaccination status): which vaccination, whether it was given, with how many doses, when the last dose was given and with which product. One element per form item."

// Which vaccination the row is about. Not asked on the form — it IS the row, printed as its
// heading ("Pockenimpfung", "Affenpockenimpfung") — but it is the element that identifies the row
// once the answers have left the form, so it is modelled.
* targetDisease 1..1 CodeableConcept "The vaccination this row asks about, named by the disease it protects against"
* targetDisease from $TargetDiseasesVS (preferred)

// Ja / Nein / Unbekannt. Unlike the hospitalisation question, all three answers produce a resource:
// see ChEkmImmunization for why, and ChEkmExtImmunizationUnknown for why "unbekannt" needs a
// modifier extension rather than a data-absent-reason.
* status 0..1 CodeableConcept "Geimpft? ja / nein / unbekannt"
* status from ChEkmYesNoUnknown (required)

// "mit total ___ Dosen" - only asked when the answer above is "ja". Left blank when the person was
// vaccinated but the number of doses was not established.
* doses 0..1 positiveInt "Total number of doses received (mit total ___ Dosen)"

// "Letzte Dosis, Datum" - only asked when the answer above is "ja".
* lastDoseDate 0..1 dateTime "Date of the last dose (Letzte Dosis, Datum)"

// "mit Impfstoff: Markenname" - only asked when the answer above is "ja". An open choice: the
// physician picks a Swiss vaccine brand or types a name that is not on the list.
* vaccine 0..1 CodeableConcept "Vaccine product / brand name (mit Impfstoff: Markenname)"
* vaccine from $SwissVaccinesVS (preferred)

Mapping: ImmunizationFormToImmunization
Source: ChEkmImmunizationForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-immunization"
Id: immunization-form-to-immunization
Title: "Immunization Form to CH EKM Immunization"
* -> "Immunization" "Maps one row of the 'Impfstatus' form section to the ChEkmImmunization profile"
* targetDisease -> "Immunization.protocolApplied.targetDisease" "The vaccination the row asks about"
* status -> "Immunization.status" "Answered 'ja' (373066001): status = completed. Answered 'nein' (373067005) or 'unbekannt' (261665006): status = not-done"
* status -> "Immunization.modifierExtension[unknown]" "Answered 'unbekannt' (261665006): the modifier extension is added so that status = not-done is not read as an assertion that the vaccination did not happen"
* doses -> "Immunization.protocolApplied.doseNumberPositiveInt" "Total number of doses; this resource describes the last dose of the series, so the last dose's number is the total"
* doses -> "Immunization.protocolApplied.doseNumberPositiveInt.extension[dataabsentreason]" "Not vaccinated: not-applicable. Unknown, or vaccinated without a stated count: asked-unknown / unknown"
* lastDoseDate -> "Immunization.occurrenceDateTime" "Date of the last dose"
* lastDoseDate -> "Immunization.occurrenceDateTime.extension[dataabsentreason]" "Not vaccinated: not-applicable. Unknown, or vaccinated without a stated date: asked-unknown / unknown"
* vaccine -> "Immunization.vaccineCode" "A picked Swiss vaccine code, or a typed brand name in vaccineCode.text; when nothing was answered, the SNOMED CT vaccine product concept for the target disease"
