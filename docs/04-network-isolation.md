# Network isolation

The single most important rule of this lab: **the detonation VM never reaches
a network that matters.**

## What "host-only" actually means

VirtualBox creates a private virtual switch. The VM and the host both have an
interface on that switch. Nothing else does. There is *no* route from that
switch to the internet unless the host machine forwards traffic — which by
default it does not.

```
   internet
       │
       ╳   ← no route by default
       │
[ host machine ]──[ vboxnet0  192.168.56.1/24 ]──[ Win7 VM  192.168.56.10 ]
```

## Configure & verify

### VirtualBox host-only network

1. **VirtualBox → Tools → Network Manager → Host-only Networks → Create.**
2. Subnet: `192.168.56.0/24`. Disable the DHCP server (we set static IPs).
3. In the VM settings → Network:
   - Adapter 1: **Host-only Adapter**, name `vboxnet0`.
   - Adapter 2/3/4: **Not attached**.
4. In the VM, set IP `192.168.56.10/24`, no gateway, no DNS.

### Block accidental host-level routing

On Linux host:

```bash
# Confirm IP forwarding is OFF.
sysctl net.ipv4.ip_forward       # should be 0
# If 1, disable for this session:
sudo sysctl -w net.ipv4.ip_forward=0
# Belt-and-suspenders firewall rule against the vbox subnet:
sudo iptables -I FORWARD -s 192.168.56.0/24 -j DROP
sudo iptables -I FORWARD -d 192.168.56.0/24 -j DROP
```

On macOS host:

```bash
# Confirm forwarding off.
sysctl net.inet.ip.forwarding    # should be 0
sudo sysctl -w net.inet.ip.forwarding=0
```

On Windows host:

```powershell
# Confirm RemoteAccess service is stopped (it enables NAT).
Get-Service RemoteAccess         # Status should be Stopped, StartType Disabled
# In the host firewall, block outbound from the host-only adapter:
New-NetFirewallRule -DisplayName "BlockVBoxHostOnlyOutbound" `
  -Direction Outbound -InterfaceAlias "VirtualBox Host-Only Network" -Action Block
```

## Verify from inside the VM

```cmd
ipconfig /all
```

Expected:

- Exactly one active interface, on `192.168.56.0/24`.
- No default gateway.
- DNS servers empty.

```cmd
ping 8.8.8.8                   :: must time out
ping 192.168.56.1              :: must succeed (the host)
nslookup google.com            :: must fail
```

If any of these go the wrong way, **shut the VM down** and re-check the
adapter configuration before continuing.

## Optional: fake internet with FakeNet-NG

For samples that bail when DNS fails, run FakeNet-NG on the host (or a second
sacrificial VM) bound to `192.168.56.1`. Configure the detonation VM's DNS to
that address. FakeNet answers everything plausibly, so the sample's network
behavior unfolds while still being captured locally.

```bash
# On the host (outside the static-lab container, since the container has no net):
sudo python3 -m fakenet -c fakenet.ini   # bind to 192.168.56.1
```

Wireshark on the same adapter records the resulting traffic.

## Pre-flight checklist (paste into your lab notebook)

```text
[ ] Host IP forwarding OFF.
[ ] Host firewall blocks outbound from host-only adapter.
[ ] VM has exactly one NIC, host-only, static IP, no gateway.
[ ] `ping 8.8.8.8` from VM fails.
[ ] `nslookup` from VM fails.
[ ] Snapshot `pre-detonation` taken AFTER isolation verified.
```
