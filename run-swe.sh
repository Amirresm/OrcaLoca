#!/usr/bin/env bash

source "$(dirname "$0")/conf/_load.sh"

echo ">> filter_instance: ${FILTER_INSTANCE:-.*}  max_retry: $MAX_RETRY"
exec python evaluation/run.py \
    --model "$MODEL" \
    --dataset "$DATASET" \
    --split "$SPLIT" \
    --final_stage "$FINAL_STAGE" \
    --container_name "$CONTAINER_NAME" \
    --max_retry "$MAX_RETRY" \
    --filter_instance "${FILTER_INSTANCE:-.*}"
