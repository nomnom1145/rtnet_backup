#!/usr/bin/env bash
ITEM_CODE=U-22
ITEM_TITLE=cron-related\ file\ permissions

show_plan() {
  step 1 'Set cron control files to owner root:root and mode 640.'
  step 2 'Normalize owner and remove group/other write from cron job files.'
}

show_current_state() {
  local current_control='' current_jobs='' path dir file
  local control_files=(/etc/crontab /etc/cron.allow /etc/cron.deny)
  local job_dirs=(/etc/cron.d /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly)

  for path in "${control_files[@]}"; do
    [[ -e "$path" ]] || continue
    current_control+="${path} $(current_file_state "$path")"$'\n'
  done

  for dir in "${job_dirs[@]}"; do
    [[ -d "$dir" ]] || continue
    while IFS= read -r file; do
      [[ -n "$file" ]] || continue
      current_jobs+="${file} $(current_file_state "$file")"$'\n'
    done < <(find "$dir" -maxdepth 1 -type f -print 2>/dev/null)
  done

  show_current_block 'cron control file states' "${current_control%$'\n'}"
  show_current_block 'cron job file states' "${current_jobs%$'\n'}"
  return 0
}

preview_item_changes() {
  local current_jobs='' after_jobs='' path dir file
  local control_files=(/etc/crontab /etc/cron.allow /etc/cron.deny)
  local job_dirs=(/etc/cron.d /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly)

  for path in "${control_files[@]}"; do
    [[ -e "$path" ]] || continue
    preview_file_state_change "${path} ownership and mode" "$path" root root 640
  done

  for dir in "${job_dirs[@]}"; do
    [[ -d "$dir" ]] || continue
    while IFS= read -r file; do
      [[ -n "$file" ]] || continue
      current_jobs+="${file} $(current_file_state "$file")"$'\n'
      after_jobs+="${file} owner=root group=root mode=$(file_mode "$file") with group/other write removed"$'\n'
    done < <(find "$dir" -maxdepth 1 -type f -print 2>/dev/null)
  done

  preview_block_change 'cron job file handling' "${current_jobs%$'\n'}" "${after_jobs%$'\n'}"
}

check_item () 
{ 
    local rc=0;
    local path;
    local control_files=(/etc/crontab /etc/cron.allow /etc/cron.deny);
    local job_dirs=(/etc/cron.d /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly);
    for path in "${control_files[@]}";
    do
        [[ -e "$path" ]] || continue;
        if ! check_file_owner_mode "$path" 640 root bin; then
            rc=1;
        fi;
    done;
    local dir file;
    for dir in "${job_dirs[@]}";
    do
        [[ -d "$dir" ]] || continue;
        while IFS= read -r file; do
            [[ -n "$file" ]] || continue;
            if owner_in_set "$(file_owner "$file")" root bin; then
                pass "$file owner=$(file_owner "$file")";
            else
                fail "$file owner issue: $(file_owner "$file")";
                rc=1;
            fi;
            if mode_leq "$file" 755; then
                pass "$file mode=$(file_mode "$file")";
            else
                fail "$file mode issue: $(file_mode "$file")";
                rc=1;
            fi;
        done < <(find "$dir" -maxdepth 1 -type f -print 2>/dev/null);
    done;
    return "$rc"
}

apply_item () 
{ 
    require_root;
    local path;
    local control_files=(/etc/crontab /etc/cron.allow /etc/cron.deny);
    local job_dirs=(/etc/cron.d /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly);
    for path in "${control_files[@]}";
    do
        [[ -e "$path" ]] || continue;
        chown root:root "$path";
        chmod 640 "$path";
    done;
    local dir file;
    for dir in "${job_dirs[@]}";
    do
        [[ -d "$dir" ]] || continue;
        while IFS= read -r file; do
            [[ -n "$file" ]] || continue;
            chown root:root "$file";
            chmod go-w "$file";
        done < <(find "$dir" -maxdepth 1 -type f -print 2>/dev/null);
    done;
    pass 'U-22 Remediation steps applied.'
}
