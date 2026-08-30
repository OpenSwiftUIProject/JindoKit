#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
MISE_ENV=""
MISE_ARGS=()

usage() {
  printf '%s\n' \
    "Usage: ./setup.sh [--sui-no-spi | --sui | --osui-no-spi | --osui]" \
    "" \
    "Options:" \
    "  --sui-no-spi   Use mise.sui-no-spi.toml and generate the SwiftUI open source example." \
    "  --sui   Use mise.sui.toml and generate the SwiftUI SPI example." \
    "  --osui-no-spi  Use mise.osui-no-spi.toml and generate the OpenSwiftUI open source example." \
    "  --osui  Use mise.osui.toml and generate the OpenSwiftUI SPI example."
}

run_mise() {
  if [[ ${#MISE_ARGS[@]} -gt 0 ]]; then
    mise "${MISE_ARGS[@]}" "$@"
  else
    mise "$@"
  fi
}

select_mise_env() {
  if [[ -n "$MISE_ENV" ]]; then
    usage >&2
    exit 2
  fi
  MISE_ENV="$1"
  MISE_ARGS=(--env "$MISE_ENV")
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sui-no-spi)
      select_mise_env "sui-no-spi"
      ;;
    --sui)
      select_mise_env "sui"
      ;;
    --osui-no-spi)
      select_mise_env "osui-no-spi"
      ;;
    --osui)
      select_mise_env "osui"
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
if [[ -n "$MISE_ENV" ]]; then
  mise trust "$SCRIPT_DIR/mise.$MISE_ENV.toml"
fi
run_mise install
run_mise exec -- tuist generate --no-open
