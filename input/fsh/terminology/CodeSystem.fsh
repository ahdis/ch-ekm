CodeSystem: ChEkmExposureComponent
Id: ch-ekm-exposure-component
Title: "CH EKM Exposure Component"
Description: "Internal code system used as discriminator for the components of a CH EKM Exposure observation. Used because no suitable standard code exists for these structural roles."
* ^status = #active
* ^experimental = false
* ^caseSensitive = true
// * #transmission-route "Transmission route" "The likely route of transmission."
* #sexual-contact-partner "Sexual contact partner"
* #sexual-contact-partner ^designation[+].language = #de-CH
* #sexual-contact-partner ^designation[=].value = "Sexualkontaktpartner"
* #sexual-contact-partner ^designation[+].language = #fr-CH
* #sexual-contact-partner ^designation[=].value = "Partenaire de contact sexuel"
* #sexual-contact-partner ^designation[+].language = #it-CH
* #sexual-contact-partner ^designation[=].value = "Partner di contatto sessuale"
// * #relationship-type "Type of relationship" "Type of the relationship to the sexual contact partner."

CodeSystem: ChEkmRelationshipType
Id: ch-ekm-relationship-type
Title: "CH EKM Relationship Type"
Description: "Type of relationship to a sexual contact partner (Art der Beziehung). Suggestesd list as of June 1st"
* ^status = #active
* ^experimental = false
* ^caseSensitive = true
* #steady-partner "Steady partner"
* #steady-partner ^designation[+].language = #de-CH
* #steady-partner ^designation[=].value = "Fester Partner"
* #steady-partner ^designation[+].language = #fr-CH
* #steady-partner ^designation[=].value = "Partenaire stable"
* #steady-partner ^designation[+].language = #it-CH
* #steady-partner ^designation[=].value = "Partner fisso"
* #non-steady-partner "Non-steady partner"
* #non-steady-partner ^designation[+].language = #de-CH
* #non-steady-partner ^designation[=].value = "Nicht fester Partner"
* #non-steady-partner ^designation[+].language = #fr-CH
* #non-steady-partner ^designation[=].value = "Partenaire non stable"
* #non-steady-partner ^designation[+].language = #it-CH
* #non-steady-partner ^designation[=].value = "Partner non fisso"
* #offered-paid-sex "Offered paid sex"
* #offered-paid-sex ^designation[+].language = #de-CH
* #offered-paid-sex ^designation[=].value = "Angebot von bezahltem Sex"
* #offered-paid-sex ^designation[+].language = #fr-CH
* #offered-paid-sex ^designation[=].value = "Offre de sexe rémunéré"
* #offered-paid-sex ^designation[+].language = #it-CH
* #offered-paid-sex ^designation[=].value = "Offerta di sesso a pagamento"
* #used-paid-sex "Used paid sex"
* #used-paid-sex ^designation[+].language = #de-CH
* #used-paid-sex ^designation[=].value = "Inanspruchnahme von bezahltem Sex"
* #used-paid-sex ^designation[+].language = #fr-CH
* #used-paid-sex ^designation[=].value = "Recours à du sexe rémunéré"
* #used-paid-sex ^designation[+].language = #it-CH
* #used-paid-sex ^designation[=].value = "Ricorso a sesso a pagamento"

// "Reported pathogen" — the answer shared by two questions of the "Verlauf" (course) section:
//   Hospitalisation reason  -> the stay was because of the reported disease
//   Cause of death          -> the person died of the reported disease
// In both, the other two answers ("other" = 74964007, "unknown" = 261665006) are plain SNOMED CT
// qualifiers, while this one is NOT a code at all: it says the answer IS the disease this very
// report is about. On the wire that becomes a reference to the diagnosis Condition
// (Encounter.reasonReference / Observation.focus) and, for the cause of death, the disease code
// itself. It therefore has to be a form-level discriminator rather than a clinical concept, and it
// must stay disease-agnostic so both sub-questionnaires are reusable for every organism (the Mpox
// code 359814004 lives in ChEkmConditionMpox, not in the form). Hence this one local code.
CodeSystem: ChEkmReportedPathogen
Id: ch-ekm-reported-pathogen
Title: "CH EKM Reported Pathogen"
Description: "Internal code system holding the single form answer that is not a clinical concept but a pointer to the disease this report is about. Used by the hospitalisation reason and cause of death form items; on extraction it becomes a reference to the diagnosis Condition rather than a code of its own."
* ^status = #active
* ^experimental = false
* ^caseSensitive = true
* #reported-pathogen "Reported pathogen"
* #reported-pathogen ^designation[+].language = #de-CH
* #reported-pathogen ^designation[=].value = "Gemeldeter Erreger"
* #reported-pathogen ^designation[+].language = #fr-CH
* #reported-pathogen ^designation[=].value = "Agent pathogène déclaré"
* #reported-pathogen ^designation[+].language = #it-CH
* #reported-pathogen ^designation[=].value = "Agente patogeno notificato"
