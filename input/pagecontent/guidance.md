### Personal Data (Patient)
Depending on the disease defined in the code of the Condition, the requirement for how the patient’s personal data, such as name or address, (e.g. Beispielin Muster, Tannenstrasse 10a, 3097 Bern) is reported varies. There are different Patient profiles to be used:
* **Full Name**
   * Disease: Hepatitis C, etc.
   * see Profile [CH EKM Patient](StructureDefinition-ch-ekm-patient.html) 
   * [Example](Patient-ChEkmPatient.json.html): Beispielin Muster (Patient.name.family = Muster, Patient.name.given = Beispielin, where Patient.address.line and Patien.telecom[phone])
* **Initials**
   * Disease: Pneumococcal infectious, etc
   * see Profile [CH EKM Patient Initials](StructureDefinition-ch-ekm-patient-initials.html) 
   * [Example](Patient-ChEkmPatientInitials.json.html): MB (Patient.name.family = M, Patient.name.given = B, no telecom and no street address)
* **VCT Code**
   * Organism: Pending
   * see Profile [CH ELM Patient VCT](StructureDefinition-ChElmPatientVCT.html) 
   * [Example](Patient-ChEkmPatientVCT.json.html): kste12345 (Patient.identifier[LocalPid].system= http://fhir.ch/ig/ch-ekm/identifier/vct Patient.identifier[LocalPid].value=kste12345, Patient.name.family/Patient.name.given = masked, no telecom and no street address)
* **HIV Code**
   * Organism: HIV/AIDS
   * Basic principle: Take the first letter of the first name and add the number of letters of the first name. E.g. Samuel -> S6. This value need to be provided in the [CH EKM Extension: HIV code](StructureDefinition-ch-ekm-ext-hiv-code.html) and Patient.name.family, Patient.name.given need to be masked.
   * see Profile [CH ELM Patient HIV](StructureDefinition-ChEkmPatientHIV.html) 
   * [Example](Patient-ChEkmPatientHIV.json.html): E5 (Patient.name.extension = E5, Patient.name.family/Patient.name.given = masked, no telecom and no street address)
