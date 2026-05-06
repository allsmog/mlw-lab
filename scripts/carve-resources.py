#!/usr/bin/env python3
"""
Carve embedded resources out of a PE and identify them.

Stuxnet hides multiple components inside the dropper's resource section:
the kernel drivers, the Step7 hijack DLL, configuration files, and PLC
payload blocks. This script walks the resource directory, dumps each
entry, hashes it, attempts to identify the file type, and writes a
manifest you can include in your report.

Usage:
    python3 scripts/carve-resources.py samples/<file> [-o analysis/<axis>/]

Output:
    <outdir>/manifest.csv      type, language, codepage, size, sha256, filename
    <outdir>/manifest.json     same data, machine-readable
    <outdir>/<type>_<id>.bin   each carved resource

Run inside the static-lab container so the parsing tools are available
and the sample stays on a read-only mount:

    make shell
    python3 scripts/carve-resources.py samples/<file> -o analysis/dropper/
"""

import argparse
import csv
import hashlib
import json
import sys
from pathlib import Path

import pefile

KNOWN_HASHES = {
    # Populate with the hashes from the Symantec dossier appendix once you
    # have your sample. Format: "sha256_hex": "label".
    # "0000000000000000000000000000000000000000000000000000000000000000": "mrxnet.sys",
}

MAGIC_TYPES = [
    (b"MZ",                              "pe"),
    (b"\x7fELF",                         "elf"),
    (b"\xd0\xcf\x11\xe0\xa1\xb1\x1a\xe1","cfb / ole2"),
    (b"PK\x03\x04",                      "zip"),
    (b"\x1f\x8b",                        "gzip"),
    (b"BZh",                             "bzip2"),
    (b"\x70\x70\x70\x70",                "s7-block?"),  # MC7 blocks often start with 0x70 'p'
]


def identify(blob: bytes) -> str:
    """Cheap content-based file-type guess."""
    for magic, label in MAGIC_TYPES:
        if blob.startswith(magic):
            if label == "pe":
                # PE-or-MS-DOS-stub: check the PE signature offset.
                try:
                    peoff = int.from_bytes(blob[0x3C:0x40], "little")
                    if blob[peoff:peoff + 4] == b"PE\0\0":
                        return "pe"
                except (IndexError, ValueError):
                    pass
                return "ms-dos exe / stub"
            return label
    return "unknown"


def walk_resources(pe: pefile.PE):
    """Yield (type, id_or_name, language, codepage, blob) for every leaf."""
    if not hasattr(pe, "DIRECTORY_ENTRY_RESOURCE"):
        return
    for type_entry in pe.DIRECTORY_ENTRY_RESOURCE.entries:
        type_name = (
            type_entry.name.decode(errors="replace")
            if type_entry.name
            else f"type_{type_entry.id}"
        )
        if not hasattr(type_entry, "directory"):
            continue
        for id_entry in type_entry.directory.entries:
            res_name = (
                id_entry.name.decode(errors="replace")
                if id_entry.name
                else str(id_entry.id)
            )
            if not hasattr(id_entry, "directory"):
                continue
            for lang_entry in id_entry.directory.entries:
                if not hasattr(lang_entry, "data"):
                    continue
                rva = lang_entry.data.struct.OffsetToData
                size = lang_entry.data.struct.Size
                lang = lang_entry.data.lang
                codepage = lang_entry.data.struct.CodePage
                blob = pe.get_memory_mapped_image()[rva:rva + size]
                yield type_name, res_name, lang, codepage, bytes(blob)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("sample", help="Path to PE sample")
    ap.add_argument("-o", "--outdir", default="analysis/carved",
                    help="Output directory (default: analysis/carved)")
    args = ap.parse_args()

    sample = Path(args.sample)
    if not sample.is_file():
        print(f"not a file: {sample}", file=sys.stderr)
        return 2

    out = Path(args.outdir)
    out.mkdir(parents=True, exist_ok=True)

    try:
        pe = pefile.PE(str(sample), fast_load=False)
    except pefile.PEFormatError as exc:
        print(f"not a PE: {exc}", file=sys.stderr)
        return 1

    rows = []
    for typ, ident, lang, codepage, blob in walk_resources(pe):
        sha = hashlib.sha256(blob).hexdigest()
        guess = identify(blob)
        safe = f"{typ}_{ident}".replace("/", "_").replace(" ", "_")
        outfile = out / f"{safe}.bin"
        outfile.write_bytes(blob)
        match = KNOWN_HASHES.get(sha, "")
        rows.append({
            "type": typ,
            "id": ident,
            "lang": lang,
            "codepage": codepage,
            "size": len(blob),
            "sha256": sha,
            "guess": guess,
            "known_match": match,
            "file": str(outfile.relative_to(out.parent)
                        if out.parent in outfile.parents else outfile),
        })

    if not rows:
        print("no resources found in the PE")
        return 0

    rows.sort(key=lambda r: (r["type"], str(r["id"])))

    csv_path = out / "manifest.csv"
    with csv_path.open("w", newline="") as fh:
        writer = csv.DictWriter(fh, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)

    json_path = out / "manifest.json"
    json_path.write_text(json.dumps(rows, indent=2))

    print(f"[+] carved {len(rows)} resources into {out}/")
    print(f"[+] manifest: {csv_path}, {json_path}")
    print()
    print(f"{'TYPE':<14} {'ID':<10} {'SIZE':>10}  {'GUESS':<14}  SHA256  (KNOWN_MATCH)")
    print("-" * 100)
    for r in rows:
        print(f"{r['type']:<14} {str(r['id']):<10} {r['size']:>10}  "
              f"{r['guess']:<14}  {r['sha256']}  {r['known_match']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
