#!/bin/bash
#
# VS Code / Cursor 共通の設定ファイルをエディタのUserディレクトリへ配置する。
# エディタ固有の設定ファイルが存在する場合は、共通設定へ上書きマージする。
#
# 使い方: editor-settings.sh <エディタ固有設定ディレクトリ> <配置先Userディレクトリ>

set -euo pipefail

if [ $# -ne 2 ]; then
  echo "使い方: $(basename "$0") <エディタ固有設定ディレクトリ> <配置先Userディレクトリ>" >&2
  exit 1
fi

overlay_dir="$1"
user_dir="$2"
shared_dir="$(cd "$(dirname "$0")/.." && pwd)/dot_editor"

# jqはJSONCを読めないため、行頭の//コメント行を除去してから渡す
strip_jsonc() {
  sed -e 's|^[[:space:]]*//.*$||' "$1"
}

mkdir -p "$user_dir"

for name in settings.json keybindings.json; do
  shared="$shared_dir/$name"
  overlay="$overlay_dir/$name"
  dest="$user_dir/$name"

  # エディタ自身が設定ファイルを書き換えるため、symlinkではなく実体を置く
  rm -f "$dest"

  if [ ! -f "$overlay" ]; then
    cp "$shared" "$dest"
    continue
  fi

  case "$name" in
    # オブジェクトのため再帰的に上書きマージする
    settings.json)
      jq -s 'reduce .[] as $o ({}; . * $o)' \
        <(strip_jsonc "$shared") <(strip_jsonc "$overlay") > "$dest"
      ;;
    # 配列のため連結する。後に置いたエディタ固有の定義が優先される
    keybindings.json)
      jq -s 'add' \
        <(strip_jsonc "$shared") <(strip_jsonc "$overlay") > "$dest"
      ;;
  esac
done
