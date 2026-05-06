#!/usr/bin/env bash
# First-pass static triage of a sample.
#
# Designed to run inside the static-lab container (see docker-compose.yml).
# Writes results to analysis/<basename>/.
#
# Usage:  ./scripts/triage.sh samples/stuxnet.bin

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <path-to-sample>" >&2
  exit 2
fi

sample="$1"
[[ -f "$sample" ]] || { echo "not a file: $sample" >&2; exit 1; }

base=$(basename "$sample")
out="analysis/$base"
mkdir -p "$out"

echo "[*] sample : $sample"
echo "[*] outdir : $out"

# 1) Hashes + size + file type.
echo "[*] hashes ..."
{
  echo "size:   $(stat -c%s "$sample" 2>/dev/null || stat -f%z "$sample") bytes"
  echo "md5:    $(md5sum    "$sample" | awk '{print $1}')"
  echo "sha1:   $(sha1sum   "$sample" | awk '{print $1}')"
  echo "sha256: $(sha256sum "$sample" | awk '{print $1}')"
  echo "file:   $(file -b   "$sample")"
} > "$out/00-hashes.txt"

# 2) PE structure.
echo "[*] pefile ..."
python3 - "$sample" > "$out/01-pe-info.txt" <<'PY' || true
import sys, pefile
pe = pefile.PE(sys.argv[1], fast_load=False)
print(pe.dump_info())
PY

# 3) Authenticode signatures (the stolen-cert finding lives here).
echo "[*] signify ..."
python3 -m signify.authenticode "$sample" > "$out/02-authenticode.txt" 2>&1 || true

# 4) Capabilities.
echo "[*] capa ..."
capa "$sample" > "$out/03-capa.txt" 2>&1 || true

# 5) Strings (deobfuscated).
echo "[*] floss ..."
floss "$sample" > "$out/04-floss.txt" 2>&1 || true

# 6) Embedded blobs (Stuxnet hides DLLs and PLC blocks inside the PE).
echo "[*] binwalk ..."
( cd "$out" && binwalk --dd='.*' "../../$sample" > 05-binwalk.txt 2>&1 ) || true

# 7) YARA.
echo "[*] yara ..."
yara -r yara/stuxnet.yar "$sample" > "$out/06-yara.txt" 2>&1 || true

echo
echo "[+] done. results in $out/"
ls -lah "$out/"
