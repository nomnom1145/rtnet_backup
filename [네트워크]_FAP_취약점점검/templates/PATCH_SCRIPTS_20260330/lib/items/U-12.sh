#!/usr/bin/env bash
ITEM_CODE=U-12
ITEM_TITLE=/etc/services\ owner\ and\ mode

show_plan() {
  step 1 'Set /etc/services owner to root:root.'
  step 2 'Set /etc/services mode to 644.'
}

show_current_state() {
  show_file_state '/etc/services ownership and mode' /etc/services
  show_current_block '/etc/services first lines' "$(file_excerpt /etc/services 10)"
  return 0
}

preview_item_changes() {
  preview_file_state_change '/etc/services ownership and mode' /etc/services root root 644
}

check_item () 
{ 
    check_file_owner_mode /etc/services 644 root bin sys
}

apply_item () 
{ 
    require_root;
    chown root:root /etc/services;
    chmod 644 /etc/services;
    pass 'U-12 Remediation steps applied.'
}
