# First lab session — a 60-minute walkthrough

A concrete script for your first hour, after instructor approval has
cleared and a sample sits in `samples/`. Goal: produce enough material to
populate the **persistence** and **evasion** chapters of your report.

Time budget is conservative. Faster is fine.

---

## 0. (5 min) Pre-flight

```bash
# From the repo root.
ls samples/                       # confirm the sample is here
cat docs/instructor-approval.txt  # confirm written approval is filed
sha256sum samples/<file>          # confirm the hash matches what you expect
```

If anything in step 0 is missing, **stop and resolve it** before going further.

---

## 1. (5 min) Verify the sample is on the allowlist

```bash
# Edit scripts/verify-hashes.sh and add your approved SHA-256 to KNOWN_HASHES.
$EDITOR scripts/verify-hashes.sh
make verify SAMPLE=samples/<file>
# → should print "[+] MATCH: <label>" before continuing.
```

If you get NO MATCH, you either have the wrong sample or the wrong hash
in the allowlist. Stop and resolve.

---

## 2. (10 min) Run the automated triage

```bash
make triage SAMPLE=samples/<file>
```

This produces seven files under `analysis/<file>/`:

| File                  | What it tells you                                |
| --------------------- | ------------------------------------------------ |
| `00-hashes.txt`       | MD5/SHA-1/SHA-256, file type, size               |
| `01-pe-info.txt`      | PE header, sections, imports, exports, resources |
| `02-authenticode.txt` | Signature chain — **stolen-cert finding lives here** |
| `03-capa.txt`         | High-level capabilities                          |
| `04-floss.txt`        | Plain + obfuscated strings                       |
| `05-binwalk.txt`      | Embedded blobs                                   |
| `06-yara.txt`         | YARA rule hits                                   |

Open them in your editor or pager; skim each for one minute.

---

## 3. (10 min) Carve the embedded resources

Stuxnet's dropper carries multiple files in its resource section
(drivers, the Step7 hijack DLL, configuration data, PLC blocks). Pull
them out and hash them:

```bash
make shell                              # drop into the static container
python3 scripts/carve-resources.py samples/<file> -o analysis/<file>/carved
```

The script writes:

- `analysis/<file>/carved/manifest.csv`   — table of carvings.
- `analysis/<file>/carved/manifest.json`  — same data, machine-readable.
- `analysis/<file>/carved/<type>_<id>.bin` — each carving on disk.

Hash each carving, paste into `report/01-introduction.md` § 1.4 and
into `report/04-persistence.md` § 4.1.

---

## 4. (10 min) Persistence: the stolen-cert finding

The fastest big finding. Inside the container shell:

```bash
# For each carved .bin that looks like a PE:
python3 -m signify.authenticode analysis/<file>/carved/<carving>.bin
```

What you're looking for:

- `signer.subject` — the company name on the cert.
- `serial` — the cert serial number.
- `validity` — issued/expires dates.
- The output will likely flag the cert as untrusted / revoked. **That is
  the finding.** Snip the relevant lines into `report/04-persistence.md`
  § 4.2.

If you see Realtek Semiconductor or JMicron Technology, you have the
classic Stuxnet drivers. Cross-check the SHA-256 against the Symantec
dossier appendix to confirm which file is `mrxnet.sys` vs `mrxcls.sys`.

---

## 5. (10 min) Evasion: pull the AV allowlist and gate strings

Still inside the container:

```bash
# AV process names Stuxnet checks for.
grep -iE "avp|mcshield|rtvscan|ccsvchst|trend|f-secure|etrust|kav|nod32|symantec" \
    analysis/<file>/04-floss.txt | sort -u

# Step7-related strings (environmental keying gate).
grep -iE "s7tgtopx|s7otbxdx|s7otbxsx|s7blk|wincc|step7|simatic" \
    analysis/<file>/04-floss.txt | sort -u

# PLC / Profibus indicators.
grep -iE "profibus|profinet|cp_343|cp343|dp_send|dp_recv|szl" \
    analysis/<file>/04-floss.txt | sort -u

# Kill-date constants (look for 2012 references).
grep -E "2012|0x9999|24.*06|June" analysis/<file>/04-floss.txt | head
```

Each list goes into a different section of the report:

- AV list → `report/06-evasion.md` § 6.1.
- Step7 strings → `report/06-evasion.md` § 6.2 (gate 1) and
  `report/05-payload.md` § 5.1.
- PLC strings → `report/05-payload.md` § 5.2.
- Kill-date → `report/06-evasion.md` § 6.5.

---

## 6. (5 min) Run YARA against the carved files

Sanity check that your detection rules fire:

```bash
yara -r yara/stuxnet.yar analysis/<file>/carved/
```

Expected hits (depending on which carvings you have):

- `Stuxnet_Dropped_Filename_Strings`
- `Stuxnet_Step7_DLL_Hijack`
- `Stuxnet_AV_Process_Allowlist`
- `Stuxnet_Driver_Realtek_Cert` (on the .sys carvings)
- `Stuxnet_Driver_JMicron_Cert` (on later-variant carvings)

If a rule you expect fails to hit, `yara -s` will show which strings
matched and which didn't — useful for tuning.

---

## 7. (5 min) Write the persistence section while it's fresh

While everything is in your head, open `report/04-persistence.md` and
fill in the blanks:

- § 4.1 driver table (filename, role, signer subject) from the
  authenticode output.
- § 4.2 cert details (serial, dates) from authenticode + a quick lookup
  of the revocation date.

Even rough notes are gold here — you'll polish later.

Commit your work:

```bash
git add analysis/ report/
git commit -m "Session 1: persistence + evasion data collection"
```

> Reminder: the carved binaries themselves (`*.bin`) are gitignored. Only
> the markdown notes and CSV/JSON manifests get committed.

---

## What you have at the end of session 1

- A confirmed-authentic sample with a logged hash.
- Seven triage outputs.
- Carved resources with a manifest.
- A near-complete persistence chapter.
- Half of the evasion chapter.
- All your YARA rules confirmed firing.

That's a strong start. Sessions 2–4 dig into propagation (LNK + Spooler
+ MS08-067) and the payload's DLL hijack + PLC blocks; those are where
the real reverse-engineering work happens.
