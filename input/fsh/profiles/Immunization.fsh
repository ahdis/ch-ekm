// The "Impfstatus" section of the reporting form (https://github.com/ahdis/ch-ekm/issues/29).
//
// ONE Immunization PER VACCINATION THAT TOOK PLACE — not one per administered dose, and not one per
// form row. The form asks, for each vaccination that is relevant to the reported disease, a single
// closed question ("Geimpft?" — yes / no / unknown) plus three details about the vaccination as a
// whole (total number of doses, date of the LAST dose, product). Only "yes" describes a vaccination,
// so only "yes" produces an Immunization, and the resource then summarises the whole series.
//
// "No" and "unknown" are ANSWERS, not vaccinations: they are recorded as
// ChEkmObservationVaccinationStatus (see Observation.fsh). Earlier drafts squeezed both into this
// resource as `status = not-done` — plus, for "unknown", a modifier extension that took the
// assertion back — which R4 cannot express honestly: `Immunization.status` has no "unknown", and a
// consumer that ignored the extension read "definitely not vaccinated" off a record that said the
// opposite. The form row is still fully reported, because the section carries one entry per row
// whatever the answer was; only the resource type changes with the answer.
//
// Which vaccination types are asked is a per-disease question, so the target diseases are fixed by
// the disease specialisation (ChEkmImmunizationMpox), exactly as the manifestation value set is.
//
// HOW THE ANSWER REACHES THE WIRE
//   yes       THIS profile: status = completed, occurrenceDateTime = date of the last dose,
//             protocolApplied.doseNumberPositiveInt = total number of doses. Both details are
//             optional on the form, so either can be present-but-valueless with a
//             data-absent-reason #asked-unknown.
//   no        ChEkmObservationVaccinationStatus, value = sct#373067005 "No"
//   unknown   ChEkmObservationVaccinationStatus, value = sct#261665006 "Unknown"
//
// WHY THE DOSE NUMBER TAKES A DATA-ABSENT-REASON. `protocolApplied.targetDisease` names the
// vaccination the row is about and is required, so that "was this person vaccinated against
// smallpox?" is answerable directly from the resource rather than only by mapping `vaccineCode`
// through a vaccine -> disease ConceptMap. Keeping it means keeping `protocolApplied`, and R4 makes
// `doseNumber[x]` 1..1 inside that element - so when no dose count was given the dose is
// present-but-valueless with a data-absent-reason.
//
// `occurrence[x]` is 1..1 at the resource root and gets the same treatment when the date is unknown.
// Both follow the idiom the IG already uses for Patient.deceasedDateTime and Address.country
// (forms-summary.md section 12).
//
// NOTE: the IG Publisher currently DAMAGES this shape when the template is carried in
// `Questionnaire.contained[0]` - it drops a valueless primitive inside a BackboneElement and retypes
// a valued one (positiveInt -> string). The resources themselves are correct; see TODO.md and the
// minimal reproduction on branch oe_contained_primitive_extension in ../ch-ig.

Profile: ChEkmImmunization
Parent: CHCoreImmunization
Id: ch-ekm-immunization
Title: "CH EKM Immunization: Vaccination status"
Description: "This CH EKM base profile constrains the Immunization resource for the 'yes' answers of the 'Impfstatus' (vaccination status) section of the reporting form: per vaccination type relevant to the reported disease that the affected person did receive, with how many doses in total, when the last dose was given and with which product. The 'no' and 'unknown' answers are ChEkmObservationVaccinationStatus instead. Referenced from Composition.section[immunization]."
* . ^short = "CH EKM Immunization: a vaccination the person received, for one target disease"

// Only a vaccination that took place is an Immunization, so there is exactly one status. `not-done`
// is deliberately excluded: it asserts that the vaccination did NOT happen, which is a "no"
// answer, and that answer is an Observation.
* status = #completed (exactly)
* status ^short = "Always completed: this resource exists only for a 'yes' answer"
* statusReason 0..0
* statusReason ^short = "Not used: the resource is never not-done, so there is no reason to give"

* patient 1..
* patient only Reference(ChEkmPatient)

// The product. `vaccineCode` is 1..1, and the form's product question is optional, so a row without
// an answered product still needs a code: the disease specialisation supplies the SNOMED CT vaccine
// product concept for its target disease as the fallback (see ChEkmImmunizationMpox). A brand name
// the physician typed rather than picked from the list lands in `vaccineCode.text` alongside it.
// The binding itself is inherited from CHCoreImmunization (preferred -> Swiss vaccines), which is
// also the answer value set of the form item.
* vaccineCode 1..1
* vaccineCode ^short = "The vaccine product. A Swiss vaccine (brand) code when the physician picked one, otherwise the SNOMED CT vaccine product concept for the target disease; a typed brand name is carried in vaccineCode.text"

// Date of the LAST dose, not of a single administration — the form asks for one date per
// vaccination series. Valueless + data-absent-reason when the physician did not give a date.
* occurrence[x] only dateTime
* occurrenceDateTime ^short = "Date of the LAST dose ('Letzte Dosis, Datum'). Valueless with a data-absent-reason #asked-unknown when no date was given"

// The vaccination the row is about, and how many doses it comprised.
* protocolApplied 1..1
* protocolApplied.targetDisease 1..1
* protocolApplied.targetDisease from $TargetDiseasesVS (preferred)
* protocolApplied.targetDisease ^short = "The vaccination type the form row asks about, as the disease it protects against (e.g. smallpox, mpox)"
// TOTAL number of doses, which is why doseNumber and not seriesDoses: the resource describes the
// LAST dose of the series, and the last dose's number IS the total. `seriesDoses[x]` means
// "how many doses the recommended series has", which is not what the form asks.
* protocolApplied.doseNumber[x] only positiveInt
* protocolApplied.doseNumberPositiveInt ^short = "Total number of doses received ('mit total ___ Dosen') — the number of the last dose. Valueless with a data-absent-reason #asked-unknown when no count was given"
