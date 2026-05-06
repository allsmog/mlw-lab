# Propagation analysis

Stuxnet uses four publicly documented propagation paths. For each, the goal of
this section is: (1) identify the trigger inside the binary, (2) describe the
exploited bug, (3) confirm behavior in the dynamic lab where safe, (4) write a
detection.

## 1. LNK 0-day — CVE-2010-2568 ("Shortcut icon loading")

**Bug.** Windows Shell parsed `.lnk` files to render their icon. The parser
loaded the icon from a path inside the LNK without validating it; a crafted
LNK could cause the Shell to call `LoadLibrary` on an attacker-controlled DLL.
Just *displaying* a folder containing the LNK was enough — no double-click.

**Stuxnet artifacts.**

- Multiple `.lnk` files on the USB image, each pointing at the malicious DLL
  via a `CONTROL.EXE`-styled path so different drive letters all hit the same
  payload.
- Companion `~WTR4132.tmp` (the loaded DLL) and `~WTR4141.tmp`.

**Static analysis tasks.**

```bash
# In the static-lab container:
xxd samples/copy.lnk | less                   # inspect the LinkInfo / IDList
python3 -c "import lief; print(lief.parse('samples/~WTR4132.tmp').imports)"
yara -r yara/stuxnet.yar samples/
```

What to find / write up:

- The IDList structure inside the LNK and where the controlled path lives.
- The DLL's exported entry, what it does on load (DllMain).
- How Stuxnet selects between 32-bit and 64-bit payloads.

**Dynamic analysis (host-only VM, snapshot before).**

1. Mount a virtual disk image containing the LNK + DLL as a USB-style device,
   read-only, on the unpatched Win7 VM.
2. Open Explorer to the disk; the LNK icon parse triggers exploitation
   without a click.
3. Procmon will show `explorer.exe` loading the malicious DLL.

**Detection.** YARA rule `Stuxnet_LNK_Loader` in `yara/stuxnet.yar`. For real
defenders: MS10-046 patch + AppLocker / WDAC blocking unsigned DLL loads from
removable media.

---

## 2. Print Spooler — CVE-2010-2729

**Bug.** The Windows Print Spooler service exposed an RPC interface that did
not properly authenticate write-file operations under certain conditions. A
remote attacker on the same network as a printer-sharing host could write a
file into `%WINDIR%\system32\` and then trick the spooler into executing it.

**Stuxnet artifacts.** Calls into `winspool.drv` / RPC interfaces with
forged `EnumPrinters` / `StartDocPrinter` sequences.

**Static analysis tasks.**

- Look for imports of `winspool.drv`, references to `\\PIPE\\spoolss`,
  `EnumPrinters`, `StartDocPrinter`, `WritePrinter`.
- Trace where the spooler-targeting code dispatches from — likely a network
  propagation thread.

**Dynamic analysis.** Two unpatched Win7 VMs on the host-only network, both
sharing a printer. Detonate on host A; observe SMB / spooler traffic to host B
in Wireshark; observe a new file appearing in `system32` on host B in Procmon.

**Detection.** YARA rule + network-IDS signature for the unusual `StartDoc`
sequence. For defenders: MS10-061 patch.

---

## 3. MS08-067 — Server service (`netapi32`) RCE

**Bug.** Path-canonicalization flaw in `NetPathCanonicalize` inside the Server
service let an attacker send a crafted RPC request causing a stack overflow
and code execution.

**Stuxnet artifacts.** Calls into `\\PIPE\\browser` / `\\PIPE\\srvsvc`,
crafted UNC paths with `..\..\..\..` traversal sequences.

**Static analysis tasks.**

- Find the shellcode payload that's sent to the vulnerable RPC endpoint.
- Identify the OS-version-specific offsets Stuxnet supplies (it carries
  several).

**Dynamic analysis.** Host-only network, target VM with Server service
running, unpatched. Detonate on host A; observe `services.exe` crash /
shellcode execution on host B.

**Detection.** Snort / Suricata rule for the canonical MS08-067 PoC bytes;
YARA against the carried shellcode. For defenders: MS08-067 patch (2008).

---

## 4. USB and SMB shares (post-exploitation propagation)

In addition to the two CVEs above, Stuxnet copies itself to:

- Removable media — fresh `.lnk`s + the loader DLL, so the LNK 0-day re-fires
  on the next host.
- Any writable SMB share it can authenticate to via stolen credentials,
  spreading laterally inside an organization.

**Static analysis tasks.**

- Locate the file-copy routines: `CopyFileW`, `WriteFile` to `\\?\` paths,
  `WNetEnumResource`, `WNetAddConnection2` for SMB enumeration.
- Identify the credential-harvesting code path (LSASS reads /
  `CredEnumerate`).

**Dynamic analysis.** Use a second VM with a writable share; observe the
sample enumerating shares and writing files.

**Detection.** YARA on the carried filenames (`~WTR4132.tmp`, `~WTR4141.tmp`)
and on the LNK/DLL pair pattern.

---

## What to put in your write-up

For each of the four:

1. CVE / bug class.
2. Original disclosure date and patch date.
3. The exact bytes / functions in the binary that implement the trigger
   (Ghidra screenshot or pseudo-code).
4. The behavior captured in your dynamic run (Procmon trace excerpt, pcap).
5. Your YARA/Snort detection and an evaluation of false-positive risk.
