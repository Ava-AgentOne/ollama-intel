#!/bin/bash
# Unraid passes optional template variables as empty strings — unset them so
# they don't override Ollama's defaults with empty values
[ -z "${GGML_VK_VISIBLE_DEVICES:-}" ] && unset GGML_VK_VISIBLE_DEVICES
[ -z "${OLLAMA_FLASH_ATTENTION:-}" ] && unset OLLAMA_FLASH_ATTENTION
[ -z "${OLLAMA_NUM_PARALLEL:-}" ] && unset OLLAMA_NUM_PARALLEL

echo "[ollama-intel:vulkan] Vulkan devices:"
vulkaninfo --summary 2>/dev/null | grep -E 'deviceName|driverName' || echo "  (no Vulkan device detected — is /dev/dri passed through?)"

if [ -n "${GGML_VK_VISIBLE_DEVICES:-}" ]; then
    echo "[ollama-intel:vulkan] Device filter: $GGML_VK_VISIBLE_DEVICES"
fi

if [ -n "${OLLAMA_NUM_PARALLEL:-}" ]; then
    echo "[ollama-intel:vulkan] Parallel requests: $OLLAMA_NUM_PARALLEL"
fi

echo "[ollama-intel:vulkan] Starting Ollama..."
ollama --version 2>/dev/null || true
# exec so ollama runs as PID 1 and receives SIGTERM on container stop
exec ollama serve
