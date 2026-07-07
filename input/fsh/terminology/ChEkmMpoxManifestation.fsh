ValueSet: ChEkmMpoxManifestation
Title: "CH EKM Mpox Manifestation"
Description: "This CH EKM value set includes the codes for the manifestation of Mpox: skin lesions grouped by body site plus systemic symptoms. Skin-lesion sites use post-coordinated SNOMED CT expressions (Skin lesion : Finding site = <skin structure>), aligned with the German DEMIS Mpox notification codes; lesions at other locations use the generic Skin lesion base concept (a specific site can be captured in Condition.evidence.code.text)."
* ^status = #active
* ^experimental = false

* include codes from valueset ChEkmOtherNoneUnknown                            // "andere" (Other), "Keine" (finding absent), "unbekannt" (Unknown)
* $sct#"95324001:{363698007=280158000}" "Skin lesion of anogenital region"     // Hautläsion genital/anal (Skin lesion : Finding site = Skin of anogenital region)
* $sct#"95324001:{363698007=73897004}"  "Skin lesion of face"                  // Hautläsion Gesicht (Skin lesion : Finding site = Skin of face)
* $sct#"95324001:{363698007=116370005}" "Skin lesion of extremity"             // Hautläsion Extremitäten (Skin lesion : Finding site = Skin of extremity)
* $sct#95324001   "Skin lesion (disorder)"                                     // Hautläsion andere Lokalisationen (generic base; specific site -> evidence.code.text)
* $sct#30746006   "Lymphadenopathy (disorder)"                                 // Lymphadenopathie
* $sct#68962001   "Myalgia (finding)"                                          // Myalgie
* $sct#25064002   "Headache (finding)"                                         // Kopfschmerzen
* $sct#161891005  "Backache"                                                   // Rückenschmerzen
* $sct#13791008   "Asthenia (finding)"                                         // Asthenie
* $sct#386661006  "Fever (finding)"                                            // Fieber