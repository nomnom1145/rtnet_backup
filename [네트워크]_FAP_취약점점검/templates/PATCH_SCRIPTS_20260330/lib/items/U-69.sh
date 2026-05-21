#!/usr/bin/env bash
ITEM_CODE=U-69
ITEM_TITLE=Login\ warning\ banner

u69_read_line() {
  local __var_name="$1"
  local __line=''

  if [[ -t 0 ]]; then
    if ! IFS= read -r __line; then
      printf -v "$__var_name" '%s' ''
      return 1
    fi
  elif { exec 3</dev/tty; } 2>/dev/null; then
    if ! IFS= read -r __line <&3; then
      exec 3<&-
      printf -v "$__var_name" '%s' ''
      return 1
    fi
    exec 3<&-
  else
    if ! IFS= read -r __line; then
      printf -v "$__var_name" '%s' ''
      return 1
    fi
  fi

  printf -v "$__var_name" '%s' "$__line"
  return 0
}

u69_collect_custom_banner() {
  local line custom=''

  info 'Enter custom banner text for this run.'
  info 'Finish input with a single line: EOF'
  info 'Press Enter on an empty first line to keep the current banner content.'

  while :; do
    printf 'banner> '
    if ! u69_read_line line; then
      if [[ -z "$custom" ]]; then
        return 1
      fi
      warn 'Input ended before EOF. Using the text entered so far.'
      break
    fi

    if [[ -z "$custom" && -z "$line" ]]; then
      return 1
    fi

    if [[ "$line" == 'EOF' ]]; then
      break
    fi

    custom+="${line}"$'\n'
  done

  U69_RUNTIME_BANNER_CONTENT="${custom%$'\n'}"
  export U69_RUNTIME_BANNER_CONTENT
  BANNER_MESSAGE="$U69_RUNTIME_BANNER_CONTENT"
  export BANNER_MESSAGE
  info 'Custom banner content will be used for this run.'
  return 0
}

show_plan() {
  step 1 'Backup /etc/motd, /etc/issue.net, and /etc/ssh/sshd_config.'
  step 2 'Optionally replace the banner content for this run before apply.'
  step 3 'Write banner content to /etc/motd and /etc/issue.net.'
  step 4 'Set sshd Banner to /etc/issue.net.'
  step 5 'If vsftpd config exists, set ftpd_banner as well.'
}

allow_resolve_when_compliant() {
  return 0
}

confirm_resolve_when_compliant() {
  prompt_yes_no 'U-69 already passes. Do you want to reapply or replace the banner content anyway?'
}

prepare_item_preview() {
  if [[ -n "${BANNER_MESSAGE:-}" || -n "${U69_RUNTIME_BANNER_CONTENT:-}" ]]; then
    info 'Custom banner content is already defined for this run.'
    return 0
  fi

  if prompt_yes_no 'Do you want to replace the banner content for this run before apply?'; then
    if ! u69_collect_custom_banner; then
      info 'No custom banner text was entered. The current banner source will be used.'
    fi
  fi

  return 0
}

show_current_state() {
  local banner_value current_ftp

  banner_value="$(read_sshd_key Banner | tail -n 1 || true)"
  show_current_block '/etc/motd content' "$(file_excerpt /etc/motd 20)"
  show_current_block '/etc/issue.net content' "$(file_excerpt /etc/issue.net 20)"
  show_current_value 'sshd Banner setting' "${banner_value:+Banner ${banner_value}}"
  if [[ -f /etc/vsftpd/vsftpd.conf ]]; then
    current_ftp="$(grep -E '^[[:space:]]*ftpd_banner=' /etc/vsftpd/vsftpd.conf 2>/dev/null | tail -n 1 || true)"
    show_current_value '/etc/vsftpd/vsftpd.conf ftpd_banner' "${current_ftp}"
  fi
  return 0
}

preview_item_changes() {
  local banner_file banner_value ftp_banner current_motd current_issue current_ftp
  banner_file="${BANNER_MESSAGE_FILE:-$DEFAULT_BANNER_MESSAGE_FILE}"
  banner_value="$(read_sshd_key Banner | tail -n 1)"
  ftp_banner="$(banner_single_line)"
  current_motd="$(sed -n '1,20p' /etc/motd 2>/dev/null || true)"
  current_issue="$(sed -n '1,20p' /etc/issue.net 2>/dev/null || true)"

  if [[ -n "${BANNER_MESSAGE:-}" ]]; then
    info 'Banner content source: BANNER_MESSAGE environment variable'
    preview_block_change '/etc/motd content' "${current_motd}" "${BANNER_MESSAGE}"
    preview_block_change '/etc/issue.net content' "${current_issue}" "${BANNER_MESSAGE}"
  else
    info "Banner content source file: ${banner_file}"
    if [[ -r "$banner_file" ]]; then
      preview_block_change '/etc/motd content' "${current_motd}" "$(cat "$banner_file")"
      preview_block_change '/etc/issue.net content' "${current_issue}" "$(cat "$banner_file")"
    else
      warn "Banner source file not found: ${banner_file}"
    fi
  fi

  preview_change 'sshd Banner setting' "${banner_value:+Banner ${banner_value}}" 'Banner /etc/issue.net'
  if [[ -f /etc/vsftpd/vsftpd.conf ]]; then
    current_ftp="$(grep -E '^[[:space:]]*ftpd_banner=' /etc/vsftpd/vsftpd.conf 2>/dev/null | tail -n 1 || true)"
    preview_change '/etc/vsftpd/vsftpd.conf ftpd_banner' "${current_ftp}" "ftpd_banner=${ftp_banner}"
  fi
}

check_item () 
{ 
    local rc=0;
    local banner motd issue;
    motd='';
    issue='';
    [[ -s /etc/motd ]] && motd=1 || true;
    [[ -s /etc/issue.net ]] && issue=1 || true;
    banner="$(read_sshd_key Banner | tail -n 1)";
    if [[ -n "$motd" ]]; then
        pass '/etc/motd: O (has content)';
    else
        fail '/etc/motd: X (empty)';
        rc=1;
    fi;
    if safe_ss_listeners | awk '{print $5}' | grep -Eq '(^|:)22$'; then
        if [[ -n "$issue" ]]; then
            pass '/etc/issue.net: O (has content)';
        else
            fail '/etc/issue.net: X (empty)';
            rc=1;
        fi;
        if [[ -n "${banner:-}" && "${banner,,}" != none ]]; then
            pass "sshd Banner: O (current: ${banner})";
        else
            fail "sshd Banner: X (current: $(display_current_value "${banner:-}"))";
            rc=1;
        fi;
    else
        info 'SSH 포트 미사용 상태로 판단되어 issue.net/Banner 는 참고 항목으로 남깁니다.';
    fi;
    return "$rc"
}

apply_item () 
{ 
    require_root;
    local ftp_banner;
    backup_file /etc/motd;
    backup_file /etc/issue.net;
    backup_file /etc/ssh/sshd_config;
    write_banner_file /etc/motd;
    write_banner_file /etc/issue.net;
    chmod 644 /etc/motd /etc/issue.net;
    set_sshd_key Banner /etc/issue.net;
    if [[ -f /etc/vsftpd/vsftpd.conf ]]; then
        backup_file /etc/vsftpd/vsftpd.conf;
        ftp_banner="$(banner_single_line)";
        if grep -Eq '^[[:space:]]*ftpd_banner=' /etc/vsftpd/vsftpd.conf; then
            awk -v banner="$ftp_banner" '
              BEGIN { updated = 0 }
              /^[[:space:]]*ftpd_banner=/ {
                print "ftpd_banner=" banner
                updated = 1
                next
              }
              { print }
              END {
                if (!updated) {
                  print "ftpd_banner=" banner
                }
              }
            ' /etc/vsftpd/vsftpd.conf > /etc/vsftpd/vsftpd.conf.tmp;
            mv /etc/vsftpd/vsftpd.conf.tmp /etc/vsftpd/vsftpd.conf;
        else
            printf 'ftpd_banner=%s\n' "$ftp_banner" >> /etc/vsftpd/vsftpd.conf;
        fi;
    fi;
    pass 'U-69 Remediation steps applied. sshd reload 는 운영 창구에 맞춰 수행하세요.'
}
