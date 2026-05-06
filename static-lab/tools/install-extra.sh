#!/usr/bin/env bash
# Run inside the container to add tools that aren't pinned in the Dockerfile.
# These are optional extras — the base image already covers the essentials.
set -euo pipefail

python3 -m pip install --user --no-cache-dir \
    binary-refinery==0.6.39 \
    malduck==4.4.0 \
    yarGen==0.23.6

echo "[+] Extras installed in ~/.local/bin"
echo "    Add to PATH if needed:  export PATH=\"\$HOME/.local/bin:\$PATH\""
