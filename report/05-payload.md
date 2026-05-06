# 5. Payload — Step7, WinCC, and the PLC sabotage

## 5.1 The s7otbxdx.dll hijack

> TODO: Explain the export-forwarding mechanism. Renamed legitimate DLL
> becomes `s7otbxsx.dll`; Stuxnet's `s7otbxdx.dll` re-exports every
> function, forwarding most calls to the legitimate one and intercepting
> a small set (block read/write).

### 5.1.1 Forwarded vs. hooked exports

> TODO: Table from your `pefile` walk of the exports — which forward to
> `s7otbxsx`, which do not. The hooked subset is what you analyze.

### 5.1.2 The read interceptor

> TODO: Pseudo-C from Ghidra. When Step7 reads an infected PLC block,
> the hooked function returns the *original* clean block to the engineer.

### 5.1.3 The write interceptor

> TODO: Pseudo-C. When Step7 writes a new block, Stuxnet may inject
> additional malicious blocks alongside.

## 5.2 The PLC payloads

### 5.2.1 S7-315 payload — the centrifuge attack

> TODO: Describe the carried MC7 blocks (OB35 trigger, FCs / FBs
> implementing the attack state machine). Identify the targeted
> Profibus configuration (Vacon NX / Fararo Paya frequency-converter
> mix). Note this section is static-only; include carved block hashes.

### 5.2.2 S7-417 payload — the cascade-protection attack

> TODO: Briefly describe the second, partially encrypted payload.

## 5.3 The rotor-frequency sabotage logic

### 5.3.1 Reconnaissance phase

> TODO: ~13-day learning window. Stuxnet records sensor values during
> normal operation, building a "what does normal look like" buffer in a
> data block. Identify the DB used.

### 5.3.2 Attack phase

> TODO: Frequency excursions: ~1410 Hz (well above the 1064 Hz nominal
> rotor speed → stress fractures), and ~2 Hz (well below → imbalance).
> Identify the constants in the binary.

### 5.3.3 Sensor spoofing during the attack

> TODO: While the attack runs, the recorded "normal" sensor values are
> replayed to the SCADA / engineer view. Describe the replay logic.

## 5.4 What was *not* reproduced

> TODO: Honest scope statement. The PLC payload was not detonated;
> conclusions about its runtime behavior come from static analysis and
> from Langner's *To Kill a Centrifuge*. Cite explicitly.

## 5.5 Defense recommendations

> TODO: Network segmentation (Purdue model), authenticated PLC
> programming, integrity attestation for engineering workstations,
> physical safety interlocks at the drive (hardware overspeed limit
> independent of PLC).
