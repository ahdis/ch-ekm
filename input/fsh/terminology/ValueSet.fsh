ValueSet: ChEkmBiologicalSex
Title: "CH EKM Biological Sex"
Description: "This CH EKM value set includes the codes for biological sex."
* ^status = #active

* $sct#248152002 "Female (finding)"
* $sct#248153007 "Male (finding)"
* $sct#32570681000036106 "Indeterminate sex (finding)"
* $sct#32570691000036108 "Intersex (finding)"

Instance: ChEkmSexToHl7Gender
InstanceOf: ConceptMap
Title: "Mapping CH EKM Biological Sex to HL7 Administrative Gender"
Usage: #definition

* status = #active
* sourceUri = "http://fhir.ch/ig/ch-ekm/ValueSet/ChEkmBiologicalSex"
* targetUri = "http://hl7.org/fhir/ValueSet/administrative-gender"

* group[0].source = "http://snomed.info/sct"
* group[0].target = "http://hl7.org/fhir/administrative-gender"

* group[0].element[0].code = #248152002
* group[0].element[0].target[0].code = #female
* group[0].element[0].target[0].equivalence = #equal

* group[0].element[1].code = #248153007
* group[0].element[1].target[0].code = #male
* group[0].element[1].target[0].equivalence = #equal

* group[0].element[2].code = #32570681000036106
* group[0].element[2].target[0].code = #other
* group[0].element[2].target[0].equivalence = #wider

* group[0].element[3].code = #32570691000036108
* group[0].element[3].target[0].code = #other
* group[0].element[3].target[0].equivalence = #wider