#!/usr/bin/env bash
ITEM_CODE=WT-02
ITEM_TITLE=Tomcat\ config\ file\ permissions

show_plan() {
  step 1 'Locate the Tomcat conf directory.'
  step 2 'Set owner to TOMCAT_OWNER:TOMCAT_GROUP or the current conf directory owner/group.'
  step 3 'Set *.xml/*.properties/*.policy file mode to 640.'
}

show_current_state() {
  local conf_dir current_files='' file

  conf_dir="$(find_tomcat_conf_dir || true)"
  if [[ -z "$conf_dir" ]]; then
    fail 'Tomcat conf directory not found. Set TOMCAT_CONF_DIR.'
    return 0
  fi

  show_current_value 'Tomcat conf directory' "${conf_dir}"
  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    current_files+="${file} $(current_file_state "$file")"$'\n'
  done < <(find "$conf_dir" -maxdepth 1 -type f \( -name '*.xml' -o -name '*.properties' -o -name '*.policy' \) | sort)
  show_current_block 'Tomcat config file states' "${current_files%$'\n'}"
  return 0
}

preview_item_changes() {
  local conf_dir owner group current_files='' after_files='' file

  conf_dir="$(find_tomcat_conf_dir || true)"
  if [[ -z "$conf_dir" ]]; then
    fail 'Tomcat conf directory not found. Set TOMCAT_CONF_DIR.'
    return 0
  fi

  owner="${TOMCAT_OWNER:-$(stat -c '%U' "$conf_dir")}"
  group="${TOMCAT_GROUP:-$(stat -c '%G' "$conf_dir")}"

  show_current_value 'Tomcat conf directory' "${conf_dir}"
  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    current_files+="${file} $(current_file_state "$file")"$'\n'
    after_files+="${file} owner=${owner} group=${group} mode=640"$'\n'
  done < <(find "$conf_dir" -maxdepth 1 -type f \( -name '*.xml' -o -name '*.properties' -o -name '*.policy' \) | sort)
  preview_block_change 'Tomcat config file states' "${current_files%$'\n'}" "${after_files%$'\n'}"
}

check_item () 
{ 
    local conf_dir;
    conf_dir="$(find_tomcat_conf_dir || true)";
    if [[ -z "$conf_dir" ]]; then
        fail 'Tomcat conf directory not found. Set TOMCAT_CONF_DIR.';
        return 1;
    fi;
    local rc=0;
    local file owner mode found=0;
    while IFS= read -r file; do
        [[ -n "$file" ]] || continue;
        found=1;
        owner="$(file_owner "$file")";
        mode="$(file_mode "$file")";
        if [[ "$owner" == root ]]; then
            fail "$file owner issue: root";
            rc=1;
        else
            pass "$file owner=${owner}";
        fi;
        if mode_leq "$file" 640; then
            pass "$file mode=${mode}";
        else
            fail "$file mode issue: ${mode}";
            rc=1;
        fi;
    done < <(find "$conf_dir" -maxdepth 1 -type f \( -name '*.xml' -o -name '*.properties' -o -name '*.policy' \) | sort);
    if [[ "$found" -eq 0 ]]; then
        fail "${conf_dir} 에 점검 대상 file not found.";
        return 1;
    fi;
    return "$rc"
}

apply_item () 
{ 
    require_root;
    local conf_dir owner group;
    conf_dir="$(find_tomcat_conf_dir || true)";
    if [[ -z "$conf_dir" ]]; then
        fail 'Tomcat conf directory not found. Set TOMCAT_CONF_DIR.';
        return 1;
    fi;
    owner="${TOMCAT_OWNER:-$(stat -c '%U' "$conf_dir")}";
    group="${TOMCAT_GROUP:-$(stat -c '%G' "$conf_dir")}";
    if [[ "$owner" == root || "$owner" == UNKNOWN ]]; then
        fail 'TOMCAT_OWNER/TOMCAT_GROUP 를 지정해 주세요. conf directory owner가 root 입니다.';
        return 1;
    fi;
    local file;
    while IFS= read -r file; do
        [[ -n "$file" ]] || continue;
        chown "${owner}:${group}" "$file";
        chmod 640 "$file";
    done < <(find "$conf_dir" -maxdepth 1 -type f \( -name '*.xml' -o -name '*.properties' -o -name '*.policy' \) | sort);
    pass "WT-02 Remediation steps applied: owner=${owner}:${group}, dir=${conf_dir}"
}
