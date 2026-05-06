# theZoo — Stuxnet variants

Public repository: <https://github.com/ytisf/theZoo>

theZoo ships **three** Stuxnet-related bundles. The metadata below was
fetched from the repo's public `.md5`, `.sha256`, and `.pass` text
files — no `.zip` was downloaded into this lab on your behalf. Pull the
zip yourself; verify against these hashes before extracting.

## Variants

### 1. `Win32.Stuxnet.B.Duqu-Realtek` — **the canonical 2010 dropper**

This is the famous Stuxnet 1.x signed with the stolen Realtek cert. If
your assignment says "Stuxnet" without qualifier, it's almost certainly
this one.

```
Path:    malware/Binaries/Win32.Stuxnet.B.Duqu-Realtek/
Zip:     Win32.Stuxnet.B.Duqu-Realtek.zip   (~56 KB)
Pass:    infected
MD5:     c5d82342430cfd542bc287b178025e5f
SHA-256: 7dafe09a44e72c7b6522319e40c3fadcbad7a0b42d584988a1be8de818689896
```

### 2. `Win32.Stuxnet.A.Duqu-C-Media` — variant A

Earlier or alternate variant signed with a C-Media certificate.

```
Path:    malware/Binaries/Win32.Stuxnet.A.Duqu-C-Media/
Zip:     Win32.Stuxnet.A.Duqu-C-Media.zip   (~13 KB)
Pass:    infected
MD5:     1c35a13a0da0ea687100a7b273f9a5af
SHA-256: dc859fe1e4f877b314b9455e1b4a1d920c325f5a3b3cd90637c6431346f77194
```

### 3. `TrojanWin32.Duqu.Stuxnet` — Duqu+Stuxnet bundle

A Duqu-related bundle that includes Stuxnet artifacts. Useful if your
project also covers Duqu (the Stuxnet "cousin" that shares the Tilded
platform).

```
Path:    malware/Binaries/TrojanWin32.Duqu.Stuxnet/
Zip:     TrojanWin32.Duqu.Stuxnet.zip       (~13 KB)
Pass:    infected
MD5:     03bb47f461c51203d6799919dbb37012
SHA-256: 152c64365b6224e065e18d9a3421adbf94eb231aa93ac242675c6c45c7929c97
```

## Acquiring (3 minutes, you do this)

```bash
# Pick the variant your instructor approved. Realtek is the default.
VARIANT=Win32.Stuxnet.B.Duqu-Realtek
EXPECTED_SHA=7dafe09a44e72c7b6522319e40c3fadcbad7a0b42d584988a1be8de818689896

# Pull *only* that one zip. No need to clone the whole repo.
curl -fL -o samples/$VARIANT.zip \
  "https://raw.githubusercontent.com/ytisf/theZoo/master/malware/Binaries/$VARIANT/$VARIANT.zip"

# Verify the zip integrity BEFORE extracting.
echo "$EXPECTED_SHA  samples/$VARIANT.zip" | sha256sum -c -
# → must print "OK". Anything else: stop, delete, ask your instructor.

# Keep it encrypted on disk; only extract inside a snapshotted detonation VM
# (or under your static-lab container's read-only mount).
ls -la samples/
```

## Two layers of hashes

Be precise in your report — there are *two* hashes that matter for each
variant, and they are different things:

| Hash                        | What it identifies                                           | Where it lives                  |
| --------------------------- | ------------------------------------------------------------ | ------------------------------- |
| **`.zip` SHA-256** (above)  | Confirms you pulled the bytes theZoo intended to ship.       | theZoo's `.sha256` file.        |
| **Dropper PE SHA-256**      | The actual malware binary inside the zip. Cross-references the Symantec dossier appendix. | Compute after `unzip -P infected`. |

After extraction, hash the dropper itself and add that hash to
`scripts/verify-hashes.sh` — that's the one your `make verify` will
match against, and it's the hash you cite in the report's chain of
custody.

## Acceptable-use, again

theZoo's README is explicit: live malware, isolated VM, no internet, no
guest additions. Do not extract the zip outside the dynamic-lab VM (or
the static-lab container's read-only `samples/` mount, where it can't
execute). Never sync `samples/` to cloud storage.
