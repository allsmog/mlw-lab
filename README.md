# mlw-lab — Stuxnet Analysis (school project)

A reproducible lab for studying Stuxnet across four axes:

1. **Propagation** — LNK 0-day (CVE-2010-2568), Print Spooler (CVE-2010-2729), MS08-067, USB & SMB shares.
2. **Persistence / stealth** — signed kernel drivers (Realtek/JMicron stolen certs), rootkit hooks.
3. **Payload** — Step7/WinCC DLL hijack (`s7otbxdx.dll`), PLC code injection on Siemens S7-315/417, rotor-frequency sabotage logic.
4. **Evasion** — anti-AV checks, environmental keying.

> **Read [`SAFETY.md`](SAFETY.md) before doing anything.** Stuxnet is live, signed, propagating malware. Get instructor sign-off in writing before pulling samples.

## Two analysis surfaces

| Surface  | Where it runs                            | What it's for                                                                 |
| -------- | ---------------------------------------- | ----------------------------------------------------------------------------- |
| Static   | `static-lab/` Docker container           | Inspecting a sample without executing it: YARA, capa, FLOSS, radare2, Volatility, etc. |
| Dynamic  | `dynamic-lab/` Vagrant VM (Win7 x86)     | Detonating in an isolated VM with snapshots and host-only networking.         |

**A container is *not* a sandbox for executing malware.** Containers share the host kernel; Stuxnet's kernel drivers (`mrxnet.sys`, `mrxcls.sys`) cannot be safely contained that way. Use the container only to run analysis tools against the sample at rest. See [`docs/01-lab-architecture.md`](docs/01-lab-architecture.md).

## Layout

```
.
├── README.md
├── SAFETY.md
├── Makefile                    # convenience: make build / make shell / make triage SAMPLE=...
├── docs/
│   ├── 01-lab-architecture.md
│   ├── 02-static-analysis-setup.md
│   ├── 03-dynamic-analysis-setup.md
│   ├── 04-network-isolation.md
│   ├── 05-sample-acquisition.md
│   ├── 06-first-session.md     # 60-minute session-1 walkthrough
│   ├── propagation.md
│   ├── persistence.md
│   ├── payload.md
│   └── evasion.md
├── static-lab/
│   ├── Dockerfile              # REMnux-style static analysis image
│   ├── docker-compose.yml      # mounts samples/ read-only, no network
│   ├── extra-ca.crt            # placeholder for proxy CA (PEM)
│   └── tools/install-extra.sh
├── dynamic-lab/
│   ├── Vagrantfile             # detonator + target VMs (host-only)
│   ├── fakenet/fakenet.ini     # FakeNet-NG config tuned for Stuxnet
│   └── README.md
├── yara/
│   └── stuxnet.yar             # starter detection rules
├── sigma/                      # behavioral detection rules (Sysmon-based)
│   └── *.yml
├── scripts/
│   ├── verify-hashes.sh        # SHA-256 check against an allowlist
│   ├── triage.sh               # PE triage + capa + YARA + FLOSS
│   └── carve-resources.py      # carve embedded blobs from the PE resource section
├── samples/                    # gitignored; drop authorized sample(s) here
├── analysis/                   # raw outputs and rough notes, per axis
│   ├── propagation/
│   ├── persistence/
│   ├── payload/
│   └── evasion/
└── report/                     # markdown source for the academic write-up
    ├── 00-abstract.md  ...  08-conclusion.md
    └── references.md
```

## Quick start (static analysis only)

```bash
# 1. Build the analysis container.
make build

# 2. Drop an authorized sample into samples/ (see docs/05-sample-acquisition.md).
#    DO NOT commit it. Verify the hash:
make verify

# 3. Run automated triage (PE info + capa + YARA + FLOSS).
make triage SAMPLE=samples/stuxnet.bin

# 4. Drop into a shell with all the tools available.
make shell
```

## Quick start (dynamic detonation)

```bash
cd dynamic-lab
# Read README.md FIRST — you must:
#   - confirm host-only networking
#   - take a snapshot
#   - get instructor approval
vagrant up
```

## Scope honesty

Some pieces of this project you can fully replicate; some you can't:

- **LNK exploit** — yes, the trigger is reproducible against an unpatched Win7 VM with a USB image.
- **Print Spooler / MS08-067** — yes, against unpatched VMs on the host-only network.
- **Signed driver loading** — yes, but the stolen certs are revoked; you'll see signature-verification failures, which is itself a finding.
- **Rootkit hooks** — yes, observable with WinDbg / Volatility.
- **Step7 DLL hijack** — partial; you can observe the hijack mechanism statically, but full execution needs Siemens Step7 (commercial).
- **PLC code injection / rotor sabotage** — **static only.** This requires a real S7-315 or S7-417 PLC, or PLCSim. Document the logic from the binary; don't try to execute it.
- **Stolen-cert validation** — static only.

## Citations to start with

- Falliere, Murchu, Chien — *W32.Stuxnet Dossier* (Symantec, 2011).
- Langner — *To Kill a Centrifuge* (2013).
- Matrosov, Rodionov, Harley, Malcho — *Stuxnet Under the Microscope* (ESET).
- Kaspersky — *Stuxnet/Duqu: The Evolution of Drivers*.
- Zetter — *Countdown to Zero Day* (2014).
