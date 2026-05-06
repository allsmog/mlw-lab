# 4. Persistence and stealth

## 4.1 The two kernel drivers

| File         | Role                                  | Cert subject (signer) |
| ------------ | ------------------------------------- | --------------------- |
| `mrxcls.sys` | User-mode payload loader              | > TODO                |
| `mrxnet.sys` | File-system filter (file hiding)      | > TODO                |

> TODO: Brief paragraph on why two drivers were used (separation of
> concerns: load vs. hide).

## 4.2 The stolen certificates

### 4.2.1 Realtek Semiconductor Corp.

> TODO: Cert serial, validity dates, revocation date (VeriSign,
> 2010-07-16). Show the output of `python3 -m signify.authenticode`
> redacted to the relevant fields.

### 4.2.2 JMicron Technology Corp.

> TODO: Same fields. Note the temporal sequence — JMicron was used after
> the Realtek cert was revoked.

### 4.2.3 Why "signed" did not mean "trusted"

> TODO: Discuss the implicit trust users placed in Authenticode at the
> time, and the modern mitigations (KMCS, EV cert hardware tokens,
> Microsoft attestation signing, HVCI).

## 4.3 Service installation

> TODO: Procmon excerpt showing registry writes to
> `HKLM\SYSTEM\CurrentControlSet\Services\MRxCls` and `MRxNet`,
> including ImagePath and Start values.

## 4.4 Rootkit hooks

### 4.4.1 mrxnet.sys as a file-system filter

> TODO: Describe the IRP_MJ_DIRECTORY_CONTROL hook, the filename
> predicate (matches "~WTR" prefix and ".TMP" suffix, etc.), and how it
> filters directory enumeration responses.

### 4.4.2 Demonstration

> TODO: Side-by-side `dir` output with the driver loaded vs. unloaded.

## 4.5 Defense recommendations

> TODO: HVCI, Driver Signature Enforcement (DSE), Early Launch Anti-Malware
> (ELAM), attestation signing, code-signing-cert hygiene (HSM-backed keys,
> short-lived certs).
