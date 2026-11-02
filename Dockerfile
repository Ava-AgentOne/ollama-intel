# Ollama with Intel iGPU acceleration via IPEX-LLM (SYCL backend)
#
# Version pins deliberately match Intel's own ipex-llm inference image
# (intel/ipex-llm: docker/llm/inference-cpp/Dockerfile). The ipex-llm[cpp]
# wheels are built against oneAPI 2025.0 and validated with compute
# runtime 24.52 / IGC 2.5.6 — do not bump the base image or the GPU driver
# .debs independently. Newer compute-runtime releases (25.x+) are built for
# Ubuntu 24.04 only and will not install on this jammy base.
#
# The RUN steps are deliberately split into layers ordered by change
# frequency (base tooling → Python → GPU drivers → ipex-llm). With the
# registry build cache, a rebuild only re-creates the layers whose inputs
# changed, so users download just those instead of the whole multi-GB stack.
# Do not merge these RUNs back into one.
FROM intel/oneapi-basekit:2025.0.2-0-devel-ubuntu22.04

ARG http_proxy
ARG https_proxy

# ipex-llm, pinned to an exact build so every rebuild installs the same thing.
# 2.3.0b20251110 is the last build Intel published (10 Nov 2025); it pins
# bigdl-core-cpp, which carries the Ollama binary, to the matching build.
# Bumping this re-creates the multi-GB ipex-llm layer (users re-download it
# once), so bump deliberately.
ARG IPEX_LLM_VERSION=2.3.0b20251110

# Core environment variables
# PIP_NO_CACHE_DIR=1: without it, pip's wheel cache (~GBs) gets baked into
# the image layers.
ENV TZ=UTC \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    SYCL_CACHE_PERSISTENT=1 \
    SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1 \
    ZES_ENABLE_SYSMAN=1 \
    USE_XETLA=OFF \
    OLLAMA_HOST=0.0.0.0:11434 \
    OLLAMA_NUM_GPU=999

# ONEAPI_DEVICE_SELECTOR and OLLAMA_NUM_PARALLEL are NOT set here — an empty
# value breaks SYCL device detection. start.sh unsets them when empty, so they
# are safe to pass via docker run -e or the Unraid template.

# Layer 1: apt repositories + base tooling (rarely changes)
RUN set -eux && \
    wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | tee /usr/share/keyrings/intel-oneapi-archive-keyring.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/intel-oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list && \
    chmod 644 /usr/share/keyrings/intel-oneapi-archive-keyring.gpg && \
    rm -f /etc/apt/sources.list.d/intel-graphics.list && \
    wget -O- https://repositories.intel.com/graphics/intel-graphics.key | gpg --dearmor | tee /usr/share/keyrings/intel-graphics.gpg > /dev/null && \
    echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/graphics/ubuntu jammy arc" | tee /etc/apt/sources.list.d/intel.gpu.jammy.list && \
    chmod 644 /usr/share/keyrings/intel-graphics.gpg && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      curl wget git sudo libunwind8-dev vim less gnupg gpg-agent software-properties-common && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Layer 2: Python 3.11 + pip (rarely changes)
RUN set -eux && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y --no-install-recommends python3.11 python3-pip python3.11-dev python3.11-distutils python3-wheel && \
    rm /usr/bin/python3 && ln -s /usr/bin/python3.11 /usr/bin/python3 && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    wget https://bootstrap.pypa.io/get-pip.py -O get-pip.py && \
    python3 get-pip.py && rm get-pip.py && \
    pip install --no-cache-dir --upgrade requests argparse urllib3 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Layer 3: pinned Intel GPU userspace drivers (24.52 stack — matches Intel's
# ipex-llm pin) + Level Zero loader (rarely changes)
RUN set -eux && \
    apt-get remove -y libze-dev libze-intel-gpu1 || true && \
    mkdir -p /tmp/gpu && cd /tmp/gpu && \
    wget https://github.com/intel/intel-graphics-compiler/releases/download/v2.5.6/intel-igc-core-2_2.5.6+18417_amd64.deb && \
    wget https://github.com/intel/intel-graphics-compiler/releases/download/v2.5.6/intel-igc-opencl-2_2.5.6+18417_amd64.deb && \
    wget https://github.com/intel/compute-runtime/releases/download/24.52.32224.5/intel-level-zero-gpu_1.6.32224.5_amd64.deb && \
    wget https://github.com/intel/compute-runtime/releases/download/24.52.32224.5/intel-opencl-icd_24.52.32224.5_amd64.deb && \
    wget https://github.com/intel/compute-runtime/releases/download/24.52.32224.5/libigdgmm12_22.5.5_amd64.deb && \
    wget https://github.com/intel/compute-runtime/releases/download/24.35.30872.22/intel-level-zero-gpu-legacy1_1.3.30872.22_amd64.deb && \
    wget https://github.com/intel/compute-runtime/releases/download/24.35.30872.22/intel-opencl-icd-legacy1_24.35.30872.22_amd64.deb && \
    wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.17537.20/intel-igc-core_1.0.17537.20_amd64.deb && \
    wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.17537.20/intel-igc-opencl_1.0.17537.20_amd64.deb && \
    dpkg -i *.deb && rm -rf /tmp/gpu && \
    mkdir /tmp/level-zero && cd /tmp/level-zero && \
    wget https://github.com/oneapi-src/level-zero/releases/download/v1.31.0/libze1_1.31.0+u22.04_amd64.deb && \
    wget https://github.com/oneapi-src/level-zero/releases/download/v1.31.0/libze-dev_1.31.0+u22.04_amd64.deb && \
    dpkg -i *.deb && rm -rf /tmp/level-zero

# Layer 4: ipex-llm (the multi-GB bulk, including the Ollama binary) and the
# Ollama launcher. Only changes when IPEX_LLM_VERSION is bumped.
RUN set -eux && \
    pip install --no-cache-dir "ipex-llm[cpp]==${IPEX_LLM_VERSION}" \
      --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/ && \
    mkdir -p /llm/ollama && cd /llm/ollama && init-ollama

COPY start.sh /llm/ollama/start.sh
RUN chmod +x /llm/ollama/start.sh

WORKDIR /llm/ollama
ENTRYPOINT ["/llm/ollama/start.sh"]
