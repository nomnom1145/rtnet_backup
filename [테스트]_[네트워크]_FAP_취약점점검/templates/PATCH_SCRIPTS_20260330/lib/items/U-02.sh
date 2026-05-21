#!/usr/bin/env bash
ITEM_CODE=U-02
ITEM_TITLE=Password\ complexity

show_plan() {
  step 1 'Backup /etc/security/pwquality.conf and /etc/login.defs.'
  step 2 'Set minlen/ucredit/lcredit/dcredit/ocredit in pwquality.conf.'
  step 3 'Set PASS_MIN_LEN in /etc/login.defs.'
}

show_current_state() {
  local current_pwquality current_pam current_pass_min_len

  current_pwquality="$(grep -E '^[[:space:]]*(minlen|ucredit|lcredit|dcredit|ocredit)[[:space:]]*=' /etc/security/pwquality.conf 2>/dev/null || true)"
  current_pam="$(grep -n 'pam_pwquality\.so' /etc/pam.d/system-auth 2>/dev/null || true)"
  current_pass_min_len="$(grep -E '^[[:space:]]*PASS_MIN_LEN[[:space:]]+' /etc/login.defs 2>/dev/null | tail -n 1 || true)"

  show_current_block '/etc/security/pwquality.conf active lines' "${current_pwquality}"
  show_current_block '/etc/pam.d/system-auth pam_pwquality lines' "${current_pam}"
  show_current_value '/etc/login.defs PASS_MIN_LEN' "${current_pass_min_len}"
  return 0
}

preview_item_changes() {
  local current_pwquality current_pass_min_len

  current_pwquality="$(grep -E '^[[:space:]]*(minlen|ucredit|lcredit|dcredit|ocredit)[[:space:]]*=' /etc/security/pwquality.conf 2>/dev/null || true)"
  current_pass_min_len="$(grep -E '^[[:space:]]*PASS_MIN_LEN[[:space:]]+' /etc/login.defs 2>/dev/null | tail -n 1 || true)"

  preview_block_change \
    '/etc/security/pwquality.conf lines' \
    "${current_pwquality}" \
    "$(printf '%s\n%s\n%s\n%s\n%s' \
      "minlen = ${PWQUALITY_MINLEN:-10}" \
      'ucredit = -1' \
      'lcredit = -1' \
      'dcredit = -1' \
      'ocredit = -1')"
  preview_change \
    '/etc/login.defs PASS_MIN_LEN' \
    "${current_pass_min_len}" \
    "PASS_MIN_LEN ${PASS_MIN_LEN_REQUIRED:-8}"
}

check_item () 
{ 
    local rc=0;
    local minlen ucredit lcredit dcredit ocredit pass_min_len;
    local sys_minlen sys_u sys_l sys_d sys_o;
    minlen="$(read_equals_key /etc/security/pwquality.conf minlen)";
    ucredit="$(read_equals_key /etc/security/pwquality.conf ucredit)";
    lcredit="$(read_equals_key /etc/security/pwquality.conf lcredit)";
    dcredit="$(read_equals_key /etc/security/pwquality.conf dcredit)";
    ocredit="$(read_equals_key /etc/security/pwquality.conf ocredit)";
    pass_min_len="$(read_space_key /etc/login.defs PASS_MIN_LEN)";
    sys_minlen="$(read_pam_option /etc/pam.d/system-auth pam_pwquality.so minlen)";
    sys_u="$(read_pam_option /etc/pam.d/system-auth pam_pwquality.so ucredit)";
    sys_l="$(read_pam_option /etc/pam.d/system-auth pam_pwquality.so lcredit)";
    sys_d="$(read_pam_option /etc/pam.d/system-auth pam_pwquality.so dcredit)";
    sys_o="$(read_pam_option /etc/pam.d/system-auth pam_pwquality.so ocredit)";
    minlen="${minlen:-$sys_minlen}";
    ucredit="${ucredit:-$sys_u}";
    lcredit="${lcredit:-$sys_l}";
    dcredit="${dcredit:-$sys_d}";
    ocredit="${ocredit:-$sys_o}";
    info "Check criteria: minlen>=10, u/l/d/o credit<=-1, PASS_MIN_LEN>=8";
    if [[ "${minlen:-}" =~ ^[0-9]+$ && ${minlen} -ge 10 ]]; then
        report_check_value 0 "minlen" "${minlen:-}" ">=10";
    else
        report_check_value 1 "minlen" "${minlen:-}" ">=10";
        rc=1;
    fi;
    local key value;
    for key in ucredit lcredit dcredit ocredit;
    do
        value="${!key:-}";
        if [[ "$value" =~ ^-?[0-9]+$ && $value -le -1 ]]; then
            report_check_value 0 "$key" "${value:-}" "<=-1";
        else
            report_check_value 1 "$key" "${value:-}" "<=-1";
            rc=1;
        fi;
    done;
    if [[ "${pass_min_len:-}" =~ ^[0-9]+$ && ${pass_min_len} -ge 8 ]]; then
        report_check_value 0 "PASS_MIN_LEN" "${pass_min_len:-}" ">=8";
    else
        report_check_value 1 "PASS_MIN_LEN" "${pass_min_len:-}" ">=8";
        rc=1;
    fi;
    if pam_has_module /etc/pam.d/system-auth pam_pwquality.so; then
        pass '/etc/pam.d/system-auth has pam_pwquality.so';
    else
        fail '/etc/pam.d/system-auth is missing pam_pwquality.so.';
        rc=1;
    fi;
    return "$rc"
}

apply_item () 
{ 
    require_root;
    backup_file /etc/security/pwquality.conf;
    backup_file /etc/login.defs;
    set_equals_key /etc/security/pwquality.conf minlen "${PWQUALITY_MINLEN:-10}";
    set_equals_key /etc/security/pwquality.conf ucredit -1;
    set_equals_key /etc/security/pwquality.conf lcredit -1;
    set_equals_key /etc/security/pwquality.conf dcredit -1;
    set_equals_key /etc/security/pwquality.conf ocredit -1;
    set_space_key /etc/login.defs PASS_MIN_LEN "${PASS_MIN_LEN_REQUIRED:-8}";
    pass 'U-02 Remediation steps applied. 실행 시 pwquality.conf/login.defs 를 수정합니다.'
}
