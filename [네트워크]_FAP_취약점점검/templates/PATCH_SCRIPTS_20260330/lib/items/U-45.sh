#!/usr/bin/env bash
ITEM_CODE=U-45
ITEM_TITLE=Restrict\ su\ to\ privileged\ group

show_plan() {
  step 1 'Backup /etc/pam.d/su.'
  step 2 'Ensure wheel group exists and set su group/mode to wheel:4750.'
  step 3 'Enable pam_wheel restriction in /etc/pam.d/su.'
  step 4 'If SU_ALLOWED_USERS is set, add those users to wheel.'
}

show_current_state() {
  local su_path=/usr/bin/su
  local current_su_state wheel_members pam_wheel_line

  [[ -x "$su_path" ]] || su_path=/bin/su

  if [[ -e "$su_path" ]]; then
    current_su_state="owner=$(file_owner "$su_path") group=$(file_group "$su_path") mode=$(file_mode "$su_path")"
  else
    current_su_state='not found'
  fi

  if getent group wheel >/dev/null 2>&1; then
    wheel_members="$(getent group wheel | awk -F: '{print $4}')"
  else
    wheel_members='not found'
  fi

  pam_wheel_line="$(grep -n -E 'pam_wheel\.so' /etc/pam.d/su 2>/dev/null || true)"

  show_current_value "${su_path} ownership and mode" "${current_su_state}"
  show_current_value 'wheel group members' "${wheel_members:-none}"
  show_current_block '/etc/pam.d/su pam_wheel lines' "${pam_wheel_line}"
  return 0
}

preview_item_changes() {
  local su_path=/usr/bin/su wheel_members pam_wheel_line
  local current_su_state target_su_state target_pam_line target_wheel_members
  [[ -x "$su_path" ]] || su_path=/bin/su
  target_pam_line='auth           required        pam_wheel.so use_uid group=wheel'

  if [[ -e "$su_path" ]]; then
    current_su_state="owner=$(file_owner "$su_path") group=$(file_group "$su_path") mode=$(file_mode "$su_path")"
  else
    current_su_state='not found'
  fi
  target_su_state='owner=root group=wheel mode=4750'
  preview_change "${su_path} ownership and mode" "$current_su_state" "$target_su_state"

  if getent group wheel >/dev/null 2>&1; then
    wheel_members="$(getent group wheel | awk -F: '{print $4}')"
    :
  else
    wheel_members=''
  fi
  if [[ -n "${SU_ALLOWED_USERS:-}" ]]; then
    target_wheel_members="${wheel_members:-none} + ${SU_ALLOWED_USERS}"
  else
    target_wheel_members="${wheel_members:-none}"
  fi
  preview_change 'wheel group members' "${wheel_members:-none}" "${target_wheel_members}"

  pam_wheel_line="$(grep -E 'pam_wheel\.so' /etc/pam.d/su 2>/dev/null | tail -n 1 || true)"
  preview_change '/etc/pam.d/su pam_wheel line' "${pam_wheel_line}" "${target_pam_line}"
  preview_change 'Additional users to add to wheel' 'none' "${SU_ALLOWED_USERS:-none}"

  if [[ -z "${wheel_members:-}" && -z "${SU_ALLOWED_USERS:-}" ]]; then
    warn 'No wheel members are currently defined.'
    warn 'This run will be blocked to avoid locking out su access.'
    info 'Example: SU_ALLOWED_USERS=admin1,admin2 sudo sh U-45_02_RESOLVE.sh'
  fi
}

pre_apply_check() {
  local wheel_members=''

  if getent group wheel >/dev/null 2>&1; then
    wheel_members="$(getent group wheel | awk -F: '{print $4}')"
  fi

  if [[ -z "${SU_ALLOWED_USERS:-}" && -z "${wheel_members:-}" ]]; then
    fail 'wheel group has no members and SU_ALLOWED_USERS is empty. Refusing to restrict su.'
    info 'Run example: SU_ALLOWED_USERS=admin1,admin2 sudo sh U-45_02_RESOLVE.sh'
    return 1
  fi

  warn 'This item can restrict su access immediately.'
  prompt_yes_no 'Continue with su restriction changes?' || return 1
}

check_item () 
{ 
    local rc=0;
    local su_path=/usr/bin/su;
    [[ -x "$su_path" ]] || su_path=/bin/su;
    if [[ ! -e "$su_path" ]]; then
        fail 'su 바이너리를 찾지 못했습니다.';
        return 1;
    fi;
    if check_file_owner_mode "$su_path" 4750 root; then
        :;
    else
        rc=1;
    fi;
    if [[ "$(file_group "$su_path")" == wheel ]]; then
        pass "$su_path group=wheel";
    else
        fail "$su_path group issue: $(file_group "$su_path")";
        rc=1;
    fi;
    if getent group wheel > /dev/null 2>&1; then
        pass 'wheel group 존재';
    else
        fail 'wheel group이 없습니다.';
        rc=1;
    fi;
    if grep -Eq '^[[:space:]]*auth[[:space:]]+(required|requisite)[[:space:]]+pam_wheel\.so.*(use_uid|group=wheel)' /etc/pam.d/su; then
        pass '/etc/pam.d/su 에 pam_wheel.so 설정 존재';
    else
        fail '/etc/pam.d/su 에 pam_wheel.so 제한 설정이 없습니다.';
        rc=1;
    fi;
    return "$rc"
}

apply_item () 
{ 
    require_root;
    local su_path=/usr/bin/su;
    [[ -x "$su_path" ]] || su_path=/bin/su;
    backup_file /etc/pam.d/su;
    getent group wheel > /dev/null 2>&1 || groupadd wheel;
    chgrp wheel "$su_path";
    chmod 4750 "$su_path";
    if grep -Eq '^[[:space:]]*#?[[:space:]]*auth[[:space:]].*pam_wheel\.so' /etc/pam.d/su; then
        sed -ri 's|^[[:space:]]*#?[[:space:]]*auth[[:space:]].*pam_wheel\.so.*|auth           required        pam_wheel.so use_uid group=wheel|' /etc/pam.d/su;
    else
        awk '
      BEGIN { inserted = 0 }
      {
        print
        if (!inserted && $0 ~ /pam_rootok\.so/) {
          print "auth           required        pam_wheel.so use_uid group=wheel"
          inserted = 1
        }
      }
      END {
        if (!inserted) {
          print "auth           required        pam_wheel.so use_uid group=wheel"
        }
      }
    ' /etc/pam.d/su > /etc/pam.d/su.tmp;
        mv /etc/pam.d/su.tmp /etc/pam.d/su;
    fi;
    if [[ -n "${SU_ALLOWED_USERS:-}" ]]; then
        local user;
        IFS=',' read -r -a _users <<< "$SU_ALLOWED_USERS";
        for user in "${_users[@]}";
        do
            usermod -aG wheel "$user";
        done;
        info "wheel group에 사용자 추가: ${SU_ALLOWED_USERS}";
    else
        warn 'SU_ALLOWED_USERS 가 지정되지 않았습니다. wheel group 구성원은 별도 확인하세요.';
    fi;
    pass 'U-45 Remediation steps applied.'
}
