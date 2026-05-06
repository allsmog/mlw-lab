# 7. Detection and defenses

## 7.1 Detections developed in this study

### 7.1.1 YARA rules

> TODO: Reproduce each rule from `yara/stuxnet.yar` with a short
> commentary on what it catches and the false-positive risk.

### 7.1.2 Sigma rules

> TODO: Reproduce each rule from `sigma/` with the same commentary,
> mapping it to MITRE ATT&CK techniques (Driver Service Install =
> T1543.003, etc.).

### 7.1.3 Network signatures

> TODO: Snort/Suricata rules, if you wrote any, for the SMB and Print
> Spooler propagation traffic.

## 7.2 Mapping to MITRE ATT&CK

> TODO: Table mapping each Stuxnet behavior to its ATT&CK technique ID:
>
> | Behavior                          | Technique  |
> | --------------------------------- | ---------- |
> | Removable-media infection         | T1091      |
> | Replication via SMB shares        | T1021.002  |
> | Stolen code-signing certificate   | T1553.002  |
> | Rootkit (file-system filter)      | T1014      |
> | Process injection                 | T1055      |
> | Modify system image / hijack DLL  | T1574.001  |
> | Disable / modify tools            | T1562.001  |
> | Time-based evasion                | T1497.003  |
> | Impair process control (ICS)      | T0831      |
> | Manipulate I/O image (ICS)        | T0835      |

## 7.3 Defense in depth

> TODO: Layered defenses, organized by the four axes:
>
> - **Propagation defenses** — patch management, removable-media
>   policies, AppLocker / WDAC, network segmentation, deny-by-default
>   SMB.
> - **Persistence defenses** — HVCI, DSE, ELAM, attestation signing,
>   short-lived signing certs.
> - **Payload defenses (ICS-specific)** — Purdue-model segmentation,
>   integrity attestation for engineering workstations, hardware
>   overspeed safety interlocks.
> - **Evasion defenses** — IOC-based detection (carried artifacts),
>   defense-side environmental awareness (would your detection see
>   "drivers signed by an unfamiliar vendor on this network"?).

## 7.4 Lessons that generalize

> TODO: 2–3 paragraphs on what Stuxnet taught the industry — that the
> air gap is not a defense, that signed drivers must be verified by
> *origin*, that ICS visibility is essential, that targeted malware
> looks nothing like commodity malware in a sandbox.
