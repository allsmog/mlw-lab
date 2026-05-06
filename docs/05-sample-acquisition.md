# Sample acquisition

> Read [`../SAFETY.md`](../SAFETY.md) first. Get written instructor approval
> before you download anything.

This file does *not* link to samples. Confirm the source list with your
instructor; common sanctioned sources include:

- **VX-Underground** — large public collection, including a Stuxnet folder.
  Requires acknowledging their use policy.
- **MalwareBazaar (abuse.ch)** — searchable by hash; requires a free account.
- **theZoo** — GitHub project; samples are zipped with a known password
  (`infected`) to discourage accidental detonation.
- **University-provided sample server** — many courses host their own. Always
  preferred when available.

## Hashes to verify against

The Symantec dossier (Falliere/Murchu/Chien, 2011), Appendix A, lists hashes
for the major Stuxnet components. After downloading, verify SHA-256 before
doing anything else. Edit `scripts/verify-hashes.sh` to include the hashes
your instructor signs off on.

A typical (publicly documented) reference set:

| Component                 | Role                                      |
| ------------------------- | ----------------------------------------- |
| `~WTR4132.tmp`            | LNK loader                                |
| `~WTR4141.tmp`            | LNK loader (sibling)                      |
| `mrxnet.sys`              | Rootkit driver (file-hiding)              |
| `mrxcls.sys`              | Loader driver (Realtek-signed)            |
| `oem7A.PNF`, `mdmcpq3.PNF`| Configuration / payload data              |
| `s7otbxdx.dll`            | Step7 hijack DLL                          |

Don't rely on filenames — verify hashes.

## Storage on disk

- Keep samples password-protected (`7z a -pinfected`) when not actively in use.
- The `samples/` directory in this repo is `.gitignore`d. Keep it that way.
- Never sync `samples/` to cloud storage (Dropbox, iCloud, OneDrive — they
  will scan the file, may flag your account, and some may delete it).

## Chain of custody (for the write-up)

For the academic report, document for each sample:

1. Source URL / collection name.
2. Date / time of download.
3. SHA-256 (and MD5/SHA-1 for cross-reference with older reports).
4. File size in bytes.
5. Any password used to extract.
6. Hash match against a published reference (cite the paper).

`scripts/verify-hashes.sh` generates lines 3–4 for you.
