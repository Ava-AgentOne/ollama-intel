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
- 🌋 **Vulkan Variant** — optional experimental `:vulkan` tag running stock upstream Ollama (latest models, smaller image)
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
docker run -d \\
  --name ollama-intel \\
  --restart unless-stopped \\
  -p 11434:11434 \\
  --device /dev/dri/card0:/dev/dri/card0 \\
  --device /dev/dri/renderD128:/dev/dri/renderD128 \\
  --shm-size=16g \\
  --memory=32g \\
  -v /mnt/user/appdata/ollama:/root/.ollama \\
  -e OLLAMA_DEBUG=1 \\
  -e OLLAMA_KEEP_ALIVE=30s \\
  ghcr.io/ava-agentone/ollama-intel:latest
```

> Access Ollama at `http://<your-server-ip>:11434`

### Unraid (br0 / macvlan)

If you prefer the container to have its own IP on your LAN (common on Unraid):

```bash
docker run -d \\
  --name ollama-intel \\
  --restart unless-stopped \\
  --network br0 \\
  --ip <YOUR_IP> \\
  --device /dev/dri/card0:/dev/dri/card0 \\
  --device /dev/dri/renderD128:/dev/dri/renderD128 \\
  --shm-size=16g \\
  --memory=32g \\
  -v /mnt/user/appdata/ollama:/root/.ollama \\
  -e OLLAMA_DEBUG=1 \\
  -e OLLAMA_KEEP_ALIVE=30s \\
  ghcr.io/ava-agentone/ollama-intel:latest
```

> Replace `<YOUR_IP>` with a free static IP on your LAN (e.g., `192.168.1.100`).

### Unraid Private Apps (Recommended)

Add all Ava-AgentOne containers to your Unraid **Apps** tab:

1. Run in your Unraid terminal:
   ```bash
   mkdir -p /boot/config/plugins/community.applications/private/Ava-AgentOne
   curl -o /boot/config/plugins/community.applications/private/Ava-AgentOne/ollama-intel.xml \\
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

## 🔄 Updating

Updates are **seamless** on Unraid — just click **Update** in the Docker tab. The container image is rebuilt weekly from source via GitHub Actions, so each update picks up the latest ipex-llm build automatically.

> ℹ️ The Ollama binary inside the container is the one bundled by IPEX-LLM, which trails official Ollama releases (IPEX-LLM currently tracks Ollama v0.9.x). Brand-new Ollama features and model formats may not be available until Intel updates IPEX-LLM. Need the newest Ollama? Try the experimental [Vulkan variant](#-vulkan-variant-experimental).

No need to remove and reinstall. Your models, settings, and SYCL shader cache are stored in the mounted volume and persist across updates.

> ⚠️ **Note**: Unraid's Update button pulls a new image but does NOT re-read template XML changes. If a new release adds optional env vars (like `ONEAPI_DEVICE_SELECTOR`, `OLLAMA_NUM_PARALLEL`, and `TZ`, added in v1.2), the container still works perfectly — but to see the new fields in the Edit screen, remove and reinstall from Private Apps.

## ⚙️ Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_HOST` | `0.0.0.0:11434` | Listen address and port |
| `OLLAMA_NUM_GPU` | `999` | Number of layers to offload to GPU (999 = all) |
| `OLLAMA_DEBUG` | `0` (Unraid template: `1`) | Enable verbose debug logging |
| `OLLAMA_KEEP_ALIVE` | `5m` (Unraid template: `30s`) | How long to keep models loaded after last request |
| `OLLAMA_NUM_PARALLEL` | `` | Max parallel requests (set to `1` for limited GPU memory) |
| `ONEAPI_DEVICE_SELECTOR` | `` | Target specific GPU device (e.g., `level_zero:0` for iGPU, `level_zero:1` for dGPU) |
| `TZ` | `UTC` | Container timezone |
| `SYCL_CACHE_PERSISTENT` | `1` | Cache compiled SYCL shaders between restarts |
| `ZES_ENABLE_SYSMAN` | `1` | Enable Intel GPU system management |
| `SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS` | `1` | Performance optimization for Level Zero backend |

## 🌋 Vulkan Variant (Experimental)

The `:vulkan` tag runs **stock upstream Ollama** with its Vulkan backend on the Intel iGPU via the open-source Mesa (ANV) driver — no IPEX-LLM, no oneAPI toolkit.

| | `:latest` (SYCL / IPEX-LLM) | `:vulkan` |
|---|---|---|
| **Ollama version** | Bundled by IPEX-LLM (trails upstream, ~v0.9.x) | Latest official release |
| **New models/features** | After Intel updates IPEX-LLM | Immediately |
| **Image size** | Very large (full oneAPI toolkit) | Small |
| **Maturity** | Stable, Intel-validated stack | Experimental upstream backend |

```bash
docker run -d \\
  --name ollama-intel-vulkan \\
  --restart unless-stopped \\
  -p 11434:11434 \\
  --device /dev/dri \\
  -v /mnt/user/appdata/ollama:/root/.ollama \\
  -e OLLAMA_KEEP_ALIVE=30s \\
  ghcr.io/ava-agentone/ollama-intel:vulkan
```

Unraid template URL:
```
https://raw.githubusercontent.com/Ava-AgentOne/ollama-intel/main/unraid-template-vulkan.xml
```

**Extra environment variables (`:vulkan` only):**

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_IGPU_ENABLE` | `1` (set in image) | Ollama drops iGPUs by default; this opts back in |
| `GGML_VK_VISIBLE_DEVICES` | `` | Restrict to specific Vulkan device IDs (e.g., `0`) |
| `OLLAMA_FLASH_ATTENTION` | `` | Set to `0` if you get garbled output on your iGPU |
| `OLLAMA_VULKAN` | | Set to `0` to disable the Vulkan backend entirely |

**Caveats:**

- Upstream Vulkan support is still maturing. Some Intel iGPUs — notably Arrow Lake with models ≥3B — have produced garbled output ([ollama#13964](https://github.com/ollama/ollama/issues/13964), [ollama#13086](https://github.com/ollama/ollama/issues/13086)). If that happens, try `OLLAMA_FLASH_ATTENTION=0`, a smaller model, or fall back to `:latest`.
- Models are stored in the same format, so both variants can share the same appdata volume and you can switch tags without re-downloading — but **don't run both containers at the same time** (they would race on the model store and fight over the iGPU).

## 🛡️ NPU Support

Intel Core Ultra processors include an NPU (Neural Processing Unit), but **NPU is not currently supported** for Ollama inference. The IPEX-LLM Ollama binary uses the SYCL backend which targets iGPU and discrete Arc GPUs only. NPU support exists in IPEX-LLM's Python and llama.cpp C++ APIs but has not been integrated into Ollama yet.

We're tracking upstream progress at [ipex-llm/ipex-llm](https://github.com/ipex-llm/ipex-llm) and will add NPU support when it becomes available. See [#2](https://github.com/Ava-AgentOne/ollama-intel/issues/2) for details.

## 🔌 Companion Projects

| Project | Description |
|---------|-------------|
| [**ollama-dashboard**](https://github.com/Ava-AgentOne/ollama-dashboard) | Real-time monitoring dashboard with benchmarking, request history, and 6 visual themes |
| [**Open WebUI**](https://github.com/open-webui/open-webui) | ChatGPT-style web interface for Ollama |

## 🛠️ Hardware Requirements

- **GPU**: Intel integrated graphics — Xe-LPG (Meteor Lake), Xe-HPG (Arc), or newer
- **Devices**: `/dev/dri/card0` and `/dev/dri/renderD128` must be available
- **RAM**: 32GB+ recommended (iGPU shares system RAM for VRAM)
- **OS**: Linux host with Intel GPU drivers (Unraid 7.x works out of the box)

## 📁 Volume Mounts

| Host Path | Container Path | Purpose |
|-----------|---------------|----------|
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

Intel iGPU shares system RAM. If you're running large models, ensure you have enough free RAM. Adjust `--memory` and `--shm-size` flags as needed. The `OLLAMA_KEEP_ALIVE=30s` setting helps by unloading models quickly after use. You can also set `OLLAMA_NUM_PARALLEL=1` to reduce GPU memory usage.
</details>

<details>
<summary><strong>Multiple GPUs detected (iGPU + dGPU)</strong></summary>

If you have both an integrated and discrete GPU, set `ONEAPI_DEVICE_SELECTOR` to target the one you want:

```bash
# Use only iGPU
-e ONEAPI_DEVICE_SELECTOR=level_zero:0

# Use only dGPU
-e ONEAPI_DEVICE_SELECTOR=level_zero:1
```

Check device IDs with: `docker exec ollama-intel sycl-ls`
</details>

<details>
<summary><strong>Vulkan variant: garbled or nonsense output</strong></summary>

A known upstream issue on some Intel iGPUs (especially Arrow Lake with 3B+ models). Try `-e OLLAMA_FLASH_ATTENTION=0`, use a smaller model, or switch to the stable `:latest` (SYCL) image.
</details>

## 📜 License

[MIT](LICENSE) — Use it, modify it, share it.

---

<div align="center">

**Built for Unraid** · Powered by [Intel IPEX-LLM](https://github.com/intel-analytics/ipex-llm) · Compatible with [Ollama](https://ollama.com)

</div>
