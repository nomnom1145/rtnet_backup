#!/usr/bin/env bash
ITEM_CODE=U-23
ITEM_TITLE=Disable\ DoS-prone\ services

show_plan() {
  step 1 'Disable xinetd echo/discard/daytime/chargen entries when present.'
  step 2 'Restart xinetd if it is running.'
  step 3 'If DISABLE_SERVICES is set, disable and stop those systemd services.'
  step 4 'Re-check watched ports.'
}

show_current_state() {
  local listeners xinetd_lines='' file svc unit enabled_state active_state

  show_current_value 'watched ports' "${U23_PORTS}"
  listeners="$(find_u23_listeners || true)"
  show_current_block 'active watched listeners' "${listeners:-none found}"

  for file in /etc/xinetd.d/echo /etc/xinetd.d/echo-stream /etc/xinetd.d/echo-dgram \
              /etc/xinetd.d/discard /etc/xinetd.d/discard-stream /etc/xinetd.d/discard-dgram \
              /etc/xinetd.d/daytime /etc/xinetd.d/daytime-stream /etc/xinetd.d/daytime-dgram \
              /etc/xinetd.d/chargen /etc/xinetd.d/chargen-stream /etc/xinetd.d/chargen-dgram; do
    [[ -e "$file" ]] || continue
    xinetd_lines+="${file}: $(grep -E '^[[:space:]]*disable[[:space:]]*=' "$file" 2>/dev/null | tail -n 1 || printf 'disable line not set')"$'\n'
  done
  show_current_block 'xinetd disable lines' "${xinetd_lines%$'\n'}"

  if [[ -n "${DISABLE_SERVICES:-}" ]]; then
    xinetd_lines=''
    IFS=',' read -r -a _svcs <<< "${DISABLE_SERVICES}"
    for svc in "${_svcs[@]}"; do
      unit="$svc"
      systemctl list-unit-files "$svc" >/dev/null 2>&1 || unit="${svc}.service"
      enabled_state="$(systemctl is-enabled "$unit" 2>/dev/null || true)"
      active_state="$(systemctl is-active "$unit" 2>/dev/null || true)"
      xinetd_lines+="${unit}: enabled=${enabled_state:-unknown} active=${active_state:-unknown}"$'\n'
    done
    show_current_block 'requested systemd service states' "${xinetd_lines%$'\n'}"
  fi
  return 0
}

preview_item_changes() {
  local line found=0 xinetd_found=0 file current_disable
  local svc unit enabled_state active_state

  info "Watched ports: ${U23_PORTS}"
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    info "Active listener: $line"
    found=1
  done < <(find_u23_listeners)

  if [[ "$found" -eq 0 ]]; then
    info 'No watched listeners are currently open.'
  fi

  for file in /etc/xinetd.d/echo /etc/xinetd.d/echo-stream /etc/xinetd.d/echo-dgram \
              /etc/xinetd.d/discard /etc/xinetd.d/discard-stream /etc/xinetd.d/discard-dgram \
              /etc/xinetd.d/daytime /etc/xinetd.d/daytime-stream /etc/xinetd.d/daytime-dgram \
              /etc/xinetd.d/chargen /etc/xinetd.d/chargen-stream /etc/xinetd.d/chargen-dgram; do
    [[ -e "$file" ]] || continue
    current_disable="$(grep -E '^[[:space:]]*disable[[:space:]]*=' "$file" 2>/dev/null | tail -n 1 || true)"
    preview_change "${file} disable line" "${current_disable}" 'disable = yes'
    xinetd_found=1
  done

  if [[ "$xinetd_found" -eq 0 ]]; then
    info 'No matching xinetd entries were found.'
  fi

  if [[ -n "${DISABLE_SERVICES:-}" ]]; then
    info "Services requested to stop/disable: ${DISABLE_SERVICES}"
    IFS=',' read -r -a _svcs <<< "${DISABLE_SERVICES}"
    for svc in "${_svcs[@]}"; do
      unit="$svc"
      systemctl list-unit-files "$svc" >/dev/null 2>&1 || unit="${svc}.service"
      enabled_state="$(systemctl is-enabled "$unit" 2>/dev/null || true)"
      active_state="$(systemctl is-active "$unit" 2>/dev/null || true)"
      preview_change "systemd ${unit}" "enabled=${enabled_state:-unknown}, active=${active_state:-unknown}" 'enabled=disabled, active=inactive'
    done
  else
    warn 'DISABLE_SERVICES is empty. Only xinetd entries will be changed.'
  fi
}

pre_apply_check() {
  local file xinetd_found=0 listeners

  for file in /etc/xinetd.d/echo /etc/xinetd.d/echo-stream /etc/xinetd.d/echo-dgram \
              /etc/xinetd.d/discard /etc/xinetd.d/discard-stream /etc/xinetd.d/discard-dgram \
              /etc/xinetd.d/daytime /etc/xinetd.d/daytime-stream /etc/xinetd.d/daytime-dgram \
              /etc/xinetd.d/chargen /etc/xinetd.d/chargen-stream /etc/xinetd.d/chargen-dgram; do
    [[ -e "$file" ]] || continue
    xinetd_found=1
    break
  done

  listeners="$(find_u23_listeners || true)"
  if [[ -n "$listeners" && "$xinetd_found" -eq 0 && -z "${DISABLE_SERVICES:-}" ]]; then
    fail 'Open watched ports were detected, but no xinetd target files or DISABLE_SERVICES were provided.'
    return 1
  fi

  warn 'This item can stop live services immediately.'
  prompt_yes_no 'Continue with live service changes?' || return 1
}

check_item () 
{ 
    local found=0;
    local line;
    while IFS= read -r line; do
        [[ -n "$line" ]] || continue;
        fail "DoS 취약 서비스 포트 사용 중: $line";
        found=1;
    done < <(find_u23_listeners);
    if [[ "$found" -eq 0 ]]; then
        pass 'U-23 대상 포트가 열려 있지 않습니다.';
        return 0;
    fi;
    return 1
}

apply_item () 
{ 
    require_root;
    local file;
    for file in /etc/xinetd.d/echo /etc/xinetd.d/echo-stream /etc/xinetd.d/echo-dgram /etc/xinetd.d/discard /etc/xinetd.d/discard-stream /etc/xinetd.d/discard-dgram /etc/xinetd.d/daytime /etc/xinetd.d/daytime-stream /etc/xinetd.d/daytime-dgram /etc/xinetd.d/chargen /etc/xinetd.d/chargen-stream /etc/xinetd.d/chargen-dgram;
    do
        [[ -e "$file" ]] || continue;
        backup_file "$file";
        set_xinetd_disable_yes "$file";
    done;
    if systemctl is-active xinetd > /dev/null 2>&1; then
        systemctl restart xinetd;
    fi;
    if [[ -n "${DISABLE_SERVICES:-}" ]]; then
        local svc;
        IFS=',' read -r -a _svcs <<< "$DISABLE_SERVICES";
        for svc in "${_svcs[@]}";
        do
            if systemctl list-unit-files "$svc" > /dev/null 2>&1; then
                systemctl disable --now "$svc";
            else
                if systemctl list-unit-files "${svc}.service" > /dev/null 2>&1; then
                    systemctl disable --now "${svc}.service";
                else
                    warn "systemd 서비스 미발견: $svc";
                fi;
            fi;
        done;
    else
        warn 'DISABLE_SERVICES 가 비어 있습니다. 25/53/123/161/162 포트 서비스는 업무 영향 확인 후 중지하세요.';
    fi;
    if find_u23_listeners | grep -q .; then
        fail '일부 포트는 아직 열려 있습니다. 업무 영향 검토가 필요한 서비스일 수 있습니다.';
        return 1;
    fi;
    pass 'U-23 Remediation steps applied.'
}
