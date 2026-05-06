# Static-analysis-only image. Tools parse samples as data; samples are NEVER
# executed inside this container. Run with `network_mode: none`.
FROM ubuntu:24.04

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
        python3-dev \
        python3-pip \
        python3-venv \
        openjdk-17-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

# Install the optional extra CA bundle. The repo ships an empty placeholder;
# replace static-lab/extra-ca.crt with your proxy's PEM cert and rebuild.
COPY ./extra-ca.crt /usr/local/share/ca-certificates/extra-ca.crt
RUN if grep -q "BEGIN CERTIFICATE" /usr/local/share/ca-certificates/extra-ca.crt; then \
        update-ca-certificates; \
    else \
        rm /usr/local/share/ca-certificates/extra-ca.crt; \
    fi

# Make pip / requests / urllib3 trust the system CA store (which now includes
# the extra cert if provided).
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    PIP_CERT=/etc/ssl/certs/ca-certificates.crt

# Python tooling: PE parsing, capability detection, string deobfuscation,
# memory forensics, sig parsing. Installed into a venv at /opt/analysis-venv
# so we don't fight Ubuntu's PEP 668 system-pip lock.
RUN python3 -m venv /opt/analysis-venv
ENV PATH="/opt/analysis-venv/bin:${PATH}" \
    VIRTUAL_ENV=/opt/analysis-venv
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir \
        pefile==2024.8.26 \
        flare-capa==9.4.0 \
        flare-floss==3.1.1 \
        oletools==0.60.2 \
        signify==0.9.2 \
        volatility3==2.28.0 \
        yara-python==4.5.4 \
        cryptography==48.0.0 \
        lief==0.17.6

# Ghidra headless analyzer (no GUI; for batch decompilation / scripts).
ARG GHIDRA_VERSION=11.1.2
ARG GHIDRA_DATE=20240709
RUN cd /opt && \
    wget -q "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/ghidra_${GHIDRA_VERSION}_PUBLIC_${GHIDRA_DATE}.zip" -O ghidra.zip && \
    unzip -q ghidra.zip && \
    rm ghidra.zip && \
    ln -s /opt/ghidra_${GHIDRA_VERSION}_PUBLIC /opt/ghidra && \
    ln -s /opt/ghidra/support/analyzeHeadless /usr/local/bin/ghidra-headless

# Tell Ghidra where to find the JDK (it can't autodetect non-interactively).
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
RUN echo "JAVA_HOME_OVERRIDE=${JAVA_HOME}" >> /opt/ghidra/support/launch.properties

# Non-root analyst user.
RUN useradd -m -s /bin/bash analyst
USER analyst
WORKDIR /work

# Quality of life.
RUN echo 'alias ll="ls -lah"' >> ~/.bashrc && \
    echo 'export PS1="\[\e[1;31m\][static-lab]\[\e[0m\] \w \$ "' >> ~/.bashrc

CMD ["/bin/bash"]
