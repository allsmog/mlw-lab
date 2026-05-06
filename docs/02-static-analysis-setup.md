# Static analysis setup

The static lab is a Docker container with read-only access to `samples/` and
no network. You can run any tool against the sample without risk of executing
its code.

## Prereqs

- Docker (Engine 24+) and Docker Compose v2.
- ~3 GB free for the image.

## Build

```bash
make build
# or:
cd static-lab && docker compose build
```

## Open a shell

```bash
make shell
# or:
cd static-lab && docker compose run --rm static-lab
```

You'll land in `/work` with these mounts:

- `/work/samples`  → host `samples/` (read-only)
- `/work/analysis` → host `analysis/` (writable; put your notes/exports here)
- `/work/yara`     → host `yara/` (read-only)
- `/work/scripts`  → host `scripts/` (read-only)

## Tools available out of the box

| Tool              | What for                                                          |
| ----------------- | ----------------------------------------------------------------- |
| `yara`            | Run rules against a sample.                                       |
| `capa`            | Identify capabilities ("creates service", "injects code"…).       |
| `floss`           | Extract obfuscated/stack strings missed by `strings`.             |
| `r2`              | radare2 — interactive disassembly / scripting.                    |
| `pefile` (py)     | PE header / section / import / resource parsing.                  |
| `lief` (py)       | Cross-format binary parsing.                                      |
| `signify` (py)    | Authenticode signature inspection (great for the stolen certs).   |
| `binwalk`         | Find embedded binaries inside a binary (Stuxnet packs many).      |
| `oletools`        | If you encounter Office droppers (not Stuxnet itself, but useful).|
| `vol` (vol3)      | Volatility 3 for memory dumps from the dynamic VM.                |
| `ghidra-headless` | Batch Ghidra analysis / script-driven decompilation.              |

## Typical first pass against a sample

```bash
# 1. Hash + verify.
sha256sum samples/stuxnet.bin

# 2. Header / section / import overview.
python3 -c "import pefile,sys; pe=pefile.PE(sys.argv[1]); pe.print_info()" samples/stuxnet.bin > analysis/pe-info.txt

# 3. Authenticode signer + cert chain (will likely show revocation).
python3 -m signify.fingerprinter samples/stuxnet.bin
python3 -m signify.authenticode samples/stuxnet.bin

# 4. Capabilities.
capa samples/stuxnet.bin > analysis/capa.txt

# 5. Strings (obfuscated + plain).
floss samples/stuxnet.bin > analysis/floss.txt

# 6. YARA rules.
yara -r yara/stuxnet.yar samples/

# 7. Embedded resources / DLLs hidden in the PE.
binwalk -e samples/stuxnet.bin
```

The `scripts/triage.sh` wrapper runs steps 1–6 in sequence and writes results
into `analysis/<sample>/`.

## What the container won't do

- Execute the sample (no Wine, no PE-execution shim — by design).
- Reach the internet (no network).
- Write to `samples/` (read-only mount).

If you need to detonate, use the dynamic lab — see `03-dynamic-analysis-setup.md`.
