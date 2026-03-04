#!/bin/bash
# tmuxのウィンドウ名をClaude Codeの作業状況に応じて変更する

# tmux環境でない場合は何もしない
if [ -z "$TMUX" ]; then
  exit 0
fi

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

get_action() {
  echo "$INPUT" | python3 -c "
import sys, json, os

d = json.load(sys.stdin)
tool = d.get('tool_name', '')
inp = d.get('tool_input', {})

if tool == 'Bash':
    cmd = inp.get('command', '')
    first_line = cmd.split('\n')[0][:40]
    print(first_line or 'Bash')
elif tool in ('Edit', 'Write', 'Read'):
    fp = inp.get('file_path', '')
    name = os.path.basename(fp)
    print(f'{tool}: {name}' if name else tool)
elif tool == 'Grep':
    pattern = inp.get('pattern', '')[:30]
    print(f'Search: {pattern}' if pattern else 'Grep')
elif tool == 'Glob':
    pattern = inp.get('pattern', '')[:30]
    print(f'Glob: {pattern}' if pattern else 'Glob')
else:
    print(tool)
" 2>/dev/null || echo "$TOOL_NAME"
}

rename_window() {
  tmux rename-window "$1" 2>/dev/null || true
}

CWD=$(get_field "cwd" "")
HOOK_EVENT=$(get_field "hook_event_name" "")
TOOL_NAME=$(get_field "tool_name" "")

# プロジェクト名とブランチを取得
if [ -n "$CWD" ]; then
  PROJECT=$(basename "$CWD")
  BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null)
  if [ -n "$BRANCH" ]; then
    CONTEXT="$PROJECT($BRANCH)"
  else
    CONTEXT="$PROJECT"
  fi
else
  CONTEXT="Claude Code"
fi

case "$HOOK_EVENT" in
  PreToolUse)
    ACTION=$(get_action)
    rename_window "● $CONTEXT | $ACTION"
    ;;
  Stop)
    rename_window "○ $CONTEXT"
    ;;
  *)
    rename_window "○ $CONTEXT"
    ;;
esac
