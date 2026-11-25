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
// The contact questions of the "Wie" (issue #44). SNOMED CT has no disease-agnostic concept for them
// (only pathogen-bound ones such as "Occupational exposure to monkeypox virus"), hence local codes;
// the disease the case had is the one the report is about.
// "Andere Übertragungswege": ONE question, answered by picking one of the codes of ChEkmContactRoute
// (contact as medical / nursing staff, in the household).
* #contact-route "Route of transmission through contact" "Other route of transmission through contact (Andere Übertragungswege); the value names the contact, from ChEkmContactRoute."
* #contact-route ^designation[+].language = #de-CH
* #contact-route ^designation[=].value = "Andere Übertragungswege"
* #contact-route ^designation[+].language = #fr-CH
* #contact-route ^designation[=].value = "Autres voies de transmission"
* #contact-route ^designation[+].language = #it-CH
* #contact-route ^designation[=].value = "Altre vie di trasmissione"
// "Kontakt mit laborbestätigtem Fall": a closed question of its own, answered yes / no / unknown
// (ChEkmYesNoUnknown).
* #confirmed-case-contact "Contact with a laboratory-confirmed case" "Exposure through contact with a laboratory-confirmed case of the disease this report is about."
* #confirmed-case-contact ^designation[+].language = #de-CH
* #confirmed-case-contact ^designation[=].value = "Kontakt mit laborbestätigtem Fall"
* #confirmed-case-contact ^designation[+].language = #fr-CH
* #confirmed-case-contact ^designation[=].value = "Contact avec un cas confirmé en laboratoire"
* #confirmed-case-contact ^designation[+].language = #it-CH
* #confirmed-case-contact ^designation[=].value = "Contatto con un caso confermato in laboratorio"
// "Berufliche Tätigkeit" (issue #48): the group of occupations the person works in, as far as it
// matters for the exposure; the value is a code of ChEkmOccupationalActivity or "unknown".
* #occupational-activity "Occupational activity" "The group of occupations the person works in, classified by how close the contact with other people is (Berufliche Tätigkeit); the value names the group, from ChEkmOccupationalActivity."
* #occupational-activity ^designation[+].language = #de-CH
* #occupational-activity ^designation[=].value = "Berufliche Tätigkeit"
* #occupational-activity ^designation[+].language = #fr-CH
* #occupational-activity ^designation[=].value = "Activité professionnelle"
* #occupational-activity ^designation[+].language = #it-CH
* #occupational-activity ^designation[=].value = "Attività professionale"

// The answers of "Andere Übertragungswege" (issue #44): one of them is picked (radio buttons, like
// "Art der Beziehung"), so they are VALUES of the component ChEkmExposureComponent#contact-route,
// not component codes of their own. No "unknown": the question is optional, unanswered = absent.
CodeSystem: ChEkmContactRoute
Id: ch-ekm-contact-route
Title: "CH EKM Contact Route"
Description: "Other routes of transmission through contact (Andere Übertragungswege): contact as medical / nursing staff, contact in the household."
* ^status = #active
* ^experimental = false
* ^caseSensitive = true
* #healthcare-worker-contact "Contact as medical / nursing staff" "Exposure through contact in the person's work as medical or nursing staff."
* #healthcare-worker-contact ^designation[+].language = #de-CH
* #healthcare-worker-contact ^designation[=].value = "Kontakt als Medizinal- / Pflegepersonal"
* #healthcare-worker-contact ^designation[+].language = #fr-CH
* #healthcare-worker-contact ^designation[=].value = "Contact en tant que personnel médical / soignant"
* #healthcare-worker-contact ^designation[+].language = #it-CH
* #healthcare-worker-contact ^designation[=].value = "Contatto in qualità di personale medico / sanitario"
* #household-contact "Contact in the household" "Exposure through contact within the person's household."
* #household-contact ^designation[+].language = #de-CH
* #household-contact ^designation[=].value = "Kontakt im Haushalt"
* #household-contact ^designation[+].language = #fr-CH
* #household-contact ^designation[=].value = "Contact dans le ménage"
* #household-contact ^designation[+].language = #it-CH
* #household-contact ^designation[=].value = "Contatto nell'economia domestica"

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


// The answers of "Berufliche Tätigkeit" (issue #48), without "unknown" (sct#261665006, added by the
// value set ChEkmExposureOccupationalActivity).
//
// LOCAL CODES ALTHOUGH SNOMED CT HAS OCCUPATIONS. The five answers are not occupations but groups of
// them, cut by one criterion: how close the contact with other people is. SNOMED CT (International
// Edition 2026-11-01) covers that only in part:
//   healthcare-nursing       223366009 "Healthcare professional" fits.
//   sex-work                 449344001 "Sex worker" fits.
//   close-contact-services   no concept. The nearest, 308219004 "Personal services occupation", is
//                            the PARENT of "Sex worker", so the two answers would overlap.
//   care-education           229774002 "Caregiver occupation" is the care half only; teaching is
//                            307972006 "Education profession", and their common ancestor 265930003
//                            "Education/welfare/health profession" also contains healthcare.
//   no-close-contact         no concept; a group defined by what it is not.
// A value set with two exact SNOMED CT codes, one too narrow and two local ones would be harder to
// evaluate than five codes that mean exactly what the form says, and the SNOMED CT hierarchy would
// suggest subsumptions the form does not intend. Hence one local code system for all five.
CodeSystem: ChEkmOccupationalActivity
Id: ch-ekm-occupational-activity
Title: "CH EKM Occupational Activity"
Description: "Groups of occupations by how close the contact with other people is (Berufliche Tätigkeit): healthcare and nursing, sex work, services involving close physical contact, supervision and education, occupation without close contact with other people."
* ^status = #active
* ^experimental = false
* ^caseSensitive = true
* #healthcare-nursing "Healthcare and nursing" "The person works in healthcare or nursing."
* #healthcare-nursing ^designation[+].language = #de-CH
* #healthcare-nursing ^designation[=].value = "Gesundheitswesen und Pflege"
* #healthcare-nursing ^designation[+].language = #fr-CH
* #healthcare-nursing ^designation[=].value = "Santé et soins"
* #healthcare-nursing ^designation[+].language = #it-CH
* #healthcare-nursing ^designation[=].value = "Sanità e assistenza"
* #sex-work "Sex work" "The person works as a sex worker."
* #sex-work ^designation[+].language = #de-CH
* #sex-work ^designation[=].value = "Sexarbeit"
* #sex-work ^designation[+].language = #fr-CH
* #sex-work ^designation[=].value = "Travail du sexe"
* #sex-work ^designation[+].language = #it-CH
* #sex-work ^designation[=].value = "Lavoro sessuale"
* #close-contact-services "Services involving close physical contact" "The person provides services that involve close physical contact, other than healthcare, nursing and sex work."
* #close-contact-services ^designation[+].language = #de-CH
* #close-contact-services ^designation[=].value = "Dienstleistungen mit engem Körperkontakt"
* #close-contact-services ^designation[+].language = #fr-CH
* #close-contact-services ^designation[=].value = "Services impliquant un contact physique rapproché"
* #close-contact-services ^designation[+].language = #it-CH
* #close-contact-services ^designation[=].value = "Servizi che comportano uno stretto contatto fisico"
* #care-education "Supervision and education" "The person works in the supervision, care or education of other people."
* #care-education ^designation[+].language = #de-CH
* #care-education ^designation[=].value = "Betreuung und Bildung"
* #care-education ^designation[+].language = #fr-CH
* #care-education ^designation[=].value = "Encadrement et éducation"
* #care-education ^designation[+].language = #it-CH
* #care-education ^designation[=].value = "Assistenza e istruzione"
* #no-close-contact "Occupation without close contact with other people" "The person's occupation involves no close contact with other people."
* #no-close-contact ^designation[+].language = #de-CH
* #no-close-contact ^designation[=].value = "Berufliche Tätigkeit ohne engen Personenkontakt"
* #no-close-contact ^designation[+].language = #fr-CH
* #no-close-contact ^designation[=].value = "Activité professionnelle sans contact étroit avec d’autres personnes"
* #no-close-contact ^designation[+].language = #it-CH
* #no-close-contact ^designation[=].value = "Attività professionale senza contatti stretti con altre persone"
