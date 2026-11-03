Logical: ChEkmManifestationForm
Parent: Base
Title: "CH EKM Form: Diagnosis and Manifestation"
Description: "Logical model for the form section 'Diagnosis and manifestation' (German form: 'Diagnose und Manifestation') in the clinical findings report. One element per form item."
Characteristics: #can-be-target

* manifestation 0..* CodeableConcept "Manifestations"
* manifestationOther 0..1 string "Other (free text)"
* manifestationBeginDate 0..1 dateTime "Onset of manifestation - date"
* manifestationBeginUnknown 0..1 Coding "Onset of manifestation - unknown" "The 'unknown' tick box under the date (issue #41): ticked = SNOMED CT 261665006 'Unknown', otherwise not answered. Offered only while no date is entered."
* manifestationBeginUnknown from ChEkmUnknown (required)


Mapping: ManifestationToCondition
Source: ChEkmManifestationForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-condition"
Id: manifestation-to-condition
Title: "Manifestation Form to CH EKM Condition"
* -> "Condition" "Maps the form section to the ChEkmCondition profile"
* manifestation -> "Condition.evidence.code" "Manifestation coded from ChEkmManifestation"
* manifestationOther -> "Condition.evidence.code.text" "Free text for 'other'"
* manifestationBeginDate -> "Condition.onsetDateTime"
* manifestationBeginUnknown -> "Condition.onsetDateTime.extension[dataabsentreason]" "data-absent-reason #asked-unknown when the begin date is explicitly not known (and no date is given)"
