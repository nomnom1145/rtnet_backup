#!/usr/bin/env bash
ITEM_CODE=U-47
ITEM_TITLE=Maximum\ password\ age

show_plan() {
  step 1 'Backup /etc/login.defs.'
  step 2 'Set PASS_MAX_DAYS to the required maximum.'
}

show_current_state() {
  local current_line

  current_line="$(grep -E '^[[:space:]]*PASS_MAX_DAYS[[:space:]]+' /etc/login.defs 2>/dev/null | tail -n 1 || true)"
  show_current_value '/etc/login.defs PASS_MAX_DAYS' "${current_line}"
  return 0
}

preview_item_changes() {
  local current_line

  current_line="$(grep -E '^[[:space:]]*PASS_MAX_DAYS[[:space:]]+' /etc/login.defs 2>/dev/null | tail -n 1 || true)"
  preview_change '/etc/login.defs PASS_MAX_DAYS' "${current_line}" "PASS_MAX_DAYS ${PASS_MAX_DAYS_REQUIRED:-90}"
}

check_item () 
{ 
    local value;
    value="$(read_space_key /etc/login.defs PASS_MAX_DAYS)";
    if [[ "${value:-}" =~ ^[0-9]+$ && ${value} -ge 1 && ${value} -le 90 ]]; then
        report_check_value 0 "PASS_MAX_DAYS" "${value:-}" "1-90";
        return 0;
    fi;
    report_check_value 1 "PASS_MAX_DAYS" "${value:-}" "1-90";
    return 1
}

apply_item () 
{ 
    require_root;
    backup_file /etc/login.defs;
    set_space_key /etc/login.defs PASS_MAX_DAYS "${PASS_MAX_DAYS_REQUIRED:-90}";
    pass 'U-47 Remediation steps applied.'
}
