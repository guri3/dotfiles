#!/bin/bash
# 呟き駆動の日報生成のために、対象日1日分のデータを収集するスクリプト
# 使い方: collect.sh [対象日 YYYY-MM-DD]  （省略時は今日・ローカルタイム=JST）
# 出力: == TWEETS == / == PROMPTS == / == SESSIONS == の3セクションを stdout へ
#
# エラーで途中終了しないよう set -e は使わない。各セクションを可能な範囲で出力する。

CLAUDE_DIR="$HOME/.claude"
GURI_DIR="$HOME/.guri3"

# 対象日（省略時は今日・ローカルタイム）
TARGET="${1:-$(date +%Y-%m-%d)}"

# 対象日を各種フォーマットへ変換する（macOS の date を利用）
YMD=$(date -j -f %Y-%m-%d "$TARGET" +%Y%m%d 2>/dev/null)
NEXT=$(date -j -v+1d -f %Y-%m-%d "$TARGET" +%Y-%m-%d 2>/dev/null)
if [ -z "$YMD" ] || [ -z "$NEXT" ]; then
  echo "対象日の解釈に失敗した: '$TARGET'（YYYY-MM-DD 形式で指定すること）" >&2
  exit 1
fi

echo "# 日報データ収集: ${TARGET}（翌日境界: ${NEXT}・PROMPTS/TWEETS は JST、SESSIONS の timestamp は UTC）"

# == TWEETS ==
# 呟きログ（UserPromptSubmit hook が蓄積する tweets.jsonl）をそのまま出力する
echo ""
echo "== TWEETS =="
TWEETS_FILE="$GURI_DIR/ai/${YMD}_nippo/tweets.jsonl"
if [ -f "$TWEETS_FILE" ]; then
  cat "$TWEETS_FILE" 2>/dev/null || echo "(failed to read tweets)"
else
  echo "(no tweets)"
fi

# == PROMPTS ==
# history.jsonl から対象日ローカル 00:00〜翌日 00:00 のエントリを抽出する
# 出力列: HH:MM<TAB>project末尾ディレクトリ名<TAB>sessionId先頭8文字<TAB>display(改行を空白化・200文字まで)
echo ""
echo "== PROMPTS =="
if [ -f "$CLAUDE_DIR/history.jsonl" ]; then
  python3 - "$TARGET" "$CLAUDE_DIR/history.jsonl" <<'PY' 2>/dev/null || echo "(failed to parse prompts)"
import json, sys, datetime

target, path = sys.argv[1], sys.argv[2]
d = datetime.date.fromisoformat(target)
# ローカルタイム（システム TZ = JST 前提）の当日 00:00 と翌日 00:00 を epoch ミリ秒へ
start_ms = int(datetime.datetime.combine(d, datetime.time.min).timestamp() * 1000)
end_ms = int(datetime.datetime.combine(d + datetime.timedelta(days=1), datetime.time.min).timestamp() * 1000)

rows = []
with open(path) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            e = json.loads(line)
        except Exception:
            continue
        ts = e.get("timestamp", 0)
        if not isinstance(ts, (int, float)) or not (start_ms <= ts < end_ms):
            continue
        local = datetime.datetime.fromtimestamp(ts / 1000)
        hhmm = local.strftime("%H:%M")
        proj = (e.get("project") or "").rstrip("/").split("/")[-1] or "-"
        sid = (e.get("sessionId") or "")[:8] or "-"
        disp = (e.get("display") or "").replace("\n", " ").replace("\r", " ").replace("\t", " ")[:200]
        rows.append((ts, "%s\t%s\t%s\t%s" % (hhmm, proj, sid, disp)))

rows.sort(key=lambda r: r[0])
if rows:
    for _, r in rows:
        print(r)
else:
    print("(no prompts)")
PY
else
  echo "(no history.jsonl)"
fi

# == SESSIONS ==
# 当日更新の主セッション（agent-* を除外）を列挙する
# 各ファイルの列: 最初のtimestamp<TAB>最後のtimestamp<TAB>sessionId先頭8文字<TAB>cwd<TAB>最後のaiTitle(無ければ -)
# timestamp は UTC のまま。開始時刻順にソート。
echo ""
echo "== SESSIONS == (timestamp は UTC)"
# ヒアドキュメントが stdin を専有するため、ファイル一覧は一時ファイル経由で python へ渡す
FILELIST=$(mktemp 2>/dev/null || echo "/tmp/nippo_sessions.$$")
find "$CLAUDE_DIR/projects" -name "*.jsonl" ! -name "agent-*" -newermt "${TARGET} 00:00:00" ! -newermt "${NEXT} 00:00:00" > "$FILELIST" 2>/dev/null
if [ ! -s "$FILELIST" ]; then
  echo "(no sessions)"
else
  python3 - "$FILELIST" <<'PY' 2>/dev/null || echo "(failed to parse sessions)"
import json, sys, os

with open(sys.argv[1]) as fl:
    paths = fl.read().splitlines()

rows = []
for path in paths:
    path = path.strip()
    if not path:
        continue
    first = None
    last = None
    title = "-"
    cwd = "-"
    try:
        with open(path) as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    e = json.loads(line)
                except Exception:
                    continue
                ts = e.get("timestamp")
                if isinstance(ts, str) and ts:
                    if first is None or ts < first:
                        first = ts
                    if last is None or ts > last:
                        last = ts
                if e.get("type") == "ai-title":
                    at = e.get("aiTitle")
                    if at:
                        title = at
                elif cwd == "-":
                    c = e.get("cwd")
                    if c:
                        cwd = c
    except Exception:
        continue
    # sessionId はファイル名（.jsonl を除いた部分）から取るのが最も確実
    sid = os.path.basename(path)[:-6][:8] if path.endswith(".jsonl") else os.path.basename(path)[:8]
    title = title.replace("\n", " ").replace("\r", " ").replace("\t", " ")
    rows.append((first or "", "%s\t%s\t%s\t%s\t%s" % (first or "-", last or "-", sid, cwd, title)))

rows.sort(key=lambda r: r[0])
for _, r in rows:
    print(r)
PY
fi
rm -f "$FILELIST" 2>/dev/null
