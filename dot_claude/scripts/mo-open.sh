#!/bin/bash

# PostToolUse hook: Write ツールで .md ファイルが作成されたら mo で開く
# mo はバックグラウンドで動作し、既にサーバーが起動していればファイルを追加する

# jq が存在しない場合はスキップ
if ! command -v jq &>/dev/null; then
  exit 0
fi

# mo が存在しない場合はスキップ
if ! command -v mo &>/dev/null; then
  exit 0
fi

# stdin から JSON 入力を読み取り
input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

# Write ツール以外はスキップ
if [ "$tool_name" != "Write" ]; then
  exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# .md ファイルでなければスキップ
if [[ "$file_path" != *.md ]]; then
  exit 0
fi

# ファイルが存在しなければスキップ
if [ ! -f "$file_path" ]; then
  exit 0
fi

# mo でファイルを開く（claude グループに追加）
mo "$file_path" --target claude 2>/dev/null

exit 0
