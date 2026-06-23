FROM python:3.10-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        vim \
        curl \
        ca-certificates \
        build-essential \
        docker.io \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

RUN pip install --no-cache-dir -e . \
    && pip install --no-cache-dir llama-index-llms-openai-like

# Per-image data dir. Mount the SAME host /data into every container; each image
# scopes itself to /data/<DATA_SUBDIR>. Override at build with:
#   docker build --build-arg DATA_SUBDIR=qwen-32b -t orcaloca:qwen .
ARG DATA_SUBDIR=orcaloca
ENV ORCA_DATA=/data/${DATA_SUBDIR}

CMD ["/bin/bash"]
