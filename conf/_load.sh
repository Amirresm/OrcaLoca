#!/usr/bin/env bash
# Sourced by run-*.sh. Resolves the experiment data dir and loads its conf.
set -euo pipefail

# Repo root (this file lives in <repo>/conf/), regardless of caller's CWD.
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export APP_DIR

# Experiment data dir — chosen at RUNTIME, not baked into the image.
# Set it with:  export ORCA_DATA=/data/<exp>   or pass it:  ./run-smoke.sh <exp>
if [ -z "${ORCA_DATA:-}" ]; then
    echo "ERROR: ORCA_DATA is not set." >&2
    echo "  export ORCA_DATA=/data/<exp>     and re-run, or" >&2
    echo "  ./run-smoke.sh <exp>             (sets it to /data/<exp> for you)" >&2
    exit 1
fi
export ORCA_DATA
mkdir -p "$ORCA_DATA"

# Per-experiment conf lives in the data dir. On first use, scaffold it from the
# template and stop, so you fill in real values (vLLM port, etc.) before running.
# No silent fallback to the template -> no accidental wrong-endpoint runs.
CONF="${ORCA_CONF:-$ORCA_DATA/conf.sh}"
if [ ! -f "$CONF" ]; then
    cp "$APP_DIR/conf/example.sh" "$CONF"
    echo "Created $CONF from template." >&2
    echo "Edit it (set OPENAI_API_BASE_URL to your vLLM port), then re-run." >&2
    exit 1
fi

echo ">> data dir: $ORCA_DATA"
echo ">> sourcing config: $CONF"
# shellcheck disable=SC1090
source "$CONF"

echo ">> MODEL=$MODEL  ENDPOINT=$OPENAI_API_BASE_URL  DATASET=$DATASET  STAGE=$FINAL_STAGE"
