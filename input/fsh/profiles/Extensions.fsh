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