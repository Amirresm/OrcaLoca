#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

CONF="${ORCA_CONF:-data/conf.sh}"
if [ ! -f "$CONF" ]; then
    CONF="conf/example.sh"
fi
echo ">> sourcing config: $CONF"
# shellcheck disable=SC1090
source "$CONF"

echo ">> MODEL=$MODEL  ENDPOINT=$OPENAI_API_BASE_URL  DATASET=$DATASET  STAGE=$FINAL_STAGE"
