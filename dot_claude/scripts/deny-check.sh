#!/bin/bash

# jq が存在しない場合はエラー終了
if ! command -v jq &>/dev/null; then
  echo "Error: jq が見つかりません。deny-check.sh は jq を必要とします。" >&2
  exit 1
fi

# JSON 入力を読み取り、コマンドとツール名を抽出
input=$(cat)
cmd_input=$(echo "$input" | jq -r '.tool_input.command' 2>/dev/null || echo "")
tool_name=$(echo "$input" | jq -r '.tool_name' 2>/dev/null || echo "")

# Bash コマンドのみをチェック
if [ "$tool_name" != "Bash" ]; then
  exit 0
fi

# settings.json から拒否パターンを読み取り
settings_file="$HOME/.claude/settings.json"

# Bash コマンドの全拒否パターンを取得
deny_patterns=$(jq -r '.permissions.deny[] | select(startswith("Bash(")) | gsub("^Bash\\("; "") | gsub("\\)$"; "")' "$settings_file" 2>/dev/null)

# コマンドが拒否パターンにマッチするかチェックする関数
matches_deny_pattern() {
  local cmd="$1"
  local pattern="$2"

  # 先頭・末尾の空白を削除
  cmd="${cmd#"${cmd%%[![:space:]]*}"}" # 先頭の空白を削除
  cmd="${cmd%"${cmd##*[![:space:]]}"}" # 末尾の空白を削除

  # glob パターンマッチング（ワイルドカード対応）
  [[ "$cmd" == $pattern ]]
}

# まずコマンド全体をチェック
while IFS= read -r pattern; do
  # 空行をスキップ
  [ -z "$pattern" ] && continue

  # コマンド全体がパターンにマッチするかチェック
  if matches_deny_pattern "$cmd_input" "$pattern"; then
    echo "Error: コマンドが拒否されました: '$cmd_input' (パターン: '$pattern')" >&2
    exit 2
  fi
done <<<"$deny_patterns"

# コマンドを論理演算子で分割し、各部分もチェック
# セミコロン、&& と || で分割（パイプ | と単一 & は分割しない）
# 注意: パイプ、サブシェル ($())、コマンド置換内のコマンドは検知できない
temp_command="${cmd_input//;/$'\n'}"
temp_command="${temp_command//&&/$'\n'}"
temp_command="${temp_command//\|\|/$'\n'}"

# グロブ展開を無効化して分割処理
set -f
while IFS=$'\n' read -r cmd_part; do
  # 空の部分をスキップ
  [ -z "$(echo "$cmd_part" | tr -d '[:space:]')" ] && continue

  # 各拒否パターンに対してチェック
  while IFS= read -r pattern; do
    # 空行をスキップ
    [ -z "$pattern" ] && continue

    # このコマンド部分がパターンにマッチするかチェック
    if matches_deny_pattern "$cmd_part" "$pattern"; then
      echo "Error: コマンドが拒否されました: '$cmd_part' (パターン: '$pattern')" >&2
      set +f
      exit 2
    fi
  done <<<"$deny_patterns"
done <<<"$temp_command"
set +f

# コマンドを許可
exit 0
