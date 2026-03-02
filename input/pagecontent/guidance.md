### Personal Data (Patient)
Depending on the disease defined in the code of the Condition, the requirement for how the patient’s personal data, such as name or address, (e.g. Beispielin Muster, Tannenstrasse 10a, 3097 Bern) is reported varies. There are different Patient profiles to be used:
* **Full Name**
   * Disease: Hepatitis C, etc.
   * see Profile [CH EKM Patient](StructureDefinition-ch-ekm-patient.html) 
   * [Example](Patient-ChEkmPatient.json.html): Beispielin Muster (Patient.name.family = Muster, Patient.name.given = Beispielin, Patient.address)
* **Initials**
   * Disease: Pneumococcal infectious, etc
   * see Profile [CH EKM Patient Initials](StructureDefinition-ch-ekm-patient-initials.html) 
   * [Example](Patient-ChEkmPatientInitials.json.html): MB (Patient.name.family = M, Patient.name.given = B, no telecom, no street address, no gender identity and no biological sex information)
