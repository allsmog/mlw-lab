# Ghidra headless scripts

Drop-in scripts to run inside the static-lab container's `ghidra-headless`.

## StuxnetExportAnalysis.java

Identifies which exports of a PE are real local implementations and
which are export-forwarders to another DLL. In `s7otbxdx.dll` (the
Stuxnet hijacker), the small "local" set is the hooked subset that
intercepts PLC block read/write — exactly what you reverse for §5.1
of the report.

### Run

```bash
make shell                                       # enter the container
mkdir -p /tmp/gp
ghidra-headless /tmp/gp s7analysis \
    -import samples/s7otbxdx.dll \
    -scriptPath scripts/ghidra \
    -postScript StuxnetExportAnalysis.java \
    -deleteProject
```

Outputs (next to the existing analysis tree):

- `analysis/s7otbxdx.dll/exports.csv`         — full export table.
- `analysis/s7otbxdx.dll/hooked-exports.txt`  — non-forwarders only;
  start your reversing list here.

### What you do with the output

Cross-reference `hooked-exports.txt` against the expected legitimate
Step7 export set (e.g., `s7blk_read`, `s7blk_write`, `s7db_open`).
The hooked entries should be a strict subset of those — if Stuxnet
hijacked a function it didn't need to, that's a finding worth noting.

For each hooked export, open Ghidra's GUI, navigate to the address,
and decompile. Save pseudo-C into `analysis/s7otbxdx.dll/<name>.c`
and reference from `report/05-payload.md` § 5.1.

### Tweaks you might want

- Increase the forwarder-string read window if you see odd truncations
  (currently 128 bytes).
- Filter to names matching `s7*` only, if a binary has many unrelated
  exports.
- Add a SHA-256 check at the top of `run()` to refuse running against
  anything not on your approved hash list.
