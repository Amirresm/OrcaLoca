#!/usr/bin/env bash
# Scaffold an experiment under the shared /data mount, INSIDE the container.
# Usage: ./setup.sh <experiment>    (creates /data/<experiment>/conf.sh)
set -euo pipefail
cd "$(dirname "$0")"

EXP="${1:?usage: ./setup.sh <experiment>   (creates /data/<experiment>/conf.sh)}"
case "$EXP" in
    /*) DIR="$EXP" ;;
    *)  DIR="/data/$EXP" ;;
esac

mkdir -p "$DIR"
if [ -e "$DIR/conf.sh" ]; then
    echo "$DIR/conf.sh already exists — leaving it as-is."
else
    cp conf/example.sh "$DIR/conf.sh"
    echo "Created $DIR/conf.sh"
fi

echo
echo "Next:"
echo "  vim $DIR/conf.sh        # set OPENAI_API_BASE_URL to your vLLM port"
echo "  ./run-smoke.sh $EXP     # then: ./run-swe.sh $EXP"
