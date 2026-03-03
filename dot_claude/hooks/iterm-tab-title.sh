#!/bin/bash
# iTerm2のタブタイトルをClaude Codeの作業状況に応じて変更する

INPUT=$(cat)

get_field() {
  local field="$1"
  local default="${2:-}"
  echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('$field', '$default'))
" 2>/dev/null || echo "$default"
}

set_tab_title() {
  printf '\033]1;%s\007' "$1" > /dev/tty 2>/dev/null || true
}

CWD=$(get_field "cwd" "")
HOOK_EVENT=$(get_field "hook_event_name" "")
TOOL_NAME=$(get_field "tool_name" "")

# プロジェクト名とブランチを取得
if [ -n "$CWD" ]; then
  PROJECT=$(basename "$CWD")
  BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null)
  if [ -n "$BRANCH" ]; then
    CONTEXT="$PROJECT ($BRANCH)"
  else
    CONTEXT="$PROJECT"
  fi
else
  CONTEXT="Claude Code"
fi

case "$HOOK_EVENT" in
  PreToolUse)
    set_tab_title "● $CONTEXT | $TOOL_NAME"
    ;;
  Stop)
    set_tab_title "○ $CONTEXT"
    ;;
  *)
    set_tab_title "○ $CONTEXT"
    ;;
esac
