#!/usr/bin/env bash
set -euo pipefail

# Loads the treating-physician example resources into a FHIR server. Waits for
# the server to be ready, then PUTs each resource by id in dependency order.
#
# Usage:
#   ./scripts/start_hapi.sh                          
#   ./scripts/load_examples.sh http://localhost:8080/fhir  # -> local HAPI (default)
#   ./scripts/load_examples.sh https://smartforms.ahdis.ch/api/fhir   # -> any other server
#
# The Smart Forms playground needs these resources on whatever server it is
# pointed at (Settings -> Source FHIR server) for %user pre-population to work —
# see forms-summary.md §10.

BASE_URL="${1:-https://smartforms.ahdis.ch/api/fhir}"
RES_DIR="$(cd "$(dirname "$0")/.." && pwd)/fsh-generated/resources"

# Resources in dependency order: PractitionerRole references Practitioner and
# Organization, so those must exist first.
RESOURCES=(
  "Practitioner/ChEkmPractitionerTreatingPhysicianExample|Practitioner-ChEkmPractitionerTreatingPhysicianExample.json"
  "Organization/ChEkmOrganizationTreatingPhysicianExample|Organization-ChEkmOrganizationTreatingPhysicianExample.json"
  "PractitionerRole/ChEkmPractitionerRoleTreatingPhysicianExample|PractitionerRole-ChEkmPractitionerRoleTreatingPhysicianExample.json"
  "Patient/ChEkmPatientInitialsExample|Patient-ChEkmPatientInitialsExample.json"
  "Patient/ChEkmPatientDupontAntoine|Patient-ChEkmPatientDupontAntoine.json")

echo "Waiting for FHIR server at ${BASE_URL} ..."
until curl -sf -o /dev/null "${BASE_URL}/metadata"; do
  printf '.'
  sleep 5
done
echo " ready."

for entry in "${RESOURCES[@]}"; do
  path="${entry%%|*}"
  file="${entry##*|}"
  echo "PUT ${path}"
  status=$(curl -s -o /tmp/put_resp.json -w "%{http_code}" \
    -X PUT "${BASE_URL}/${path}" \
    -H "Content-Type: application/fhir+json" \
    -H "Accept: application/fhir+json" \
    --data-binary @"${RES_DIR}/${file}")
  echo "  -> HTTP ${status}"
  if [[ "${status}" != "200" && "${status}" != "201" ]]; then
    echo "  ! failed:"
    cat /tmp/put_resp.json
    echo
    exit 1
  fi
done

echo "All resources loaded into ${BASE_URL}."
