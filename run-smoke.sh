#!/usr/bin/env bash
# Smoke test on a couple of instances.
# Usage: ./run-smoke.sh [experiment]   (experiment -> /data/<experiment>)
#   or set ORCA_DATA beforehand and call with no arg.
if [ -n "${1:-}" ]; then
    case "$1" in
        /*) export ORCA_DATA="$1" ;;
        *)  export ORCA_DATA="/data/$1" ;;
    esac
fi
source "$(dirname "$0")/conf/_load.sh"

# Run from the experiment data dir so ./log* and ./output/ land under $ORCA_DATA.
cd "$ORCA_DATA"

echo ">> smoke instances: $SMOKE_INSTANCES"
exec python "$APP_DIR/evaluation/run.py" \
    --model "$MODEL" \
    --dataset "$DATASET" \
    --split "$SPLIT" \
    --final_stage "$FINAL_STAGE" \
    --container_name "$CONTAINER_NAME" \
    --instance_ids $SMOKE_INSTANCES
