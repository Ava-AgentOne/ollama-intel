#!/bin/bash
# Source oneAPI environment
source /opt/intel/oneapi/setvars.sh 2>/dev/null || true

# Set library paths
export LD_LIBRARY_PATH=/opt/intel/oneapi/compiler/2025.0/lib:/opt/intel/oneapi/mkl/2025.0/lib:${LD_LIBRARY_PATH:-}

# Apply device selector if set (e.g., level_zero:0 for iGPU only)
if [ -n "$ONEAPI_DEVICE_SELECTOR" ]; then
    export ONEAPI_DEVICE_SELECTOR="$ONEAPI_DEVICE_SELECTOR"
    echo "[ollama-intel] Device selector: $ONEAPI_DEVICE_SELECTOR"
fi

# Apply parallel request limit if set
if [ -n "$OLLAMA_NUM_PARALLEL" ]; then
    export OLLAMA_NUM_PARALLEL="$OLLAMA_NUM_PARALLEL"
    echo "[ollama-intel] Parallel requests: $OLLAMA_NUM_PARALLEL"
fi

# Print version info on startup
echo "[ollama-intel] Starting Ollama..."
cd /llm/ollama
./ollama --version 2>/dev/null || true
./ollama serve
