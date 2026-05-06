# Sample acquisition

> Read [`../SAFETY.md`](../SAFETY.md) first. Get **written instructor
> approval** before downloading anything. The instructor-approval email
> template lives at [`instructor-approval-template.md`](instructor-approval-template.md).

## Which Stuxnet you want

Two distinct lineages exist; you almost certainly want the second.

| Variant       | First seen          | PLC target | Propagation                          | Status                                 |
| ------------- | ------------------- | ---------- | ------------------------------------ | -------------------------------------- |
| Stuxnet 0.5   | ~2007 (dev ~2005)   | S7-417     | Step7 project-file infection only    | Less common in research collections; documented in Symantec's "Stuxnet 0.5: The Missing Link" (2013). |
| **Stuxnet 1.x** (the famous one) | 2009–2010   | **S7-315** | LNK 0-day, Print Spooler, MS08-067, USB, SMB | Widely available; the subject of the Symantec dossier (2011) and ESET paper (2010). |

Specify which variant in your instructor approval and in your sample
request. Default to 1.x unless your course says otherwise.

## Public sources

Listed in roughly the order most courses prefer.

### 1. University-hosted sample server

If your course has one, **use it**. It is pre-vetted, hash-locked, and
instructor-blessed; you skip the rest of this list. Ask before assuming.

### 2. MalwareBazaar — abuse.ch

URL: <https://bazaar.abuse.ch/>
Direct browse for the Stuxnet YARA tag:
<https://bazaar.abuse.ch/browse/yara/StuxNet_Malware_1/>

- Operated by abuse.ch and Spamhaus. Reputable, widely used in academia.
- Web UI lets you browse samples and download them; account
  registration optional for browsing, **required** to download via API.
- API access requires a free Auth-Key (request one at the abuse.ch
  Authentication Portal, link from the site).
- Download via API:
  ```bash
  curl -X POST -H "Auth-Key: <YOUR-KEY>" \
       --form 'query=get_file' \
       --form "sha256_hash=<HASH>" \
       https://mb-api.abuse.ch/api/v1/ -o sample.zip
  # The zip is encrypted with password "infected".
  ```
- File metadata API (no auth required for some queries; use this for
  verification):
  ```bash
  curl -X POST --form 'query=get_info' \
       --form "hash=<HASH>" \
       https://mb-api.abuse.ch/api/v1/
  ```

### 3. theZoo

URL: <https://github.com/ytisf/theZoo>

- GitHub-hosted live-malware educational repository.
- Stuxnet sample is in the project's directory layout (each malware
  family gets its own folder with a binary, password file, EULA, and
  metadata).
- Standard "infected" password convention on the encrypted archives.
- Repository README is blunt about risk: live malware, isolated VM
  required, no internet.

### 4. VX-Underground

URL: <https://vx-underground.org/>

- Claims largest public malware repository (35M+ samples).
- Has dedicated Stuxnet content. Public access; some collections may
  require account registration.
- Often hosted as 7z archives with the "infected" password.

### 5. Malpedia (Fraunhofer FKIE)

URL: <https://malpedia.caad.fkie.fraunhofer.de/details/win.stuxnet>

- Curated threat-actor / malware-family encyclopedia. Includes IOC
  bundles, YARA rules, and references to academic papers.
- Sample download requires a researcher account (academic / industry
  affiliation). Apply through their site.
- Even without an account, the public IOC and reference page is
  valuable — you'll find a curated reading list for your bibliography.

## Authoritative analysis papers

The hashes you'll cross-reference against live in these papers, not in
this repo. Pull them yourself; they're free.

| Paper                                                        | Where to find it                                                                          |
| ------------------------------------------------------------ | ----------------------------------------------------------------------------------------- |
| Falliere, Murchu, Chien — *W32.Stuxnet Dossier* v1.4 (2011)  | Broadcom: <https://docs.broadcom.com/docs/security-response-w32-stuxnet-dossier-11-en>    |
| Matrosov, Rodionov, Harley, Malcho — *Stuxnet Under the Microscope* (ESET 2010, Rev 1.31) | ESET: <https://web-assets.esetstatic.com/wls/en/papers/white-papers/Stuxnet_Under_the_Microscope.pdf> |
| Kaspersky GReAT — *Stuxnet/Duqu: The Evolution of Drivers* (2011) | Securelist: <https://securelist.com/stuxnetduqu-the-evolution-of-drivers/36462/>          |
| Symantec — *Stuxnet 0.5: The Missing Link* (2013)            | Broadcom: <https://docs.broadcom.com/doc/stuxnet-missing-link-13-en>                      |
| Antiy Labs — *Report on the Worm Stuxnet's Attack*           | <https://www.antiy.net/media/reports/stuxnet_analysis.pdf>                                |
| Langner — *To Kill a Centrifuge* (2013)                      | <https://www.langner.com/wp-content/uploads/2017/03/to-kill-a-centrifuge.pdf>             |
| MITRE ATT&CK — Stuxnet (S0603)                               | <https://attack.mitre.org/software/S0603/>                                                |

The **Symantec dossier (Appendix A)** is the canonical hash source.
After you have the dossier, copy its hash table into
`scripts/verify-hashes.sh` and into `report/01-introduction.md` § 1.4.

## Workflow (in order)

1. Email your instructor with [`instructor-approval-template.md`](instructor-approval-template.md).
   Wait for written reply. Save it as `docs/instructor-approval.txt`
   (gitignored).
2. Read the Symantec dossier appendix. Note the hashes and filenames of
   the components you intend to study.
3. Pick a source from §2–§5 above (or your course's hosted server).
   Register / acknowledge their TOS as required.
4. Search by SHA-256 from the dossier. Download.
5. Verify the SHA-256 immediately:
   ```bash
   make verify SAMPLE=samples/<file>
   ```
   This will fail until you populate `KNOWN_HASHES` in
   `scripts/verify-hashes.sh` with the dossier's hashes.
6. Keep the sample password-protected when not in use:
   ```bash
   7z a -pinfected -mhe=on samples/stuxnet.7z samples/stuxnet.bin
   ```

## Storage hygiene

- `samples/` is gitignored — never commit.
- Don't sync `samples/` to cloud storage (Dropbox / iCloud / OneDrive
  will scan and may delete or report).
- If you copy the sample between machines, do it over the host-only
  network from the static-lab container, not via USB.

## Chain of custody (for the report)

For each sample, record in `report/01-introduction.md` § 1.4:

1. Source (which repository).
2. Date / time of download (UTC).
3. SHA-256 (and MD5, SHA-1 for cross-reference with the older papers).
4. File size in bytes.
5. Archive password if any.
6. Hash match against published reference (which paper, which appendix entry).
7. Instructor-approval reference (course code, instructor name, date).

## What I (Claude) did and did not do for you

I researched the public landscape of Stuxnet samples and documented the
five sources above with their access conditions. I did **not** download
a sample, and I will not. The instructor-approval gate is the chain of
custody that protects you legally and academically — it cannot be
short-circuited by an AI assistant.
