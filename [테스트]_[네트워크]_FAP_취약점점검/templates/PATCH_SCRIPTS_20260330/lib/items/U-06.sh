#!/usr/bin/env bash
ITEM_CODE=U-06
ITEM_TITLE=Unowned\ files\ and\ directories

U06_REPORT_FILE="${U06_REPORT_FILE:-/tmp/U-06_unowned_report.txt}"
U06_SAMPLE_LIMIT="${U06_SAMPLE_LIMIT:-20}"

show_plan() {
  step 1 'Scan for files/directories with no owner or no group.'
  step 2 'Write unresolved items to a report file.'
  step 3 'Show only count and sample paths to prevent excessive stdout.'
  step 4 'If AUTO_REMOVE_TEMP_UNOWNED=1, remove only temporary unowned paths under /tmp or /var/tmp.'
}

show_current_state() {
  local report="$U06_REPORT_FILE"
  local count=0

  show_current_value 'scan scope' '/'
  show_current_value 'report file' "$report"
  show_current_value 'sample limit' "$U06_SAMPLE_LIMIT"

  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    warn 'Current path listing for U-06 requires root privileges.'
    return 0
  fi

  : > "$report"

  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    printf '%s\n' "$path" >> "$report"
    count=$((count + 1))
  done < <(find_unowned_paths)

  show_current_value 'unowned path count' "$count"

  if [[ "$count" -eq 0 ]]; then
    show_current_block 'unowned path sample' 'none found'
  else
    show_current_block 'unowned path sample' "$(head -n "$U06_SAMPLE_LIMIT" "$report")"
    warn "전체 목록은 보고서 파일에서 확인하세요: $report"
  fi

  return 0
}

preview_item_changes() {
  local report="$U06_REPORT_FILE"
  local count=0
  local after_action

  preview_change 'report file' "$report" "$report"
  preview_change 'AUTO_REMOVE_TEMP_UNOWNED' "${AUTO_REMOVE_TEMP_UNOWNED:-0}" "${AUTO_REMOVE_TEMP_UNOWNED:-0}"
  preview_change 'sample limit' "$U06_SAMPLE_LIMIT" "$U06_SAMPLE_LIMIT"

  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    preview_block_change 'detected unowned path handling' 'root privileges required for a full scan' 'root privileges required for a full scan'
    return 0
  fi

  : > "$report"

  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    printf '%s\n' "$path" >> "$report"
    count=$((count + 1))
  done < <(find_unowned_paths)

  if [[ "${AUTO_REMOVE_TEMP_UNOWNED:-0}" == 1 ]]; then
    after_action='Paths under /tmp and /var/tmp: remove automatically
All other paths: write to report file'
  else
    after_action='All detected paths: write to report file only'
  fi

  preview_block_change 'detected unowned path count' "$count" "$after_action"

  if [[ "$count" -gt 0 ]]; then
    preview_block_change 'detected unowned path sample' "$(head -n "$U06_SAMPLE_LIMIT" "$report")" "$after_action"
  fi
}

check_item() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    fail 'Run this check as root for an accurate full-system scan.'
    return 2
  fi

  local report="$U06_REPORT_FILE"
  local count=0

  : > "$report"

  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    printf '%s\n' "$path" >> "$report"
    count=$((count + 1))
  done < <(find_unowned_paths)

  if [[ "$count" -eq 0 ]]; then
    pass 'owner 없는 파일/directory가 없습니다.'
    return 0
  fi

  fail "owner 미확인 파일/directory가 ${count}개 발견되었습니다. 전체 목록: $report"
  info "상위 ${U06_SAMPLE_LIMIT}개 샘플:"
  head -n "$U06_SAMPLE_LIMIT" "$report" | while IFS= read -r path; do
    info "$path"
  done

  return 1
}

apply_item() {
  require_root

  local report="$U06_REPORT_FILE"
  local unresolved=0
  local removed=0
  local total=0
  local path

  : > "$report"

  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    total=$((total + 1))

    if [[ "${AUTO_REMOVE_TEMP_UNOWNED:-0}" == 1 && ( "$path" == /tmp/* || "$path" == /var/tmp/* ) ]]; then
      rm -rf -- "$path"
      removed=$((removed + 1))
    else
      printf '%s\n' "$path" >> "$report"
      unresolved=$((unresolved + 1))
    fi
  done < <(find_unowned_paths)

  if [[ "$total" -eq 0 ]]; then
    pass 'owner 없는 파일/directory가 없습니다.'
    return 0
  fi

  if [[ "$removed" -gt 0 ]]; then
    info "임시 경로 삭제 개수: $removed"
  fi

  if [[ "$unresolved" -eq 0 ]]; then
    pass 'U-06 Remediation steps applied. 임시 경로 내 항목만 자동 정리되었습니다.'
    return 0
  fi

  warn "자동 조치 제외 항목 개수: $unresolved"
  warn "자동 조치 제외 항목 보고서: $report"
  info "상위 ${U06_SAMPLE_LIMIT}개 샘플:"
  head -n "$U06_SAMPLE_LIMIT" "$report" | while IFS= read -r path; do
    info "$path"
  done

  fail 'U-06 은 경로별 owner 매핑이 필요해 보수적으로 보고서만 생성하도록 작성했습니다.'
  return 1
}