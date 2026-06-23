#!/usr/bin/env bash
set -euo pipefail

# Loads the treating-physician example resources into the local HAPI FHIR
# instance (started via ./start_hapi.sh). Waits for the server to be ready,
# then PUTs each resource by id in dependency order.

BASE_URL="${1:-http://localhost:8080/fhir}"
RES_DIR="$(cd "$(dirname "$0")" && pwd)/fsh-generated/resources"

# Resources in dependency order: PractitionerRole references Practitioner and
# Organization, so those must exist first.
RESOURCES=(
  "Practitioner/ChEkmPractitionerTreatingPhysicianExample|Practitioner-ChEkmPractitionerTreatingPhysicianExample.json"
  "Organization/ChEkmOrganizationTreatingPhysicianExample|Organization-ChEkmOrganizationTreatingPhysicianExample.json"
  "PractitionerRole/ChEkmPractitionerRoleTreatingPhysicianExample|PractitionerRole-ChEkmPractitionerRoleTreatingPhysicianExample.json"
  "Patient/ChEkmPatientInitialsExample|Patient-ChEkmPatientInitialsExample.json"
)

echo "Waiting for HAPI FHIR at ${BASE_URL} ..."
until curl -sf -o /dev/null "${BASE_URL}/metadata"; do
  printf '.'
  sleep 5
done
echo " ready."

for entry in "${RESOURCES[@]}"; do
  path="${entry%%|*}"
  file="${entry##*|}"
  echo "PUT ${path}"
  status=$(curl -s -o /tmp/hapi_put_resp.json -w "%{http_code}" \
    -X PUT "${BASE_URL}/${path}" \
    -H "Content-Type: application/fhir+json" \
    -H "Accept: application/fhir+json" \
    --data-binary @"${RES_DIR}/${file}")
  echo "  -> HTTP ${status}"
  if [[ "${status}" != "200" && "${status}" != "201" ]]; then
    echo "  ! failed:"
    cat /tmp/hapi_put_resp.json
    echo
    exit 1
  fi
done

echo "All resources loaded into ${BASE_URL}."
