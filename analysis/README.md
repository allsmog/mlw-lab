# analysis/

Your write-ups, organized to match the four axes of the project. Each
subfolder corresponds to a docs/ file with the analysis prompts you should
answer.

```
propagation/   ← see ../docs/propagation.md
persistence/   ← see ../docs/persistence.md
payload/       ← see ../docs/payload.md
evasion/       ← see ../docs/evasion.md
```

## Suggested file naming inside each axis

```
01-overview.md           your prose section for the report
02-static-findings.md    Ghidra screenshots, decompilation, IOCs
03-dynamic-findings.md   Procmon excerpts, pcap notes, registry diffs
04-detection.md          your YARA / Snort / Sigma rules + FP analysis
artifacts/               raw outputs from triage.sh, exported hashes, etc.
```

## What to commit vs. not commit

Commit:

- Markdown write-ups.
- YARA / Snort / Sigma rules you wrote.
- Hash lists and IOC tables.
- Diagrams.

Do **not** commit (the `.gitignore` enforces this):

- Sample files or anything carved out of them (`.exe`, `.dll`, `.sys`, `.lnk`,
  `.bin`, `.dmp`).
- VM images.
- Memory dumps.

When in doubt, leave it out — your report can reference an artifact by hash
without including it.
