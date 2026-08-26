// The "Impfstatus" section of the reporting form (https://github.com/ahdis/ch-ekm/issues/29).
//
// ONE Immunization PER VACCINATION TYPE ASKED — not one per administered dose. The form asks, for
// each vaccination that is relevant to the reported disease, a single closed question
// ("geimpft? ja / nein / unbekannt") plus three details about the vaccination as a whole (total
// number of doses, date of the LAST dose, product). So the resource summarises a series, and the
// row exists whatever the answer was: the fact that a physician was asked about the smallpox
// vaccination and said "nein" is reportable information, and it would be lost if only "ja"
// produced a resource (the same argument that decided issue #28 for the cause of death).
//
// Which vaccination types are asked is a per-disease question, so the target diseases are fixed by
// the disease specialisation (ChEkmImmunizationMpox), exactly as the manifestation value set is.
//
// HOW THE THREE ANSWERS REACH THE WIRE
//   ja        status = completed, occurrenceDateTime = date of the last dose,
//             protocolApplied.doseNumberPositiveInt = total number of doses
//   nein      status = not-done; occurrence and dose number carry data-absent-reason
//             #not-applicable — there is no date and no dose because there was no vaccination
//   unbekannt status = not-done PLUS modifierExtension[unknown]; occurrence and dose number carry
//             data-absent-reason #asked-unknown
//
// The "unbekannt" row is the only one that needs anything beyond the base resource, and it needs a
// MODIFIER extension rather than a plain one — see ChEkmExtImmunizationUnknown for the full
// reasoning, and invariant ch-ekm-immunization-unknown for the status pairing.
//
// WHY THE DOSE NUMBER TAKES A DATA-ABSENT-REASON. `protocolApplied.targetDisease` names the
// vaccination the row is about and is required on EVERY row, including "nein" and "unbekannt", so
// that "was this person vaccinated against smallpox?" is answerable directly from the resource
// rather than only by mapping `vaccineCode` through a vaccine -> disease ConceptMap. Keeping it
// means keeping `protocolApplied`, and R4 makes `doseNumber[x]` 1..1 inside that element - so when
// no dose count was given the dose is present-but-valueless with a data-absent-reason.
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
Description: "This CH EKM base profile constrains the Immunization resource for the 'Impfstatus' section of the reporting form: per vaccination type relevant to the reported disease, whether the affected person was vaccinated (yes / no / unknown), with how many doses in total, when the last dose was given and with which product. Referenced from Composition.section[immunization]."
* . ^short = "CH EKM Immunization: vaccination status for one target disease"
* obeys ch-ekm-immunization-unknown

// "Unbekannt" — see ChEkmExtImmunizationUnknown. Sliced on `modifierExtension`, not `extension`:
// a modifier extension that is filed under `extension` is silently ignorable, which defeats the
// whole point of declaring it modifier.
* modifierExtension ^slicing.discriminator.type = #value
* modifierExtension ^slicing.discriminator.path = "url"
* modifierExtension ^slicing.rules = #open
* modifierExtension contains ChEkmExtImmunizationUnknown named unknown 0..1
* modifierExtension[unknown] ^short = "Present when the answer was 'unbekannt': it is not known whether this vaccination took place"

* status ^short = "completed = vaccinated ('ja'); not-done = not vaccinated ('nein'), or — together with modifierExtension[unknown] — not known ('unbekannt')"
* statusReason 0..0
* statusReason ^short = "Not used: the form does not ask WHY a vaccination was not given"

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
// vaccination series. Valueless + data-absent-reason for the "nein" / "unbekannt" rows.
* occurrence[x] only dateTime
* occurrenceDateTime ^short = "Date of the LAST dose ('Letzte Dosis, Datum'). Valueless with a data-absent-reason when the person was not vaccinated or it is unknown"

// The vaccination the row is about, and how many doses it comprised.
* protocolApplied 1..1
* protocolApplied.targetDisease 1..1
* protocolApplied.targetDisease from $TargetDiseasesVS (preferred)
* protocolApplied.targetDisease ^short = "The vaccination type the form row asks about, as the disease it protects against (e.g. smallpox, mpox)"
// TOTAL number of doses, which is why doseNumber and not seriesDoses: the resource describes the
// LAST dose of the series, and the last dose's number IS the total. `seriesDoses[x]` means
// "how many doses the recommended series has", which is not what the form asks.
* protocolApplied.doseNumber[x] only positiveInt
* protocolApplied.doseNumberPositiveInt ^short = "Total number of doses received ('mit total ___ Dosen') — the number of the last dose. Valueless with a data-absent-reason when not vaccinated, unknown, or not stated"
