# 1. Introduction

## 1.1 Background

> TODO: One paragraph on Stuxnet's place in the malware timeline:
> discovered June 2010 (VirusBlokAda), publicly named by Symantec, the
> Natanz uranium-enrichment context, why it mattered (first publicly
> documented cyber-physical weapon at scale).

## 1.2 Attribution and context

> TODO: Briefly summarize the public reporting on attribution. Cite Zetter
> and Langner. Be precise about what is reported vs. confirmed; don't
> claim more than the sources do.

## 1.3 Scope of this analysis

This report examines Stuxnet across four axes:

1. **Propagation** — the four bug classes Stuxnet weaponized to move
   between hosts (LNK, Print Spooler, MS08-067, removable media / SMB).
2. **Persistence and stealth** — the signed kernel drivers that hid
   Stuxnet on disk and enabled its long dwell time.
3. **Payload** — the Step7 / WinCC DLL hijack, the carried PLC code, and
   the rotor-frequency sabotage logic.
4. **Evasion** — anti-AV checks and environmental keying that made the
   sample silent outside its target environment.

> TODO: One paragraph stating what *this* report contributes (your
> reproduction, your detections, your defense recommendations) and what
> it does not attempt (the PLC payload could not be detonated; see §2).

## 1.4 Sample provenance

| Field           | Value             |
| --------------- | ----------------- |
| Source          | > TODO            |
| Acquisition date| > TODO            |
| SHA-256         | > TODO            |
| Size (bytes)    | > TODO            |
| Container hash  | > TODO if applicable |
| Cross-reference | Symantec dossier appendix entry: > TODO |

> TODO: Note instructor approval reference (course code, date).
