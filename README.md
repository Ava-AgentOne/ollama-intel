<div align="center">

<img src="https://raw.githubusercontent.com/avaesamagent-dot/ollama-intel/main/icon.png" alt="ollama-intel" width="150">

# 🧠 ollama-intel

**Ollama with Intel iGPU Acceleration via IPEX-LLM**

[![Build & Push to GHCR](https://github.com/avaesamagent-dot/ollama-intel/actions/workflows/build.yml/badge.svg)](https://github.com/avaesamagent-dot/ollama-intel/actions/workflows/build.yml)
[![GHCR](https://img.shields.io/badge/GHCR-ollama--intel-blue?logo=github)](https://github.com/avaesamagent-dot/ollama-intel/pkgs/container/ollama-intel)
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

### Docker Run

```bash
docker run -d \
  --name ollama-intel \
  --restart unless-stopped \
  --network br0 \
  --ip 10.0.1.212 \
  --device /dev/dri/card0:/dev/dri/card0 \
  --device /dev/dri/renderD128:/dev/dri/renderD128 \
  --shm-size=16g \
  --memory=32g \
  -v /mnt/user/appdata/ollama:/root/.ollama \
  -e OLLAMA_DEBUG=1 \
  -e OLLAMA_KEEP_ALIVE=30s \
  ghcr.io/avaesamagent-dot/ollama-intel:latest
```

### Unraid Installation

1. In Unraid, go to **Docker** → **Add Container** → paste the template URL:
   ```
   https://raw.githubusercontent.com/avaesamagent-dot/ollama-intel/main/unraid-template.xml
   ```
2. Adjust the IP address and click **Apply**
3. Pull a model: `docker exec ollama-intel ollama pull gemma3:4b`
4. Start chatting via [Open WebUI](https://github.com/open-webui/open-webui) or any Ollama-compatible client

## ⚙️ Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_HOST` | `0.0.0.0:11434` | Listen address and port |
| `OLLAMA_NUM_GPU` | `999` | Number of layers to offload to GPU (999 = all) |
| `OLLAMA_DEBUG` | `0` | Enable verbose debug logging |
| `OLLAMA_KEEP_ALIVE` | `5m` | How long to keep models loaded after last request |
| `SYCL_CACHE_PERSISTENT` | `1` | Cache compiled SYCL shaders between restarts |
| `ZES_ENABLE_SYSMAN` | `1` | Enable Intel GPU system management |
| `SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS` | `1` | Performance optimization for Level Zero backend |

## 🔌 Companion Projects

| Project | Description |
|---------|-------------|
| [**ollama-dashboard**](https://github.com/avaesamagent-dot/ollama-dashboard) | Real-time monitoring dashboard with benchmarking, request history, and 6 visual themes |
| [**Open WebUI**](https://github.com/open-webui/open-webui) | ChatGPT-style web interface for Ollama |

## 🛠️ Hardware Requirements

- **GPU**: Intel integrated graphics — Xe-LPG (Meteor Lake), Xe-HPG (Arc), or newer
- **Devices**: `/dev/dri/card0` and `/dev/dri/renderD128` must be available
- **RAM**: 32GB+ recommended (iGPU shares system RAM for VRAM)
- **OS**: Linux host with Intel GPU drivers (Unraid 7.x works out of the box)

## 📁 Volume Mounts

| Host Path | Container Path | Purpose |
|-----------|---------------|---------|
| `/mnt/user/appdata/ollama` | `/root/.ollama` | Models, configs, and SYCL shader cache |

## 🔍 Troubleshooting

<details>
<summary><strong>First run is very slow</strong></summary>

This is normal! SYCL needs to compile shaders for your specific GPU on first use. With `SYCL_CACHE_PERSISTENT=1`, subsequent runs use the cached shaders and start much faster.
</details>

<details>
<summary><strong>Logs show "runner.inference=cpu"</strong></summary>

This is a display quirk in Ollama's logging — it doesn't reflect actual compute. Run `intel_gpu_top` on the host while a model is generating to confirm GPU utilization.
</details>

<details>
<summary><strong>GPU not detected inside container</strong></summary>

```bash
# Check GPU devices exist on host
ls -la /dev/dri/

# Check SYCL detection inside container
docker exec ollama-intel sycl-ls

# Verify devices are passed through
docker exec ollama-intel ls -la /dev/dri/
```
</details>

<details>
<summary><strong>Out of memory errors</strong></summary>

Intel iGPU shares system RAM. If you're running large models, ensure you have enough free RAM. Adjust `--memory` and `--shm-size` flags as needed. The `OLLAMA_KEEP_ALIVE=30s` setting helps by unloading models quickly after use.
</details>

## 📜 License

[MIT](LICENSE) — Use it, modify it, share it.

---

<div align="center">

**Built for Unraid** · Powered by [Intel IPEX-LLM](https://github.com/intel-analytics/ipex-llm) · Compatible with [Ollama](https://ollama.com)

</div>
