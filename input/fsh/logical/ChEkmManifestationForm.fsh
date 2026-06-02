Logical: ChEkmManifestationForm
Parent: Base
Id: ch-ekm-manifestation-form
Title: "CH EKM Form: Diagnose und Manifestation"
Description: "Logical model for the form section 'Diagnose und Manifestation' in the clinical findings report. One element per form item."
Characteristics: #can-be-target

* manifestation 0..* CodeableConcept "Manifestationen"
* manifestationOther 0..1 string "andere (Freitext)"
* manifestationBeginDate 0..1 dateTime "Manifestationsbeginn - Datum"
* manifestationBeginUnknown 0..1 boolean "Manifestationsbeginn - unbekannt"


Mapping: ManifestationToCondition
Source: ChEkmManifestationForm
Target: "http://fhir.ch/ig/ch-ekm/StructureDefinition/ch-ekm-condition"
Id: manifestation-to-condition
Title: " Manifestation Form to CH EKM Condition"
* -> "Condition" "Maps the form section to the ChEkmCondition profile"
* manifestation -> "Condition.evidence.code" "Manifestation coded from ChEkmManifestation"
* manifestationOther -> "Condition.evidence.code.text" "Free text for 'andere'"
* manifestationBeginDate -> "Condition.onsetDateTime"
* manifestationBeginUnknown -> "Condition.onsetDateTime.extension[dataabsentreason]" "data-absent-reason #unknown when the begin date is explicitly not known"

