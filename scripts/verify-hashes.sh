#!/usr/bin/env bash
# Verify a sample's SHA-256 against an instructor-approved allowlist.
# Edit KNOWN_HASHES to include the hashes your instructor signs off on.
#
# Usage:  ./scripts/verify-hashes.sh samples/stuxnet.bin

set -euo pipefail

# Allowlist: SHA-256<space>label
# Populate after instructor approval. These placeholders are NOT real Stuxnet
# hashes — replace them.
KNOWN_HASHES=(
  # "0000000000000000000000000000000000000000000000000000000000000000  stuxnet-dropper"
  # "1111111111111111111111111111111111111111111111111111111111111111  mrxnet.sys"
  # "2222222222222222222222222222222222222222222222222222222222222222  mrxcls.sys"
  # "3333333333333333333333333333333333333333333333333333333333333333  s7otbxdx.dll"
)

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <path-to-sample>" >&2
  exit 2
fi

target="$1"
[[ -f "$target" ]] || { echo "not a file: $target" >&2; exit 1; }

actual=$(sha256sum "$target" | awk '{print $1}')
size=$(stat -c%s "$target" 2>/dev/null || stat -f%z "$target")

echo "file:    $target"
echo "size:    $size bytes"
echo "sha256:  $actual"
echo

if [[ ${#KNOWN_HASHES[@]} -eq 0 ]]; then
  cat <<'EOF'
NOTE: KNOWN_HASHES is empty. Edit scripts/verify-hashes.sh and add the
SHA-256 hashes your instructor approved (one per line, with a label).
Until then, this script can record the hash but cannot verify it.
EOF
  exit 3
fi

for entry in "${KNOWN_HASHES[@]}"; do
  expected=$(echo "$entry" | awk '{print $1}')
  label=$(echo "$entry" | awk '{$1=""; sub(/^ /,""); print}')
  if [[ "$actual" == "$expected" ]]; then
    echo "[+] MATCH: $label"
    exit 0
  fi
done

echo "[!] NO MATCH against the approved hash list."
echo "    Either the file is unauthorized, or you need to add its hash."
exit 4
