#!/usr/bin/env bash
# OrcaLoca run configuration.
#
# Inside the container, copy this to the mounted data volume and edit it there so
# your changes persist across `docker run`s:
#
#     cp conf/example.sh data/conf.sh
#     vim data/conf.sh
#     ./run-smoke.sh        # auto-sources data/conf.sh if present
#
# run-*.sh source ${ORCA_CONF:-data/conf.sh}, falling back to conf/example.sh.

# ---- LLM: self-hosted vLLM (OpenAI-compatible) ----------------------------
# Model name stays constant; you change HOST:PORT per model you serve.
# vLLM must be started so this model name is what --served-model-name reports.
export MODEL="generic-vllm"
export OPENAI_API_BASE_URL="http://localhost:8001/v1"   # <-- change port per model
export OPENAI_API_KEY="dummy"                            # vLLM ignores this unless started with --api-key
export VLLM_CONTEXT_WINDOW="32768"                       # your model's max context length

# ---- Dataset --------------------------------------------------------------
export DATASET="princeton-nlp/SWE-bench_Lite"
export SPLIT="test"
export FINAL_STAGE="search"          # trace_analysis | search | edit

# Smoke test: a couple of quick instances.
export SMOKE_INSTANCES="astropy__astropy-12907 astropy__astropy-6938"

# Full run: regex of instance_ids. '.*' = entire split.
export FILTER_INSTANCE=".*"

# ---- Run knobs ------------------------------------------------------------
export CONTAINER_NAME="orcar_swe_bench_run_ctr"
export MAX_RETRY="2"

# ---- Caches: keep big HF dataset downloads in the mounted data volume -----
export HF_HOME="/app/data/hf_cache"
