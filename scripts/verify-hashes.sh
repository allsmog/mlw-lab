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
  # Layer 1: theZoo zip-archive hashes (verifies download integrity).
  # Pulled from theZoo's public .sha256 metadata files. See
  # docs/sample-sources/thezoo.md for full per-variant breakdown.
  # ----------------------------------------------------------------------------
  "7dafe09a44e72c7b6522319e40c3fadcbad7a0b42d584988a1be8de818689896  theZoo: Win32.Stuxnet.B.Duqu-Realtek.zip (canonical 2010 dropper, encrypted)"
  "dc859fe1e4f877b314b9455e1b4a1d920c325f5a3b3cd90637c6431346f77194  theZoo: Win32.Stuxnet.A.Duqu-C-Media.zip (variant A, encrypted)"
  "152c64365b6224e065e18d9a3421adbf94eb231aa93ac242675c6c45c7929c97  theZoo: TrojanWin32.Duqu.Stuxnet.zip (Duqu+Stuxnet bundle, encrypted)"

  # ----------------------------------------------------------------------------
  # Layer 2: Dropper PE hashes from the Symantec dossier appendix.
  # POPULATE THESE YOURSELF after reading the dossier and after unzipping.
  # https://docs.broadcom.com/docs/security-response-w32-stuxnet-dossier-11-en
  # ----------------------------------------------------------------------------
  # SHA-256 hashes go here. Format examples (NOT real dropper hashes -- replace):
  #
  # "0000000000000000000000000000000000000000000000000000000000000000  stuxnet-dropper (Symantec dossier App. A)"
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
