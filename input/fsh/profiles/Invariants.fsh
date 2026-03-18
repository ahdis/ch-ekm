
Invariant: name-initials
Description: "a name with initials"
Severity: #error
Expression: "given.exists() and given.first().exists() and (''+given.first()).length() = 1 and family.exists() and (''+family).length() = 1"

Invariant: ch-ekm-hiv-check
Description: "invalid hiv code: 1) either start with a letter or the number 0, 2) be a maximum of 2 characters long, 3) have a number in the last place 4) if it starts with 0, it must either consist only of 0 or be followed by a 1."
Severity: #error
Expression: "value.matches('^[A-Za-z][0-9]$|^0$|^01$')"

