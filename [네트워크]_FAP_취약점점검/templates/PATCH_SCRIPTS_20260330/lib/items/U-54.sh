#!/usr/bin/env bash
ITEM_CODE=U-54
ITEM_TITLE=Session\ timeout

show_plan() {
  step 1 'Create or replace /etc/profile.d/99-session-timeout.sh.'
  step 2 'Set TMOUT and export it.'
}

u54_current_tmout_lines() {
  local files=(/etc/profile)
  local file
  shopt -s nullglob
  for file in /etc/profile.d/*.sh; do
    files+=("$file")
  done
  shopt -u nullglob
  grep -HnE '(^|[[:space:]])(TMOUT|TIMEOUT)[[:space:]]*=' "${files[@]}" 2>/dev/null || true
}

show_current_state() {
  local value current_lines

  value="$(find_tmout_value)"
  current_lines="$(u54_current_tmout_lines)"
  show_current_value 'effective TMOUT/TIMEOUT value' "${value}"
  show_current_block 'TMOUT/TIMEOUT definition lines' "${current_lines}"
  return 0
}

preview_item_changes() {
  local value current_lines

  value="$(find_tmout_value)"
  current_lines="$(u54_current_tmout_lines)"
  preview_change 'effective TMOUT/TIMEOUT value' "${value}" "${SESSION_TIMEOUT_SECONDS:-600}"
  preview_block_change \
    '/etc/profile.d/99-session-timeout.sh content' \
    "$(file_excerpt /etc/profile.d/99-session-timeout.sh 20)" \
    "$(printf '%s\n%s\n%s' \
      "TMOUT=${SESSION_TIMEOUT_SECONDS:-600}" \
      'readonly TMOUT' \
      'export TMOUT')"
  show_current_block 'Current TMOUT/TIMEOUT definition lines' "${current_lines}"
}

check_item () 
{ 
    local value;
    value="$(find_tmout_value)";
    if [[ "${value:-}" =~ ^[0-9]+$ && ${value} -ge 1 && ${value} -le 600 ]]; then
        report_check_value 0 "TMOUT/TIMEOUT" "${value:-}" "1-600";
        return 0;
    fi;
    report_check_value 1 "TMOUT/TIMEOUT" "${value:-}" "1-600";
    return 1
}

apply_item () 
{ 
    require_root;
    backup_file /etc/profile.d/99-session-timeout.sh;
    cat > /etc/profile.d/99-session-timeout.sh  <<EOF_TMOUT
TMOUT=${SESSION_TIMEOUT_SECONDS:-600}
readonly TMOUT
export TMOUT
EOF_TMOUT

    chmod 644 /etc/profile.d/99-session-timeout.sh;
    pass 'U-54 Remediation steps applied.'
}
