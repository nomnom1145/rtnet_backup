#!/bin/sh
case "${0##*/}:${BASH##*/}:${BASH_VERSION:-}" in
  sh:sh:*|sh::|*:sh:*) exec /usr/bin/env bash "$0" "$@" ;;
esac
if [ -z "${BASH_VERSION:-}" ]; then exec /usr/bin/env bash "$0" "$@"; fi
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Default privileged account for U-45.
# Override example:
#   sudo SU_ALLOWED_USERS=fap,secusse1 sh U-45_02_RESOLVE.sh
: "${SU_ALLOWED_USERS:=fap}"
export SU_ALLOWED_USERS
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/item_runner.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/items/U-45.sh"
run_resolve_item
