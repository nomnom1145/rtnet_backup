#!/usr/bin/env bash
ITEM_CODE=U-08
ITEM_TITLE=/etc/shadow\ owner\ and\ mode

show_plan() {
  step 1 'Set /etc/shadow owner to root:root.'
  step 2 'Set /etc/shadow mode to 400.'
}

show_current_state() {
  show_file_state '/etc/shadow ownership and mode' /etc/shadow
  return 0
}

preview_item_changes() {
  preview_file_state_change '/etc/shadow ownership and mode' /etc/shadow root root 400
}

check_item () 
{ 
    local rc=0;
    local owner mode;
    owner="$(file_owner /etc/shadow)";
    mode="$(file_mode /etc/shadow)";
    if [[ "$owner" == root ]]; then
        pass '/etc/shadow owner=root';
    else
        fail "/etc/shadow owner issue: $owner";
        rc=1;
    fi;
    if mode_leq /etc/shadow 400; then
        pass "/etc/shadow mode=${mode}";
    else
        fail "/etc/shadow mode issue: ${mode}";
        rc=1;
    fi;
    return "$rc"
}

apply_item () 
{ 
    require_root;
    chown root:root /etc/shadow;
    chmod 400 /etc/shadow;
    pass 'U-08 Remediation steps applied.'
}
