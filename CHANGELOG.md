# Changelog

All notable changes to ollama-intel will be documented in this file.

## [v1.1] - 2026-07-04

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
