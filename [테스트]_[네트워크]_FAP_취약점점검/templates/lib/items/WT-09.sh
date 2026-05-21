#!/usr/bin/env bash
ITEM_CODE=WT-09
ITEM_TITLE=Tomcat\ admin/default\ port

show_plan() {
  step 1 'Locate Tomcat server.xml.'
  step 2 'Change Connector port 8080 to NEW_TOMCAT_HTTP_PORT.'
}

wt09_port_8080_blocks() {
  local file="$1"

  awk '
    !in_connector && /<Connector/ {
      in_connector = 1
      block = $0 ORS
      if ($0 ~ />/) {
        if (block ~ /port="8080"/) {
          printf "%s", block
        }
        in_connector = 0
        block = ""
      }
      next
    }
    in_connector {
      block = block $0 ORS
      if ($0 ~ />/) {
        if (block ~ /port="8080"/) {
          printf "%s", block
        }
        in_connector = 0
        block = ""
      }
      next
    }
  ' "$file" 2>/dev/null || true
}

show_current_state() {
  local conf_dir server_xml current_connectors

  conf_dir="$(find_tomcat_conf_dir || true)"
  if [[ -z "$conf_dir" ]]; then
    fail 'Tomcat conf directory not found. Set TOMCAT_CONF_DIR.'
    return 0
  fi

  server_xml="${conf_dir}/server.xml"
  show_current_value 'Tomcat conf directory' "${conf_dir}"
  show_current_value 'Tomcat server.xml path' "${server_xml}"
  current_connectors="$(wt09_port_8080_blocks "$server_xml")"
  show_current_block 'Connector blocks using port 8080' "${current_connectors}"
  return 0
}

preview_item_changes() {
  local conf_dir server_xml target_port current_8080_lines target_lines current_connectors after_connectors tmp
  conf_dir="$(find_tomcat_conf_dir || true)"
  target_port="${NEW_TOMCAT_HTTP_PORT:-$TOMCAT_DEFAULT_HTTP_PORT}"

  if [[ -z "$conf_dir" ]]; then
    fail 'Tomcat conf directory not found. Set TOMCAT_CONF_DIR.'
    return 0
  fi

  server_xml="${conf_dir}/server.xml"
  info "Tomcat conf directory: ${conf_dir}"
  info "Target replacement port: ${target_port}"

  if [[ -f "$server_xml" ]]; then
    current_8080_lines="$(grep -n 'Connector.*port=\"8080\"' "$server_xml" || true)"
    target_lines="$(printf '%s\n' "$current_8080_lines" | sed "s/port=\\\"8080\\\"/port=\\\"${target_port}\\\"/g")"
    preview_block_change "${server_xml} Connector lines for 8080" "${current_8080_lines}" "${target_lines}"
    current_connectors="$(wt09_port_8080_blocks "$server_xml")"
    tmp="$(mktemp)"
    cp -a -- "$server_xml" "$tmp"
    rewrite_server_xml "$tmp" change_port
    after_connectors="$(wt09_port_8080_blocks "$tmp" | sed "s/port=\\\"8080\\\"/port=\\\"${target_port}\\\"/g")"
    rm -f "$tmp"
    preview_block_change "${server_xml} Connector blocks using port 8080" "${current_connectors}" "${after_connectors}"
  else
    warn "${server_xml} file not found."
  fi

  if safe_ss_listeners | awk '{print $5}' | grep -Eq "(^|:)${target_port}$"; then
    warn "Target port ${target_port} is already in use."
  else
    info "Target port ${target_port} appears unused."
  fi
}

pre_apply_check() {
  local target_port
  target_port="${NEW_TOMCAT_HTTP_PORT:-$TOMCAT_DEFAULT_HTTP_PORT}"

  if [[ "$target_port" == "8080" ]]; then
    fail 'Target port is still 8080. Set NEW_TOMCAT_HTTP_PORT to a different value.'
    return 1
  fi

  if [[ ! "$target_port" =~ ^[0-9]+$ || "$target_port" -lt 1 || "$target_port" -gt 65535 ]]; then
    fail "Invalid target port: ${target_port}"
    return 1
  fi

  if safe_ss_listeners | awk '{print $5}' | grep -Eq "(^|:)${target_port}$"; then
    fail "Target port ${target_port} is already in use."
    return 1
  fi

  warn 'Tomcat restart and upstream/LB changes may be required after this change.'
  prompt_yes_no 'Continue with Tomcat port change?' || return 1
}

check_item () 
{ 
    local conf_dir server_xml count;
    conf_dir="$(find_tomcat_conf_dir || true)";
    if [[ -z "$conf_dir" ]]; then
        fail 'Tomcat conf directory not found. Set TOMCAT_CONF_DIR.';
        return 1;
    fi;
    server_xml="${conf_dir}/server.xml";
    [[ -f "$server_xml" ]] || { 
        fail "${server_xml} file not found.";
        return 1
    };
    count="$(connector_xpath_count "$server_xml" 'count(//*[local-name()="Connector"][@port="8080"])')";
    if [[ "$count" == 0 || "$count" == 0.0 ]]; then
        pass '8080 포트를 사용하는 Connector 가 없습니다.';
        return 0;
    fi;
    fail "8080 포트를 사용하는 Connector 수: ${count}";
    return 1
}

apply_item () 
{ 
    require_root;
    local conf_dir server_xml;
    conf_dir="$(find_tomcat_conf_dir || true)";
    if [[ -z "$conf_dir" ]]; then
        fail 'Tomcat conf directory not found. Set TOMCAT_CONF_DIR.';
        return 1;
    fi;
    server_xml="${conf_dir}/server.xml";
    backup_file "$server_xml";
    rewrite_server_xml "$server_xml" change_port;
    pass "WT-09 Remediation steps applied. NEW_TOMCAT_HTTP_PORT=${NEW_TOMCAT_HTTP_PORT:-$TOMCAT_DEFAULT_HTTP_PORT}"
}
