#!/usr/bin/env bash
ITEM_CODE=U-07
ITEM_TITLE=/etc/passwd\ owner\ and\ mode

show_plan() {
  step 1 'Set /etc/passwd owner to root:root.'
  step 2 'Set /etc/passwd mode to 644.'
}

show_current_state() {
  show_file_state '/etc/passwd ownership and mode' /etc/passwd
  show_current_block '/etc/passwd first lines' "$(file_excerpt /etc/passwd 5)"
  return 0
}

preview_item_changes() {
  preview_file_state_change '/etc/passwd ownership and mode' /etc/passwd root root 644
}

check_item () 
{ 
    check_file_owner_mode /etc/passwd 644 root bin
}

apply_item () 
{ 
    require_root;
    chown root:root /etc/passwd;
    chmod 644 /etc/passwd;
    pass 'U-07 Remediation steps applied.'
}
