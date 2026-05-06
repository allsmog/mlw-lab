# Sigma rules — Stuxnet behavioral detection

These rules are written against Sysmon / Windows Security event channels
and are intended for the dynamic detonation lab plus general blue-team
applicability. Convert to your SIEM's query language with `sigmac`:

```bash
pip install sigma-cli
sigma convert -t splunk -p sysmon sigma/*.yml
sigma convert -t kibana sigma/*.yml
```

## Coverage

| File                                  | Purpose                                                | ATT&CK    |
| ------------------------------------- | ------------------------------------------------------ | --------- |
| `stuxnet-driver-service-install.yml`  | Service install pointing at suspicious .sys names      | T1543.003 |
| `stuxnet-suspicious-driver-load.yml`  | Driver load with the Realtek/JMicron stolen-cert names | T1014     |
| `stuxnet-explorer-loads-tmp-dll.yml`  | LNK 0-day: explorer.exe loading a `~WTR*.tmp` DLL      | T1204.002 |
| `stuxnet-spooler-write-system32.yml`  | Print Spooler writing into system32 (CVE-2010-2729)    | T1068     |
| `stuxnet-step7-dll-hijack.yml`        | Renamed `s7otbxsx.dll` appearing alongside hijacker    | T1574.001 |

These are **starter** rules. Tighten them with bytes you confirm against
your own sample, and validate they fire (true positive) and don't fire
on benign baselines (false positive control) before deploying.
