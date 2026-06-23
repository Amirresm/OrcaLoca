#!/usr/bin/env bash

source "$(dirname "$0")/conf/_load.sh"

echo ">> smoke instances: $SMOKE_INSTANCES"
exec python evaluation/run.py \
    --model "$MODEL" \
    --dataset "$DATASET" \
    --split "$SPLIT" \
    --final_stage "$FINAL_STAGE" \
    --container_name "$CONTAINER_NAME" \
    --instance_ids $SMOKE_INSTANCES
