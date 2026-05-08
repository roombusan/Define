#!/bin/bash
# 파일 변경 시 자동으로 git commit + push

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

echo "▶ 자동 저장 시작 (Ctrl+C로 종료)"
echo "  폴더: $DIR"
echo ""

PENDING=0

# fswatch로 변경 감지, .git 폴더 제외
fswatch -r --exclude=".git" --exclude="auto-save.sh" . | while read -r event; do
  PENDING=1

  # 0.5초 대기 (연속 저장 묶기)
  sleep 0.5

  if [ "$PENDING" -eq 1 ]; then
    PENDING=0

    # 변경 사항 있을 때만 커밋
    if ! git diff --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
      git add -A
      TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
      git commit -m "auto-save $TIMESTAMP" --quiet
      echo "[저장됨] $TIMESTAMP"

      # 원격 저장소 연결된 경우 push
      if git remote get-url origin &>/dev/null; then
        git push --quiet 2>/dev/null && echo "[업로드됨] GitHub 반영 완료" || echo "[알림] GitHub 업로드 실패 (오프라인?)"
      fi
    fi
  fi
done
