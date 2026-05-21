#!/usr/bin/env bash
ITEM_CODE=U-15
ITEM_TITLE=World\ writable\ files

show_plan() {
  step 1 'Scan configured paths for world writable regular files.'
  step 2 'Remove others-write permission from each matching file.'
}

show_current_state() {
  local current_paths

  show_current_value 'scan paths' "${WW_SCAN_PATHS:-$WW_SCAN_PATHS_DEFAULT}"

  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    warn 'Current path listing for U-15 requires root privileges.'
    return 0
  fi

  current_paths="$(find_world_writable_files || true)"
  show_current_block 'world writable file list' "${current_paths:-none found}"
  return 0
}

preview_item_changes() {
  local current_paths

  preview_change 'scan paths' "${WW_SCAN_PATHS:-$WW_SCAN_PATHS_DEFAULT}" "${WW_SCAN_PATHS:-$WW_SCAN_PATHS_DEFAULT}"

  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    current_paths="$(find_world_writable_files || true)"
  else
    current_paths='root privileges required for a full scan'
  fi

  preview_block_change \
    'world writable file handling' \
    "${current_paths:-none found}" \
    'Apply chmod o-w to each listed file'
}

check_item () 
{ 
    if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
        fail 'Run this check as root for an accurate full-path scan.'
        return 2;
    fi;
    local found=0;
    local path;
    while IFS= read -r path; do
        [[ -n "$path" ]] || continue;
        fail "world writable 파일: $path";
        found=1;
    done < <(find_world_writable_files);
    if [[ "$found" -eq 0 ]]; then
        pass 'world writable file not found.';
        return 0;
    fi;
    return 1
}

apply_item () 
{ 
    require_root;
    local path;
    local changed=0;
    while IFS= read -r path; do
        [[ -n "$path" ]] || continue;
        chmod o-w -- "$path";
        info "others 쓰기 제거: $path";
        changed=1;
    done < <(find_world_writable_files);
    if [[ "$changed" -eq 0 ]]; then
        pass '조치 대상 world writable file not found.';
    else
        pass 'U-15 Remediation steps applied.';
    fi
}
