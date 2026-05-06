# dynamic-lab — detonation VM

Windows 7 SP1 x86, host-only network, snapshot-driven.

## Prereqs

- VirtualBox 7.0+ (or convert the Vagrantfile to libvirt/VMware as needed).
- Vagrant 2.4+.
- A Windows 7 SP1 x86 base box you are licensed to use. Set its name with:
  ```bash
  export WIN7_BOX=win7-sp1-x86-analyst
  ```
- ~30 GB free disk. 4 GB RAM headroom.

## One-time bootstrap

```bash
vagrant up         # builds the VM, installs analyst tools (Sysinternals, Wireshark, x64dbg, FakeNet-NG, ...)
vagrant halt       # shut down cleanly
# In VirtualBox GUI: take snapshot "clean-tools-installed".
```

After bootstrap, the VM should never reach the internet again. See
[`../docs/04-network-isolation.md`](../docs/04-network-isolation.md) to verify.

## Each detonation run

1. **Restore** to `clean-tools-installed`.
2. **Verify isolation** — open `cmd` in the VM, `ipconfig`, confirm only the
   host-only adapter is up. `ping 8.8.8.8` must fail.
3. **Copy in the sample** — through the host-only network from a tiny SMB
   server on your host (or via VirtualBox's shared folder *only* with `read-only`
   set; otherwise leave shared folders off and use SMB).
4. **Take a fresh snapshot** called `pre-detonation`.
5. **Start instrumentation** before you double-click anything:
   - Procmon: filter `Process Name is not procmon.exe`.
   - Wireshark: capture on the host-only adapter from your host.
   - Sysmon (if installed): `Get-WinEvent Microsoft-Windows-Sysmon/Operational`.
   - FakeNet-NG: `python -m fakenet` (provides fake DNS/HTTP/SMB so the sample's
     network calls resolve).
6. **Detonate**. For Stuxnet specifically:
   - Original dropper is a `.lnk` + companion files on a "USB image" — present
     this to Win7 via a virtual disk attached read-only.
   - Note the dropped files: `~WTR4132.tmp`, `~WTR4141.tmp`, `mrxnet.sys`,
     `mrxcls.sys`.
   - Watch for service installation, kernel driver load, and SMB / Print Spooler
     traffic.
7. **Capture artifacts** — copy logs, Procmon `.PML`, pcap, dropped files into
   the host via the host-only SMB share. Hash everything.
8. **Roll back** to `pre-detonation` (or `clean-tools-installed` for a fresh
   environment).

## Things to validate before each run

```text
[ ] Network adapter set to host-only (NOT NAT, NOT bridged).
[ ] No port-forwards configured.
[ ] No second NIC present in VM settings.
[ ] Shared folders disabled (or RO + empty).
[ ] Clipboard sharing disabled.
[ ] USB controller disabled.
[ ] Snapshot "pre-detonation" exists.
[ ] Host antivirus excluded from samples/ (so it doesn't quarantine evidence)
    AND host antivirus enabled everywhere else.
```

## Windows configuration to make Stuxnet observable

Disable the things that would otherwise mask behavior:

```powershell
# Inside the VM, as Administrator, BEFORE the clean snapshot.
Set-MpPreference -DisableRealtimeMonitoring $true     # Defender off (it would block)
Set-Service -Name wuauserv -StartupType Disabled       # no auto-patches
sc.exe config sppsvc start= disabled
# Enable PowerShell + Sysmon logging.
auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable
```

These weakenings exist on purpose to give the malware room to act so you can
observe it. They are **never** acceptable on a non-detonation host.
