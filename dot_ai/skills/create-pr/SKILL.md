---
name: create-pr
description: 現状の作業ブランチのPull Request（PR）を作成する。
model: sonnet
---

# Pull Request（PR）の作成

現状の作業ブランチのPRを作成する

## 事前確認

- `git status` で未コミットの変更がないか確認する
- 作業ブランチの push 状態を `git branch -vv` で確認する
  - 未 tracking（upstream なし）の場合は `git push -u origin <branch>`
  - tracking 済みで ahead がある場合は `git push`
  - tracking 済みで ahead なしの場合は push 不要

## ルール

- `gh pr create --draft`でドラフトPRを作成
- **【重要】`.github/PULL_REQUEST_TEMPLATE.md`などのテンプレートが存在する場合は必ず準拠すること**
  - テンプレートを読み取り、すべてのセクションを含める
  - 各セクションは `git log` と `git diff <base>...HEAD` から読み取れる情報で記入する
  - 読み取れない情報しか無いセクションは **本文を追記しない**
    - テンプレート内の `<!-- ... -->` コメントはそのまま残す
    - チェックボックス（`- [ ]`）もそのまま残す
- テンプレートがない場合は `git log` と `git diff <base>...HEAD` で変更内容を確認し、簡潔な本文を書く
  - 章立ては作らず、`## 概要` に変更内容を箇条書きでまとめるだけで良い
- ベースブランチは `gh repo view --json defaultBranchRef` でリポジトリのデフォルトブランチを確認して `--base` で明示指定する
- `--head` も現在のブランチ名を明示指定する（誤爆防止）
- Assignees は`--assignee @me`で指定する
- Labels は作業中を表すものを指定する
  - `gh label list`でラベル一覧を取得し、`作業中` / `WIP` / `in-progress` 等に該当するものがあれば `--label` で付与、なければ付与しない
- PRのタイトルにprefixは不要
  - コミットメッセージに `feat:` / `fix:` 等のプレフィックスがあっても、PRタイトルからは外す
  - タイトルは代表的なコミットメッセージから prefix を除いたものを基本とし、複数コミットが別機能の場合は総括した文言にする
- 口調は直近マージ済みPRに寄せる
  - `gh pr list --state merged --limit 5 --json title,body` で直近5件を取得
  - タイトル・本文ともに、そこで使われている **最頻出の文体** （である調 / ですます調 / 体言止め / 常体 等）に合わせる
  - 参照できるPRが無い場合は常体（である調）で統一する

## 本文の渡し方

- 本文は `--body` に改行を含むダブルクォート文字列で直接渡す
  - 例: `gh pr create --draft --base master --head feat-x --assignee @me --title "..." --body "## 概要

- 変更点1
- 変更点2

## 背景・目的

<!-- なぜこの変更が必要か -->
"`
  - 日本語、`<!-- -->` コメント、`- [ ]` チェックボックスはそのまま含めて良い
- ヒアドキュメント（`$(cat <<'EOF' ... EOF)`）や `--body-file` は使わない。`--body` に直接渡すこと

## 完了後

- 作成したPRのURLを出力する
