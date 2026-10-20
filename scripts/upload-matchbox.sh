#!/usr/bin/env bash
#
# Replace the CH EKM package on the matchbox the Smart Forms EHR validates against
# (https://test.ahdis.ch/matchboxv3/fhir, see ../smart-forms/ARCHITECTURE.md) with the package the
# IG Publisher just built in output/.
#
# Two calls, because matchbox will not overwrite an installed version from an uploaded package:
#   1. DELETE ImplementationGuide/<name>-<version>   uninstalls it and evicts every cached engine
#                                                    that loaded it
#   2. POST   $install-npm-package?name=&version=    installs output/package.tgz (body, application/gzip);
#                                                    missing dependencies come from the package registry
# `$install-npm-package` hands the package to the installer as a data: URL, and the installer only
# replaces an existing version when the URL is http(s) from localhost or build.fhir.org — for anything
# else it returns WITHOUT installing and without an error. Hence step 1, and hence the check at the
# end: matchbox serves the package.json `description` as the IG's `title`, and the Publisher puts the
# build time into it ("… (built Tue, Oct 20, 2026 09:41+0200)"), so the title on the server must be
# the description of the uploaded package. (The IG's `date` on the server is the install time.)
#
# Between step 1 and step 2 the server has no CH EKM package; if step 2 fails, validation against
# the CH EKM profiles fails until the script is run again successfully.
#
# Usage:
#   ./scripts/upload-matchbox.sh                          # output/package.tgz -> test.ahdis.ch
#   ./scripts/upload-matchbox.sh path/to/package.tgz
#   MATCHBOX_BASE=http://localhost:8080/matchboxv3/fhir ./scripts/upload-matchbox.sh
#
set -euo pipefail

# Run from the repo root regardless of where the script is invoked from.
cd "$(dirname "$0")/.."

PKG="${1:-output/package.tgz}"
BASE="${MATCHBOX_BASE:-https://test.ahdis.ch/matchboxv3/fhir}"
ACCEPT='Accept: application/fhir+json'

if [ ! -f "$PKG" ]; then
  echo "ERROR: $PKG not found — run the IG Publisher first"
  exit 1
fi

PKG_JSON=$(tar -xzOf "$PKG" package/package.json)
NAME=$(jq -r .name <<<"$PKG_JSON")
VERSION=$(jq -r .version <<<"$PKG_JSON")
PKG_DESC=$(jq -r .description <<<"$PKG_JSON")
IG_ID="$NAME-$VERSION"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# The installed IG's title (= its package.json description), empty when not installed.
ig_title() {
  local status
  status=$(curl -s -o "$TMP/ig.json" -w '%{http_code}' -H "$ACCEPT" "$BASE/ImplementationGuide/$IG_ID")
  if [ "$status" = "200" ]; then
    jq -r '.title // empty' "$TMP/ig.json"
  fi
}

built() { sed -nE 's/.*\(built (.*)\)$/\1/p' <<<"$1"; }

# Summarise an OperationOutcome: count the information issues, print the others; fail on error/fatal.
check_oo() {
  local label=$1 file=$2 status=$3
  if ! jq -e . "$file" >/dev/null 2>&1; then
    echo "ERROR: $label failed (HTTP $status), response:"
    cat "$file"
    exit 1
  fi
  jq -r '"  \([.issue[]? | select(.severity == "information")] | length) information issue(s)",
         (.issue[]? | select(.severity != "information") | "  [\(.severity)] \(.diagnostics // .details.text // "")")' "$file"
  if [[ "$status" != 2* ]] || jq -e 'any(.issue[]?; .severity == "error" or .severity == "fatal")' "$file" >/dev/null; then
    echo "ERROR: $label failed (HTTP $status)"
    exit 1
  fi
}

echo "Package:  $PKG  ($NAME#$VERSION, built $(built "$PKG_DESC"))"
echo "matchbox: $BASE"

BEFORE=$(ig_title)
if [ -n "$BEFORE" ]; then
  echo
  echo "Installed: $IG_ID, built $(built "$BEFORE") — uninstalling"
  STATUS=$(curl -s -o "$TMP/delete.json" -w '%{http_code}' -X DELETE -H "$ACCEPT" "$BASE/ImplementationGuide/$IG_ID")
  check_oo "DELETE ImplementationGuide/$IG_ID" "$TMP/delete.json" "$STATUS"
else
  echo
  echo "Not installed yet: $IG_ID"
fi

echo
echo "Installing $NAME#$VERSION (dependencies are fetched by the server, this can take a few minutes)"
STATUS=$(curl -s -o "$TMP/install.json" -w '%{http_code}' --max-time 900 \
  -X POST -H 'Content-Type: application/gzip' -H "$ACCEPT" \
  --data-binary "@$PKG" \
  "$BASE/\$install-npm-package?name=$NAME&version=$VERSION")
check_oo "\$install-npm-package" "$TMP/install.json" "$STATUS"

AFTER=$(ig_title)
echo
if [ "$AFTER" != "$PKG_DESC" ]; then
  echo "ERROR: $IG_ID on the server is '${AFTER:-<not installed>}'"
  echo "       expected the uploaded build: '$PKG_DESC'"
  exit 1
fi
echo "OK: $IG_ID on $BASE is the build of $(built "$PKG_DESC")"
