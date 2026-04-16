<div align="center">

<img src="https://raw.githubusercontent.com/Ava-AgentOne/ollama-intel/main/icon.png" alt="ollama-intel" width="150">

# 🦙 ollama-intel

**Ollama with Intel iGPU Acceleration via IPEX-LLM**

[![Build & Push to GHCR](https://github.com/Ava-AgentOne/ollama-intel/actions/workflows/build.yml/badge.svg)](https://github.com/Ava-AgentOne/ollama-intel/actions/workflows/build.yml)
[![GHCR](https://img.shields.io/badge/GHCR-ollama--intel-blue?logo=github)](https://github.com/Ava-AgentOne/ollama-intel/pkgs/container/ollama-intel)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Unraid](https://img.shields.io/badge/Unraid-Compatible-orange?logo=unraid)](https://unraid.net)

*Run large language models locally on Intel integrated GPUs — no discrete GPU required.*

---

</div>

## 📖 What Is This?

**ollama-intel** is a pre-configured Docker container that runs [Ollama](https://ollama.com) with full hardware acceleration on **Intel integrated GPUs** (Xe-LPG, Arc). It uses Intel's [IPEX-LLM](https://github.com/intel-analytics/ipex-llm) library to offload all model layers to the iGPU via the **SYCL** backend.

This means you can run AI models like Llama 3, Phi-4, Gemma 3, and more — entirely on your Intel NUC, mini PC, or any system with a modern Intel iGPU — without needing an NVIDIA or AMD discrete GPU.

### 🎯 Who Is This For?

- **Unraid users** who want local AI without a dedicated GPU
- **Intel NUC / mini PC owners** looking to maximize their hardware
- **Home lab enthusiasts** wanting private, offline LLM inference
- Anyone with a **Meteor Lake, Arrow Lake, or Intel Arc** iGPU

## ✨ Features

- 🚀 **Full iGPU Acceleration** — All model layers run on Intel SYCL0 (not CPU fallback)
- 📦 **Drop-in Ollama Replacement** — Compatible with Open WebUI, Chatbox, and any Ollama client
- 🔧 **Optimized for Unraid** — br0 networking, XML template, persistent model storage
- ⚡ **Shader Caching** — First run compiles SYCL shaders; subsequent runs are much faster
- 🏠 **Fully Local & Private** — No cloud, no API keys, no data leaves your network

## 📊 Performance

Tested on **Intel Core Ultra 7 155H** (Meteor Lake) with 64GB RAM:

| Model Size | Examples | Speed |
|-----------|----------|-------|
| **4B** | Phi-4-mini, Qwen3:4b | ~15+ tok/s |
| **7-8B** | Llama 3.1:8b, Gemma 3 | ~8-12 tok/s |
| **14B+** | Qwen3:14b | ~4-6 tok/s |

> 💡 **Note:** `runner.inference=cpu` in Ollama logs is a display quirk — actual inference runs on SYCL0 (iGPU). Check GPU utilization with `intel_gpu_top` to confirm.

## 🚀 Quick Start

### Docker Run (Standard Bridge)

```bash
docker run -d \
  --name ollama-intel \
  --restart unless-stopped \
  -p 11434:11434 \
  --device /dev/dri/card0:/dev/dri/card0 \
  --device /dev/dri/renderD128:/dev/dri/renderD128 \
  --shm-size=16g \
  --memory=32g \
  -v /mnt/user/appdata/ollama:/root/.ollama \
  -e OLLAMA_DEBUG=1 \
  -e OLLAMA_KEEP_ALIVE=30s \
  ghcr.io/ava-agentone/ollama-intel:latest
```

> Access Ollama at `http://<your-server-ip>:11434`

### Unraid (br0 / macvlan)

If you prefer the container to have its own IP on your LAN (common on Unraid):

```bash
docker run -d \
  --name ollama-intel \
  --restart unless-stopped \
  --network br0 \
  --ip <YOUR_IP> \
  --device /dev/dri/card0:/dev/dri/card0 \
  --device /dev/dri/renderD128:/dev/dri/renderD128 \
  --shm-size=16g \
  --memory=32g \
  -v /mnt/user/appdata/ollama:/root/.ollama \
  -e OLLAMA_DEBUG=1 \
  -e OLLAMA_KEEP_ALIVE=30s \
  ghcr.io/ava-agentone/ollama-intel:latest
```

> Replace `<YOUR_IP>` with a free static IP on your LAN (e.g., `192.168.1.100`).

### Unraid Private Apps (Recommended)

Add all Ava-AgentOne containers to your Unraid **Apps** tab:

1. Run in your Unraid terminal:
   ```bash
   mkdir -p /boot/config/plugins/community.applications/private/Ava-AgentOne
   curl -o /boot/config/plugins/community.applications/private/Ava-AgentOne/ollama-intel.xml \
     https://raw.githubusercontent.com/Ava-AgentOne/unraid-templates/main/ollama-intel.xml
   ```
2. Go to **Apps** tab → **Private Apps** in the left sidebar
3. Click **Install**, assign an IP, and click **Apply**
4. Pull a model: `docker exec ollama-intel ollama pull gemma3:4b`
5. Start chatting via [Open WebUI](https://github.com/open-webui/open-webui) or any Ollama-compatible client

> 💡 See [unraid-templates](https://github.com/Ava-AgentOne/unraid-templates) for an auto-sync script that keeps templates updated.

### Unraid Template (Manual Install)

Alternatively, paste the template URL directly in Unraid:

1. In Unraid, go to **Docker** → **Add Container** → **Template** dropdown → paste this URL:
   ```
   https://raw.githubusercontent.com/Ava-AgentOne/ollama-intel/main/unraid-template.xml
   ```
2. Assign an available IP address on your network and click **Apply**
3. Pull a model: `docker exec ollama-intel ollama pull gemma3:4b`
4. Start chatting via [Open WebUI](https://github.com/open-webui/open-webui) or any Ollama-compatible client
