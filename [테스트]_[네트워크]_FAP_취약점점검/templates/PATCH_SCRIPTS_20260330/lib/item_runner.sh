#!/usr/bin/env bash
set -euo pipefail

run_check_item() {
  local rc=0
  section "Check | ${ITEM_CODE} | ${ITEM_TITLE}"
  check_item || rc=$?

  if declare -F show_current_state >/dev/null 2>&1; then
    section "Current state | ${ITEM_CODE} | ${ITEM_TITLE}"
    if ! show_current_state; then
      warn "Current state could not be fully generated for ${ITEM_CODE}."
    fi
  fi

  return "$rc"
}

run_resolve_item() {
  local check_rc=0

  section "Resolve workflow | ${ITEM_CODE} | ${ITEM_TITLE}"
  info 'Step 1: run vulnerability check first.'
  if check_item; then
    check_rc=0
  else
    check_rc=$?
  fi

  if [[ "$check_rc" -eq 0 ]]; then
    if declare -F allow_resolve_when_compliant >/dev/null 2>&1 && allow_resolve_when_compliant; then
      info "${ITEM_CODE} is currently compliant."
      if declare -F confirm_resolve_when_compliant >/dev/null 2>&1; then
        if ! confirm_resolve_when_compliant; then
          pass "No action required for ${ITEM_CODE}."
          return 0
        fi
      fi
      info "Continuing with optional reapply/update flow for ${ITEM_CODE}."
    else
      pass "No action required for ${ITEM_CODE}."
      return 0
    fi
  else
    warn "Issues detected for ${ITEM_CODE}."
  fi
  section "Plan | ${ITEM_CODE} | ${ITEM_TITLE}"
  show_plan

  if declare -F prepare_item_preview >/dev/null 2>&1; then
    if ! prepare_item_preview; then
      warn "Preparation step did not complete for ${ITEM_CODE}. No changes were applied."
      return 1
    fi
  fi

  if declare -F preview_item_changes >/dev/null 2>&1; then
    section "Preview | ${ITEM_CODE} | ${ITEM_TITLE}"
    if ! preview_item_changes; then
      warn "Preview could not be fully generated for ${ITEM_CODE}. Continue with the plan review below."
    fi
  fi

  if ! prompt_yes_no 'Apply the changes above now?'; then
    warn 'Cancelled by user. No changes were applied.'
    return 1
  fi

  if declare -F pre_apply_check >/dev/null 2>&1; then
    if ! pre_apply_check; then
      warn 'Safety check did not approve the changes. No changes were applied.'
      return 1
    fi
  fi

  section "Applying changes | ${ITEM_CODE}"
  apply_item

  section "Post-check | ${ITEM_CODE}"
  if check_item; then
    pass "Post-check passed for ${ITEM_CODE}."
    return 0
  fi

  warn "Post-check still reports issues for ${ITEM_CODE}. Review the output above."
  return 1
}
