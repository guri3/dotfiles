#!/bin/bash
#
# VS Code / Cursor 共通の拡張機能一覧をインストールする。
# エディタ固有設定ディレクトリに以下のファイルがあれば反映する。
#   extensions.txt          このエディタにのみ追加でインストールする拡張機能
#   extensions-exclude.txt  このエディタにはインストールしない拡張機能
#
# 使い方: editor-extensions.sh <エディタのCLI名> <エディタ固有設定ディレクトリ>

set -uo pipefail

if [ $# -ne 2 ]; then
  echo "使い方: $(basename "$0") <エディタのCLI名> <エディタ固有設定ディレクトリ>" >&2
  exit 1
fi

cli="$1"
overlay_dir="$2"
shared_dir="$(cd "$(dirname "$0")/.." && pwd)/dot_editor"

if ! command -v "$cli" >/dev/null 2>&1; then
  echo "$cli コマンドが見つからない。エディタの導入とCLIの有効化を済ませてから再実行すること" >&2
  exit 1
fi

# コメントと空行を除いた拡張機能IDのみを出力する
read_list() {
  [ -f "$1" ] || return 0
  sed -e 's/#.*$//' -e 's/[[:space:]]//g' "$1" | grep -v '^$'
  return 0
}

targets="$(
  { read_list "$shared_dir/extensions.txt"; read_list "$overlay_dir/extensions.txt"; } | sort -u
)"

exclude="$overlay_dir/extensions-exclude.txt"
if [ -f "$exclude" ]; then
  excluded="$(read_list "$exclude")"
  if [ -n "$excluded" ]; then
    targets="$(printf '%s\n' "$targets" | grep -vxF "$excluded")"
  fi
fi

failed=()
while read -r ext; do
  [ -n "$ext" ] || continue
  "$cli" --install-extension "$ext" || failed+=("$ext")
done <<< "$targets"

if [ ${#failed[@]} -gt 0 ]; then
  echo "インストールに失敗した拡張機能: ${failed[*]}" >&2
  echo "エディタ側で利用できない拡張機能であれば $overlay_dir/extensions-exclude.txt へ追記すること" >&2
  exit 1
fi
