# samples/

Drop authorized Stuxnet samples here.

**This directory is .gitignored.** Files placed here will never be committed
to git. Do not remove the gitignore entry.

Before adding a sample:

1. Read `../SAFETY.md`.
2. Get instructor approval in writing.
3. Verify the SHA-256 against the approved list (`../scripts/verify-hashes.sh`).
4. Keep samples password-protected (`7z a -pinfected stuxnet.7z stuxnet.bin`)
   when not actively in use.
5. Never sync this folder to cloud storage.
