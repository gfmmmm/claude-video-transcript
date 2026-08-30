#!/usr/bin/env bash
# 대본추출 스킬 — Mac 한 줄 설치 스크립트
#
# 하는 일:
#   1. Homebrew 확인
#   2. ffmpeg, yt-dlp, openai-whisper 설치 (이미 있으면 건너뜀)
#   3. 스킬을 ~/.claude/skills/대본추출 에 복사 (이미 있으면 최신으로 갱신)
#
# 사용법:
#   curl -fsSL https://raw.githubusercontent.com/gfmmmm/claude-video-transcript/main/install.sh | bash

set -euo pipefail

REPO="https://github.com/gfmmmm/claude-video-transcript.git"
SKILL_DIR="$HOME/.claude/skills/대본추출"

echo ""
echo "▶ 1/3  Homebrew 확인"
if ! command -v brew >/dev/null 2>&1; then
  echo "   ✗ Homebrew가 없습니다. https://brew.sh 에서 먼저 설치한 뒤 다시 실행해주세요."
  exit 1
fi
echo "   ✓ Homebrew 있음"

echo ""
echo "▶ 2/3  도구 설치 (ffmpeg, yt-dlp, openai-whisper)"
for pkg in ffmpeg yt-dlp openai-whisper; do
  if brew list --formula "$pkg" >/dev/null 2>&1; then
    echo "   ✓ $pkg 이미 설치됨"
  else
    echo "   … $pkg 설치 중 (openai-whisper는 몇 분 걸릴 수 있습니다)"
    brew install "$pkg" || {
      echo ""
      echo "   ✗ $pkg 설치에 실패했습니다."
      echo "     위 에러 메시지를 통째로 복사해서 Claude Code에 붙여넣고"
      echo "     \"$pkg 설치 도와줘\" 라고 하면 원인을 잡아줍니다."
      exit 1
    }
  fi
done

echo ""
echo "▶ 3/3  스킬 설치 → $SKILL_DIR"
mkdir -p "$HOME/.claude/skills"
if [ -d "$SKILL_DIR/.git" ]; then
  git -C "$SKILL_DIR" pull --ff-only
  echo "   ✓ 기존 스킬을 최신으로 갱신했습니다"
else
  if [ -e "$SKILL_DIR" ]; then
    echo "   ✗ $SKILL_DIR 이(가) 이미 있는데 git 저장소가 아닙니다."
    echo "     폴더를 옮기거나 지운 뒤 다시 실행해주세요."
    exit 1
  fi
  git clone --quiet "$REPO" "$SKILL_DIR"
  echo "   ✓ 스킬을 새로 설치했습니다"
fi

echo ""
echo "▶ 설치 확인"
for cmd in ffmpeg yt-dlp whisper; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "   ✓ $cmd"
  else
    echo "   ✗ $cmd 명령을 찾지 못했습니다. 터미널을 새로 열고 다시 확인해주세요."
  fi
done

echo ""
echo "✅ 완료. Claude Code를 새로 열고  /대본추출  을 입력해보세요."
echo ""
