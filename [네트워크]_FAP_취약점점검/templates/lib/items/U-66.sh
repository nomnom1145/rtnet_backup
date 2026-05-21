#!/usr/bin/env bash
ITEM_CODE=U-66
ITEM_TITLE=at\ file\ owner\ and\ mode

show_plan() {
  step 1 'Create /etc/at.allow or /etc/at.deny if missing.'
  step 2 'Set owner root:root and mode 640 on both files.'
}

show_current_state() {
  show_file_state '/etc/at.allow ownership and mode' /etc/at.allow
  show_current_block '/etc/at.allow content' "$(file_excerpt /etc/at.allow 20)"
  show_file_state '/etc/at.deny ownership and mode' /etc/at.deny
  show_current_block '/etc/at.deny content' "$(file_excerpt /etc/at.deny 20)"
  return 0
}

preview_item_changes() {
  local allow_state deny_state allow_content deny_content
  local target_allow_content target_deny_content

  if [[ -e /etc/at.allow ]]; then
    allow_state="owner=$(file_owner /etc/at.allow):$(file_group /etc/at.allow) mode=$(file_mode /etc/at.allow)"
    allow_content="$(sed -n '1,20p' /etc/at.allow 2>/dev/null || true)"
    target_allow_content="${allow_content}"
  else
    allow_state='missing'
    allow_content=''
    target_allow_content='root'
  fi

  if [[ -e /etc/at.deny ]]; then
    deny_state="owner=$(file_owner /etc/at.deny):$(file_group /etc/at.deny) mode=$(file_mode /etc/at.deny)"
    deny_content="$(sed -n '1,20p' /etc/at.deny 2>/dev/null || true)"
    target_deny_content="${deny_content}"
  else
    deny_state='missing'
    deny_content=''
    target_deny_content='empty file'
  fi

  preview_change '/etc/at.allow owner and mode' "$allow_state" 'owner=root:root mode=640'
  preview_block_change '/etc/at.allow content' "$allow_content" "$target_allow_content"
  preview_change '/etc/at.deny owner and mode' "$deny_state" 'owner=root:root mode=640'
  preview_block_change '/etc/at.deny content' "$deny_content" "$target_deny_content"
}

pre_apply_check() {
  warn 'This item can change which users are allowed to use at jobs.'
  prompt_yes_no 'Continue with at access control changes?' || return 1
}

check_item () 
{ 
    local rc=0;
    local found=0;
    local file;
    for file in /etc/at.allow /etc/at.deny;
    do
        [[ -e "$file" ]] || continue;
        found=1;
        if ! check_file_owner_mode "$file" 640 root bin; then
            rc=1;
        fi;
    done;
    if [[ "$found" -eq 0 ]]; then
        fail '/etc/at.allow 또는 /etc/at.deny 가 없습니다.';
        rc=1;
    fi;
    return "$rc"
}

apply_item () 
{ 
    require_root;
    [[ -e /etc/at.allow ]] || printf 'root\n' > /etc/at.allow;
    [[ -e /etc/at.deny ]] || : > /etc/at.deny;
    chown root:root /etc/at.allow /etc/at.deny;
    chmod 640 /etc/at.allow /etc/at.deny;
    pass 'U-66 Remediation steps applied.'
}
