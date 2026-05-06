# 6. Evasion

## 6.1 Anti-AV checks

> TODO: Dump the full process / service / file-name list Stuxnet checks
> against. Describe the per-product behavior:
>
> - Some products → switch injection technique.
> - Some products → bail entirely.
>
> Source the list from your `floss` / `strings` output.

## 6.2 Environmental keying

The expensive payload only fires when the host *is* the target. Stuxnet's
gate chain:

| # | Check                                | Pass condition          |
| - | ------------------------------------ | ----------------------- |
| 1 | Step7 installed                      | `s7tgtopx.exe` present  |
| 2 | PLC CPU type (via SZL query)         | S7-315-2 or S7-417      |
| 3 | Profibus device count + vendor IDs   | Specific cascade match  |
| 4 | Date < 24 June 2012                  | Kill switch             |

> TODO: For each check, identify the bytes / function in your
> disassembly and the constant being compared against.

> TODO: Flow diagram of the gate chain (figures/keying-flow.png).

## 6.3 Anti-debug / anti-VM (light)

> TODO: Note Stuxnet's relatively modest anti-VM posture, since the
> environmental keying does most of the evasive work. Document any
> `IsDebuggerPresent` / `CheckRemoteDebuggerPresent` / PEB checks you
> identify.

## 6.4 Why this evades sandbox-based AV

> TODO: 1 paragraph. A sandbox that runs the sample for 60 seconds and
> logs behavior will see *nothing interesting* unless the sandbox happens
> to look like a Step7 station with the right Profibus topology. This is
> why public AV missed Stuxnet for so long, and why behavior-based
> detection alone is insufficient against targeted threats — IOC-based
> rules on carried artifacts (drivers, filenames) are needed.

## 6.5 The kill date

> TODO: 24 June 2012 — describe the temporal logic and what happens to a
> sample after the date passes (no new infections; existing infections
> persist until cleaned).
