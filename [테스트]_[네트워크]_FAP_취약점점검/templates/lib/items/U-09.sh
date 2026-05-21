#!/usr/bin/env bash
ITEM_CODE=U-09
ITEM_TITLE=/etc/hosts\ owner\ and\ mode

show_plan() {
  step 1 'Set /etc/hosts owner to root:root.'
  step 2 'Set /etc/hosts mode to 644.'
}

show_current_state() {
  show_file_state '/etc/hosts ownership and mode' /etc/hosts
  show_current_block '/etc/hosts first lines' "$(file_excerpt /etc/hosts 10)"
  return 0
}

preview_item_changes() {
  preview_file_state_change '/etc/hosts ownership and mode' /etc/hosts root root 644
}

check_item () 
{ 
    check_file_owner_mode /etc/hosts 644 root bin
}

apply_item () 
{ 
    require_root;
    chown root:root /etc/hosts;
    chmod 644 /etc/hosts;
    pass 'U-09 Remediation steps applied.'
}
