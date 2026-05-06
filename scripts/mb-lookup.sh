#!/usr/bin/env bash
# Look up a sample's metadata on MalwareBazaar (abuse.ch) by SHA-256.
#
# This script DOES NOT download the sample. It queries the metadata
# endpoint, which is useful for cross-checking what a hash claims to be
# before you authorize the download. No Auth-Key is required for the
# get_info endpoint at the time of writing.
#
# Usage:  ./scripts/mb-lookup.sh <sha256-hex>
# Output: pretty-printed JSON of MalwareBazaar's metadata for that hash.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <sha256-hex>" >&2
  exit 2
fi

hash="$1"
if [[ ! "$hash" =~ ^[A-Fa-f0-9]{64}$ ]]; then
  echo "error: not a sha256 hex string (need exactly 64 hex chars)" >&2
  exit 2
fi

# get_info: returns family, signer, file size, first/last seen, tags, etc.
response=$(curl -sS --fail-with-body \
  -X POST \
  --form 'query=get_info' \
  --form "hash=$hash" \
  https://mb-api.abuse.ch/api/v1/)

if command -v jq >/dev/null 2>&1; then
  echo "$response" | jq .
else
  echo "$response"
fi
