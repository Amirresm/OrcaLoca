#!/usr/bin/env bash
# Run ONLY the edit stage on top of existing search output (output/<id>/searcher_*.json).
# Skips trace+search; resume-safe. Usage: ./run-edit.sh [experiment]
if [ -n "${1:-}" ]; then
    case "$1" in
        /*) export ORCA_DATA="$1" ;;
        *)  export ORCA_DATA="/data/$1" ;;
    esac
fi
source "$(dirname "$0")/conf/_load.sh"

# Run from the experiment data dir so ./output/ and ./log* resolve under $ORCA_DATA.
cd "$ORCA_DATA"

echo ">> edit-resume over $DATASET ($SPLIT), reading existing search output"
exec python "$APP_DIR/evaluation/run_edit_resume.py" \
    --model "$MODEL" \
    --dataset "$DATASET" \
    --split "$SPLIT" \
    --container_name "$CONTAINER_NAME" \
    --filter_instance "${FILTER_INSTANCE:-.*}"
