# Persistence & stealth analysis

Stuxnet's stealth rests on two kernel drivers signed with stolen
code-signing certificates from Realtek Semiconductor and (later) JMicron
Technology.

## The two drivers

| File         | Role                                                          |
| ------------ | ------------------------------------------------------------- |
| `mrxcls.sys` | Loader. Injects the user-mode payload into target processes.  |
| `mrxnet.sys` | File-system filter. Hides Stuxnet's own files on disk.        |

Both register as kernel services and are auto-started.

## Stolen certificates

- **Realtek Semiconductor Corp.** — both drivers were originally signed with
  this cert. Reported to VeriSign; revoked 2010-07-16.
- **JMicron Technology Corp.** — used in a later sample after the Realtek
  cert was revoked. Also revoked.

Static check (in the container):

```bash
python3 -m signify.authenticode samples/mrxcls.sys
# Inspect:
#   - signer name (Realtek / JMicron)
#   - certificate serial number
#   - countersignature timestamp
#   - revocation status (will fail; the certs are revoked)
```

What to write up:

- The serial numbers of both certs.
- The revocation date (look up via the cert's CRL distribution point).
- Why "signed by a real company" doesn't mean "trustworthy" — supply-chain
  implications.
- Modern mitigations: kernel-mode code-signing requirements (KMCS),
  Microsoft attestation signing, EV cert hardware tokens.

## Service installation

In Procmon during dynamic detonation, watch for:

- Registry writes to `HKLM\SYSTEM\CurrentControlSet\Services\MRxCls` and
  `MRxNet`.
- `ImagePath` pointing at the dropped `.sys` files in `system32\drivers\`.
- A `Start` value of `1` (system) or `0` (boot).

## Rootkit hooks

`mrxnet.sys` is a file-system filter (FSF) driver. It registers with the I/O
manager and intercepts `IRP_MJ_DIRECTORY_CONTROL` queries; when a directory
listing would include a Stuxnet file, the driver removes that entry from the
result.

Static analysis:

```text
- Open mrxnet.sys in Ghidra.
- Find DriverEntry → IoCreateDevice → IoAttachDeviceToDeviceStack.
- Locate the dispatch routine for IRP_MJ_DIRECTORY_CONTROL.
- Identify the filename predicate that decides what to hide
  (Stuxnet hides files starting with "~WTR" and ending in ".TMP",
  among others — confirm against the binary).
```

Dynamic analysis (live VM):

- WinDbg attached to the VM kernel via the host-only serial pipe:
  - `!drvobj mrxnet 2` to see dispatch table.
  - `!devobj` for attached file-system filters.
- Volatility 3 against a memory dump:
  - `vol -f infected.elf windows.modules`
  - `vol -f infected.elf windows.driverirp`
  - `vol -f infected.elf windows.ssdt` (look for hooks).

## What to put in your write-up

1. Cert details for both drivers + revocation timeline.
2. Service install registry trace (Procmon export).
3. Driver dispatch table and the IRP_MJ_DIRECTORY_CONTROL handler in
   pseudo-C.
4. A demonstration: with the rootkit loaded, Explorer / `dir` does *not*
   show the dropped files; with the driver service stopped, they reappear.
5. Modern defenses: HVCI, Driver Signature Enforcement, ELAM, attestation
   signing.
