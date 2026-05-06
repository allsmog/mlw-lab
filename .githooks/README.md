# Git hooks

`pre-commit` blocks accidental commits of malware samples and other
binary artifacts. Triggers on PE / ELF / Mach-O magic bytes, on common
binary file extensions, and on anything under `samples/`.

## Enable for this repo

Run once after cloning:

```bash
git config core.hooksPath .githooks
```

That's a per-repo setting; it does not affect any other clone you have.

## Test it

```bash
echo -ne 'MZ\x90\x00' > /tmp/fake.exe
cp /tmp/fake.exe ./oops-i-staged-malware
git add ./oops-i-staged-malware
git commit -m "oops"
# → hook refuses; exit 1; nothing committed.
git restore --staged ./oops-i-staged-malware
rm ./oops-i-staged-malware /tmp/fake.exe
```

## Override

If you've genuinely got a benign binary you want to commit (probably you
don't), bypass with:

```bash
git commit --no-verify
```

Don't make a habit of it.
