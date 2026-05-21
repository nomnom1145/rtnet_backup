# Vulnerability Scripts

RHEL 8.4 기준으로 엑셀 `상세결과` 시트와 `target_server` 로그를 참고해 만든 항목별 스크립트입니다.

## File Pattern
- `U-02_01_CHECK.sh`
- `U-02_02_RESOLVE.sh`

## Structure
- `lib/common.sh`: shared helper functions only
- `lib/item_runner.sh`: common execution flow for check/resolve
- `lib/items/U-02.sh`: code-specific check/plan/remediation logic
- top-level `*_01_CHECK.sh`, `*_02_RESOLVE.sh`: thin entry scripts

즉, 실제 항목 로직을 수정하려면 해당 코드 파일만 보면 됩니다.
예: `U-02` 수정 시 `lib/items/U-02.sh` 확인

## Execution
- `./U-02_01_CHECK.sh` or `bash U-02_01_CHECK.sh`
- `./U-02_02_RESOLVE.sh` or `bash U-02_02_RESOLVE.sh`
- `sh U-02_01_CHECK.sh` also works because the script re-execs with `bash`

## Resolve Flow
- `RESOLVE` script runs the vulnerability check first
- if issues are found, it shows the planned steps
- for items with preview support, it also shows the current value and target value before applying
- it asks the user for confirmation before applying changes
- after applying, it runs a post-check

## Notes
- This session did not apply real remediation to the target server.
- The scripts were created and syntax-checked in the test environment only.
- Some items are intentionally conservative because of operational impact.
  - `U-06`: report-first behavior by default
  - `U-23`: no automatic service stop unless `DISABLE_SERVICES` is provided
  - `WT-09`: default Tomcat replacement port is `18080`

## Frequently Used Variables
- `conf/banner_message.txt`: default banner content file for `U-69`
- `BANNER_MESSAGE_FILE=/path/to/file`: use another banner content file
- `BANNER_MESSAGE='single line text'`: one-line override without editing a file
- `SU_ALLOWED_USERS=user1,user2`: add listed users to `wheel` during `U-45`
- `AUTO_REMOVE_TEMP_UNOWNED=1`: allow auto-removal for `/tmp`, `/var/tmp` only in `U-06`
- `DISABLE_SERVICES=dnsmasq,chronyd`: disable and stop listed services in `U-23`
- `TOMCAT_CONF_DIR=/apps/tomcat/conf`: force Tomcat conf path
- `TOMCAT_OWNER=tomcat`, `TOMCAT_GROUP=tomcat`: force Tomcat file owner/group for `WT-02`
- `NEW_TOMCAT_HTTP_PORT=18080`: set replacement port for `WT-09`
