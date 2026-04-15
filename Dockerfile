FROM intelanalytics/ipex-llm-inference-cpp-xpu:latest

ENV ZES_ENABLE_SYSMAN=1
ENV USE_XETLA=OFF
ENV OLLAMA_HOST=0.0.0.0:11434
ENV OLLAMA_NUM_GPU=999
ENV SYCL_CACHE_PERSISTENT=1
ENV SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1

# GPU device selection (e.g., level_zero:0 for iGPU, level_zero:1 for dGPU)
# Leave empty to use all available Intel GPUs
ENV ONEAPI_DEVICE_SELECTOR=""

# Parallel request handling (reduce to 1 for limited GPU memory)
ENV OLLAMA_NUM_PARALLEL=""

RUN mkdir -p /llm/ollama && \
    cd /llm/ollama && \
    init-ollama

COPY start.sh /llm/ollama/start.sh
RUN chmod +x /llm/ollama/start.sh

WORKDIR /llm/ollama
ENTRYPOINT ["/llm/ollama/start.sh"]
