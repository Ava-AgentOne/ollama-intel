#!/bin/bash
# Source oneAPI environment
source /opt/intel/oneapi/setvars.sh 2>/dev/null || true

# Add oneAPI compiler/MKL libraries to the library path without hardcoding
# the toolkit version, so a base image bump can't silently break linking
for dir in /opt/intel/oneapi/compiler/*/lib /opt/intel/oneapi/mkl/*/lib; do
    [ -d "$dir" ] && export LD_LIBRARY_PATH="$dir:${LD_LIBRARY_PATH:-}"
done

# Unraid passes optional template variables as empty strings, and an empty
# ONEAPI_DEVICE_SELECTOR breaks SYCL device detection — unset empty optionals
[ -z "${ONEAPI_DEVICE_SELECTOR:-}" ] && unset ONEAPI_DEVICE_SELECTOR
[ -z "${OLLAMA_NUM_PARALLEL:-}" ] && unset OLLAMA_NUM_PARALLEL

if [ -n "${ONEAPI_DEVICE_SELECTOR:-}" ]; then
    echo "[ollama-intel] Device selector: $ONEAPI_DEVICE_SELECTOR"
fi

if [ -n "${OLLAMA_NUM_PARALLEL:-}" ]; then
    echo "[ollama-intel] Parallel requests: $OLLAMA_NUM_PARALLEL"
fi

# Print version info on startup
echo "[ollama-intel] Starting Ollama..."
cd /llm/ollama
./ollama --version 2>/dev/null || true
# exec so ollama runs as PID 1 and receives SIGTERM on container stop
exec ./ollama serve
