# Dynamic analysis setup

See [`../dynamic-lab/README.md`](../dynamic-lab/README.md) for the operational
checklist. This file explains the *why* behind the choices.

## Why Windows 7 SP1 x86

- Stuxnet is 32-bit. A 64-bit guest cannot run the 32-bit kernel drivers; you'd
  miss the rootkit entirely.
- Windows 7 SP1 reproduces enough of the original target environment to trigger
  the LNK and Print Spooler exploits, while still being recoverable. Windows XP
  SP3 is closer to the original target but harder to obtain a license for.
- Patches for CVE-2010-2568, CVE-2010-2729, MS08-067 are present on a
  fully-updated Win7 — leave the VM unpatched.

## Why host-only networking, no NAT

- NAT would let the sample reach the internet (its C2 servers are dead, but
  any unexpected DNS / HTTP request to a non-Stuxnet host would be a
  containment failure).
- Host-only puts the VM on a private subnet visible only to the host. Combined
  with FakeNet-NG running on the host (or in a second sacrificial VM on the
  same subnet), you get realistic-looking responses to the sample's network
  calls without ever touching a real network.
- SMB / Print Spooler propagation needs a second host on the subnet to
  observe. Use a second Win7 VM if you want to see propagation; both stay on
  host-only.

## Why snapshots, not "just rebuild"

- Stuxnet drops files in many places, installs services, loads kernel
  drivers, and modifies the registry. Manual cleanup is error-prone.
- Snapshots give you an exact-bytes rollback in seconds.
- Rule: **one detonation, one rollback.** Never re-use a dirty VM.

## Why disable VirtualBox extras (clipboard, drag-drop, USB, audio)

Each is an attack surface from the guest to the host. Stuxnet specifically
spreads via removable media — leaving USB on means a USB device passed through
from the host could become a propagation vector if you ever forgot the
isolation rule. Off by default; you can re-enable per-feature only if a
specific experiment requires it.

## Instrumentation order matters

If you start Procmon *after* detonation, you've already missed the dropper.
The order is always:

1. Capture starts (Procmon, Wireshark, Sysmon).
2. Snapshot `pre-detonation`.
3. Detonate.
4. Wait for behaviors to play out (Stuxnet has timed checks; give it minutes).
5. Stop captures, export, hash, copy out via the host-only share.
6. Rollback.

## Memory dump

Take a memory dump while the sample is live — Volatility will give you injected
threads and hidden modules. In VirtualBox:

```bash
VBoxManage debugvm "stuxnet-detonation" dumpvmcore --filename=infected.elf
# On the host, in the static-lab container:
vol -f infected.elf windows.pslist
vol -f infected.elf windows.malfind
vol -f infected.elf windows.modules
```
