# CH EKM (R4)
FHIR® Implementation Guide for the EKM (Elektronische klinische Meldung) of the Swiss Federal Office of Public Health (FOPH).

* [CI Build](https://build.fhir.org/ig/ahdis/ch-ekm/branches/master/index.html)

## Terminology handling

Terminology is handled by the FOPH directly on the ABN environment.

To update the current ValueSets and CodeSystem in the FHIR Implementation Guide there is a script in tests/updateterminolgy.sh which will call the ABN environment API and copy the resources into the input\resources folder. 