CodeSystem: ChEkmAdministrativeGenderLanguageSupplement
Id: ch-ekm-administrative-gender-language-supplement
Title: "CH EKM Administrative Gender Language Supplement (de/fr/it)"
Description: "CodeSystem supplement adding German, French and Italian (Swiss) display designations to the HL7 administrative-gender codes, for localized Questionnaire option labels via displayLanguage expansion."
* ^status = #active
* ^experimental = false
* ^content = #supplement
* ^supplements = $administrative-gender

* #male "Male"
* #male ^designation[+].language = #de-CH
* #male ^designation[=].value = "männlich"
* #male ^designation[+].language = #fr-CH
* #male ^designation[=].value = "masculin"
* #male ^designation[+].language = #it-CH
* #male ^designation[=].value = "maschile"

* #female "Female"
* #female ^designation[+].language = #de-CH
* #female ^designation[=].value = "weiblich"
* #female ^designation[+].language = #fr-CH
* #female ^designation[=].value = "féminin"
* #female ^designation[+].language = #it-CH
* #female ^designation[=].value = "femminile"

* #other "Other"
* #other ^designation[+].language = #de-CH
* #other ^designation[=].value = "anderes"
* #other ^designation[+].language = #fr-CH
* #other ^designation[=].value = "autre"
* #other ^designation[+].language = #it-CH
* #other ^designation[=].value = "altro"

* #unknown "Unknown"
* #unknown ^designation[+].language = #de-CH
* #unknown ^designation[=].value = "unbekannt"
* #unknown ^designation[+].language = #fr-CH
* #unknown ^designation[=].value = "inconnu"
* #unknown ^designation[+].language = #it-CH
* #unknown ^designation[=].value = "sconosciuto"


// ============================================================================================
// SNOMED CT language supplement — de-CH / fr-CH / it-CH for the SNOMED codes enumerated in
// input/fsh/terminology/ValueSet.fsh (the explicitly listed `$sct#...` concepts; is-a filter /
// included-value-set codes are out of scope).
//
// ⚠️ DRAFT TRANSLATIONS — NOT VALIDATED. These de/fr/it values are best-effort and MUST be
// reviewed against the official SNOMED CT Swiss extension (de-CH/fr-CH/it-CH) designations before
// any production use. Mistranslated clinical terms are a patient-safety risk. Where a SNOMED CH
// designation exists, prefer it over the value below.
//
// Applied the same way as the administrative-gender supplement: expand the value set with
// displayLanguage + useSupplement = this supplement (or supply it inline as a tx-resource).
// ============================================================================================
CodeSystem: ChEkmSnomedLanguageSupplement
Id: ch-ekm-snomed-language-supplement
Title: "CH EKM SNOMED CT Language Supplement (de/fr/it)"
Description: "CodeSystem supplement adding draft German, French and Italian (Swiss) display designations to the SNOMED CT codes used by the CH EKM value sets. DRAFT — validate against the official SNOMED CT Swiss extension before production use."
* ^status = #active
* ^experimental = false
* ^content = #supplement
* ^supplements = $sct

* #417564009 "Sexual transmission (qualifier value)"
* #417564009 ^designation[+].language = #de-CH
* #417564009 ^designation[=].value = "Sexuelle Übertragung"
* #417564009 ^designation[+].language = #fr-CH
* #417564009 ^designation[=].value = "Transmission sexuelle"
* #417564009 ^designation[+].language = #it-CH
* #417564009 ^designation[=].value = "Trasmissione sessuale"

* #74964007 "Other (qualifier value)"
* #74964007 ^designation[+].language = #de-CH
* #74964007 ^designation[=].value = "Andere"
* #74964007 ^designation[+].language = #fr-CH
* #74964007 ^designation[=].value = "Autre"
* #74964007 ^designation[+].language = #it-CH
* #74964007 ^designation[=].value = "Altro"

* #261665006 "Unknown (qualifier value)"
* #261665006 ^designation[+].language = #de-CH
* #261665006 ^designation[=].value = "Unbekannt"
* #261665006 ^designation[+].language = #fr-CH
* #261665006 ^designation[=].value = "Inconnu"
* #261665006 ^designation[+].language = #it-CH
* #261665006 ^designation[=].value = "Sconosciuto"

* #171112000 "Screening due (finding)"
* #171112000 ^designation[+].language = #de-CH
* #171112000 ^designation[=].value = "Screening fällig"
* #171112000 ^designation[+].language = #fr-CH
* #171112000 ^designation[=].value = "Dépistage à effectuer"
* #171112000 ^designation[+].language = #it-CH
* #171112000 ^designation[=].value = "Screening da effettuare"

* #415684004 "Suspected (qualifier value)"
* #415684004 ^designation[+].language = #de-CH
* #415684004 ^designation[=].value = "Verdacht"
* #415684004 ^designation[+].language = #fr-CH
* #415684004 ^designation[=].value = "Suspecté"
* #415684004 ^designation[+].language = #it-CH
* #415684004 ^designation[=].value = "Sospetto"

* #444071008 "Exposure to organism (event)"
* #444071008 ^designation[+].language = #de-CH
* #444071008 ^designation[=].value = "Exposition gegenüber einem Erreger"
* #444071008 ^designation[+].language = #fr-CH
* #444071008 ^designation[=].value = "Exposition à un organisme"
* #444071008 ^designation[+].language = #it-CH
* #444071008 ^designation[=].value = "Esposizione a un organismo"

* #373572006 "Clinical finding absent (situation)"
* #373572006 ^designation[+].language = #de-CH
* #373572006 ^designation[=].value = "Klinischer Befund nicht vorhanden"
* #373572006 ^designation[+].language = #fr-CH
* #373572006 ^designation[=].value = "Constatation clinique absente"
* #373572006 ^designation[+].language = #it-CH
* #373572006 ^designation[=].value = "Reperto clinico assente"

* #1384187000 "Identifies as transgender (finding)"
* #1384187000 ^designation[+].language = #de-CH
* #1384187000 ^designation[=].value = "Identifiziert sich als Transgender"
* #1384187000 ^designation[+].language = #fr-CH
* #1384187000 ^designation[=].value = "S'identifie comme transgenre"
* #1384187000 ^designation[+].language = #it-CH
* #1384187000 ^designation[=].value = "Si identifica come transgender"

* #448421008 "Sepsis caused by Streptococcus pneumoniae"
* #448421008 ^designation[+].language = #de-CH
* #448421008 ^designation[=].value = "Sepsis durch Streptococcus pneumoniae"
* #448421008 ^designation[+].language = #fr-CH
* #448421008 ^designation[=].value = "Sepsis causé par Streptococcus pneumoniae"
* #448421008 ^designation[+].language = #it-CH
* #448421008 ^designation[=].value = "Sepsi causata da Streptococcus pneumoniae"

* #51169003 "Pneumococcal meningitis"
* #51169003 ^designation[+].language = #de-CH
* #51169003 ^designation[=].value = "Pneumokokken-Meningitis"
* #51169003 ^designation[+].language = #fr-CH
* #51169003 ^designation[=].value = "Méningite à pneumocoques"
* #51169003 ^designation[+].language = #it-CH
* #51169003 ^designation[=].value = "Meningite pneumococcica"

* #36309003 "Pneumococcal arthritis"
* #36309003 ^designation[+].language = #de-CH
* #36309003 ^designation[=].value = "Pneumokokken-Arthritis"
* #36309003 ^designation[+].language = #fr-CH
* #36309003 ^designation[=].value = "Arthrite à pneumocoques"
* #36309003 ^designation[+].language = #it-CH
* #36309003 ^designation[=].value = "Artrite pneumococcica"

* #233607000 "Pneumococcal pneumonia"
* #233607000 ^designation[+].language = #de-CH
* #233607000 ^designation[=].value = "Pneumokokken-Pneumonie"
* #233607000 ^designation[+].language = #fr-CH
* #233607000 ^designation[=].value = "Pneumonie à pneumocoques"
* #233607000 ^designation[+].language = #it-CH
* #233607000 ^designation[=].value = "Polmonite pneumococcica"

* #18165001 "Jaundice"
* #18165001 ^designation[+].language = #de-CH
* #18165001 ^designation[=].value = "Ikterus"
* #18165001 ^designation[+].language = #fr-CH
* #18165001 ^designation[=].value = "Ictère"
* #18165001 ^designation[+].language = #it-CH
* #18165001 ^designation[=].value = "Ittero"

* #707724006 "Liver enzymes level above reference range"
* #707724006 ^designation[+].language = #de-CH
* #707724006 ^designation[=].value = "Leberenzyme über dem Referenzbereich"
* #707724006 ^designation[+].language = #fr-CH
* #707724006 ^designation[=].value = "Taux d'enzymes hépatiques supérieur à la valeur de référence"
* #707724006 ^designation[+].language = #it-CH
* #707724006 ^designation[=].value = "Livello degli enzimi epatici superiore all'intervallo di riferimento"

* #409673008 "Alanine aminotransferase above reference range"
* #409673008 ^designation[+].language = #de-CH
* #409673008 ^designation[=].value = "Alanin-Aminotransferase über dem Referenzbereich"
* #409673008 ^designation[+].language = #fr-CH
* #409673008 ^designation[=].value = "Alanine aminotransférase supérieure à la valeur de référence"
* #409673008 ^designation[+].language = #it-CH
* #409673008 ^designation[=].value = "Alanina aminotransferasi superiore all'intervallo di riferimento"

* #166669000 "Aspartate aminotransferase serum level above reference range"
* #166669000 ^designation[+].language = #de-CH
* #166669000 ^designation[=].value = "Aspartat-Aminotransferase im Serum über dem Referenzbereich"
* #166669000 ^designation[+].language = #fr-CH
* #166669000 ^designation[=].value = "Taux sérique d'aspartate aminotransférase supérieur à la valeur de référence"
* #166669000 ^designation[+].language = #it-CH
* #166669000 ^designation[=].value = "Livello sierico di aspartato aminotransferasi superiore all'intervallo di riferimento"

* #235866006 "Acute hepatitis C (disorder)"
* #235866006 ^designation[+].language = #de-CH
* #235866006 ^designation[=].value = "Akute Hepatitis C"
* #235866006 ^designation[+].language = #fr-CH
* #235866006 ^designation[=].value = "Hépatite C aiguë"
* #235866006 ^designation[+].language = #it-CH
* #235866006 ^designation[=].value = "Epatite C acuta"

* #76783007 "Chronic hepatitis (disorder)"
* #76783007 ^designation[+].language = #de-CH
* #76783007 ^designation[=].value = "Chronische Hepatitis"
* #76783007 ^designation[+].language = #fr-CH
* #76783007 ^designation[=].value = "Hépatite chronique"
* #76783007 ^designation[+].language = #it-CH
* #76783007 ^designation[=].value = "Epatite cronica"

* #831000119103 "Cirrhosis of liver due to chronic hepatitis C (disorder)"
* #831000119103 ^designation[+].language = #de-CH
* #831000119103 ^designation[=].value = "Leberzirrhose infolge chronischer Hepatitis C"
* #831000119103 ^designation[+].language = #fr-CH
* #831000119103 ^designation[=].value = "Cirrhose du foie due à une hépatite C chronique"
* #831000119103 ^designation[+].language = #it-CH
* #831000119103 ^designation[=].value = "Cirrosi epatica dovuta a epatite C cronica"

* #109841003 "Liver cell carcinoma (disorder)"
* #109841003 ^designation[+].language = #de-CH
* #109841003 ^designation[=].value = "Leberzellkarzinom"
* #109841003 ^designation[+].language = #fr-CH
* #109841003 ^designation[=].value = "Carcinome hépatocellulaire"
* #109841003 ^designation[+].language = #it-CH
* #109841003 ^designation[=].value = "Carcinoma epatocellulare"

* #363800008 "General wellbeing"
* #363800008 ^designation[+].language = #de-CH
* #363800008 ^designation[=].value = "Allgemeines Wohlbefinden"
* #363800008 ^designation[+].language = #fr-CH
* #363800008 ^designation[=].value = "Bien-être général"
* #363800008 ^designation[+].language = #it-CH
* #363800008 ^designation[=].value = "Benessere generale"

* #233604007 "Pneumonia (disorder)"
* #233604007 ^designation[+].language = #de-CH
* #233604007 ^designation[=].value = "Pneumonie"
* #233604007 ^designation[+].language = #fr-CH
* #233604007 ^designation[=].value = "Pneumonie"
* #233604007 ^designation[+].language = #it-CH
* #233604007 ^designation[=].value = "Polmonite"

* #91302008 "Sepsis (disorder)"
* #91302008 ^designation[+].language = #de-CH
* #91302008 ^designation[=].value = "Sepsis"
* #91302008 ^designation[+].language = #fr-CH
* #91302008 ^designation[=].value = "Sepsis"
* #91302008 ^designation[+].language = #it-CH
* #91302008 ^designation[=].value = "Sepsi"

* #7180009 "Meningitis (disorder)"
* #7180009 ^designation[+].language = #de-CH
* #7180009 ^designation[=].value = "Meningitis"
* #7180009 ^designation[+].language = #fr-CH
* #7180009 ^designation[=].value = "Méningite"
* #7180009 ^designation[+].language = #it-CH
* #7180009 ^designation[=].value = "Meningite"

* #111880001 "Acute human immunodeficiency virus infection"
* #111880001 ^designation[+].language = #de-CH
* #111880001 ^designation[=].value = "Akute HIV-Infektion"
* #111880001 ^designation[+].language = #fr-CH
* #111880001 ^designation[=].value = "Infection aiguë par le VIH"
* #111880001 ^designation[+].language = #it-CH
* #111880001 ^designation[=].value = "Infezione acuta da HIV"

* #1003683009 "Human immunodeficiency virus Centers for Disease Control and Prevention stage 2"
* #1003683009 ^designation[+].language = #de-CH
* #1003683009 ^designation[=].value = "HIV CDC-Stadium 2"
* #1003683009 ^designation[+].language = #fr-CH
* #1003683009 ^designation[=].value = "VIH stade 2 selon les CDC"
* #1003683009 ^designation[+].language = #it-CH
* #1003683009 ^designation[=].value = "HIV stadio 2 secondo i CDC"

* #1003684003 "Human immunodeficiency virus Centers for Disease Control and Prevention stage 3"
* #1003684003 ^designation[+].language = #de-CH
* #1003684003 ^designation[=].value = "HIV CDC-Stadium 3"
* #1003684003 ^designation[+].language = #fr-CH
* #1003684003 ^designation[=].value = "VIH stade 3 selon les CDC"
* #1003684003 ^designation[+].language = #it-CH
* #1003684003 ^designation[=].value = "HIV stadio 3 secondo i CDC"

* #264931009 "Symptomatic (qualifier value)"
* #264931009 ^designation[+].language = #de-CH
* #264931009 ^designation[=].value = "Symptomatisch"
* #264931009 ^designation[+].language = #fr-CH
* #264931009 ^designation[=].value = "Symptomatique"
* #264931009 ^designation[+].language = #it-CH
* #264931009 ^designation[=].value = "Sintomatico"

* #84387000 "Asymptomatic (finding)"
* #84387000 ^designation[+].language = #de-CH
* #84387000 ^designation[=].value = "Asymptomatisch"
* #84387000 ^designation[+].language = #fr-CH
* #84387000 ^designation[=].value = "Asymptomatique"
* #84387000 ^designation[+].language = #it-CH
* #84387000 ^designation[=].value = "Asintomatico"
