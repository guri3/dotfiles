#!/bin/bash

# UserPromptSubmit hook: プロンプトが "#t 〜" マーカーで始まる場合、
# 本文を日報用ログ (tweets.jsonl) に記録し、プロンプト処理をブロックする。
#
# このスクリプトは全プロンプト送信時に実行されるため、失敗安全を最優先とする。
# jq が無い・JSON が壊れている・書き込みに失敗した等、いかなるエラーでも
# 非マッチ扱いで exit 0 し、通常のプロンプト処理を絶対に妨げない (set -e は使わない)。

# jq が存在しない場合は非マッチ扱いで終了
if ! command -v jq &>/dev/null; then
  exit 0
fi

# JSON 入力を読み取り、プロンプト本文を抽出
input=$(cat)
prompt=$(echo "$input" | jq -r '.prompt // empty' 2>/dev/null)

# マーカー "#t" (直後は空白または行末) で始まらなければ非マッチ
# "#test..." のように #t の直後が空白でない場合は非マッチになる
if [[ ! "$prompt" =~ ^#t([[:space:]]|$) ]]; then
  exit 0
fi

# 残りのフィールドを抽出
session_id=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null)
cwd=$(echo "$input" | jq -r '.cwd // empty' 2>/dev/null)

# 本文 = prompt から先頭の "#t" と直後の空白列を除去したもの
body="${prompt#\#t}"
body="${body#"${body%%[![:space:]]*}"}"

# 本文が空 (#t のみ) の場合は記録せず使い方を案内する
if [ -z "$body" ]; then
  jq -nc '{decision:"block",reason:"使い方: #t <呟き> で日報用メモを記録する"}'
  exit 0
fi

# 保存先ディレクトリ (NIPPO_BASE_DIR はテスト用の上書き口)
base_dir="${NIPPO_BASE_DIR:-$HOME/.guri3/ai}"
save_dir="$base_dir/$(date +%Y%m%d)_nippo"
mkdir -p "$save_dir" 2>/dev/null || exit 0
tweets_file="$save_dir/tweets.jsonl"

# 1 行の JSON を生成して追記 (本文が複数行でも jq --arg で安全に 1 行 JSON になる)
ts=$(date +%Y-%m-%dT%H:%M:%S%z)
line=$(jq -nc \
  --arg ts "$ts" \
  --arg session_id "$session_id" \
  --arg cwd "$cwd" \
  --arg text "$body" \
  '{ts: $ts, session_id: $session_id, cwd: $cwd, text: $text}' 2>/dev/null) || exit 0
[ -z "$line" ] && exit 0
echo "$line" >>"$tweets_file" 2>/dev/null || exit 0

# 追記後の行数を数え、記録完了を案内してブロックする
count=$(wc -l <"$tweets_file" 2>/dev/null | tr -d '[:space:]')
first_line="${body%%$'\n'*}"
summary="${first_line:0:60}"
jq -nc \
  --arg count "$count" \
  --arg summary "$summary" \
  '{decision: "block", reason: ("📝 呟きを記録した（今日" + $count + "件目）: " + $summary)}'
exit 0
