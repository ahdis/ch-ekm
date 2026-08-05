#!/usr/bin/env bash
#
# Starts a local HAPI FHIR server at http://localhost:8080/fhir, preloaded with the IG package
# so the CH EKM profiles are known to it.
#
# Needed for pre-population: %user.practitioner.resolve() / %user.organization.resolve() do a
# real HTTP fetch, so both scripts/populate-gonorrhoea.sh and the Smart Forms playground need a
# server holding the examples. After this, run scripts/load_examples.sh — see forms-summary.md §10.
#
# Usage:  ./scripts/start_hapi.sh          (runs in the foreground; Ctrl-C to stop)

set -euo pipefail

# Run from this script's directory regardless of where it is invoked from.
cd "$(dirname "$0")"

cp ../output/package.tgz hapifhir
docker run -p 8080:8080 -v "$(pwd)/hapifhir:/configs" \
  -e "--spring.config.additional-location=file:///configs/application.yaml" \
  hapiproject/hapi:latest
