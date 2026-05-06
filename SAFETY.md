# SAFETY — read before touching a sample

Stuxnet is live, weaponized malware. It propagates by USB, by SMB, and via Print
Spooler. The version typically distributed in research collections is the
"original" 2010 build; some derivatives still execute on unpatched systems. Treat
every file in `samples/` as if it could pivot to your home network if mishandled.

## Hard rules for this project

1. **Get written instructor approval** before downloading any sample. Save the
   approval message in `docs/instructor-approval.txt` (gitignored; keep locally).
2. **Never run a sample on the host.** Static analysis tools run in the container;
   detonation only ever happens inside the Vagrant VM.
3. **Never connect the analysis machine to a network you care about** while a
   sample is on disk outside the encrypted samples directory. Disable Wi-Fi /
   unplug Ethernet during dynamic runs if your hypervisor supports it.
4. **Never use a USB stick** to move samples between machines. Use the
   container-mounted directory only.
5. **Snapshot before, snapshot after, restore between runs.**
6. **Containers are not isolation for execution.** Static analysis only inside
   the container. Anything that runs `.exe`, `.dll`, or `.sys` code goes in the
   VM.
7. **Do not commit samples, dumps, packed resources, or extracted PE files** to
   git. The `.gitignore` covers the obvious cases — double-check before pushing.
8. **Network isolation must be host-only.** No NAT, no bridged. Validate with
   `ipconfig` from inside the VM: the only reachable host should be the
   hypervisor's host-only adapter.
9. **Stop and ask** if anything surprises you (unexpected child process, network
   connection you didn't expect, the VM resists shutdown). Roll back to snapshot.

## What to do if something goes wrong

- **Sample executed on host:** power off immediately (hard cut, not shutdown),
  do not reboot, contact instructor / IT. Reimage from known-good media.
- **Suspected propagation:** disconnect every cable, leave the machine off,
  contact instructor.
- **Lost track of a sample copy:** assume worst case, locate via SHA-256 hash,
  shred the file (`shred -u`), wipe slack space.

## Acceptable-use disclaimer

This repo is for an authorized educational analysis assignment. Tools and
techniques here are for understanding adversary tradecraft to build defenses.
Do not use this lab against systems you do not own or do not have written
authorization to test.
