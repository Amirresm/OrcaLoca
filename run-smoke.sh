#!/usr/bin/env bash
# Smoke test: run OrcaLoca on a couple of instances against your vLLM model.
source "$(dirname "$0")/conf/_load.sh"

# Run from the per-image data dir so ./log* and ./output/ land under $ORCA_DATA.
cd "$ORCA_DATA"

echo ">> smoke instances: $SMOKE_INSTANCES"
exec python "$APP_DIR/evaluation/run.py" \
    --model "$MODEL" \
    --dataset "$DATASET" \
    --split "$SPLIT" \
    --final_stage "$FINAL_STAGE" \
    --container_name "$CONTAINER_NAME" \
    --instance_ids $SMOKE_INSTANCES
