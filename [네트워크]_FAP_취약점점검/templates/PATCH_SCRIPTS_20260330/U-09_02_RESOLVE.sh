#!/bin/sh
case "${0##*/}:${BASH##*/}:${BASH_VERSION:-}" in
  sh:sh:*|sh::|*:sh:*) exec /usr/bin/env bash "$0" "$@" ;;
esac
if [ -z "${BASH_VERSION:-}" ]; then exec /usr/bin/env bash "$0" "$@"; fi
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/item_runner.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/items/U-09.sh"
run_resolve_item
