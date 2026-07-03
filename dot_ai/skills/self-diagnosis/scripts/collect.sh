#!/bin/bash
# Claude Code の利用状況データを集計するスクリプト
# 使い方: collect.sh [日数]  （デフォルト: 30日）
set -euo pipefail

DAYS="${1:-30}"
CLAUDE_DIR="$HOME/.claude"

# macOS / GNU 両対応でカットオフ時刻（ミリ秒）を計算する
if date -v-1d +%s >/dev/null 2>&1; then
  CUTOFF_MS=$(( $(date -v-"${DAYS}"d +%s) * 1000 ))
  CUTOFF_DATE=$(date -v-"${DAYS}"d +%Y-%m-%d)
else
  CUTOFF_MS=$(( $(date -d "${DAYS} days ago" +%s) * 1000 ))
  CUTOFF_DATE=$(date -d "${DAYS} days ago" +%Y-%m-%d)
fi

echo "# Claude Code 利用状況（直近 ${DAYS} 日: ${CUTOFF_DATE} 以降）"

echo ""
echo "## 日次アクティビティ（stats-cache.json）"
if [ -f "$CLAUDE_DIR/stats-cache.json" ]; then
  jq -r --arg cutoff "$CUTOFF_DATE" '
    [.dailyActivity[] | select(.date >= $cutoff)] |
    "対象日数: \(length)日 / メッセージ: \(map(.messageCount) | add // 0) / セッション: \(map(.sessionCount) | add // 0) / ツール呼び出し: \(map(.toolCallCount) | add // 0)",
    "（最終集計日: 参照元の lastComputedDate を確認すること）"
  ' "$CLAUDE_DIR/stats-cache.json"
  jq -r '"lastComputedDate: \(.lastComputedDate)"' "$CLAUDE_DIR/stats-cache.json"
else
  echo "stats-cache.json が存在しない"
fi

echo ""
echo "## プロンプト数（history.jsonl・プロジェクト別）"
jq -r --argjson cutoff "$CUTOFF_MS" '
  select(.timestamp >= $cutoff) | .project // "unknown"
' "$CLAUDE_DIR/history.jsonl" | sed "s|$HOME|~|" | sort | uniq -c | sort -rn

echo ""
echo "## スラッシュコマンドの手動起動回数（history.jsonl）"
jq -r --argjson cutoff "$CUTOFF_MS" '
  select(.timestamp >= $cutoff) | .display | select(startswith("/")) | split(" ")[0]
' "$CLAUDE_DIR/history.jsonl" | sort | uniq -c | sort -rn

# 期間内に更新されたトランスクリプトを対象にする
TRANSCRIPTS=$(find "$CLAUDE_DIR/projects" -name "*.jsonl" -mtime -"${DAYS}" 2>/dev/null)
if [ -z "$TRANSCRIPTS" ]; then
  echo ""
  echo "（期間内のトランスクリプトが存在しないため以降の集計をスキップ）"
  exit 0
fi

echo ""
echo "## スキル起動回数（トランスクリプト・Skill ツール呼び出し）"
echo "$TRANSCRIPTS" | xargs grep -h '"name":"Skill"' 2>/dev/null |
  jq -r '.message.content[]? | select(.type == "tool_use" and .name == "Skill") | .input.skill' 2>/dev/null |
  sort | uniq -c | sort -rn

echo ""
echo "## サブエージェント起動回数（トランスクリプト・Agent/Task ツール呼び出し）"
echo "$TRANSCRIPTS" | xargs grep -hE '"name":"(Agent|Task)"' 2>/dev/null |
  jq -r '.message.content[]? | select(.type == "tool_use" and (.name == "Agent" or .name == "Task")) | .input.subagent_type // "general-purpose"' 2>/dev/null |
  sort | uniq -c | sort -rn

echo ""
echo "## モデル利用回数（トランスクリプト・assistant メッセージ）"
echo "$TRANSCRIPTS" | xargs grep -ho '"model":"[^"]*"' 2>/dev/null |
  sed 's/"model":"//; s/"$//' | grep -v '<synthetic>' | sort | uniq -c | sort -rn

echo ""
echo "## ツール使用の拒否回数（トランスクリプト）"
DENIALS=$(echo "$TRANSCRIPTS" | xargs grep -c "The user doesn't want to proceed with this tool use" 2>/dev/null | awk -F: '{s+=$NF} END {print s+0}')
echo "拒否回数: ${DENIALS}"
echo "※内訳を見るには該当行の前にある tool_use を確認すること"

echo ""
echo "## インストール済みスキル一覧（~/.claude/skills）"
ls "$CLAUDE_DIR/skills" 2>/dev/null
