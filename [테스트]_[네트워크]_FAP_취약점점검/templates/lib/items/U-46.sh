#!/usr/bin/env bash
ITEM_CODE=U-46
ITEM_TITLE=Minimum\ password\ length

show_plan() {
  step 1 'Backup /etc/login.defs.'
  step 2 'Set PASS_MIN_LEN to the required minimum.'
}

show_current_state() {
  local current_line

  current_line="$(grep -E '^[[:space:]]*PASS_MIN_LEN[[:space:]]+' /etc/login.defs 2>/dev/null | tail -n 1 || true)"
  show_current_value '/etc/login.defs PASS_MIN_LEN' "${current_line}"
  return 0
}

preview_item_changes() {
  local current_line

  current_line="$(grep -E '^[[:space:]]*PASS_MIN_LEN[[:space:]]+' /etc/login.defs 2>/dev/null | tail -n 1 || true)"
  preview_change '/etc/login.defs PASS_MIN_LEN' "${current_line}" "PASS_MIN_LEN ${PASS_MIN_LEN_REQUIRED:-8}"
}

check_item () 
{ 
    local value;
    value="$(read_space_key /etc/login.defs PASS_MIN_LEN)";
    if [[ "${value:-}" =~ ^[0-9]+$ && ${value} -ge 8 ]]; then
        report_check_value 0 "PASS_MIN_LEN" "${value:-}" ">=8";
        return 0;
    fi;
    report_check_value 1 "PASS_MIN_LEN" "${value:-}" ">=8";
    return 1
}

apply_item () 
{ 
    require_root;
    backup_file /etc/login.defs;
    set_space_key /etc/login.defs PASS_MIN_LEN "${PASS_MIN_LEN_REQUIRED:-8}";
    pass 'U-46 Remediation steps applied.'
}
