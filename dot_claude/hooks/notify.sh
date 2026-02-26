#!/bin/bash

INPUT=$(cat)

get_field() {
  local field="$1"
  local default="$2"
  echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('$field', '$default'))
" 2>/dev/null || echo "$default"
}

CWD=$(get_field "cwd" "${CLAUDE_PROJECT_DIR:-}")
MESSAGE=$(get_field "message" "")
HOOK_EVENT=$(get_field "hook_event_name" "")

if [ -z "$MESSAGE" ]; then
  if [ "$HOOK_EVENT" = "Stop" ]; then
    MESSAGE="作業が完了しました"
  else
    MESSAGE="操作が必要です"
  fi
fi

if [ -n "$CWD" ]; then
  PROJECT=$(basename "$CWD")
  BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null)
  if [ -n "$BRANCH" ]; then
    TITLE="Claude Code - $PROJECT ($BRANCH)"
  else
    TITLE="Claude Code - $PROJECT"
  fi
else
  TITLE="Claude Code"
fi

osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\""
afplay /System/Library/Sounds/Glass.aiff &
