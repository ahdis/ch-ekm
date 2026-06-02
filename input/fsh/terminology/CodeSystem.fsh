CodeSystem: ChEkmExposureComponent
Id: ch-ekm-exposure-component
Title: "CH EKM Exposure Component"
Description: "Internal code system used as discriminator for the components of a CH EKM Exposure observation. Used because no suitable standard code exists for these structural roles."
* ^status = #active
* ^experimental = false
* ^caseSensitive = true
// * #transmission-route "Transmission route" "The likely route of transmission."
* #sexual-contact-partner "Sexual contact partner" "Sex/gender of the infected person the patient had sexual contact with."
// * #relationship-type "Type of relationship" "Type of the relationship to the sexual contact partner."

CodeSystem: ChEkmRelationshipType
Id: ch-ekm-relationship-type
Title: "CH EKM Relationship Type"
Description: "Type of relationship to a sexual contact partner (Art der Beziehung). Suggestesd list as of June 1st"
* ^status = #active
* ^experimental = false
* ^caseSensitive = true
* #steady-partner "Steady partner" "Fester Partner."
* #non-steady-partner "Non-steady partner" "Nicht fester Partner."
* #offered-paid-sex "Offered paid sex" "Angebot von bezahltem Sex."
* #used-paid-sex "Used paid sex" "Inanspruchnahme von bezahltem Sex."