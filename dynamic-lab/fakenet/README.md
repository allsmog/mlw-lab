# FakeNet-NG configuration

`fakenet.ini` is a Stuxnet-tuned config: DNS answers everything,
HTTP/HTTPS log to disk, SMB/NetBIOS listeners are up so the sample's
share-enumeration / lateral-movement code has something to talk to.

## Where to run it

Two reasonable spots:

1. **On the host**, bound to the VirtualBox host-only adapter
   (`192.168.56.1`). The detonator VM's DNS is set to this address.
2. **In a small sacrificial VM** on the same host-only subnet
   (`192.168.56.50` or similar), if you'd rather not run a network
   listener on your laptop. Trade-off: more setup, less host risk.

## Running

```bash
# Install (one time)
pip install flare-fakenet-ng

# Run
sudo python3 -m fakenet -c dynamic-lab/fakenet/fakenet.ini
```

FakeNet writes pcap captures and per-protocol logs to its working
directory. Copy them out into `analysis/propagation/` after each run.

## Pointing the detonator at FakeNet

Inside the detonator VM, before the snapshot:

```cmd
:: Set DNS to the host-only adapter address.
netsh interface ip set dnsservers "Local Area Connection" static 192.168.56.1

:: Confirm.
ipconfig /all
nslookup google.com
:: → should resolve to 192.168.56.1 (FakeNet's wildcard answer).
```

## What you should see during a Stuxnet detonation

- DNS lookups for Stuxnet's historical C2 domains
  (`mypremierfutbol.com`, `todaysfutbol.com`).
- HTTP GET requests with `index.php?data=<encoded>` query strings.
- SMB enumeration traffic (`\\PIPE\\srvsvc`, `\\PIPE\\browser`,
  `\\PIPE\\spoolss`).

Snippet these into the report's propagation chapter as evidence.
