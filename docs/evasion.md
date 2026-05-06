# Evasion analysis

Stuxnet's evasion has two sides: passive checks against the analyst's
environment, and aggressive *environmental keying* so that the malicious
payload only fires inside the intended target site.

## Anti-AV / anti-analysis

The dropper enumerates running processes and registered services to detect
and avoid common security products of the era:

- Kaspersky (`avp.exe`)
- McAfee (`mcshield.exe`)
- Symantec / Norton (`rtvscan.exe`, `ccsvchst.exe`)
- TrendMicro, ETrust, F-Secure, etc.

Static tasks:

- Locate the embedded list of process / service / file names.
- Identify the dispatch logic: some AVs caused Stuxnet to use a different
  injection technique; some caused it to bail entirely.
- Note that detection lookups are typically string comparisons against
  `Process32First`/`Process32Next` results.

```bash
# Pull the comparison strings:
floss samples/stuxnet.bin | grep -iE 'avp|mcshield|rtvscan|ccsvchst|trend|f-secure|etrust'
```

## Environmental keying

The expensive payload only runs if the host *is* the target. Stuxnet checks:

1. **Step7 installation present.** Looks for `s7tgtopx.exe`, the Step7
   environment, in `Program Files`. No Step7, no PLC payload.
2. **Specific PLC type connected.** Once on a Step7 station, when the engineer
   talks to a PLC, Stuxnet inspects the PLC's CPU type (`SZL` query).
   Only S7-315-2 with specific configuration, or S7-417, proceed.
3. **Specific Profibus device count.** S7-315 payload checks for the precise
   number of Profibus slaves and the right vendor IDs (Vacon / Fararo Paya).
4. **Date checks.** Stuxnet has a kill date (`24 June 2012`). After that, it
   stops infecting new hosts.

Static tasks:

- Find each gate. They're typically a sequence of `cmp / je` against
  hard-coded constants.
- Document the constants and what each one represents.
- Build a truth table: what does Stuxnet do if (a) Step7 absent, (b) Step7
  present but wrong PLC, (c) right PLC but wrong drive count, (d) all gates
  pass?

Why this matters for the write-up: environmental keying is *the* reason
Stuxnet was hard to attribute and hard to detect with general-purpose AV. A
sample running in a sandbox simply does nothing interesting unless the
sandbox happens to look like Natanz. Modern targeted malware borrows this
pattern (Equation Group's `LNK_FANNY`, various APT loaders).

## Anti-debugger / anti-VM checks

Stuxnet is comparatively *light* on these — its environmental keying makes
heavy anti-VM checks unnecessary. But you may still find:

- `IsDebuggerPresent`, `CheckRemoteDebuggerPresent`.
- PEB `BeingDebugged` byte read.
- Timing-based checks (`GetTickCount` deltas).

Static tasks:

- Locate any of the above and patch them out in your Ghidra project copy if
  needed for further analysis (do this on a *copy*, not the original).

## What to put in your write-up

1. The AV avoidance list, verbatim, with each product Stuxnet treats specially.
2. The environmental-keying gate chain, as a flow diagram.
3. The kill date and other temporal logic.
4. A discussion of detection: why generic dynamic analysis missed Stuxnet for
   so long, and what kinds of detection (YARA on carried artifacts, ICS
   network monitoring) actually catch this class of threat.
