FROM python:3.10-slim

# docker-cli (NOT docker.io): OrcaLoca shells out to `docker exec`, so it needs
# the client. On Debian trixie docker.io ships only the daemon (dockerd); the
# client lives in docker-cli. The daemon is the host's, via the mounted socket.
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        vim \
        curl \
        ca-certificates \
        build-essential \
        docker-cli \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

# llama-index-llms-openai-like is declared in pyproject (with llama-index-core
# pinned <0.13), so it resolves in one pass. Installing it separately would pull
# a newer core that drops llama_index.core.agent.runner -> ModuleNotFoundError.
RUN pip install --no-cache-dir -e .

# No data dir is baked in: this image is reused across experiments. Mount the
# shared host /data (-v /data:/data) and pick the experiment INSIDE the container
# via `./setup.sh <exp>` + `./run-smoke.sh <exp>` (sets ORCA_DATA=/data/<exp>).
CMD ["/bin/bash"]
