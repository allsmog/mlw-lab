# Payload analysis (Step7 / WinCC / PLC sabotage)

This is Stuxnet's defining feature: a Windows worm whose ultimate target is
not Windows. Once on a Step7 engineering workstation, it tampers with the
PLC programming workflow to load malicious ladder logic onto specific
Siemens S7-315 / S7-417 PLCs and sabotage centrifuge cascades by manipulating
their variable-frequency drives.

> **You will not detonate this end-to-end** without a real PLC or licensed
> Siemens PLCSim. The Windows side is observable in the dynamic lab; the PLC
> payload is **static-only** for this project.

## The Step7 hijack: `s7otbxdx.dll`

Siemens Step7 IDE talks to PLCs via `s7otbxdx.dll`, which exports functions
like `s7blk_read`, `s7blk_write`, `s7db_open`. Stuxnet:

1. Renames the legitimate DLL to `s7otbxsx.dll`.
2. Drops its own `s7otbxdx.dll` in the same folder.
3. Stuxnet's DLL re-exports every function, **forwarding most calls to
   `s7otbxsx.dll`**, while intercepting a small set:
   - On read of an infected PLC block: returns the *original* clean block
     (so the engineer doesn't see the malicious code).
   - On write: optionally injects malicious blocks alongside the engineer's
     code.

This is a classic DLL hijack via export forwarding.

### Static tasks

```bash
# Confirm the export-forwarder pattern:
python3 -c "
import pefile
pe = pefile.PE('samples/s7otbxdx.dll')
for exp in pe.DIRECTORY_ENTRY_EXPORT.symbols:
    print(exp.name, '->', exp.forwarder)
"
# Most exports should forward to s7otbxsx.<name>; the hijacked ones won't.
```

In Ghidra:

- Find the non-forwarded exports (the hijacked ones).
- Reverse the read/write interceptors to identify:
  - The block IDs (`OB`, `FC`, `FB`, `DB` numbers) Stuxnet hides.
  - The data Stuxnet writes when a target PLC configuration is detected.

## PLC code injection — S7-315 / S7-417

Stuxnet carries two distinct payloads:

1. **S7-315 payload** (the famous one). Targets Profibus / Profinet
   configurations matching specific frequency-converter vendors
   (Vacon NX of Finland, Fararo Paya of Iran). Triggers only when a cascade
   of these drives is detected.
2. **S7-417 payload**. More elaborate, partially encrypted, targeting a
   different PLC family. Believed to target the Natanz cascade protection
   system.

### Static tasks (no execution)

- Extract the S7 binary blocks Stuxnet carries:
  ```bash
  binwalk -e samples/stuxnet.bin
  # The carved files include MC7 bytecode blocks (the PLC's compiled language).
  ```
- Use **Snap7** offline to parse the MC7 structure:
  ```bash
  pip install python-snap7
  # Then a small script to walk the block headers, list OBs / FCs / FBs / DBs.
  ```
- Document the block layout in your report. *Do not* attempt to load these
  onto any real PLC.

## The rotor-frequency sabotage logic

Langner's *To Kill a Centrifuge* is the canonical reverse of this. Summary of
what to identify in the binary:

- A reconnaissance phase: Stuxnet records normal sensor values for ~13 days,
  building a "what does normal look like" profile.
- An attack phase: it temporarily changes the rotor speed setpoints, driving
  the centrifuges to ~1410 Hz (above their safe rotation speed) and then back
  down to ~2 Hz, in patterns timed weeks apart.
- During the attack, sensor values fed back to the SCADA / engineer are
  replaced with the recorded "normal" values — operators see nothing wrong.

### Static tasks

- Identify the constants for target frequencies (~1410 Hz, ~2 Hz, ~1064 Hz
  nominal) inside the carried PLC blocks.
- Identify the data block (DB) used to store the recorded sensor history.
- Document the state machine that gates the attack on time (~13-day delays).

### Why you can't run this part

- It only triggers when paired with a specific PLC topology that includes
  Profinet-connected variable-frequency drives in a particular vendor mix.
- It would manipulate physical rotor speeds, which has no meaningful analog
  in software simulation without industrial-control hardware.

## What to put in your write-up

1. The DLL-hijack mechanism with concrete export-forwarding evidence.
2. Pseudo-code of the read/write interceptors (Ghidra decompilation).
3. Block layout of the carried S7-315 payload.
4. The frequency / timing constants and the recon→attack state machine.
5. A defense discussion: code signing for PLCs, network segmentation between
   IT and OT, integrity attestation for engineering workstations.
