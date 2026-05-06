# Lab architecture

Two surfaces. The line between them is the line between *looking at bytes* and
*executing bytes*.

```
┌─────────────────────────────────────────────────────────────────────┐
│ Host machine (your laptop)                                          │
│                                                                     │
│  ┌────────────────────────────────┐   ┌──────────────────────────┐  │
│  │ static-lab/  (Docker)          │   │ dynamic-lab/  (Vagrant)  │  │
│  │                                │   │                          │  │
│  │ • YARA, capa, FLOSS            │   │ Win7 x86 SP1 (unpatched) │  │
│  │ • radare2, Ghidra-headless     │   │   • Procmon, Sysmon      │  │
│  │ • pefile, Volatility 3         │   │   • Wireshark            │  │
│  │ • Python tooling               │   │   • x32dbg, WinDbg       │  │
│  │                                │   │   • FakeNet-NG           │  │
│  │ Mounts:                        │   │                          │  │
│  │   ../samples  read-only        │   │ Network: host-only       │  │
│  │   ../analysis read-write       │   │ Snapshots: required      │  │
│  │ Network: NONE (none driver)    │   │                          │  │
│  └────────────────────────────────┘   └──────────────────────────┘  │
│           ↑ static analysis only              ↑ detonation          │
└─────────────────────────────────────────────────────────────────────┘
```

## Why a container is fine for static analysis

The sample sits on disk, mounted read-only. Tools (YARA, capa, FLOSS, radare2,
pefile, Ghidra headless) parse the file as data and emit reports. **No code
from the sample is ever executed.** The container is just a tidy way to
package the toolchain — it isolates the *tools*, not the malware.

## Why a container is **not** isolation for detonation

- Containers share the host kernel. A kernel-mode component (Stuxnet has two
  signed drivers) cannot be safely run in a container — kernel calls hit your
  host kernel.
- Container escape exploits exist; defense in depth wants a hypervisor barrier
  between live malware and your real OS.
- Stuxnet's propagation looks for SMB shares and removable media. Container
  network namespaces don't fully model "removable USB", and a misconfigured
  bridge network can put the container on your LAN.

For execution: VM, host-only network, snapshots, period.

## Why a VM is acceptable

A type-2 hypervisor (VirtualBox / VMware Workstation) on host-only networking
gives you:

- **Hardware-virtualization isolation** (VT-x/AMD-V), a far stronger boundary
  than a namespace.
- **Snapshots**, so a single click reverts a compromised VM.
- **Network isolation**, so the sample's SMB / Print Spooler propagation lands
  on a dedicated subnet you control.

The VM is still not perfectly safe — VM-escape CVEs exist — but combined with
host-only networking and a "one job, one VM" discipline it is the standard
academic and industry practice.

## What you will *not* be able to do safely

- **Run Stuxnet's PLC payload** without a real Siemens S7-315/S7-417 PLC or
  Siemens PLCSim. Don't try to fake it on the host. Document the logic
  statically from the binary.
- **Validate the stolen certificates as if they were live** — they are revoked.
  This is itself a finding.
- **Reproduce zero-day exploitation against a current OS.** All four CVEs are
  patched on supported Windows. Use unpatched Win7/XP VMs in the lab.
