#!/usr/bin/env bash
ITEM_CODE=U-11
ITEM_TITLE=syslog\ config\ owner\ and\ mode

show_plan() {
  step 1 'Find the active syslog config file.'
  step 2 'Set owner to root:root and mode to 644.'
}

show_current_state() {
  local target

  target="$(find_rsyslog_target)"
  show_current_value 'active syslog config file' "${target}"
  show_file_state "${target} ownership and mode" "${target}"
  show_current_block "${target} first lines" "$(file_excerpt "${target}" 10)"
  return 0
}

preview_item_changes() {
  local target

  target="$(find_rsyslog_target)"
  preview_file_state_change "${target} ownership and mode" "${target}" root root 644
}

check_item () 
{ 
    local target;
    target="$(find_rsyslog_target)";
    check_file_owner_mode "$target" 644 root bin sys
}

apply_item () 
{ 
    require_root;
    local target;
    target="$(find_rsyslog_target)";
    chown root:root "$target";
    chmod 644 "$target";
    pass "U-11 Remediation steps applied: ${target}"
}
