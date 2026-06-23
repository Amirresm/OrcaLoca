#!/usr/bin/env bash
# OrcaLoca run configuration.
#
# Inside the container, copy this into THIS IMAGE's data dir ($ORCA_DATA, which
# lives under the shared /data mount) and edit it there so it persists:
#
#     cp conf/example.sh "$ORCA_DATA/conf.sh"
#     vim "$ORCA_DATA/conf.sh"
#     ./run-smoke.sh        # auto-sources $ORCA_DATA/conf.sh if present
#
# run-*.sh source ${ORCA_CONF:-$ORCA_DATA/conf.sh}, falling back to this template.
# $ORCA_DATA is baked per-image (ENV in the Dockerfile, e.g. /data/orcaloca).

# NOTE: the data dir ($ORCA_DATA) is NOT set here — it's chosen at runtime
# (./setup.sh <exp> / ./run-smoke.sh <exp>), which is also how this very file's
# location is found. Setting it here would be too late to matter.

# ---- LLM: self-hosted vLLM (OpenAI-compatible) ----------------------------
# Model name stays constant; you change HOST:PORT per model you serve.
# vLLM must be started so this model name is what --served-model-name reports.
export MODEL="generic-vllm"
export OPENAI_API_BASE_URL="http://localhost:11888/v1"   # <-- change port per model
export OPENAI_API_KEY="dummy"                            # vLLM ignores this unless started with --api-key
export VLLM_CONTEXT_WINDOW="32768"                       # your model's max context length
export LLM_TIMEOUT="6000"                                # per-request timeout (s); raise for slow models

# tiktoken can't map a custom model name to a tokenizer, so token counts use this
# encoding as a fallback (approximate vs. your model's real tokenizer). cl100k_base
# is fine for most; o200k_base matches GPT-4o-era models.
export TIKTOKEN_ENCODING="cl100k_base"

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

# ---- Caches ---------------------------------------------------------------
# HF dataset is identical across models, so share it at the /data root to avoid
# re-downloading per image. Scope it per-image instead with "$ORCA_DATA/hf_cache".
export HF_HOME="/data/hf_cache"

# Logs (./log*) and outputs (./output/) are written into $ORCA_DATA automatically
# because run-*.sh cd into it before launching.
