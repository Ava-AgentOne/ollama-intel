#!/bin/bash
source /opt/intel/oneapi/setvars.sh 2>/dev/null || true
export LD_LIBRARY_PATH=/opt/intel/oneapi/compiler/2025.0/lib:/opt/intel/oneapi/mkl/2025.0/lib:$LD_LIBRARY_PATH
cd /llm/ollama
./ollama serve
