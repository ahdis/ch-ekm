Extension: ChEkmExtHivCode
Id: ch-ekm-ext-hiv-code
Title: "CH EKM Extension: HIV code"
Description: "This CH EKM extension enables to provide the HIV Code."
* ^context[+].type = #element
* ^context[=].expression = "HumanName"
* . ^short = "CH EKM Extension: HIV Code"
* obeys ch-ekm-hiv-check
* value[x] 1..
* value[x] only string
* valueString ^short = "Name of the HIV code"
* valueString ^maxLength = 2

Extension: ChEkmExtExpositionAddress
Id: ch-ekm-ext-exposition-address
Title: "CH EKM Extension: Exposition Address"
Description: "This CH EKM extension enables to provide the exposition address."
* ^context[+].type = #element
* ^context[=].expression = "Observation"
* . ^short = "CH EKM Extension: Exposition Address"
* value[x] 1..
* value[x] only Address
* valueAddress ^short = "Exposition address"