// Form section "Impfstatus" (https://github.com/ahdis/ch-ekm/issues/29). On the rendered form this
// is its own tab, placed after the Exposition section.
//
// ONE INSTANCE OF THIS MODEL PER VACCINATION TYPE THE FORM ASKS ABOUT. The model is disease-
// agnostic — it describes a single row ("Vaccinated against X? yes, with N doses / no / unknown;
// last dose on …, vaccine …") — and the disease decides how many rows there are and which
// target disease each carries. Mpox has two: the historical smallpox vaccination and the mpox
// vaccination. That is also why `targetDisease` is part of the model rather than of the
// questionnaire only: it is what tells the rows apart on the wire.
//
// EVERY ANSWERED ROW MAPS ONTO ONE RESOURCE, but not always the same one: "yes" is a
// ChEkmImmunization, "no" and "unknown" are a ChEkmObservationVaccinationStatus. Only "yes"
// describes a vaccination; the other two are answers to a closed question, and R4
// `Immunization.status` cannot express "unknown" at all. Both are referenced from
// Composition.section[immunization], so the section still carries one entry per answered row. See
// ChEkmImmunization and ChEkmObservationVaccinationStatus for the full reasoning.

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

// Yes / No / Unknown. Unlike the hospitalisation question, all three answers produce a resource -
// but the answer decides WHICH resource, see the header. An unanswered row produces none.
* status 0..1 CodeableConcept "Vaccinated? yes / no / unknown (Geimpft?)"
* status from ChEkmYesNoUnknown (required)

// "mit total ___ Dosen" - only asked when the answer above is "yes". Left blank when the person was
// vaccinated but the number of doses was not established.
* doses 0..1 positiveInt "Total number of doses received (mit total ___ Dosen)"

// "Letzte Dosis, Datum" - only asked when the answer above is "yes".
* lastDoseDate 0..1 dateTime "Date of the last dose (Letzte Dosis, Datum)"

// "mit Impfstoff: Markenname" - only asked when the answer above is "yes". An open choice: the
// physician picks a Swiss vaccine brand or types a name that is not on the list.
* vaccine 0..1 CodeableConcept "Vaccine product / brand name (mit Impfstoff: Markenname)"
* vaccine from $SwissVaccinesVS (preferred)

Mapping: ImmunizationFormToImmunization
Source: ChEkmImmunizationForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-immunization"
Id: immunization-form-to-immunization
Title: "Immunization Form to CH EKM Immunization"
* -> "Immunization" "Maps a row of the 'Impfstatus' form section that was answered 'yes' to the ChEkmImmunization profile. 'no' and 'unknown' map to ChEkmObservationVaccinationStatus instead — see the ImmunizationFormToVaccinationStatus mapping"
* targetDisease -> "Immunization.protocolApplied.targetDisease" "The vaccination the row asks about"
* status -> "Immunization.status" "Answered 'yes' (373066001): status = completed. This resource exists for no other answer"
* doses -> "Immunization.protocolApplied.doseNumberPositiveInt" "Total number of doses; this resource describes the last dose of the series, so the last dose's number is the total"
* doses -> "Immunization.protocolApplied.doseNumberPositiveInt.extension[dataabsentreason]" "Vaccinated without a stated count: asked-unknown"
* lastDoseDate -> "Immunization.occurrenceDateTime" "Date of the last dose"
* lastDoseDate -> "Immunization.occurrenceDateTime.extension[dataabsentreason]" "Vaccinated without a stated date: asked-unknown"
* vaccine -> "Immunization.vaccineCode" "A picked Swiss vaccine code, or a typed brand name in vaccineCode.text; when nothing was answered, the SNOMED CT vaccine product concept for the target disease"

Mapping: ImmunizationFormToVaccinationStatus
Source: ChEkmImmunizationForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-observation-vaccination-status"
Id: immunization-form-to-vaccination-status
Title: "Immunization Form to CH EKM Vaccination Status Observation"
* -> "Observation" "Maps a row of the 'Impfstatus' form section that was answered 'no' or 'unknown' to the ChEkmObservationVaccinationStatus profile. 'yes' maps to ChEkmImmunization instead"
* status -> "Observation.valueCodeableConcept" "The answer itself: 'no' (373067005) or 'unknown' (261665006). 'yes' produces no Observation"
* targetDisease -> "Observation.component.valueCodeableConcept" "The vaccination the row asks about, named by the disease it protects against"
* vaccine -> "Observation.component.code" "The SNOMED CT vaccine product of the row. NOT the answered brand name: the product question is only asked when the answer is 'yes', so this is always the fixed product concept for the row"
// `doses` and `lastDoseDate` have no target here: both form items are enableWhen-gated on "yes", so
// they cannot have an answer on the branch this mapping covers.
