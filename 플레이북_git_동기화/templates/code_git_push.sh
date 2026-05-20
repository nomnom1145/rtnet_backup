#!/bin/bash

# 작업 실패 시 즉시 종료
set -e

# 기존 작업 디렉터리
SOURCE_DIR="/fap/ansible/projects"

# Git 저장소 디렉터리
GIT_REPO_DIR="/home/fap/rtnet_backup"

# Git 브랜치
GIT_BRANCH="main"

# Git 한글 경로가 깨져 보이지 않도록 설정
git config --global core.quotepath false

# 현재 세션의 문자 인코딩 설정
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8

# pager 비활성화
export GIT_PAGER=cat
export PAGER=cat

# 커밋 메시지 자동 생성
COMMIT_MESSAGE="auto sync $(date '+%Y-%m-%d %H:%M:%S')"

# 구분선 출력 함수
print_section() {
    echo
    echo "=================================================="
    echo "$1"
    echo "=================================================="
}

print_section "Git 동기화 시작"

echo "SOURCE_DIR   : $SOURCE_DIR"
echo "GIT_REPO_DIR : $GIT_REPO_DIR"
echo "GIT_BRANCH   : $GIT_BRANCH"

# 기존 작업 디렉터리 존재 확인
if [ ! -d "$SOURCE_DIR" ]; then
    echo
    echo "[실패] SOURCE_DIR 없음: $SOURCE_DIR"
    exit 1
fi

# Git 저장소 확인
if [ ! -d "$GIT_REPO_DIR/.git" ]; then
    echo
    echo "[실패] Git 저장소 아님: $GIT_REPO_DIR"
    exit 1
fi

cd "$GIT_REPO_DIR"

git config user.name "Ansible Auto Sync"
git config user.email "sg.jang@rtnet.co.kr"

print_section "원격 저장소 최신화"

git pull --quiet origin "$GIT_BRANCH"

echo "[완료] git pull 성공"

print_section "삭제 예정 파일 확인"

DELETE_CHECK=$(find "$GIT_REPO_DIR" -mindepth 1 \
    -path "$GIT_REPO_DIR/.git" -prune -o \
    -path "$GIT_REPO_DIR/.git/*" -prune -o \
    -name ".gitignore" -prune -o \
    -name "*.log" -prune -o \
    -name "*.retry" -prune -o \
    -name "__pycache__" -prune -o \
    -name ".env" -prune -o \
    -name "venv" -prune -o \
    -name ".vault_pass.txt" -prune -o \
    -name "vault_mail.yml" -prune -o \
    -name "id_ed25519*" -prune -o \
    -name "*.pem" -prune -o \
    -name "*.key" -prune -o \
    -print | while read -r target_path; do
        relative_path="${target_path#$GIT_REPO_DIR/}"
        if [ ! -e "$SOURCE_DIR/$relative_path" ]; then
            echo "*deleting $relative_path"
        fi
    done)

if [ -n "$DELETE_CHECK" ]; then
    echo "[확인] 아래 파일은 SOURCE_DIR에 없기 때문에 삭제됩니다."
    echo
    echo "$DELETE_CHECK"
else
    echo "[확인] 삭제 예정 파일 없음"
fi

print_section "파일 동기화"

# 기존 파일 삭제
find "$GIT_REPO_DIR" -mindepth 1 \
    -path "$GIT_REPO_DIR/.git" -prune -o \
    -path "$GIT_REPO_DIR/.git/*" -prune -o \
    -name ".gitignore" -prune -o \
    -name "*.log" -prune -o \
    -name "*.retry" -prune -o \
    -name "__pycache__" -prune -o \
    -name ".env" -prune -o \
    -name "venv" -prune -o \
    -name ".vault_pass.txt" -prune -o \
    -name "vault_mail.yml" -prune -o \
    -name "id_ed25519*" -prune -o \
    -name "*.pem" -prune -o \
    -name "*.key" -prune -o \
    -exec rm -rf {} +

# 파일 복사
tar \
    --exclude=".git" \
    --exclude=".gitignore" \
    --exclude="*.log" \
    --exclude="*.retry" \
    --exclude="__pycache__" \
    --exclude=".env" \
    --exclude="venv" \
    --exclude=".vault_pass.txt" \
    --exclude="vault_mail.yml" \
    --exclude="id_ed25519*" \
    --exclude="*.pem" \
    --exclude="*.key" \
    -C "$SOURCE_DIR" \
    -cf - . | tar -C "$GIT_REPO_DIR" -xf -

echo "[완료] 파일 동기화 완료"

print_section "Git 변경사항 확인"

GIT_STATUS=$(git status --short)

if [ -z "$GIT_STATUS" ]; then
    echo "[완료] 변경사항 없음"
    exit 0
fi

echo "[변경사항]"
echo "$GIT_STATUS"

print_section "Git 커밋 준비"

git add .

echo "[커밋 대상 요약]"
git --no-pager diff --cached --stat

print_section "Git 커밋"

git commit -m "$COMMIT_MESSAGE"

print_section "Git Push"

git push --quiet origin "$GIT_BRANCH"

echo "[완료] GitHub 동기화 완료"
echo "커밋 메시지: $COMMIT_MESSAGE"