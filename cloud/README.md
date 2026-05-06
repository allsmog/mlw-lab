# cloud/ — disposable analysis droplet

`stuxnet-lab.cloud-init.yml` bootstraps a fresh Ubuntu 24.04 cloud
instance into a fully configured Stuxnet analysis lab in one shot. The
malware lives on the droplet; your laptop never touches it. When the
project is done, you destroy the droplet and everything is gone.

## Pick a provider

Any of these have a "User Data" / "Cloud-Init" field at instance creation:

| Provider          | Cheapest option                               | Where to paste the cloud-init |
| ----------------- | --------------------------------------------- | ------------------------------ |
| Hetzner Cloud     | CAX11 ARM (~€3.79/mo) or CX22 (~€4.51/mo)     | "Cloud config" tab            |
| DigitalOcean      | Basic droplet $6/mo                           | "Advanced options → User Data"|
| Linode (Akamai)   | Nanode 1 GB $5/mo                             | "Add-ons → User Data"         |
| Vultr             | Cloud Compute $5/mo                           | "User Data" textarea          |
| Oracle Cloud      | Free tier ARM Ampere (always-free)            | "Show advanced options → Cloud-init script" |
| AWS Lightsail     | $5/mo                                         | "Add launch script (cloud-init)" |

Smallest spec that actually works: 2 GB RAM, 1 vCPU, 25 GB disk. Ghidra
likes ≥ 4 GB if you'll do GUI reverse-engineering remotely.

## Use it

1. **Generate an SSH keypair** locally if you don't already have one:
   ```bash
   ssh-keygen -t ed25519 -C "stuxnet-lab"
   # press enter to accept ~/.ssh/id_ed25519
   ```
2. **Copy your public key** content:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
3. **Edit `stuxnet-lab.cloud-init.yml`** — replace `SSH_PUBKEY_PLACEHOLDER`
   with that public key (the whole single-line string starting with
   `ssh-ed25519 ...`).
4. **Create the instance** in your provider's UI, paste the file into
   the "User Data" / "Cloud-Init" field, click create.
5. **Wait ~5 minutes** for the bootstrap to finish (the `texlive-xetex`
   pull and the static-lab container build are the slow parts).
6. **SSH in:**
   ```bash
   ssh analyst@<droplet-ip>
   ls ~/lab-ready          # this file exists when bootstrap finished
   tail /var/log/cloud-init-output.log    # check for any failures
   cd ~/mlw-lab
   ```
7. **Pull the sample on the droplet** (your laptop never sees it):
   ```bash
   curl -fL -o samples/Win32.Stuxnet.B.Duqu-Realtek.zip \
     "https://raw.githubusercontent.com/ytisf/theZoo/master/malware/Binaries/Win32.Stuxnet.B.Duqu-Realtek/Win32.Stuxnet.B.Duqu-Realtek.zip"
   make verify SAMPLE=samples/Win32.Stuxnet.B.Duqu-Realtek.zip
   ```
8. **Follow** [`../docs/06-first-session.md`](../docs/06-first-session.md).

## When the project is done — DESTROY THE DROPLET

This is the whole point. Use your provider's "Destroy" / "Terminate"
button. Confirm. The VM, the disk, the encrypted sample, the carved
artifacts — all of it gone.

**What to keep before destroying:**

- Your `report/*.md` markdown — `git push` from inside the droplet to
  your fork.
- The compiled PDF — `scp analyst@<droplet-ip>:~/mlw-lab/report/stuxnet-report.pdf .`
- Any IOC tables / YARA rules you wrote — already in git.

**What NOT to copy off the droplet:**

- The encrypted `.zip`.
- The decrypted dropper.
- Any carved artifacts (`*.bin`, `*.sys`, `*.dll`, `*.dmp`).

The `.gitignore` already prevents these from being pushed via git, but
don't `scp` them either.

## What the cloud-init actually does

Reading top to bottom:

- Creates an `analyst` user with sudo, key-only SSH.
- Disables password SSH and root SSH outright.
- Installs Docker, pandoc/xetex, Python venv tooling.
- Hardens the host: ufw deny-incoming-except-SSH, sysctl no IP
  forwarding, sshd config tightening.
- Clones the repo onto `/home/analyst/mlw-lab`, checks out the
  development branch, enables the pre-commit hook.
- Builds the static-analysis container so `make shell` is instant.
- Drops a `~/lab-ready` marker when the whole thing is done.

It does **not** download a sample. That's still your finger on the
trigger — chain of custody is yours, even on the droplet.

## Hardening tweaks worth considering

- **Lock SSH to your IP only.** Most providers have a perimeter
  firewall UI separate from ufw. Set inbound 22 to your home IP only.
- **Add a fail2ban rule** if you must expose SSH widely:
  ```bash
  sudo apt install fail2ban
  ```
- **Disable IPv6** on the droplet if your provider gives you one and
  you don't need it.
- **Snapshot before you do anything destructive** — most providers
  support manual snapshots for a small additional fee. A snapshot is a
  point-in-time you can roll back to without rebuilding.

## Troubleshooting

**`lab-ready` never appears.**
SSH in anyway and inspect `/var/log/cloud-init-output.log`. The most
common failure is a transient `apt` mirror error. Re-run the failed
step manually:

```bash
cd ~ && source /etc/profile.d/lab-env.sh
git clone "$LAB_REPO" mlw-lab && cd mlw-lab
git checkout "$LAB_BRANCH"
git config core.hooksPath .githooks
docker compose -f static-lab/docker-compose.yml build
touch ~/lab-ready
```

**`make verify` reports NO MATCH on the zip.**
You pulled the wrong file or the network corrupted the download. Delete
the zip, re-curl, retry. Double-check the URL didn't get HTML-escaped
somewhere along the way.

**Docker build fails on TLS.**
Your provider may have a TLS-inspecting proxy. Drop your CA cert into
`static-lab/extra-ca.crt` and rebuild — see `docs/02-static-analysis-setup.md`.
