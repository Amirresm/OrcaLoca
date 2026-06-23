#!/usr/bin/env bash
# Sourced by run-*.sh. Resolves the per-image data dir, picks a conf, loads it.
set -euo pipefail

# Repo root (this file lives in <repo>/conf/), regardless of caller's CWD.
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export APP_DIR

# Per-image data dir. Sources of truth, in order:
#   1. ORCA_DATA set inside the conf (below)         -> wins
#   2. -e ORCA_DATA / Docker ENV ORCA_DATA=/data/... -> default for the conf
#   3. /data                                         -> last resort
# You mount the SAME host /data into every container (-v /data:/data); each image
# writes only under its own subdir.
export ORCA_DATA="${ORCA_DATA:-/data}"

# Config lookup uses the *current* ORCA_DATA (so a per-image conf must live in a
# dir you can name before sourcing). The repo template is the fallback.
CONF="${ORCA_CONF:-$ORCA_DATA/conf.sh}"
if [ ! -f "$CONF" ]; then
    CONF="$APP_DIR/conf/example.sh"
fi

echo ">> sourcing config: $CONF"
# shellcheck disable=SC1090
source "$CONF"

# Finalize AFTER sourcing so an ORCA_DATA set in the conf takes effect here.
export ORCA_DATA
mkdir -p "$ORCA_DATA"

echo ">> data dir: $ORCA_DATA"
echo ">> MODEL=$MODEL  ENDPOINT=$OPENAI_API_BASE_URL  DATASET=$DATASET  STAGE=$FINAL_STAGE"
