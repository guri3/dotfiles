---
name: create-pr
description: 現状の作業ブランチのPull Request（PR）を作成する。
---

# Pull Request（PR）の作成

現状の作業ブランチのPRを作成する

## 事前確認

- `git status` で未コミットの変更がないか確認する
- 作業ブランチがリモートに push 済みか確認し、必要なら `git push -u origin <branch>` で push する

## ルール

- `gh pr create --draft`でドラフトPRを作成
- **【重要】`.github/PULL_REQUEST_TEMPLATE.md`などのテンプレートが存在する場合は必ず準拠すること**
  - テンプレートを読み取り、すべてのセクションを含める
  - 情報が足りないセクションは編集せずにそのまま残す
- テンプレートがない場合は `git log` と `git diff <base>...HEAD` で変更内容を確認し、簡潔な本文を書く
- ベースブランチは `gh repo view --json defaultBranchRef` でリポジトリのデフォルトブランチを確認して指定する
- Assignees は`@me`とする
- Labels は作業中を表すものを指定する
  - `gh label list`でラベル一覧を取得し、作業中を表すものが存在しない場合は付与しない
- PRのタイトルにprefixは不要
- 口調はなるべくいつものPRに寄せて

## 完了後

- 作成したPRのURLを出力する
