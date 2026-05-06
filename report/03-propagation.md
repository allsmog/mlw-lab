# 3. Propagation

## 3.1 LNK 0-day — CVE-2010-2568

### 3.1.1 The bug

> TODO: 2–3 sentences on the icon-loading path inside the Shell, the
> CONTROL.EXE redirection, and how mere display of a folder is enough to
> trigger a `LoadLibrary` on attacker-controlled bytes. Cite MS10-046.

### 3.1.2 Stuxnet's implementation

> TODO: Describe the LNK files Stuxnet drops (multiple per USB image,
> different drive letters), the loader DLLs (`~WTR4132.tmp`,
> `~WTR4141.tmp`), and the 32/64-bit selection logic. Include a
> hex-dump excerpt of one LNK's IDList.

### 3.1.3 Reproduction

> TODO: Procmon trace excerpt showing `explorer.exe` loading the
> malicious DLL after opening the folder.

### 3.1.4 Detection

> TODO: Reproduce your YARA rule and argue its false-positive risk.
> Cross-reference Sigma rule sigma/stuxnet-lnk-loader.yml.

---

## 3.2 Print Spooler — CVE-2010-2729

### 3.2.1 The bug
> TODO

### 3.2.2 Stuxnet's implementation
> TODO

### 3.2.3 Reproduction
> TODO

### 3.2.4 Detection
> TODO

---

## 3.3 MS08-067 — Server service RCE

### 3.3.1 The bug
> TODO

### 3.3.2 Stuxnet's implementation
> TODO

### 3.3.3 Reproduction
> TODO

### 3.3.4 Detection
> TODO

---

## 3.4 USB and SMB lateral movement

> TODO: Describe the file-copy primitives, share enumeration, and credential
> reuse. Distinguish between propagation-via-exploit (3.1–3.3) and
> propagation-via-authenticated-share-write covered here.
