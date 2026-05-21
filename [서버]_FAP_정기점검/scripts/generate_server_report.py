import json
import math
import os
import re
import sys
from copy import copy
from datetime import datetime

from openpyxl import load_workbook
from openpyxl.styles import Alignment

TARGET_SHEET = "Sheet1"
DR_SOURCE_SHEET_CANDIDATES = ["2026", "통합"]
DR_SOURCE_START_ROW = 4
USER_START_ROW = 142
USER_NEXT_SECTION_ROW = 162
WEB_IP_START_ROW = 169
WEB_IP_NEXT_SECTION_ROW = 175
WORK_MANAGEMENT_ROW = 184
DR_SECTION_TITLE = "10. DR 모의훈련 작업 내역"


def load_input(arg):
    if os.path.isfile(arg):
        with open(arg, "r", encoding="utf-8") as file:
            return json.load(file)
    return json.loads(arg)


def choose_source_sheet(workbook):
    for name in DR_SOURCE_SHEET_CANDIDATES:
        if name in workbook.sheetnames:
            return workbook[name]
    return workbook[workbook.sheetnames[0]]


def normalize_date(value):
    if isinstance(value, datetime):
        return value.strftime("%Y-%m-%d")
    return value


def copy_cell_style(ws, src_row, dst_row, col):
    src = ws.cell(src_row, col)
    dst = ws.cell(dst_row, col)
    if src.has_style:
        dst._style = copy(src._style)
    if src.font:
        dst.font = copy(src.font)
    if src.fill:
        dst.fill = copy(src.fill)
    if src.border:
        dst.border = copy(src.border)
    if src.alignment:
        dst.alignment = copy(src.alignment)
    if src.protection:
        dst.protection = copy(src.protection)
    dst.number_format = src.number_format


def copy_row_style(ws, src_row, dst_row, max_col=7):
    for col in range(1, max_col + 1):
        copy_cell_style(ws, src_row, dst_row, col)
    ws.row_dimensions[dst_row].height = ws.row_dimensions[src_row].height


def ensure_rows(ws, start_row, wanted_count, anchor_row, max_col=7):
    if wanted_count <= 1:
        return
    for i in range(wanted_count - 1):
        row = start_row + i + 1
        ws.insert_rows(row)
        copy_row_style(ws, anchor_row, row, max_col=max_col)


def ensure_merged_rows(ws, start_row, wanted_count):
    if wanted_count <= 1:
        return
    template_row = start_row
    for _ in range(wanted_count - 1):
        row = template_row + 1
        ws.insert_rows(row)
        copy_row_style(ws, template_row, row, max_col=7)
        ws.merge_cells(start_row=row, start_column=2, end_row=row, end_column=3)
        ws.merge_cells(start_row=row, start_column=4, end_row=row, end_column=5)
        template_row += 1


def ensure_merge(ws, start_row, start_col, end_row, end_col):
    target = f"{ws.cell(start_row, start_col).coordinate}:{ws.cell(end_row, end_col).coordinate}"
    for merged in list(ws.merged_cells.ranges):
        if str(merged) == target:
            return
    ws.merge_cells(start_row=start_row, start_column=start_col, end_row=end_row, end_column=end_col)


def find_row_by_first_column(ws, label):
    for row in range(1, ws.max_row + 1):
        value = ws.cell(row, 1).value
        if str(value or "").strip() == label:
            return row
    raise ValueError(f"Could not find row label: {label}")


def source_row_has_data(ws, row):
    return any(ws.cell(row, col).value not in (None, "") for col in (2, 3, 4, 5, 7))


def read_dr_mock_rows(source_path):
    workbook = load_workbook(source_path, data_only=True)
    ws = choose_source_sheet(workbook)
    rows = []
    for row in range(DR_SOURCE_START_ROW, ws.max_row + 1):
        if not source_row_has_data(ws, row):
            continue
        rows.append(
            {
                1: normalize_date(ws.cell(row, 2).value),
                2: normalize_date(ws.cell(row, 3).value),
                4: normalize_date(ws.cell(row, 4).value),
                6: normalize_date(ws.cell(row, 5).value),
                7: normalize_date(ws.cell(row, 7).value),
            }
        )
    return rows


def parse_version_number(text):
    matches = re.findall(r"\d+(?:\.\d+)+", text or "")
    return matches[0] if matches else (text or "").strip()


def parse_cpu(text):
    match = re.search(r"([0-9]+(?:\.[0-9]+)?)\s+us", text or "")
    return match.group(1) if match else (text or "").strip()


def parse_memory(text):
    total = re.search(r"Total=([^|]+)", text or "")
    used = re.search(r"Used=([^|]+)", text or "")
    return (total.group(1).strip() if total else ""), (used.group(1).strip() if used else "")


def decode_json_list(value):
    if isinstance(value, list):
        return value
    if not value:
        return []
    try:
        return json.loads(value)
    except Exception:
        return [value]


def parse_disk_lines(lines):
    disk_map = {"/": {}, "/app": {}, "/data": {}}
    for line in decode_json_list(lines):
        item = {}
        for part in str(line).split("||"):
            if "=" in part:
                key, value = part.split("=", 1)
                item[key.strip()] = value.strip()
        mount = item.get("Mount")
        if mount in disk_map:
            disk_map[mount] = item
    return disk_map


def parse_process_table(text):
    results = {}
    for line in (text or "").splitlines()[1:]:
        parts = line.split()
        if not parts:
            continue
        name = parts[0]
        status = " ".join(parts[1:])
        results[name] = status
    return results


def process_result_for(name, mapping):
    for key, status in mapping.items():
        if key == name or key.startswith(name):
            return ("정상" if status.startswith("Up") else "비정상"), status
    return "없음", "docker ps -a 결과 없음"


def parse_csv_lines(text):
    rows = []
    for line in (text or "").splitlines():
        line = line.strip()
        if line:
            rows.append([part.strip() for part in line.split(",")])
    return rows


def parse_pipe_lines(text):
    rows = []
    for line in (text or "").splitlines():
        line = line.strip()
        if line:
            rows.append([part.strip() for part in line.split("|")])
    return rows


def normalize_cell_text(value):
    if value is None:
        return ""
    return str(value).strip()


def set_wrapped_left(cell):
    base = copy(cell.alignment) if cell.alignment else Alignment()
    cell.alignment = Alignment(
        horizontal="left",
        vertical="top",
        wrap_text=True,
        text_rotation=base.text_rotation,
        shrink_to_fit=base.shrink_to_fit,
        indent=base.indent,
    )


def set_wrapped_center(cell):
    base = copy(cell.alignment) if cell.alignment else Alignment()
    cell.alignment = Alignment(
        horizontal="center",
        vertical="center",
        wrap_text=True,
        text_rotation=base.text_rotation,
        shrink_to_fit=base.shrink_to_fit,
        indent=base.indent,
    )


def estimate_row_height(*values):
    line_count = 1
    for value in values:
        text = normalize_cell_text(value)
        if not text:
            continue
        wrapped = 0
        for part in text.splitlines() or [""]:
            wrapped += max(1, math.ceil(len(part) / 18))
        line_count = max(line_count, wrapped)
    return max(20, line_count * 18)


def fill_top_summary(ws, payload):
    ws.cell(3, 3, payload.get("report_date", ""))
    ws.cell(4, 4, payload.get("first_org", "알티넷솔루션"))
    ws.cell(5, 4, payload.get("second_org", "신세계I&C"))
    ws.cell(4, 6, payload.get("first_name", ""))
    ws.cell(5, 6, payload.get("second_name", ""))
    ws.cell(17, 2, payload.get("special_note", ""))


def fill_host_labels(ws, payload):
    first_ip = payload.get("first_ip", "")
    second_ip = payload.get("second_ip", "")
    if first_ip:
        ws["A46"] = f"    3) {first_ip} CPU 사용률 확인"
        ws["A58"] = f"    3) {first_ip} 디스크 사용률 확인"
        ws["A74"] = f"    3) {first_ip} 메모리 사용률 확인"
        ws["A91"] = f"    1) {first_ip}"
    if second_ip:
        ws["A50"] = f"    4) {second_ip} CPU 사용률 확인"
        ws["A64"] = f"    4) {second_ip} 디스크 사용률 확인"
        ws["A78"] = f"    4) {second_ip} 메모리 사용률 확인"
        ws["A101"] = f"    2) {second_ip}"


def fill_version_section(ws, payload):
    ws.cell(30, 2, parse_version_number(payload.get("os_version", "")))
    ws.cell(31, 2, parse_version_number(payload.get("postgres_version", "")))
    ws.cell(32, 2, parse_version_number(payload.get("fap_version", "")))
    ws.cell(33, 2, parse_version_number(payload.get("redis_version", "")))
    ws.cell(34, 2, parse_version_number(payload.get("docker_version", "")))
    ws.cell(35, 2, parse_version_number(payload.get("tomcat_version", "")))
    ws.cell(36, 2, parse_version_number(payload.get("ansible_core_version", "")))


def fill_cpu_disk_memory(ws, payload):
    cpu = parse_cpu(payload.get("cpu_output", ""))
    if cpu:
        for row in (48, 52):
            ws.cell(row, 1, cpu)
            ws.cell(row, 5, "정상")

    disk_rows = parse_disk_lines(payload.get("disk_output", []))
    row_mapping = [(60, "/"), (61, "/app"), (62, "/data"), (66, "/"), (67, "/app"), (68, "/data")]
    for rownum, mount in row_mapping:
        item = disk_rows.get(mount, {})
        ws.cell(rownum, 1, mount)
        if item and item.get("Status") != "NOT_FOUND":
            ws.cell(rownum, 2, item.get("Size", ""))
            ws.cell(rownum, 3, item.get("Used", ""))
            ws.cell(rownum, 4, item.get("Use", ""))
            ws.cell(rownum, 5, "정상" if "[FAIL]" not in " ".join(item.values()) else "비정상")
        else:
            ws.cell(rownum, 2, "없음")
            ws.cell(rownum, 3, "없음")
            ws.cell(rownum, 4, "없음")
            ws.cell(rownum, 5, "없음")

    mem_total, mem_used = parse_memory(payload.get("memory_output", ""))
    if mem_total or mem_used:
        for row in (76, 80):
            ws.cell(row, 1, mem_total)
            ws.cell(row, 2, mem_used)
            ws.cell(row, 4, "정상")


def fill_patch_section(ws, payload):
    ws.cell(84, 2, payload.get("os_patch_day", ""))
    ws.cell(84, 4, payload.get("os_vulnerability", ""))
    ws.cell(84, 6, payload.get("os_note", ""))
    ws.cell(85, 2, payload.get("db_patch_day", ""))
    ws.cell(85, 4, payload.get("db_vulnerability", ""))
    ws.cell(85, 6, payload.get("db_note", ""))
    ws.cell(86, 2, payload.get("fap_patch_day", ""))
    ws.cell(86, 4, payload.get("fap_vulnerability", ""))
    ws.cell(86, 6, payload.get("fap_note", ""))


def fill_process_section(ws, payload):
    process_map = parse_process_table(payload.get("process_output", ""))
    names = ["fap-agent", "fap-manager", "fap-web", "fap-haproxy", "pg", "fap-redis", "portainer"]
    for base_row in (93, 103):
        for idx, name in enumerate(names):
            row = base_row + idx
            result, note = process_result_for(name, process_map)
            ws.cell(row, 2, name)
            ws.cell(row, 5, result)
            ws.cell(row, 6, note)


def fill_ui_service_section(ws, payload):
    for row in range(127, 138):
        ws.cell(row, 5, "정상")
    ws.cell(129, 6, f"현재 등록된 호스트 수 : {payload.get('host_count', '')}")
    ws.cell(131, 6, f"현재 등록된 사용자 수 : {payload.get('user_count', '')}")
    ws.cell(132, 6, f"현재 등록된 스케줄 수 : {payload.get('schedule_count', '')}")
    ws.cell(133, 6, f"현재 등록된 통보 수 : {payload.get('notification_count', '')}")


def fill_user_section(ws, payload):
    user_rows = parse_csv_lines(payload.get("user_account_status", ""))
    if not user_rows:
        return
    available_rows = USER_NEXT_SECTION_ROW - USER_START_ROW
    if len(user_rows) > available_rows:
        ensure_rows(ws, USER_START_ROW, len(user_rows), USER_START_ROW, max_col=7)
    for idx, row_data in enumerate(user_rows):
        row = USER_START_ROW + idx
        while len(row_data) < 6:
            row_data.append("")
        for col in range(1, 8):
            copy_cell_style(ws, USER_START_ROW, row, col)
        ensure_merge(ws, row, 6, row, 7)
        for col, value in enumerate(row_data[:5], start=1):
            ws.cell(row, col, value)
        ws.cell(row, 6, row_data[5])
        ws.cell(row, 7, None)


def fill_template_section(ws, payload):
    header_row = find_row_by_first_column(ws, "전월 수량")
    ws.cell(header_row + 1, 1, payload.get("previous_template_count", "0"))
    ws.cell(header_row + 1, 4, payload.get("current_template_count", "0"))


def fill_web_ip_section(ws, payload):
    ip_rows = parse_pipe_lines(payload.get("web_access_ip", ""))
    start_row = find_row_by_first_column(ws, "시스템 접속 허용 IP")
    available_rows = WEB_IP_NEXT_SECTION_ROW - WEB_IP_START_ROW
    if len(ip_rows) > available_rows:
        ensure_rows(ws, start_row, len(ip_rows), start_row, max_col=6)
    rows_to_fill = ip_rows if ip_rows else [["시스템 접속 허용 IP", "", "", "", ""]]
    for idx, row_data in enumerate(rows_to_fill):
        row = start_row + idx
        while len(row_data) < 5:
            row_data.append("")
        for col in range(1, 7):
            copy_cell_style(ws, start_row, row, col)
        ws.cell(row, 1, row_data[0])
        ws.cell(row, 2, row_data[1])
        ws.cell(row, 4, row_data[2])
        ws.cell(row, 5, row_data[3])
        ws.cell(row, 6, row_data[4])


def fill_dr_workflow_section(ws, payload):
    mock_row = find_row_by_first_column(ws, "모의훈련")
    cutover_row = find_row_by_first_column(ws, "실 전환")
    manual_row = find_row_by_first_column(ws, "IP 수동전환")
    ws.cell(mock_row, 3, payload.get("previous_dr_mock_count", "0"))
    ws.cell(mock_row, 5, payload.get("dr_mock_count", "0"))
    ws.cell(cutover_row, 3, payload.get("previous_dr_cutover_count", "0"))
    ws.cell(cutover_row, 5, payload.get("dr_cutover_count", "0"))
    ws.cell(manual_row, 3, payload.get("previous_dr_manual_ip_count", "0"))
    ws.cell(manual_row, 5, payload.get("dr_manual_ip_count", "0"))


def fill_work_management(ws, payload):
    current = payload.get("current_work_management", []) or []
    upcoming = payload.get("next_work_management", []) or []
    if isinstance(current, str):
        current = json.loads(current) if current else []
    if isinstance(upcoming, str):
        upcoming = json.loads(upcoming) if upcoming else []
    current_text = "\n".join(str(x) for x in current)
    upcoming_text = "\n".join(str(x) for x in upcoming)
    ws.cell(WORK_MANAGEMENT_ROW, 1, current_text)
    ws.cell(WORK_MANAGEMENT_ROW, 5, upcoming_text)
    set_wrapped_left(ws.cell(WORK_MANAGEMENT_ROW, 1))
    set_wrapped_left(ws.cell(WORK_MANAGEMENT_ROW, 5))
    ws.row_dimensions[WORK_MANAGEMENT_ROW].height = estimate_row_height(current_text, upcoming_text)


def fill_dr_mock_section(ws, rows):
    if not rows:
        return
    title_row = find_row_by_first_column(ws, DR_SECTION_TITLE)
    start_row = title_row + 2
    ensure_merged_rows(ws, start_row, len(rows))
    for offset, row_data in enumerate(rows):
        row = start_row + offset
        for col in range(1, 8):
            copy_cell_style(ws, start_row, row, col)
        ws.cell(row, 1, row_data.get(1))
        ws.cell(row, 2, row_data.get(2))
        ws.cell(row, 4, row_data.get(4))
        ws.cell(row, 6, row_data.get(6))
        ws.cell(row, 7, row_data.get(7))
        for col in (1, 2, 4):
            set_wrapped_left(ws.cell(row, col))
        for col in (6, 7):
            set_wrapped_center(ws.cell(row, col))
        ws.row_dimensions[row].height = estimate_row_height(
            row_data.get(1), row_data.get(2), row_data.get(4), row_data.get(6), row_data.get(7)
        )


def generate_report(template_path, input_payload, output_path):
    workbook = load_workbook(template_path)
    ws = workbook[TARGET_SHEET] if TARGET_SHEET in workbook.sheetnames else workbook.active
    fill_top_summary(ws, input_payload)
    fill_host_labels(ws, input_payload)
    fill_version_section(ws, input_payload)
    fill_cpu_disk_memory(ws, input_payload)
    fill_patch_section(ws, input_payload)
    fill_process_section(ws, input_payload)
    fill_ui_service_section(ws, input_payload)
    fill_user_section(ws, input_payload)
    fill_template_section(ws, input_payload)
    fill_web_ip_section(ws, input_payload)
    fill_dr_workflow_section(ws, input_payload)
    fill_work_management(ws, input_payload)
    fill_dr_mock_section(ws, read_dr_mock_rows(input_payload["dr_mock_source_path"]))
    fill_host_labels(ws, input_payload)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    workbook.save(output_path)
    return output_path


def main():
    if len(sys.argv) != 4:
        raise SystemExit("Usage: generate_server_report.py <template_xlsx> <input_json> <output_xlsx>")
    template_path = sys.argv[1]
    payload = load_input(sys.argv[2])
    output_path = sys.argv[3]
    saved = generate_report(template_path, payload, output_path)
    print(saved)


if __name__ == "__main__":
    main()
