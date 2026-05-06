# Instructor approval — email template

Adapt and send. Don't just paste it. The point is to demonstrate that
you've thought about scope, safety, and chain of custody — not to perform
a checklist.

---

**Subject:** Approval request — Stuxnet sample handling for [course code] project

Hi Professor [Last Name],

I'm writing to request written approval to handle a live Stuxnet sample
as part of the [course code] [assignment name / project description].
I've set up an isolated analysis lab and want to confirm scope and
safety with you before downloading anything.

**Project scope.**  Static and dynamic analysis of Stuxnet 1.x along
four axes:

1. Propagation — LNK CVE-2010-2568, Print Spooler CVE-2010-2729,
   MS08-067, USB / SMB lateral movement.
2. Persistence — the `mrxnet.sys` and `mrxcls.sys` kernel drivers and
   the stolen Realtek / JMicron code-signing certificates.
3. Payload — the `s7otbxdx.dll` Step7 hijack and the carried PLC code
   (S7-315 payload). PLC code analysis will be **static-only**; I do
   not have access to Siemens hardware or PLCSim.
4. Evasion — anti-AV checks and environmental keying.

**Lab.**  Two surfaces, both isolated from any network I care about:

- **Static analysis** in a Docker container with `network_mode: none`
  and the sample directory mounted read-only. Tools include Ghidra,
  YARA, capa, FLOSS, radare2, signify, Volatility 3.
- **Dynamic detonation** in a VirtualBox VM (Windows 7 SP1 x86) on a
  host-only network with `vboxnet0` configured static, no gateway, no
  DNS, and host IP forwarding disabled. Snapshots before / after every
  run; one detonation per snapshot rollback.

The full lab and safety policy are in my repo at [repo URL]; the
relevant files are `SAFETY.md`, `docs/01-lab-architecture.md`, and
`docs/04-network-isolation.md`.

**Sample plan.**  I intend to download from [pick one: the course's
hosted server / MalwareBazaar (https://bazaar.abuse.ch) / theZoo /
VX-Underground / Malpedia] and verify the SHA-256 against the
appendix of Falliere/Murchu/Chien, *W32.Stuxnet Dossier* (Symantec,
2011) before doing any analysis. I will not store the sample outside
the lab's encrypted `samples/` directory and will not move it via USB.

**What I'm asking from you:**

1. Written confirmation that handling a Stuxnet 1.x sample is in scope
   for this assignment.
2. Confirmation of the source(s) you'd like me to use (or that the
   listed sources are acceptable).
3. Any specific hashes / variants you want me to include or exclude.
4. Confirmation that the static-only treatment of the PLC payload is
   acceptable (no PLC hardware available).

I'll keep your reply on file as `docs/instructor-approval.txt` (locally,
not committed) and reference it in the methodology section of the
final report.

Happy to come by office hours to walk through the lab in person if
that's easier.

Thanks,
[Your name]
[Course code, section]

---

## Things to double-check before sending

- [ ] Course code, instructor name, and assignment title are filled in.
- [ ] You've actually read `SAFETY.md` and `docs/04-network-isolation.md`.
- [ ] Your repo URL works for the instructor (public or shared).
- [ ] You've picked a *primary* sample source rather than listing all
      five — instructors prefer specifics.
- [ ] You haven't promised more than you can deliver (e.g., don't claim
      you'll detonate the PLC payload).

## After they reply

```bash
# Save the approval reply locally (NOT committed).
$EDITOR docs/instructor-approval.txt
echo "docs/instructor-approval.txt" >> .git/info/exclude  # extra safety
```

Then proceed to `docs/05-sample-acquisition.md`.
