#!/usr/bin/env bash
ITEM_CODE=U-06
ITEM_TITLE=Unowned\ files\ and\ directories

show_plan() {
  step 1 'Scan for files/directories with no owner or no group.'
  step 2 'Write unresolved items to a report file.'
  step 3 'If AUTO_REMOVE_TEMP_UNOWNED=1, remove only temporary unowned paths under /tmp or /var/tmp.'
}

show_current_state() {
  local current_paths

  show_current_value 'scan scope' '/'
  show_current_value 'report file' "${U06_REPORT_FILE:-/tmp/U-06_unowned_report.txt}"

  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    warn 'Current path listing for U-06 requires root privileges.'
    return 0
  fi

  current_paths="$(find_unowned_paths || true)"
  show_current_block 'unowned path list' "${current_paths:-none found}"
  return 0
}

preview_item_changes() {
  local current_paths after_action

  preview_change 'report file' "${U06_REPORT_FILE:-/tmp/U-06_unowned_report.txt}" "${U06_REPORT_FILE:-/tmp/U-06_unowned_report.txt}"
  preview_change 'AUTO_REMOVE_TEMP_UNOWNED' "${AUTO_REMOVE_TEMP_UNOWNED:-0}" "${AUTO_REMOVE_TEMP_UNOWNED:-0}"

  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    current_paths="$(find_unowned_paths || true)"
  else
    current_paths='root privileges required for a full scan'
  fi

  if [[ "${AUTO_REMOVE_TEMP_UNOWNED:-0}" == 1 ]]; then
    after_action='Paths under /tmp and /var/tmp: remove automatically
All other paths: write to report file'
  else
    after_action='All detected paths: write to report file only'
  fi

  preview_block_change 'detected unowned path handling' "${current_paths:-none found}" "${after_action}"
}

check_item () 
{ 
    if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
        fail 'Run this check as root for an accurate full-system scan.'
        return 2;
    fi;
    local report="${U06_REPORT_FILE:-/tmp/U-06_unowned_report.txt}";
    local sample_limit="${U06_STDOUT_SAMPLE_LIMIT:-20}";
    local found=0;
    local sample_count=0;
    local total_count=0;
    local path;
    : > "$report";
    while IFS= read -r path; do
        [[ -n "$path" ]] || continue;
        printf '%s
' "$path" >> "$report";
        total_count=$((total_count + 1));
        if [[ "$sample_count" -lt "$sample_limit" ]]; then
            fail "owner 미확인 파일/directory: $path";
            sample_count=$((sample_count + 1));
        fi;
        found=1;
    done < <(find_unowned_paths);
    if [[ "$found" -eq 0 ]]; then
        pass 'owner 없는 파일/directory가 없습니다.';
        return 0;
    fi;
    if [[ "$total_count" -gt "$sample_limit" ]]; then
        warn "추가 owner 미확인 경로 $((total_count - sample_limit))건은 보고서를 확인하세요: $report";
    else
        warn "owner 미확인 경로 전체 목록 보고서: $report";
    fi;
    fail "owner 미확인 파일/directory 총 ${total_count}건 발견";
    return 1
}

apply_item () 
{ 
    require_root;
    local report="${U06_REPORT_FILE:-/tmp/U-06_unowned_report.txt}";
    : > "$report";
    local unresolved=0;
    local path;
    while IFS= read -r path; do
        [[ -n "$path" ]] || continue;
        if [[ "${AUTO_REMOVE_TEMP_UNOWNED:-0}" == 1 && ( "$path" == /tmp/* || "$path" == /var/tmp/* ) ]]; then
            rm -rf -- "$path";
            info "임시 경로 삭제: $path";
        else
            printf '%s\n' "$path" >> "$report";
            unresolved=1;
        fi;
    done < <(find_unowned_paths);
    if [[ "$unresolved" -eq 0 ]]; then
        pass 'U-06 Remediation steps applied. 임시 경로 내 항목만 자동 정리되었습니다.';
        return 0;
    fi;
    warn "자동 조치 제외 항목 보고서: $report";
    fail 'U-06 은 경로별 owner 매핑이 필요해 보수적으로 보고서만 생성하도록 작성했습니다.';
    return 1
}
