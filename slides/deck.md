---
marp: true
title: "Stuxnet — A Multi-Axis Analysis"
author: "<your name>"
date: "<YYYY-MM-DD>"
paginate: true
size: 16:9
theme: default
style: |
  section { font-family: Helvetica, Arial, sans-serif; }
  section.title h1 { font-size: 2.4em; }
  pre, code { font-size: 0.85em; }
---

<!-- _class: title -->

# Stuxnet
## A Multi-Axis Analysis

> TODO: name, course code, date

---

# Why Stuxnet matters

- First publicly documented cyber-physical weapon at scale (2010).
- Targeted Natanz uranium enrichment via Siemens S7-315 PLCs.
- Introduced techniques that recurred in later threats: signed-driver
  abuse, environmental keying, ICS-targeted payloads.

> TODO: 30 seconds of context. Don't dwell — your audience knows this.

---

# Lab architecture

- **Static** — Docker container, no network, samples mounted RO.
  Ghidra-headless, YARA, capa, FLOSS, radare2, signify, Volatility 3.
- **Dynamic** — VirtualBox, Win7 SP1 x86, host-only networking,
  snapshot-driven. Detonator + target VMs.
- Container is a tool sandbox, **not** isolation for execution.
- PLC payload is **static-only** — no Siemens hardware available.

> TODO: optional ASCII / diagram of the two surfaces.

---

# Sample provenance

| Field            | Value     |
| ---------------- | --------- |
| Source           | > TODO    |
| Date / time      | > TODO    |
| SHA-256          | > TODO    |
| Size             | > TODO    |
| Cross-reference  | Symantec dossier App. A entry > TODO |

> TODO: instructor approval ref.

---

# Axis 1 — Propagation

- LNK 0-day (CVE-2010-2568) — icon-load LoadLibrary.
- Print Spooler (CVE-2010-2729) — RPC write to system32.
- MS08-067 — Server service stack overflow.
- USB / SMB lateral writes via stolen credentials.

> TODO: Screenshot of one Ghidra decompilation; one Procmon trace.

---

# Axis 2 — Persistence

- `mrxnet.sys` — file-system filter, hides Stuxnet's own files.
- `mrxcls.sys` — loader, injects user-mode payload.
- Signed with stolen Realtek (revoked 2010-07-16) and JMicron certs.
- Service entries under `HKLM\...\Services\MRxCls` / `MRxNet`.

> TODO: signify output excerpt showing the stolen-cert subject.

---

# Axis 3 — Payload (Step7 hijack)

- `s7otbxdx.dll` re-exports legit `s7otbxsx.dll`.
- Forwards most calls; intercepts block-read / block-write.
- Engineer sees clean code; PLC runs malicious code.

```c
// pseudo-C from your Ghidra reversing
// → fill in from decompilation
```

> TODO: paste the export-forwarding evidence.

---

# Axis 3 — Payload (PLC sabotage)

- ~13-day reconnaissance phase: record normal sensor values.
- Attack: drive rotor frequency to ~1410 Hz, then ~2 Hz.
- Replay recorded "normal" values to SCADA during the attack.
- Engineer sees green lights; centrifuges fail.

> TODO: cite Langner, *To Kill a Centrifuge* for the rotor logic.

---

# Axis 4 — Evasion

- Anti-AV: per-product behavior on the carried allowlist.
- Environmental keying:
  1. Step7 installed?
  2. PLC type S7-315/417?
  3. Profibus topology matches?
  4. Date < 24 June 2012?
- Light anti-debug; environmental gates do the heavy lifting.

---

# Detection rules I built

- **YARA**: dropped filenames, Step7 hijack, AV allowlist, LNK loader,
  stolen-cert subjects.
- **Sigma**: driver service install, suspicious driver load, explorer
  loading `~WTR####.tmp`, spooler→system32 write, Step7 DLL hijack.

> TODO: show one rule on screen as an artifact of the work.

---

# Defenses

- HVCI / DSE / ELAM for kernel integrity.
- AppLocker / WDAC for unsigned-DLL-from-USB.
- Purdue-model segmentation for IT ↔ OT.
- Hardware overspeed safety interlocks at the drive — independent of
  the PLC's say-so.

---

# What this taught the field

- Air gaps don't isolate by themselves.
- Signed ≠ trusted; verify by *origin*.
- Sandbox-based AV misses targeted malware that doesn't act outside
  its target environment.
- ICS visibility is a category, not a feature.

---

# Limitations / honesty slide

- PLC payload analyzed statically only.
- Stolen-cert chains are revoked; verification ends in failure (which
  is the finding).
- Kill date (24 June 2012) limits live propagation today; lab is
  reproducible regardless.

---

# Questions?

> TODO: contact info, repo URL, citation list.
