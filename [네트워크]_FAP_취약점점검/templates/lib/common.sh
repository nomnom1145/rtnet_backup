#!/usr/bin/env bash
set -euo pipefail

readonly COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPTS_DIR="$(cd "${COMMON_DIR}/.." && pwd)"
readonly DEFAULT_BANNER_MESSAGE="WARNING: Authorized users only. All activity may be monitored and reported."
readonly DEFAULT_BANNER_MESSAGE_FILE="${SCRIPTS_DIR}/conf/banner_message.txt"
readonly WW_SCAN_PATHS_DEFAULT="/home /export/home /etc /bin /sbin /usr/bin /usr/sbin /usr/etc /usr/ucb /usr/ccs/bin /usr/local/bin /usr/local/sbin /tmp /var"
readonly U23_PORTS="7 9 13 19 25 53 123 161 162"
readonly TOMCAT_DEFAULT_HTTP_PORT="18080"

info() {
  printf '[INFO] %s\n' "$*"
}

warn() {
  printf '[WARN] %s\n' "$*"
}

pass() {
  printf '[PASS] %s\n' "$*"
}

fail() {
  printf '[FAIL] %s\n' "$*"
}

require_root() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    fail 'Root privileges are required.'
    exit 2
  fi
}

backup_file() {
  local target="$1"
  local stamp
  stamp="$(date +%Y%m%d%H%M%S)"
  [[ -e "$target" ]] || return 0
  cp -a -- "$target" "${target}.bak.${stamp}"
  info "Backup created: ${target}.bak.${stamp}"
}

section() {
  printf '\n=== %s ===\n' "$*"
}

step() {
  local number="$1"
  shift
  printf '  %s. %s\n' "$number" "$*"
}

rule() {
  printf '%s\n' '------------------------------------------------------------'
}

prompt_yes_no() {
  local prompt="$1"
  local answer
  printf '%s [y/N]: ' "$prompt"
  if [[ -t 0 ]]; then
    if ! read -r answer; then
      answer='n'
      printf '\n'
    fi
  elif { exec 3</dev/tty; } 2>/dev/null; then
    if ! read -r answer <&3; then
      answer='n'
      printf '\n'
    fi
    exec 3<&-
  else
    if ! read -r answer; then
      answer='n'
      printf '\n'
    fi
  fi
  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

status_mark() {
  local ok="$1"
  if [[ "$ok" -eq 0 ]]; then
    printf 'O'
  else
    printf 'X'
  fi
}

presence_mark() {
  local value="${1-}"
  if [[ -n "$value" ]]; then
    printf 'O'
  else
    printf 'X'
  fi
}

display_current_value() {
  local value="${1-}"
  if [[ -n "$value" ]]; then
    printf '%s' "$value"
  else
    printf 'not set'
  fi
}

report_check_value() {
  local ok="$1"
  local name="$2"
  local current="${3-}"
  local required="${4-}"
  local message

  message="${name}: $(status_mark "$ok") (current: $(display_current_value "$current")"
  if [[ -n "$required" ]]; then
    message="${message}, required: ${required}"
  fi
  message="${message})"

  if [[ "$ok" -eq 0 ]]; then
    pass "$message"
  else
    fail "$message"
  fi
}

preview_change() {
  local label="$1"
  local before="${2-}"
  local after="${3-}"

  info "$label"
  rule
  printf '  Previous value (이전 값): %s\n' "$(display_current_value "$before")"
  printf '  After value    (이후 값): %s\n' "$(display_current_value "$after")"
  rule
}

show_current_value() {
  local label="$1"
  local current="${2-}"

  info "$label"
  rule
  printf '  Current value (현재 값): %s\n' "$(display_current_value "$current")"
  rule
}

preview_block_change() {
  local label="$1"
  local before="${2-}"
  local after="${3-}"

  info "$label"
  rule
  printf '  Previous code (이전 코드):\n'
  if [[ -n "$before" ]]; then
    printf '%s\n' "$before" | sed 's/^/    /'
  else
    printf '    %s\n' 'not set'
  fi
  rule
  printf '  After code    (이후 코드):\n'
  if [[ -n "$after" ]]; then
    printf '%s\n' "$after" | sed 's/^/    /'
  else
    printf '    %s\n' 'not set'
  fi
  rule
}

show_current_block() {
  local label="$1"
  local current="${2-}"

  info "$label"
  rule
  printf '  Current code (현재 코드):\n'
  if [[ -n "$current" ]]; then
    printf '%s\n' "$current" | sed 's/^/    /'
  else
    printf '    %s\n' 'not set'
  fi
  rule
}

current_file_state() {
  local path="$1"

  if [[ -e "$path" ]]; then
    printf 'owner=%s group=%s mode=%s' "$(file_owner "$path")" "$(file_group "$path")" "$(file_mode "$path")"
  else
    printf 'not found'
  fi
}

show_file_state() {
  local label="$1"
  local path="$2"

  show_current_value "$label" "$(current_file_state "$path")"
}

preview_file_state_change() {
  local label="$1"
  local path="$2"
  local target_owner="$3"
  local target_group="$4"
  local target_mode="$5"

  preview_change "$label" "$(current_file_state "$path")" "owner=${target_owner} group=${target_group} mode=${target_mode}"
}

file_excerpt() {
  local path="$1"
  local lines="${2:-20}"

  [[ -r "$path" ]] || return 0
  sed -n "1,${lines}p" "$path" 2>/dev/null || true
}

mode_to_decimal() {
  local mode="$1"
  printf '%d' "$((8#${mode}))"
}

mode_leq() {
  local path="$1"
  local limit="$2"
  local current
  current="$(stat -c '%a' "$path")"
  [[ $(mode_to_decimal "$current") -le $(mode_to_decimal "$limit") ]]
}

file_mode() {
  stat -c '%a' "$1"
}

file_owner() {
  stat -c '%U' "$1"
}

file_group() {
  stat -c '%G' "$1"
}

owner_in_set() {
  local owner="$1"
  shift
  local candidate
  for candidate in "$@"; do
    [[ "$owner" == "$candidate" ]] && return 0
  done
  return 1
}

check_file_owner_mode() {
  local path="$1"
  local mode_limit="$2"
  shift 2
  local owners=("$@")
  local rc=0

  if [[ ! -e "$path" ]]; then
    fail "$path file not found."
    return 1
  fi

  local owner mode
  owner="$(file_owner "$path")"
  mode="$(file_mode "$path")"

  if owner_in_set "$owner" "${owners[@]}"; then
    pass "$path owner: $owner"
  else
    fail "$path owner issue: $owner"
    rc=1
  fi

  if mode_leq "$path" "$mode_limit"; then
    pass "$path mode: $mode (limit: $mode_limit or stricter)"
  else
    fail "$path mode issue: $mode (limit: $mode_limit or stricter)"
    rc=1
  fi

  return "$rc"
}

read_equals_key() {
  local file="$1"
  local key="$2"
  [[ -r "$file" ]] || return 0
  awk -v key="$key" '
    /^[[:space:]]*#/ { next }
    {
      line = $0
      sub(/[[:space:]]+#.*$/, "", line)
      if (match(line, "^[[:space:]]*" key "[[:space:]]*=[[:space:]]*([^[:space:]#;]+)", m)) {
        value = m[1]
      }
    }
    END { print value }
  ' "$file"
}

read_space_key() {
  local file="$1"
  local key="$2"
  [[ -r "$file" ]] || return 0
  awk -v key="$key" '
    /^[[:space:]]*#/ { next }
    {
      line = $0
      sub(/[[:space:]]+#.*$/, "", line)
      if (match(line, "^[[:space:]]*" key "[[:space:]]+([^[:space:]#;]+)", m)) {
        value = m[1]
      }
    }
    END { print value }
  ' "$file"
}

set_equals_key() {
  local file="$1"
  local key="$2"
  local value="$3"
  [[ -e "$file" ]] || : > "$file"
  if grep -Eq "^[[:space:]]*${key}[[:space:]]*=" "$file"; then
    sed -ri "s|^[[:space:]]*${key}[[:space:]]*=.*|${key} = ${value}|" "$file"
  else
    printf '%s = %s\n' "$key" "$value" >> "$file"
  fi
}

set_space_key() {
  local file="$1"
  local key="$2"
  local value="$3"
  [[ -e "$file" ]] || : > "$file"
  if grep -Eq "^[[:space:]]*${key}[[:space:]]+" "$file"; then
    sed -ri "s|^[[:space:]]*${key}[[:space:]]+.*|${key} ${value}|" "$file"
  else
    printf '%s %s\n' "$key" "$value" >> "$file"
  fi
}

read_pam_option() {
  local file="$1"
  local module="$2"
  local option="$3"
  [[ -r "$file" ]] || return 0
  awk -v module="$module" -v option="$option" '
    /^[[:space:]]*#/ { next }
    $0 ~ module {
      for (i = 1; i <= NF; i++) {
        if ($i ~ ("^" option "=")) {
          split($i, parts, "=")
          value = parts[2]
        }
      }
    }
    END { print value }
  ' "$file"
}

pam_has_module() {
  local file="$1"
  local module="$2"
  [[ -r "$file" ]] || return 1
  grep -Eq "^[[:space:]]*[^#].*${module}" "$file"
}

collect_sshd_files() {
  local files=(/etc/ssh/sshd_config)
  shopt -s nullglob
  local extra
  for extra in /etc/ssh/sshd_config.d/*.conf; do
    files+=("$extra")
  done
  shopt -u nullglob
  printf '%s\n' "${files[@]}"
}

read_sshd_key() {
  local key="$1"
  local value=''
  local file
  while IFS= read -r file; do
    [[ -r "$file" ]] || continue
    value="$({
      awk -v key="$(printf '%s' "$key" | tr '[:upper:]' '[:lower:]')" '
        /^[[:space:]]*#/ { next }
        {
          directive = tolower($1)
          if (directive == key) {
            value = $2
          }
        }
        END { print value }
      ' "$file"
    } | tail -n 1)"
    [[ -n "$value" ]] && printf '%s\n' "$value"
  done < <(collect_sshd_files)
}

set_sshd_key() {
  local key="$1"
  local value="$2"
  local file="/etc/ssh/sshd_config"
  if grep -Eqi "^[[:space:]]*${key}[[:space:]]+" "$file"; then
    sed -ri "s|^[[:space:]]*${key}[[:space:]]+.*|${key} ${value}|I" "$file"
  else
    printf '%s %s\n' "$key" "$value" >> "$file"
  fi
}

find_rsyslog_target() {
  if [[ -e /etc/rsyslog.conf ]]; then
    printf '%s\n' /etc/rsyslog.conf
  else
    printf '%s\n' /etc/syslog.conf
  fi
}

authselect_current() {
  if command -v authselect >/dev/null 2>&1; then
    authselect current 2>/dev/null || true
  fi
}

authselect_has_feature() {
  local feature="$1"
  authselect_current | grep -Fq -- "$feature"
}

find_tmout_value() {
  local files=(/etc/profile)
  shopt -s nullglob
  local file
  for file in /etc/profile.d/*.sh; do
    files+=("$file")
  done
  shopt -u nullglob
  awk '
    /^[[:space:]]*#/ { next }
    {
      if (match($0, /(^|[[:space:]])(TMOUT|TIMEOUT)[[:space:]]*=[[:space:]]*([0-9]+)/, m)) {
        value = m[3]
      }
    }
    END { print value }
  ' "${files[@]}" 2>/dev/null
}

find_unowned_paths() {
  find / \
    \( -path /proc -o -path /proc/* -o -path /sys -o -path /sys/* -o -path /dev -o -path /dev/* -o -path /run -o -path /run/* \) -prune -o \
    \( -nouser -o -nogroup \) -print 2>/dev/null
}

ww_scan_paths() {
  printf '%s\n' ${WW_SCAN_PATHS:-$WW_SCAN_PATHS_DEFAULT}
}

find_world_writable_files() {
  local path
  while IFS= read -r path; do
    [[ -d "$path" ]] || continue
    find "$path" -xdev -type f -perm -0002 -print 2>/dev/null
  done < <(ww_scan_paths)
}

ensure_line_present() {
  local file="$1"
  local line="$2"
  local regex="$3"
  if grep -Eq "$regex" "$file"; then
    return 0
  fi
  printf '%s\n' "$line" >> "$file"
}

set_xinetd_disable_yes() {
  local file="$1"
  [[ -e "$file" ]] || return 0
  if grep -Eq '^[[:space:]]*disable[[:space:]]*=' "$file"; then
    sed -ri 's|^[[:space:]]*disable[[:space:]]*=.*|        disable = yes|' "$file"
  else
    printf '        disable = yes\n' >> "$file"
  fi
}

service_unit_exists() {
  local unit="$1"
  systemctl list-unit-files "$unit" >/dev/null 2>&1 || systemctl list-unit-files "${unit}.service" >/dev/null 2>&1
}

banner_content() {
  local banner_file
  banner_file="${BANNER_MESSAGE_FILE:-$DEFAULT_BANNER_MESSAGE_FILE}"

  if [[ -n "${BANNER_MESSAGE:-}" ]]; then
    printf '%s\n' "${BANNER_MESSAGE}"
    return 0
  fi

  if [[ -r "$banner_file" ]]; then
    cat "$banner_file"
    return 0
  fi

  printf '%s\n' "$DEFAULT_BANNER_MESSAGE"
}

banner_single_line() {
  banner_content | head -n 1
}

find_tomcat_conf_dir() {
  local candidate
  if [[ -n "${TOMCAT_CONF_DIR:-}" && -d "${TOMCAT_CONF_DIR}" ]]; then
    printf '%s\n' "$TOMCAT_CONF_DIR"
    return 0
  fi
  for candidate in \
    /apps/tomcat/conf \
    /fap/tomcat/conf \
    /opt/tomcat/conf \
    /usr/local/tomcat/conf \
    /home/tomcat/conf; do
    if [[ -d "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  candidate="$({ find /apps /fap /opt /usr/local /home -maxdepth 5 -type f -path '*/tomcat/conf/server.xml' 2>/dev/null | head -n 1 || true; })"
  if [[ -n "$candidate" ]]; then
    dirname "$candidate"
    return 0
  fi
  return 1
}

write_banner_file() {
  local file="$1"
  banner_content > "$file"
}

safe_ss_listeners() {
  ss -lntupH 2>/dev/null || true
}

find_u23_listeners() {
  safe_ss_listeners | awk -v ports="$U23_PORTS" '
    BEGIN {
      split(ports, list, " ")
      for (i in list) {
        watch[list[i]] = 1
      }
    }
    {
      local = $5
      gsub(/\[/, "", local)
      gsub(/\]/, "", local)
      split(local, parts, ":")
      port = parts[length(parts)]
      if (port in watch) {
        print $0
      }
    }
  '
}

connector_xpath_count() {
  local file="$1"
  local xpath="$2"
  xmllint --xpath "$xpath" "$file" 2>/dev/null || printf '0'
}

rewrite_server_xml() {
  local file="$1"
  local mode="$2"
  local tmp
  tmp="$(mktemp)"
  awk -v mode="$mode" -v new_port="${NEW_TOMCAT_HTTP_PORT:-$TOMCAT_DEFAULT_HTTP_PORT}" '
    function process(buf,   out) {
      out = buf
      if (out ~ /<Connector/ && out ~ /HTTP\/1\.1/) {
        if (mode == "hide_server") {
          if (out ~ /server="[^"]*"/) {
            gsub(/server="[^"]*"/, "server=\" \"", out)
          } else if (out ~ /\/>/) {
            sub(/\/>/, " server=\" \" />", out)
          } else if (out ~ />/) {
            sub(/>/, " server=\" \" >", out)
          }
        }
        if (mode == "change_port") {
          gsub(/port="8080"/, "port=\"" new_port "\"", out)
        }
      }
      return out
    }
    {
      if (!in_connector && $0 ~ /<Connector/) {
        in_connector = 1
        buffer = $0 ORS
        if ($0 ~ />/) {
          printf "%s", process(buffer)
          in_connector = 0
          buffer = ""
        }
        next
      }
      if (in_connector) {
        buffer = buffer $0 ORS
        if ($0 ~ />/) {
          printf "%s", process(buffer)
          in_connector = 0
          buffer = ""
        }
        next
      }
      print
    }
    END {
      if (buffer != "") {
        printf "%s", process(buffer)
      }
    }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}
