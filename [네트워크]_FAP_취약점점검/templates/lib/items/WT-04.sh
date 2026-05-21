#!/usr/bin/env bash
ITEM_CODE=WT-04
ITEM_TITLE=Hide\ Tomcat\ server\ banner

show_plan() {
  step 1 'Locate Tomcat server.xml.'
  step 2 'Set server=" " on HTTP/1.1 Connector elements.'
}

wt04_http_connector_blocks() {
  local file="$1"

  awk '
    !in_connector && /<Connector/ {
      in_connector = 1
      block = $0 ORS
      if ($0 ~ />/) {
        if (block ~ /HTTP\/1\.1/) {
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
        if (block ~ /HTTP\/1\.1/) {
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
  show_current_value 'Tomcat server.xml path' "${server_xml}"
  current_connectors="$(wt04_http_connector_blocks "$server_xml")"
  show_current_block 'HTTP/1.1 Connector blocks' "${current_connectors}"
  return 0
}

preview_item_changes() {
  local conf_dir server_xml current_connectors after_connectors tmp

  conf_dir="$(find_tomcat_conf_dir || true)"
  if [[ -z "$conf_dir" ]]; then
    fail 'Tomcat conf directory not found. Set TOMCAT_CONF_DIR.'
    return 0
  fi

  server_xml="${conf_dir}/server.xml"
  current_connectors="$(wt04_http_connector_blocks "$server_xml")"
  tmp="$(mktemp)"
  cp -a -- "$server_xml" "$tmp"
  rewrite_server_xml "$tmp" hide_server
  after_connectors="$(wt04_http_connector_blocks "$tmp")"
  rm -f "$tmp"

  show_current_value 'Tomcat server.xml path' "${server_xml}"
  preview_block_change 'HTTP/1.1 Connector blocks' "${current_connectors}" "${after_connectors}"
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
    count="$(connector_xpath_count "$server_xml" 'count(//*[local-name()="Connector"][contains(@protocol,"HTTP/1.1") and (not(@server) or @server!=" ")])')";
    if [[ "$count" == 0 || "$count" == 0.0 ]]; then
        pass 'HTTP/1.1 Connector server header hide: O';
        return 0;
    fi;
    fail "HTTP/1.1 Connector server header hide: X (affected connectors: ${count})";
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
    rewrite_server_xml "$server_xml" hide_server;
    pass 'WT-04 Remediation steps applied.'
}
