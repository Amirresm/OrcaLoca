#!/usr/bin/env bash
# Full run: run OrcaLoca across the dataset (FILTER_INSTANCE, default '.*').
source "$(dirname "$0")/conf/_load.sh"

# Run from the per-image data dir so ./log* and ./output/ land under $ORCA_DATA.
cd "$ORCA_DATA"

echo ">> filter_instance: ${FILTER_INSTANCE:-.*}  max_retry: $MAX_RETRY"
exec python "$APP_DIR/evaluation/run.py" \
    --model "$MODEL" \
    --dataset "$DATASET" \
    --split "$SPLIT" \
    --final_stage "$FINAL_STAGE" \
    --container_name "$CONTAINER_NAME" \
    --max_retry "$MAX_RETRY" \
    --filter_instance "${FILTER_INSTANCE:-.*}"
