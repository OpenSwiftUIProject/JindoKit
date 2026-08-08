#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
MISE_ARGS=()

usage() {
  printf '%s\n' \
    "Usage: ./setup.sh [--osui]" \
    "" \
    "Options:" \
    "  --osui  Use mise.osui.toml and generate the OpenSwiftUI example."
}

run_mise() {
  if [[ ${#MISE_ARGS[@]} -gt 0 ]]; then
    mise "${MISE_ARGS[@]}" "$@"
  else
    mise "$@"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --osui)
      MISE_ARGS=(--env osui)
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

cd "$SCRIPT_DIR"
mise trust "$SCRIPT_DIR/mise.toml"
if [[ ${#MISE_ARGS[@]} -gt 0 ]]; then
  mise trust "$SCRIPT_DIR/mise.osui.toml"
fi
run_mise install
run_mise exec -- tuist generate --no-open
