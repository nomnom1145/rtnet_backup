```bash
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

# 커밋 메시지 자동 생성
COMMIT_MESSAGE="auto sync $(date '+%Y-%m-%d %H:%M:%S')"

echo
echo "===== Git 동기화 시작 ====="

echo "SOURCE_DIR: $SOURCE_DIR"
echo "GIT_REPO_DIR: $GIT_REPO_DIR"

# 기존 작업 디렉터리 존재 확인
if [ ! -d "$SOURCE_DIR" ]; then
    echo
    echo "오류: SOURCE_DIR 없음: $SOURCE_DIR"
    exit 1
fi

# Git 저장소 확인
if [ ! -d "$GIT_REPO_DIR/.git" ]; then
    echo
    echo "오류: Git 저장소 아님: $GIT_REPO_DIR"
    exit 1
fi

# Git 저장소 이동
cd "$GIT_REPO_DIR"

# 최신 상태 가져오기
echo
echo "===== git pull ====="

git pull origin "$GIT_BRANCH"

# 삭제 예정 파일 확인
echo
echo "===== 삭제 예정 파일 확인 ====="

DELETE_CHECK=$(rsync -av --delete --dry-run \
    --exclude ".git/" \
    --exclude "*.log" \
    --exclude "*.retry" \
    --exclude "__pycache__/" \
    --exclude ".env" \
    --exclude "venv/" \
    "$SOURCE_DIR"/ "$GIT_REPO_DIR"/ | grep '^deleting ' || true)

if [ -n "$DELETE_CHECK" ]; then
    echo
    echo "아래 파일은 SOURCE_DIR에 없기 때문에 삭제 예정입니다."
    echo
    echo "$DELETE_CHECK"
    echo

    read -r -p "삭제를 포함하여 계속 진행하시겠습니까? (yes/no): " CONFIRM_DELETE

    if [ "$CONFIRM_DELETE" != "yes" ]; then
        echo
        echo "사용자가 작업을 취소했습니다."
        exit 1
    fi
else
    echo "삭제 예정 파일 없음"
fi

# 파일 동기화
echo
echo "===== rsync 동기화 ====="

rsync -av --delete \
    --exclude ".git/" \
    --exclude "*.log" \
    --exclude "*.retry" \
    --exclude "__pycache__/" \
    --exclude ".env" \
    --exclude "venv/" \
    "$SOURCE_DIR"/ "$GIT_REPO_DIR"/

# Git 상태 확인
echo
echo "===== git status ====="

git status

# 변경사항 없는 경우 종료
if [ -z "$(git status --porcelain)" ]; then
    echo
    echo "변경사항 없음"
    exit 0
fi

# Git add
echo
echo "===== git add ====="

git add .

# Git commit
echo
echo "===== git commit ====="

git commit -m "$COMMIT_MESSAGE"

# Git push
echo
echo "===== git push ====="

git push origin "$GIT_BRANCH"

echo
echo "===== GitHub 동기화 완료 ====="
echo
```
