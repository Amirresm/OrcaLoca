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

CMD ["/bin/bash"]
