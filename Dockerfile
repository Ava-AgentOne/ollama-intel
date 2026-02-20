FROM intelanalytics/ipex-llm-inference-cpp-xpu:latest

ENV ZES_ENABLE_SYSMAN=1
ENV USE_XETLA=OFF
ENV OLLAMA_HOST=0.0.0.0:11434
ENV OLLAMA_NUM_GPU=999
ENV SYCL_CACHE_PERSISTENT=1
ENV SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1

RUN mkdir -p /llm/ollama && \
    cd /llm/ollama && \
    init-ollama

COPY start.sh /llm/ollama/start.sh
RUN chmod +x /llm/ollama/start.sh

WORKDIR /llm/ollama
ENTRYPOINT ["/llm/ollama/start.sh"]
