ValueSet: ChEkmExposureClass
Title: "CH EKM Exposure Class"
Description: "This CH EKM value set includes the HL7 v3 ActClass codes that classify an exposure (mirrors the ActClassExposure value set used by HL7 Europe HDR and US eCR)."
* ^status = #active
* ^experimental = false
* $v3-ActClass#EXPOS "exposure"
* $v3-ActClass#AEXPOS "acquisition exposure"
* $v3-ActClass#TEXPOS "transmission exposure"

ValueSet: ChEkmExposureTransmissionRoute
Title: "CH EKM Exposure Transmission Route"
Description: "This CH EKM value set includes the codes for the likely transmission route (Übertragungsweg)."
* ^status = #active
* ^experimental = false

* $sct#417564009 "Sexual transmission (qualifier value)" // #sexual-contact "Sexual contact with infected person" "Sexualkontakt mit infizierter Person."
* $sct#74964007   "Other (qualifier value)" // #other "Other transmission route" "Anderer Übertragungsweg."
* $sct#261665006  "Unknown (qualifier value)" // #unknown "Unknown" "Unbekannt."

ValueSet: ChEkmExposureRelationshipType
Title: "CH EKM Exposure Relationship Type"
Description: "This CH EKM value set includes the codes for the type of relationship to a sexual contact partner (Art der Beziehung)."
* ^status = #active
* ^experimental = false
* include codes from system ChEkmRelationshipType

ValueSet: ChEkmServiceRequestReason
Title: "CH EKM ServiceRequest Reason"
Description: "This CH EKM value set includes the codes for service request reason."
* ^status = #active
* ^experimental = false

* $sct#171112000 "Screening due (finding)"
* $sct#415684004 "Suspected (qualifier value)"
* $sct#444071008 "Exposure to organism (event)"
* $sct#74964007  "Other (qualifier value)"

ValueSet: ChEkmSpecimenType
Title: "CH EKM Specimen Types"
Description: "This CH EKM value set includes the codes for specimen types."
* ^status = #active
* ^experimental = false

* include codes from valueset $ch-elm-results-complete-spec

ValueSet: ChEkmOtherNoneUnknown
Title: "CH EKM OtherNoneUnknown"
Description: "This CH EKM value set includes the codes for specimen types."
* ^status = #active
* ^experimental = false

* $sct#74964007   "Other (qualifier value)"
* $sct#373572006  "Clinical finding absent (situation)"
* $sct#261665006  "Unknown (qualifier value)"

ValueSet: ChEkmGenderIdentity
Title: "CH EKM Gender Identity"
Description: "This CH EKM value set includes the codes for gender identity."
* ^status = #active
* ^experimental = false

* $sct#1384187000  "Identifies as transgender (finding)"

ValueSet: ChEkmPneumococcalDiseaseManifestation
Title: "CH EKM Pneumococcal Disease Manifestation"
Description: "This CH EKM value set includes the codes for the manifestation of pneumococcal disease."
* ^status = #active
* ^experimental = false

* $sct#448421008 "Sepsis caused by Streptococcus pneumoniae"
* $sct#51169003   "Pneumococcal meningitis"
* $sct#36309003   "Pneumococcal arthritis"
* $sct#233607000  "Pneumococcal pneumonia"

ValueSet: ChEkmHepatitisCManifestation
Title: "CH EKM Hepatitis C Manifestation"
Description: "This CH EKM value set includes the codes for the manifestation of Hepatitis C."
* ^status = #active
* ^experimental = false

* include codes from valueset ChEkmOtherNoneUnknown
* $sct#18165001   "Jaundice"
* $sct#707724006  "Liver enzymes level above reference range"
* $sct#409673008  "Alanine aminotransferase above reference range"
* $sct#166669000  "Aspartate aminotransferase serum level above reference range"

ValueSet: ChEkmHepatitisCCourseOfDisease
Title: "CH EKM HepatitisC CourseOfDisease"
Description: "This CH EKM value set includes the codes for the course of the disease of HepatitisC."
* ^status = #active
* ^experimental = false

* $sct#235866006 "Acute hepatitis C (disorder)" 
* $sct#76783007 "Chronic hepatitis (disorder)"
* $sct#831000119103 "Cirrhosis of liver due to chronic hepatitis C (disorder)"
* $sct#109841003 "Liver cell carcinoma (disorder)"
* $sct#363800008 "General wellbeing"

ValueSet: ChEkmInvasivePneumococcalDiseaseManifestation
Title: "CH EKM InvasivePneumococcalDisease Manifestation"
Description: "This CH EKM value set includes the codes for the manifestation of InvasivePneumococcalDisease."
* ^status = #active
* ^experimental = false

* include codes from valueset ChEkmOtherNoneUnknown
* $sct#233604007 "Pneumonia (disorder)"
* $sct#91302008 "Sepsis (disorder)"
* $sct#7180009 "Meningitis (disorder)"

ValueSet: ChEkmHIVManifestation
Title: "CH EKM HIV Manifestation"
Description: "This CH EKM value set includes the codes for the manifestation of HIV."
* ^status = #active
* ^experimental = false

* $sct#111880001  "Acute human immunodeficiency virus infection"
* $sct#1003683009 "Human immunodeficiency virus Centers for Disease Control and Prevention stage 2"
* $sct#1003684003 "Human immunodeficiency virus Centers for Disease Control and Prevention stage 3"

ValueSet: ChEkmGonorrhoeaManifestation
Title: "CH EKM Gonorrhoea Manifestation"
Description: "This CH EKM value set includes the codes for the manifestation of gonorrhoea."
* ^status = #active
* ^experimental = false

* include codes from system $sct where concept is-a #15628003
* $sct#84387000 "Asymptomatic (finding)"

ValueSet: ChEkmGonorrhoeaManifestationFormChoice
Title: "CH EKM Gonorrhoea Manifestation (Form)"
Description: "Simplified two-option manifestation value set for the Gonorrhoea reporting form: symptomatic / asymptomatic. These codes are a subset of ChEkmGonorrhoeaManifestation, so a form answer is written directly to Condition.evidence.code (no ConceptMap required)."
* ^status = #active
* ^experimental = false
* $sct#264931009 "Symptomatic (qualifier value)"
* $sct#84387000  "Asymptomatic (finding)"

// --- broad clinical manifestation value set (continued) ---
// * $sct#74372003   "Gonorrhea of pharynx"
// * include codes from system $sct where concept is-a #236772009
// * include codes from system $sct where concept is-a #17305005
// * include codes from system $sct where concept is-a #186931002
// * $sct#42746002   "Infection of rectum caused by Neisseria gonorrhoeae"
// * $sct#762257007  "Disseminated infection caused by Neisseria gonorrhoeae"

// Form-facing country value set (Gonorrhoea/CH EKM reporting questionnaires).
// Restricts ch-term bfs-country-codes to the ISO 3166 three-letter (alpha-3) codes via a
// server-side regex filter, removing the alpha-2/alpha-3 duplicate display entries (e.g. CH + CHE
// both render as "Schweiz"). Used only for the nationality/country FORM items; the data profiles
// (e.g. ChEkmPatientInitials address.country countrycode) keep bfs-country-codes unchanged.
// This approach does not work, because the terminology server cannot then filter on the valuesets by text, which is required by the form viewer:
// https://thct8dxx-3000.euw.devtunnels.ms/r4/ValueSet/$expand?url=http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmCountryCodes&filter=Schwei&count=10
// 
// {
//     "resourceType": "OperationOutcome",
//     "issue": [
//         {
//             "severity": "error",
//             "code": "exception",
//             "details": {
//                 "text": "Text Search is not supported"
//             },
//             "diagnostics": "Text Search is not supported"
//         }
//     ]
// }
// ValueSet: ChEkmCountryCodes
// Title: "CH EKM Country Codes (form)"
// Description: "Country value set for CH EKM reporting form items. The ch-term bfs-country-codes value set, restricted to the ISO 3166 alpha-3 (three-letter) codes so each country appears once in the form dropdown."
// * ^status = #active
// * ^experimental = false
// * include codes from system $iso3166 and valueset $bfs-country-codes where code regex "^[A-Za-z]{3}$"
