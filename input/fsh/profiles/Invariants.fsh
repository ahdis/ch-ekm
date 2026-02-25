
Invariant: name-initials
Description: "a name with initials"
Severity: #error
Expression: "given.exists() and given.first().exists() and (''+given.first()).length() = 1 and family.exists() and (''+family).length() = 1"


Invariant: ch-elm-dateTime
Description: "At least the format YYYY-MM-DD is required."
Severity: #error
Expression: "$this.toString().length() >= 10"

Invariant: ch-ekm-gender-sync
Description: "Administrative gender must be synchronized with biologicalSex (priority) or biologicalSexAtBirth."
Severity: #error
Expression: "((extension('http://hl7.org/fhir/StructureDefinition/individual-recordedSexOrGender').where(type.coding.code = '46098-0').exists()) or (extension('http://hl7.org/fhir/StructureDefinition/individual-recordedSexOrGender').where(type.coding.code = '76689-9').exists())) implies (let sourceCode = iif(extension('http://hl7.org/fhir/StructureDefinition/individual-recordedSexOrGender').where(type.coding.code = '46098-0').exists(), extension('http://hl7.org/fhir/StructureDefinition/individual-recordedSexOrGender').where(type.coding.code = '46098-0').value.coding.code, extension('http://hl7.org/fhir/StructureDefinition/individual-recordedSexOrGender').where(type.coding.code = '76689-9').value.coding.code) in ((sourceCode = '248153007' implies gender = 'male') and (sourceCode = '248152002' implies gender = 'female') and ((sourceCode = '32570681000036106' or sourceCode = '32570691000036108') implies gender = 'other')) )"