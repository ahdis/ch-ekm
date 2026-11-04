ValueSet: ChEkmMpoxManifestation
Title: "CH EKM Mpox Manifestation"
Description: "This CH EKM value set includes the codes for the manifestation of Mpox: skin lesions grouped by body site, anogenital symptoms, systemic symptoms, 'asymptomatic', and 'other' (the manifestation is then described as free text in Condition.evidence.code.text). Skin-lesion sites use post-coordinated SNOMED CT expressions (Skin lesion : Finding site = skin structure), aligned with the German DEMIS Mpox notification codes; lesions at other locations use the generic Skin lesion base concept."
* ^status = #active
* ^experimental = false

// Issue #40: "Rückenschmerzen" (161891005 Backache) removed; "Anogenitale Blutungen", "Anogenitale
// Schmerzen", "Asymptomatisch" and "Andere" (with the free text) added. The anogenital codes are the
// ones FOPH chose; their SNOMED CT terms are narrower (rectum and anus / rectum) than the form labels.
// TODO to discuss * include codes from valueset ChEkmOtherNoneUnknown                            // "Keine" (finding absent), "unbekannt" (Unknown) — "Andere" is listed below on its own
* $sct#"95324001:{363698007=280158000}" "Skin lesion of anogenital region"     // Hautläsion genital/anal (Skin lesion : Finding site = Skin of anogenital region)
* $sct#"95324001:{363698007=73897004}"  "Skin lesion of face"                  // Hautläsion Gesicht (Skin lesion : Finding site = Skin of face)
* $sct#"95324001:{363698007=116370005}" "Skin lesion of extremity"             // Hautläsion Extremitäten (Skin lesion : Finding site = Skin of extremity)
* $sct#95324001   "Skin lesion (disorder)"                                     // Hautläsion andere Lokalisationen (generic base)
* $sct#266464001  "Hemorrhage of rectum and anus (disorder)"                   // Anogenitale Blutungen
* $sct#77880009   "Rectal pain (finding)"                                      // Anogenitale Schmerzen
* $sct#30746006   "Lymphadenopathy (disorder)"                                 // Lymphadenopathie
* $sct#68962001   "Myalgia (finding)"                                          // Myalgie
* $sct#25064002   "Headache (finding)"                                         // Kopfschmerzen
* $sct#13791008   "Asthenia (finding)"                                         // Asthenie
* $sct#386661006  "Fever (finding)"                                            // Fieber
* $sct#84387000   "Asymptomatic (finding)"                                     // Asymptomatisch
* $sct#74964007   "Other (qualifier value)"                                    // Andere -> free text "Andere Manifestationen" (evidence.code.text)
