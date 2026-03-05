#!/usr/bin/env bash
# Claude Code statusline script
# stdinからJSONを受け取り、ANSIカラー付き3行ステータスラインを出力する

set -euo pipefail

# --------------------------------
# 定数
# --------------------------------
CACHE_FILE="/tmp/claude-usage-cache.json"
CACHE_TTL=360
API_URL="https://api.anthropic.com/api/oauth/usage"

# ANSIカラーコード
GREEN='\033[38;2;151;201;195m'   # #97C9C3
YELLOW='\033[38;2;229;192;123m'  # #E5C07B
RED='\033[38;2;224;108;117m'     # #E06C75
GRAY='\033[38;2;74;88;92m'       # #4A585C
RESET='\033[0m'
BOLD='\033[1m'

# --------------------------------
# stdinからJSONを読み取る
# --------------------------------
INPUT_JSON=""
if [ -t 0 ]; then
  INPUT_JSON="{}"
else
  INPUT_JSON=$(cat)
fi

# モデル名の取得と整形
MODEL_RAW=$(echo "$INPUT_JSON" | jq -r '.model // "unknown"' 2>/dev/null || echo "unknown")
case "$MODEL_RAW" in
  *"opus-4"*|*"opus4"*)   MODEL_DISPLAY="Opus 4.6" ;;
  *"sonnet-4"*|*"sonnet4"*) MODEL_DISPLAY="Sonnet 4.6" ;;
  *"haiku-4"*|*"haiku4"*)   MODEL_DISPLAY="Haiku 4.5" ;;
  *"opus"*)   MODEL_DISPLAY="Opus" ;;
  *"sonnet"*) MODEL_DISPLAY="Sonnet" ;;
  *"haiku"*)  MODEL_DISPLAY="Haiku" ;;
  *)          MODEL_DISPLAY="$MODEL_RAW" ;;
esac

# コンテキスト使用率（0-100）
CTX_PCT=$(echo "$INPUT_JSON" | jq -r '.context_window_percent // .contextWindowPercent // 0' 2>/dev/null || echo "0")
CTX_PCT=${CTX_PCT%.*}  # 小数点以下を切り捨て

# 追加/削除行数
LINES_ADDED=$(echo "$INPUT_JSON" | jq -r '.lines_added // .linesAdded // 0' 2>/dev/null || echo "0")
LINES_REMOVED=$(echo "$INPUT_JSON" | jq -r '.lines_removed // .linesRemoved // 0' 2>/dev/null || echo "0")

# gitブランチ名
CWD=$(echo "$INPUT_JSON" | jq -r '.cwd // ""' 2>/dev/null || echo "")
if [ -n "$CWD" ] && [ -d "$CWD" ]; then
  GIT_BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null || echo "")
else
  GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
fi
[ -z "$GIT_BRANCH" ] && GIT_BRANCH="detached"

# --------------------------------
# 色選択関数
# --------------------------------
get_color() {
  local pct=$1
  if [ "$pct" -lt 50 ]; then
    echo "$GREEN"
  elif [ "$pct" -lt 80 ]; then
    echo "$YELLOW"
  else
    echo "$RED"
  fi
}

# --------------------------------
# プログレスバー生成関数
# --------------------------------
make_progress_bar() {
  local pct=$1
  local filled=$(( pct * 10 / 100 ))
  local bar=""
  for i in $(seq 1 10); do
    if [ "$i" -le "$filled" ]; then
      bar="${bar}▰"
    else
      bar="${bar}▱"
    fi
  done
  echo "$bar"
}

# --------------------------------
# レートリミット情報の取得（キャッシュ付き）
# --------------------------------
get_usage_data() {
  # キャッシュチェック
  if [ -f "$CACHE_FILE" ]; then
    local cache_age=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0) ))
    if [ "$cache_age" -lt "$CACHE_TTL" ]; then
      cat "$CACHE_FILE"
      return 0
    fi
  fi

  # macOSキーチェーンからOAuthトークン取得
  local token=""
  token=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null || echo "")

  if [ -z "$token" ]; then
    echo '{"error": "no_token"}'
    return 1
  fi

  # APIコール
  local response=""
  response=$(curl -s -m 10 \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json" \
    "$API_URL" 2>/dev/null || echo '{"error": "api_error"}')

  # レスポンスをキャッシュ
  echo "$response" > "$CACHE_FILE"
  echo "$response"
}

# --------------------------------
# リセット時刻のフォーマット
# --------------------------------
format_reset_time() {
  local reset_at=$1
  local now=$(date +%s)

  # reset_atがISO8601またはUnixタイムスタンプの処理
  local reset_ts=""
  if echo "$reset_at" | grep -qE '^[0-9]+$'; then
    reset_ts=$reset_at
  else
    reset_ts=$(date -jf "%Y-%m-%dT%H:%M:%SZ" "$reset_at" +%s 2>/dev/null || \
               date -jf "%Y-%m-%dT%H:%M:%S+00:00" "$reset_at" +%s 2>/dev/null || \
               echo "")
  fi

  if [ -z "$reset_ts" ]; then
    echo "unknown"
    return
  fi

  local diff=$(( reset_ts - now ))
  local tz="Asia/Tokyo"

  # 今日か明日かで表示形式を変える
  local reset_day=$(TZ="$tz" date -r "$reset_ts" +"%Y-%m-%d")
  local today=$(TZ="$tz" date +"%Y-%m-%d")
  local tomorrow=$(TZ="$tz" date -v+1d +"%Y-%m-%d")

  local time_str=$(TZ="$tz" date -r "$reset_ts" +"%l%p" | tr -d ' ' | tr 'A-Z' 'a-z')

  if [ "$reset_day" = "$today" ]; then
    echo "${time_str} (${tz})"
  elif [ "$reset_day" = "$tomorrow" ]; then
    local month_day=$(TZ="$tz" date -r "$reset_ts" +"%b %-d")
    echo "${month_day} at ${time_str} (${tz})"
  else
    local month_day=$(TZ="$tz" date -r "$reset_ts" +"%b %-d")
    echo "${month_day} at ${time_str} (${tz})"
  fi
}

# --------------------------------
# 使用データ取得
# --------------------------------
USAGE_JSON=$(get_usage_data 2>/dev/null || echo '{"error": "failed"}')

FIVE_HOUR_PCT=$(echo "$USAGE_JSON" | jq -r '.five_hour.utilization // 0' 2>/dev/null || echo "0")
FIVE_HOUR_PCT=$(echo "$FIVE_HOUR_PCT * 100" | bc 2>/dev/null | cut -d. -f1 || echo "0")
[ -z "$FIVE_HOUR_PCT" ] && FIVE_HOUR_PCT=0

SEVEN_DAY_PCT=$(echo "$USAGE_JSON" | jq -r '.seven_day.utilization // 0' 2>/dev/null || echo "0")
SEVEN_DAY_PCT=$(echo "$SEVEN_DAY_PCT * 100" | bc 2>/dev/null | cut -d. -f1 || echo "0")
[ -z "$SEVEN_DAY_PCT" ] && SEVEN_DAY_PCT=0

FIVE_HOUR_RESET=$(echo "$USAGE_JSON" | jq -r '.five_hour.reset_at // ""' 2>/dev/null || echo "")
SEVEN_DAY_RESET=$(echo "$USAGE_JSON" | jq -r '.seven_day.reset_at // ""' 2>/dev/null || echo "")

# --------------------------------
# 各要素の色を決定
# --------------------------------
CTX_COLOR=$(get_color "$CTX_PCT")
FIVE_COLOR=$(get_color "$FIVE_HOUR_PCT")
SEVEN_COLOR=$(get_color "$SEVEN_DAY_PCT")

# --------------------------------
# プログレスバー生成
# --------------------------------
FIVE_BAR=$(make_progress_bar "$FIVE_HOUR_PCT")
SEVEN_BAR=$(make_progress_bar "$SEVEN_DAY_PCT")

# --------------------------------
# リセット時刻フォーマット
# --------------------------------
if [ -n "$FIVE_HOUR_RESET" ]; then
  FIVE_RESET_STR="Resets $(format_reset_time "$FIVE_HOUR_RESET")"
else
  FIVE_RESET_STR=""
fi

if [ -n "$SEVEN_DAY_RESET" ]; then
  SEVEN_RESET_STR="Resets $(format_reset_time "$SEVEN_DAY_RESET")"
else
  SEVEN_RESET_STR=""
fi

# --------------------------------
# 出力
# --------------------------------

# 1行目: モデル名 │ コンテキスト │ 行数 │ ブランチ
LINE1="${BOLD}🤖 ${MODEL_DISPLAY}${RESET}"
LINE1="${LINE1} ${GRAY}│${RESET} ${CTX_COLOR}📊 ${CTX_PCT}%${RESET}"
LINE1="${LINE1} ${GRAY}│${RESET} ✏️  +${LINES_ADDED}/-${LINES_REMOVED}"
LINE1="${LINE1} ${GRAY}│${RESET} 🔀 ${GIT_BRANCH}"

# 2行目: 5時間レートリミット
LINE2="⏱ 5h  ${FIVE_COLOR}${FIVE_BAR}  ${FIVE_HOUR_PCT}%${RESET}"
if [ -n "$FIVE_RESET_STR" ]; then
  LINE2="${LINE2}  ${FIVE_RESET_STR}"
fi

# 3行目: 7日間レートリミット
LINE3="📅 7d  ${SEVEN_COLOR}${SEVEN_BAR}  ${SEVEN_DAY_PCT}%${RESET}"
if [ -n "$SEVEN_RESET_STR" ]; then
  LINE3="${LINE3}  ${SEVEN_RESET_STR}"
fi

printf "%b\n" "$LINE1"
printf "%b\n" "$LINE2"
printf "%b\n" "$LINE3"
