# Changelog

All notable changes to ollama-intel will be documented in this file.

## [v1.3] - 2026-07-05

### Added
- **Experimental `:vulkan` image variant** — stock upstream Ollama with the Vulkan backend (Mesa/ANV) on Intel iGPUs. Tracks official Ollama releases, so the newest models and features work immediately; much smaller image than the oneAPI/SYCL build. Known upstream caveat: some iGPUs (e.g. Arrow Lake with 3B+ models) can produce garbled output — `OLLAMA_FLASH_ATTENTION=0` is the documented workaround, or fall back to `:latest`
- `unraid-template-vulkan.xml` — separate Unraid template for the Vulkan variant (passes the whole `/dev/dri`, exposes `GGML_VK_VISIBLE_DEVICES`, `OLLAMA_FLASH_ATTENTION`, `OLLAMA_IGPU_ENABLE`)
- `build-vulkan.yml` workflow — weekly rebuild tracking the latest Ollama release, with a smoke test (`/api/version`) before pushing to GHCR

## [v1.2] - 2026-07-05

### Fixed
- `start.sh` no longer hardcodes oneAPI 2025.0 library paths — paths are now discovered at startup, so a future base image bump can't silently break linking
- Empty optional env vars (`ONEAPI_DEVICE_SELECTOR`, `OLLAMA_NUM_PARALLEL`) are unset at startup instead of breaking SYCL device detection
- Ollama now runs as PID 1 (`exec`) so `docker stop` sends SIGTERM cleanly instead of timing out
- Removed dead multi-stage build layer and duplicate `start.sh` copy from the Dockerfile
- Default timezone changed from `Asia/Shanghai` to `UTC` (configurable via `TZ`)

### Changed
- Level Zero loader bumped 1.20.2 → 1.31.0 (`libze1`/`libze-dev` packages)
- Unraid template: added `ONEAPI_DEVICE_SELECTOR`, `OLLAMA_NUM_PARALLEL`, and `TZ` as advanced fields
- Dockerfile now documents why the base image, compute runtime, and IGC versions are pinned (they must match Intel's ipex-llm-tested stack)
- README: clarified that the bundled Ollama version comes from IPEX-LLM and trails official Ollama releases

## [v1.1] - 2026-04-16

*(Retroactive entry — this release was tagged before its changes were recorded in the changelog.)*

### Changed
- Rebuilt from source: `intel/oneapi-basekit` base image + `pip install ipex-llm[cpp]`, so weekly rebuilds pick up the latest IPEX-LLM
- Use the Intel XPU PyTorch wheel index to avoid downloading NVIDIA CUDA packages

### Added
- `ONEAPI_DEVICE_SELECTOR` (GPU selection) and `OLLAMA_NUM_PARALLEL` (parallel request limit) support in `start.sh`
- README: NPU status section, Updating section, multi-GPU troubleshooting

### Fixed
- Removed empty `ONEAPI_DEVICE_SELECTOR` ENV from the Dockerfile — an empty value breaks SYCL device detection

## [v1.0] - 2026-02-21

### Features
- Ollama with Intel iGPU acceleration via IPEX-LLM
- Full SYCL offload to Intel Arc iGPU (Xe-LPG)
- Custom start.sh with oneAPI environment setup
- GitHub Actions CI/CD with auto-build to GHCR
- Unraid CA template with Private Apps support
- 4 install methods: Docker Run, Unraid br0, App Store, Manual Template
- Persistent SYCL shader cache for faster subsequent runs
- Configurable GPU layers, shared memory, and memory limits
