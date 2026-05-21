#!/usr/bin/env bash
ITEM_CODE=U-03
ITEM_TITLE=Account\ lockout\ threshold

u03_authselect_state() {
  authselect_current | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g; s/[[:space:]]*$//' || true
}

u03_has_active_authselect_profile() {
  local authselect_state
  authselect_state="$(u03_authselect_state)"
  [[ -n "$authselect_state" && "$authselect_state" != *"No existing configuration detected."* ]]
}

u03_pam_has_faillock() {
  local file="$1"
  grep -Eq '^[[:space:]]*[^#].*pam_faillock\.so' "$file" 2>/dev/null
}

u03_insert_line_before() {
  local file="$1"
  local line="$2"
  local anchor_regex="$3"
  local tmp

  [[ -f "$file" ]] || return 1
  if grep -Fqx -- "$line" "$file"; then
    return 0
  fi

  tmp="$(mktemp)"
  awk -v new_line="$line" -v anchor_regex="$anchor_regex" '
    !inserted && $0 ~ anchor_regex {
      print new_line
      inserted = 1
    }
    { print }
    END {
      if (!inserted) {
        print new_line
      }
    }
  ' "$file" > "$tmp"
  cat "$tmp" > "$file"
  rm -f "$tmp"
}

u03_apply_pam_faillock_fallback() {
  local file
  for file in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
    [[ -f "$file" ]] || continue
    backup_file "$file"
    u03_insert_line_before "$file" 'auth        required      pam_faillock.so preauth silent' '^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_unix[.]so'
    u03_insert_line_before "$file" 'auth        required      pam_faillock.so authfail' '^[[:space:]]*auth[[:space:]]+required[[:space:]]+pam_deny[.]so'
    u03_insert_line_before "$file" 'account     required      pam_faillock.so' '^[[:space:]]*account[[:space:]]+required[[:space:]]+pam_unix[.]so'
  done
}

show_plan() {
  step 1 'Backup /etc/security/faillock.conf, /etc/ssh/sshd_config, and PAM files when needed.'
  step 2 'Enable authselect with-faillock when an active authselect profile exists.'
  step 3 'If authselect is not active, update /etc/pam.d/system-auth and /etc/pam.d/password-auth directly.'
  step 4 'Set deny/unlock_time in faillock.conf and MaxAuthTries in sshd_config.'
}

show_current_state() {
  local authselect_state max_auth deny unlock
  local current_system_auth current_password_auth current_faillock

  authselect_state="$(u03_authselect_state)"
  max_auth="$(read_sshd_key MaxAuthTries | tail -n 1 || true)"
  deny="$(read_equals_key /etc/security/faillock.conf deny || true)"
  unlock="$(read_equals_key /etc/security/faillock.conf unlock_time || true)"
  current_system_auth="$(grep -n 'pam_faillock\.so' /etc/pam.d/system-auth 2>/dev/null || true)"
  current_password_auth="$(grep -n 'pam_faillock\.so' /etc/pam.d/password-auth 2>/dev/null || true)"
  current_faillock="$(grep -E '^[[:space:]]*(deny|unlock_time)[[:space:]]*=' /etc/security/faillock.conf 2>/dev/null || true)"

  show_current_value \
    'authselect state' \
    "${authselect_state:-unavailable}"
  show_current_block \
    '/etc/pam.d/system-auth pam_faillock lines' \
    "${current_system_auth}"
  show_current_block \
    '/etc/pam.d/password-auth pam_faillock lines' \
    "${current_password_auth}"
  show_current_value \
    '/etc/ssh/sshd_config MaxAuthTries' \
    "${max_auth:+MaxAuthTries ${max_auth}}"
  show_current_block \
    '/etc/security/faillock.conf lines' \
    "${current_faillock}"

  if [[ -n "${deny:-}" || -n "${unlock:-}" ]]; then
    info "Current parsed values: deny=$(display_current_value "${deny:-}") unlock_time=$(display_current_value "${unlock:-}")"
  fi

  return 0
}

preview_item_changes() {
  local max_auth deny unlock authselect_state
  local system_auth_mark password_auth_mark
  local target_max_auth target_deny target_unlock
  local current_system_auth current_password_auth current_faillock

  target_max_auth="${SSHD_MAX_AUTH_TRIES:-5}"
  target_deny="${FAILLOCK_DENY:-5}"
  target_unlock="${FAILLOCK_UNLOCK_TIME:-120}"

  max_auth="$(read_sshd_key MaxAuthTries | tail -n 1 || true)"
  deny="$(read_equals_key /etc/security/faillock.conf deny || true)"
  unlock="$(read_equals_key /etc/security/faillock.conf unlock_time || true)"
  authselect_state="$(u03_authselect_state)"

  if u03_pam_has_faillock /etc/pam.d/system-auth; then
    system_auth_mark='O'
  else
    system_auth_mark='X'
  fi

  if u03_pam_has_faillock /etc/pam.d/password-auth; then
    password_auth_mark='O'
  else
    password_auth_mark='X'
  fi

  if [[ -n "$authselect_state" ]]; then
    info "Current authselect state: ${authselect_state}"
  else
    info 'Current authselect state: X (unavailable or not managed by authselect)'
  fi

  if u03_has_active_authselect_profile; then
    info 'Planned PAM mode: authselect with-faillock'
    preview_block_change \
      'authselect commands' \
      "${authselect_state}" \
      "$(printf '%s\n%s' 'authselect enable-feature with-faillock' 'authselect apply-changes')"
  else
    info 'Planned PAM mode: direct update of system-auth and password-auth'
    current_system_auth="$(grep -n 'pam_faillock\.so' /etc/pam.d/system-auth 2>/dev/null || true)"
    current_password_auth="$(grep -n 'pam_faillock\.so' /etc/pam.d/password-auth 2>/dev/null || true)"
    preview_block_change \
      '/etc/pam.d/system-auth pam_faillock lines' \
      "${current_system_auth}" \
      "$(printf '%s\n%s\n%s' \
        'auth        required      pam_faillock.so preauth silent' \
        'auth        required      pam_faillock.so authfail' \
        'account     required      pam_faillock.so')"
    preview_block_change \
      '/etc/pam.d/password-auth pam_faillock lines' \
      "${current_password_auth}" \
      "$(printf '%s\n%s\n%s' \
        'auth        required      pam_faillock.so preauth silent' \
        'auth        required      pam_faillock.so authfail' \
        'account     required      pam_faillock.so')"
  fi

  info "Current system-auth pam_faillock: ${system_auth_mark}"
  info "Current password-auth pam_faillock: ${password_auth_mark}"
  preview_change \
    '/etc/ssh/sshd_config MaxAuthTries' \
    "${max_auth:+MaxAuthTries ${max_auth}}" \
    "MaxAuthTries ${target_max_auth}"
  current_faillock="$(grep -E '^[[:space:]]*(deny|unlock_time)[[:space:]]*=' /etc/security/faillock.conf 2>/dev/null || true)"
  preview_block_change \
    '/etc/security/faillock.conf lines' \
    "${current_faillock}" \
    "$(printf '%s\n%s' "deny = ${target_deny}" "unlock_time = ${target_unlock}")"
  return 0
}

pre_apply_check() {
  if [[ -n "${SSH_CONNECTION:-}" || -n "${SSH_CLIENT:-}" ]]; then
    warn 'Remote SSH session detected. Authentication changes can affect remote access.'
    prompt_yes_no 'Continue with remote authentication changes?' || return 1
  fi

  if command -v authselect >/dev/null 2>&1 && ! u03_has_active_authselect_profile; then
    warn 'authselect has no active profile in this environment.'
    warn 'The script will update /etc/pam.d/system-auth and /etc/pam.d/password-auth directly.'
    prompt_yes_no 'Continue with direct PAM file changes?' || return 1
  fi
}

check_item() {
  local rc=0
  local max_auth deny unlock
  local system_auth_ok=1
  local password_auth_ok=1

  max_auth="$(read_sshd_key MaxAuthTries | tail -n 1 || true)"

  if authselect_has_feature with-faillock; then
    pass 'authselect with-faillock: O'
  else
    if u03_pam_has_faillock /etc/pam.d/system-auth; then
      pass 'system-auth pam_faillock: O'
      system_auth_ok=0
    else
      fail 'system-auth pam_faillock: X'
      rc=1
    fi

    if u03_pam_has_faillock /etc/pam.d/password-auth; then
      pass 'password-auth pam_faillock: O'
      password_auth_ok=0
    else
      fail 'password-auth pam_faillock: X'
      rc=1
    fi

    if [[ $system_auth_ok -ne 0 || $password_auth_ok -ne 0 ]]; then
      fail 'with-faillock or pam_faillock.so configuration is incomplete.'
    fi
  fi

  if [[ "${max_auth:-}" =~ ^[0-9]+$ && ${max_auth} -ge 1 && ${max_auth} -le 5 ]]; then
    report_check_value 0 'MaxAuthTries' "${max_auth:-}" '1-5'
  else
    report_check_value 1 'MaxAuthTries' "${max_auth:-}" '1-5'
    rc=1
  fi

  deny="$(read_equals_key /etc/security/faillock.conf deny || true)"
  unlock="$(read_equals_key /etc/security/faillock.conf unlock_time || true)"

  if [[ -n "${deny:-}" && "$deny" =~ ^[0-9]+$ && $deny -le 5 ]]; then
    report_check_value 0 'faillock deny' "${deny:-}" '<=5'
  else
    report_check_value 1 'faillock deny' "${deny:-}" '<=5'
    rc=1
  fi

  if [[ -n "${unlock:-}" ]]; then
    info "faillock unlock_time=${unlock}"
  fi

  return "$rc"
}

apply_item() {
  require_root

  backup_file /etc/security/faillock.conf
  backup_file /etc/ssh/sshd_config

  if command -v authselect >/dev/null 2>&1 && u03_has_active_authselect_profile; then
    if ! authselect_has_feature with-faillock; then
      authselect enable-feature with-faillock
    fi
    authselect apply-changes
  else
    warn 'Applying direct PAM fallback because no active authselect profile was detected.'
    u03_apply_pam_faillock_fallback
  fi

  set_equals_key /etc/security/faillock.conf deny "${FAILLOCK_DENY:-5}"
  set_equals_key /etc/security/faillock.conf unlock_time "${FAILLOCK_UNLOCK_TIME:-120}"
  set_sshd_key MaxAuthTries "${SSHD_MAX_AUTH_TRIES:-5}"

  pass 'U-03 remediation steps applied. Check sshd reload policy before reloading the service.'
}
