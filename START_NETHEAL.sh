#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR"

if [ ! -x ".venv/bin/python" ]; then
  echo "[NetHeal-Agent] First run: creating the Python environment and installing dependencies..."
  sh "$SCRIPT_DIR/setup-netheal.sh"
fi

echo "[NetHeal-Agent] Starting Co-Sight on http://localhost:7788/cosight/ ..."
exec "$SCRIPT_DIR/.venv/bin/python" "$SCRIPT_DIR/cosight_server/deep_research/main.py"

