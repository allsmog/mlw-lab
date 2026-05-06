#!/usr/bin/env bash
# Verify a sample's SHA-256 against an instructor-approved allowlist.
#
# IMPORTANT: This file ships with the allowlist commented OUT. You must:
#   1. Open the Symantec dossier (Falliere/Murchu/Chien 2011), Appendix A.
#      <https://docs.broadcom.com/docs/security-response-w32-stuxnet-dossier-11-en>
#   2. Copy the hashes for the components you plan to analyze.
#   3. Confirm with your instructor which specific samples are in scope.
#   4. Uncomment / add the matching lines below.
#
# Each line is "sha256<two-spaces>label". Two spaces, like sha256sum prints.
#
# Usage:  ./scripts/verify-hashes.sh samples/stuxnet.bin

set -euo pipefail

KNOWN_HASHES=(
  # ----------------------------------------------------------------------------
  # Stuxnet 1.x components — populate from the dossier appendix.
  # ----------------------------------------------------------------------------
  # SHA-256 hashes go here. Format examples (NOT real Stuxnet hashes — replace):
  #
  # "0000000000000000000000000000000000000000000000000000000000000000  stuxnet-dropper"
  # "1111111111111111111111111111111111111111111111111111111111111111  ~WTR4132.tmp (LNK loader)"
  # "2222222222222222222222222222222222222222222222222222222222222222  ~WTR4141.tmp (LNK loader sibling)"
  # "3333333333333333333333333333333333333333333333333333333333333333  mrxnet.sys (rootkit)"
  # "4444444444444444444444444444444444444444444444444444444444444444  mrxcls.sys (loader)"
  # "5555555555555555555555555555555555555555555555555555555555555555  oem7A.PNF (config)"
  # "6666666666666666666666666666666666666666666666666666666666666666  mdmcpq3.PNF (config/payload)"
  # "7777777777777777777777777777777777777777777777777777777777777777  mdmeric3.PNF (config/payload)"
  # "8888888888888888888888888888888888888888888888888888888888888888  s7otbxdx.dll (Step7 hijacker)"
  # "9999999999999999999999999999999999999999999999999999999999999999  s7otbxsx.dll (renamed-original)"
  #
  # ----------------------------------------------------------------------------
  # Notes for verification (verbatim from the public papers):
  #
  #   Wikipedia / search snippet (UNVERIFIED — confirm against the dossier):
  #     mrxnet.sys MD5 = CC1DB5360109DE3B857654297D262CA1
  #     mrxnet.sys SHA-1 = 758240613C362BB1FD13E07D3D19F357B7F8A6DA
  #
  # Treat that pair as a starting point for cross-reference, not as
  # authoritative. The dossier's appendix is authoritative.
)

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <path-to-sample>" >&2
  exit 2
fi

target="$1"
[[ -f "$target" ]] || { echo "not a file: $target" >&2; exit 1; }

actual=$(sha256sum "$target" | awk '{print $1}')
size=$(stat -c%s "$target" 2>/dev/null || stat -f%z "$target")
md5=$(md5sum "$target" | awk '{print $1}')
sha1=$(sha1sum "$target" | awk '{print $1}')

echo "file:    $target"
echo "size:    $size bytes"
echo "md5:     $md5"
echo "sha1:    $sha1"
echo "sha256:  $actual"
echo

if [[ ${#KNOWN_HASHES[@]} -eq 0 ]]; then
  cat <<'EOF'
NOTE: KNOWN_HASHES is empty. Populate it from the Symantec dossier
appendix and re-run. See docs/05-sample-acquisition.md for the workflow.
The hashes printed above are recorded but cannot be verified yet.
EOF
  exit 3
fi

for entry in "${KNOWN_HASHES[@]}"; do
  expected=$(echo "$entry" | awk '{print $1}')
  label=$(echo "$entry" | awk '{$1=""; sub(/^ +/,""); print}')
  if [[ "$actual" == "$expected" ]]; then
    echo "[+] MATCH: $label"
    exit 0
  fi
done

echo "[!] NO MATCH against the approved hash list."
echo "    Either the file is unauthorized, or you need to add its hash."
exit 4
