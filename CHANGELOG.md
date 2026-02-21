# Changelog

All notable changes to ollama-intel will be documented in this file.

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
