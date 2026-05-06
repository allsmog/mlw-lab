# Static-analysis-only image. Tools parse samples as data; samples are NEVER
# executed inside this container. Run with `network_mode: none`.
FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

# Drop root, but install as root first.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        build-essential \
        git \
        curl \
        wget \
        unzip \
        p7zip-full \
        file \
        less \
        vim-tiny \
        jq \
        xxd \
        binutils \
        binwalk \
        upx-ucl \
        yara \
        radare2 \
        python3 \
        python3-pip \
        python3-venv \
        openjdk-17-jre-headless \
    && rm -rf /var/lib/apt/lists/*

# Python tooling: PE parsing, capability detection, string deobfuscation,
# memory forensics, sig parsing.
RUN python3 -m pip install --no-cache-dir --break-system-packages \
        pefile==2024.8.26 \
        flare-capa==7.10.0 \
        flare-floss==3.1.1 \
        oletools==0.60.2 \
        signify==0.7.0 \
        volatility3==2.7.0 \
        yara-python==4.5.1 \
        cryptography==43.0.1 \
        lief==0.15.1

# Ghidra headless analyzer (no GUI; for batch decompilation / scripts).
ARG GHIDRA_VERSION=11.1.2
ARG GHIDRA_DATE=20240709
RUN cd /opt && \
    wget -q "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/ghidra_${GHIDRA_VERSION}_PUBLIC_${GHIDRA_DATE}.zip" -O ghidra.zip && \
    unzip -q ghidra.zip && \
    rm ghidra.zip && \
    ln -s /opt/ghidra_${GHIDRA_VERSION}_PUBLIC /opt/ghidra && \
    ln -s /opt/ghidra/support/analyzeHeadless /usr/local/bin/ghidra-headless

# Non-root analyst user.
RUN useradd -m -s /bin/bash analyst
USER analyst
WORKDIR /work

# Quality of life.
RUN echo 'alias ll="ls -lah"' >> ~/.bashrc && \
    echo 'export PS1="\[\e[1;31m\][static-lab]\[\e[0m\] \w \$ "' >> ~/.bashrc

CMD ["/bin/bash"]
