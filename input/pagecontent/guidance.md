
### Personal Data (Patient)
Depending on the organism (leading code), the requirement for how the patient’s personal data, such as name or address, (e.g. Beispielin Muster, Tannenstrasse 10a, 3097 Bern) is reported varies. There are different Patient profiles to be used:
* **Full Name**
   * Organism: Hepatitis C, etc.
   * see Profile [CH EKM Patient](StructureDefinition-ch-ekm-patient.html) 
   * [Example](Patient-ChEkmPatient.json.html): Beispielin Muster (Patient.name.family = Muster, Patient.name.given = Beispielin, Patient.address)
* **Initials**
   * Organism: Pneumococcal infectious, etc
   * see Profile [CH ELM Patient Initials](StructureDefinition-ch-ekm-patient-initials.html) 
   * [Example](Patient-ChEkmPatientInitials.json.html): MB (Patient.name.family = M, Patient.name.given = B, no telecom and no street address)
