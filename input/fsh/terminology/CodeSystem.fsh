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

CodeSystem: ChEkmLaunchContext
Id: ch-ekm-launch-context
Title: "CH EKM Launch Context"
Description: "Custom SDC launch-context names used by CH EKM questionnaires where no standard SDC launchContext code applies. Currently only the sending/treating Organization (no standard SDC launchContext code covers Organization)."
* ^status = #active
* ^experimental = false
* ^caseSensitive = true
* #organization "Organization" "The sending/treating organization to pre-populate the form with."