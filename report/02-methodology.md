# 2. Methodology

## 2.1 Two analysis surfaces

A reproducible two-surface lab was used:

- **Static analysis** in a Docker container with no network and a
  read-only sample mount. Tools: YARA, capa, FLOSS, radare2, pefile,
  signify, Volatility 3, Ghidra (headless and GUI). The sample is never
  executed in this surface.
- **Dynamic analysis** in a VirtualBox VM running Windows 7 SP1 x86 on a
  host-only network, with snapshots taken before each detonation.

> TODO: Diagram of the lab (figures/lab-architecture.png — adapt the
> ASCII diagram from docs/01-lab-architecture.md).

## 2.2 Why a container is sufficient for static analysis

> TODO: 1 paragraph. Containers share the host kernel, so they are not a
> safe boundary for executing kernel-mode malware. They *are* a clean
> environment for running analysis tools that parse the sample as data.
> The static container has `network_mode: none` and mounts the sample
> read-only, ensuring tool failure cannot exfiltrate or execute.

## 2.3 Why a hypervisor is required for dynamic analysis

> TODO: 1 paragraph. Hardware-assisted virtualization (VT-x / AMD-V)
> provides the isolation that containers lack; combined with host-only
> networking and snapshots it is the academic and industry standard for
> live-malware detonation.

## 2.4 Reproducibility

The lab is published at `<repo URL>` and built with one command
(`make build`). The `.gitignore` enforces sample non-commit. Hashes of
all carved artifacts are recorded in `analysis/<axis>/`.

## 2.5 Limitations

> TODO: Be explicit. The PLC payload was analyzed statically only — no
> Siemens hardware or licensed PLCSim was available. Stolen-cert
> verification produces revoked-cert errors (a finding in itself, not a
> failure). Some propagation paths (Print Spooler, MS08-067) require a
> second VM and were/were not exercised in this study (state which).
