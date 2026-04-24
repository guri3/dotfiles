---
name: solve
description: Issueやユーザーの要望を受け取り、調査・計画・設計・実装・レビューまでの全フェーズを一貫して進めるスキル。「この問題を解決して」「〜を実装して」「〜を修正して」「〜を追加して」「このIssueに対応して」といった指示で使う。各フェーズでユーザーの確認を得ながら進むため、意図と外れた実装になるリスクを最小化する。Issue URLが提供された場合はGitHub連携も行う。
---

# 問題解決ワークフロー（solve）

## 概要

Issueやユーザーの要望を起点に、事前調査→計画→設計→実装→レビューの全フェーズを一貫して進める。計画フェーズと設計フェーズのそれぞれでユーザーの承認を得てから次に進むことで、手戻りを防ぐ。

## 入力

以下のいずれか:

- GitHub Issue URL（例: `https://github.com/owner/repo/issues/123`）
- ユーザーの要望・問題説明（自然言語）

## 出力先ディレクトリ

すべての成果物は `.guri3/ai/<作業名>/` に保存する。

- Issue起点の場合: `.guri3/ai/<yyyyMMdd>_<issue_number>_<issue_slug>/`
- 要望起点の場合: `.guri3/ai/<yyyyMMdd>_<作業スラッグ>/`
- `<yyyyMMdd>` は作業開始日の日付（例: `20260305`）
- ディレクトリが存在しない場合は自動作成する
- `.guri3` ディレクトリが存在しない場合はシンボリックリンクを作成する: `ln -s $HOME/.guri3 .guri3`

## ワークフロー

### 作業開始時の準備

各フェーズに入る前に、ワークフロー全体で使う値を確定させる。

#### 1. Issue 情報の取得（Issue 起点の場合）

Issue URL から情報を取得する。

```bash
# URL から owner / repo / issue_number を抽出（例: https://github.com/OWNER/REPO/issues/123）
issue_url="<ISSUE_URL>"
owner=$(echo "$issue_url" | awk -F/ '{print $4}')
repo=$(echo "$issue_url" | awk -F/ '{print $5}')
issue_number=$(echo "$issue_url" | awk -F/ '{print $7}')

# Issue 本文・コメントを取得
gh issue view "$issue_url" --json number,title,body,url,comments
```

取得した `owner` / `repo` / `issue_number` / `issue_title` / `issue_body` を以降のフェーズで使う。

#### 2. 作業名の決定

`<yyyyMMdd>_<identifier>_<slug>` 形式で決める。

- `<yyyyMMdd>`: 作業開始日（例: `20260424`）
- `<identifier>`: Issue 起点なら `<issue_number>`、要望起点なら省略
- `<slug>`: 英小文字・数字・`-` 区切りの 3〜5 語程度。Issue タイトルまたはユーザー要望の要点を英語化する。日本語・`/`・スペースを含めない
- 例: `20260424_123_add-user-auth`, `20260424_refactor-login-flow`

決定した作業名は以降のフェーズで同じ値を参照する。

#### 3. 作業ディレクトリ作成

```bash
# .guri3 が無ければシンボリックリンクを作成
[ -e .guri3 ] || ln -s $HOME/.guri3 .guri3
work_name="<決定した作業名>"   # 例: 20260424_123_add-user-auth
work_dir=".guri3/ai/$work_name"
mkdir -p "$work_dir"
```

#### 4. デフォルトブランチの取得

```bash
default_branch=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
```

以降のフェーズでは `$owner` / `$repo` / `$issue_number` / `$work_dir` / `$default_branch` を変数として参照する。ドキュメント本文中の `<作業名>` は `$work_name`（= `$work_dir` の末尾）に対応する。

### フェーズ1: 問題の把握と事前調査 → plan.md作成

**サブエージェント**: `planner`

`planner` サブエージェントに以下を渡す。

- **出力先**: `.guri3/ai/<作業名>/plan.md`（絶対パスで渡す）
- **Issue 起点の場合**: Issue URL、および `gh issue view <ISSUE_URL> --comments` で取得した Issue 本文・コメント全文
- **要望起点の場合**: ユーザーの要望文（発話全文）

サブエージェントが `.guri3/ai/<作業名>/plan.md` を生成するまで待ち、生成されたことを確認する。生成失敗時の扱いは「エラーハンドリング」節を参照。

### フェーズ2: plan.mdのレビュー依頼

plan.mdが生成されたらユーザーに確認を求める。

```
解決計画（plan.md）を作成しました。

ファイル: .guri3/ai/<作業名>/plan.md

解決方針の選択肢を複数提示しています。どの案で進めるかご選択ください。
修正や追加の案が必要な場合はその旨をお伝えください。
```

**ユーザーの承認なしに次フェーズへ進まないこと。**

ユーザーの承認が得られたら、Issue起点の場合はplan.mdの内容をIssueにコメントとして投稿する:

```bash
plan_comment_url=$(gh api "repos/$owner/$repo/issues/$issue_number/comments" \
  --method POST \
  --field body="$(cat "$work_dir/plan.md")" | jq -r '.html_url')
echo "計画コメントURL: $plan_comment_url"
```

### フェーズ3: 詳細設計 → design.md作成

**サブエージェント**: `system-designer`

`system-designer` サブエージェントに以下を渡す。

- **plan.md の絶対パス**: `.guri3/ai/<作業名>/plan.md`
- **出力先**: `.guri3/ai/<作業名>/design.md`（絶対パス）
- **ユーザーが選択した案の識別子**: plan.md 内の案番号または見出し（例: `案2: ミドルウェアで対応`）
- **ユーザーからの追加フィードバック**: 選択時に出た修正要望があればそのまま渡す

サブエージェントが `.guri3/ai/<作業名>/design.md` を生成するまで待ち、生成されたことを確認する。生成失敗時の扱いは「エラーハンドリング」節を参照。

### フェーズ4: design.mdのレビュー依頼

design.mdが生成されたらユーザーに確認を求める。

```
詳細設計（design.md）を作成しました。

ファイル: .guri3/ai/<作業名>/design.md

内容をご確認ください。問題なければ実装を開始します。
修正が必要な場合はその旨をお伝えください。
```

**ユーザーの承認なしに次フェーズへ進まないこと。**

ユーザーの承認が得られたら、Issue起点の場合はdesign.mdの内容をIssueにコメントとして投稿する:

```bash
design_comment_url=$(gh api "repos/$owner/$repo/issues/$issue_number/comments" \
  --method POST \
  --field body="$(cat "$work_dir/design.md")" | jq -r '.html_url')
echo "設計コメントURL: $design_comment_url"
```

### フェーズ5: 実装開始（ブランチ・空コミット・Draft PR）

design.mdの承認後、PR分割方針に従ってブランチを作成し、空コミットとDraft PRで実装の意図を宣言する。

**PR 数とベースブランチの決定**:

- **PR 数**: design.md の「PR 分割」セクションに記載された数に従う。記載がない場合は 1 PR として扱う
- **独立 PR（依存なし）のベース**: `$default_branch`
- **stacked PR（依存あり）のベース**: design.md の依存 DAG に書かれた依存元ブランチ名

**ブランチ命名規則**:

- 区切り文字は `-`（`/` を使わない）。例: `feat-add-auth`、`fix-login-redirect`
- プレフィックス（`feat`、`fix`、`refactor` など）は PR の種類に合わせる
- 作業名スラッグと同じ形式（英小文字・数字・`-`）

**PRが1つの場合**:

```bash
# ブランチ作成
git checkout -b <ブランチ名>

# 空コミットとPush
git commit --allow-empty -m "作業開始: <実装内容の簡潔な説明>"
git push -u origin <ブランチ名>

# Draft PR作成
gh pr create --draft \
  --title "<PRタイトル>" \
  --body "..." \
  --base <default_branch> \
  --assignee @me
```

**PRが複数の場合（並行実装あり）**:

各PRに対してworktreeを作成し、独立した作業ディレクトリで並行実装できるようにする。

```bash
# 並行実装するPRごとにworktreeを作成
git worktree add ../<リポジトリ名>-<ブランチ名> -b <ブランチ名>

# 各worktreeで空コミットとPush
cd ../<リポジトリ名>-<ブランチ名>
git commit --allow-empty -m "作業開始: <PR内容の説明>"
git push -u origin <ブランチ名>

# Draft PR作成（各ブランチ）
gh pr create --draft \
  --title "<PRタイトル>" \
  --body "..." \
  --base <依存するブランチ or default_branch> \
  --assignee @me
```

**PR 作成時の共通ルール**:

- `.github/PULL_REQUEST_TEMPLATE.md` が存在する場合は必ずそのテンプレートに準拠する
- Issue 起点で最終的に Issue をクローズする PR には `Closes #<issue_number>` を含める

### フェーズ6: TDD実装

design.mdのPR依存関係に従い、並行実装できるものはサブエージェントを同時に起動して実装する。

**並行実装できるPRがある場合**:

- 各worktreeに対して独立した `implementer` サブエージェントを同時に起動する

**直列実装が必要なPRがある場合**:

- 依存先のPRの実装が完了してから次のPRのサブエージェントを起動する

**各 `implementer` サブエージェントに渡す情報**:

- **design.md の絶対パス**: `.guri3/ai/<作業名>/design.md`
- **担当 PR の識別子**: design.md の PR 分割セクション内の PR 番号または見出し（例: `PR 2: API 層の実装`）
- **worktree の絶対パス**: 並行実装のとき（例: `/Users/.../repo-feat-add-auth`）。単一 PR でメインディレクトリ作業の場合はリポジトリルートのパス
- **ブランチ名 / ベースブランチ**: そのPRが push するブランチと、PR のベースブランチ（default_branch か 依存元ブランチ）
- **テスト実行コマンド**: プロジェクトのテストコマンド（例: `npm test`、`go test ./...`）。親側で README / package.json / Makefile などから特定して渡す。特定できない場合は推測せずユーザーに確認する
- **CI の有無**: `.github/workflows/` の存在を確認し、存在すれば CI 結果も取り込むよう指示する

**TDDサイクル**:

1. テストを先に書く（Red）
2. テストを通す最小限の実装をする（Green）
3. コードを整理する（Refactor）

### フェーズ7: セルフレビュー

実装が完了したら、以下の2つのサブエージェントでレビューを実施する。

**サブエージェント**: `test-checker`、`reviewer`（順次実行）

#### ステップ7-1: テスト品質チェック

`test-checker` サブエージェントに以下を渡す。

- **worktree の絶対パス**（単一 PR の場合はリポジトリルート）
- **変更ファイル一覧**: `git diff --name-only <base_branch>...HEAD` で取得
- **テストファイルと実装コードの対応**: 上記一覧から `*_test.*` / `*.test.*` / `*.spec.*` などを抽出
- **design.md の絶対パス**: テスト方針の参照のため

指摘事項があれば修正する。

#### ステップ7-2: コードレビュー

`reviewer` サブエージェントに以下を渡す。

- **worktree の絶対パス**
- **変更ファイル一覧**: `git diff --name-only <base_branch>...HEAD`
- **差分本体**: `git diff <base_branch>...HEAD`（大規模なら代替で変更ファイル一覧のみ）
- **PR URL**（作成済みのDraft PR）
- **design.md の絶対パス**

- 重大な問題（必須修正）は必ず修正する
- 修正後に再度 `reviewer` を呼び出して確認する
- 設計の根本的な見直しが必要な場合はユーザーに相談する

### フェーズ8: ユーザーへのレビュー依頼

一通りの実装とセルフレビューが完了したら、ユーザーにレビューを依頼する。

```
実装が完了しました。レビューをお願いします。

## 実装内容
- <変更点1>
- <変更点2>

## テスト状況
- <テストの実行結果>

## PR
<PR URL>

## 確認してほしい点
- <特に確認してほしいポイント>
```

### フェーズ9: フィードバック作成

**サブエージェント**: `feedback`

フェーズ9 の目的はワークフロー自体の改善点を記録することであり、ユーザーの実装レビュー応答とは独立した作業である。そのためフェーズ8 のレビュー依頼メッセージを送信した **直後** に `feedback` サブエージェントを呼び出す（ユーザーのレビュー応答は待たない）。以下の情報を渡す。

- **出力先**: `.guri3/ai/<作業名>/feedback.md`（絶対パス）
- **plan.md の絶対パス**: `.guri3/ai/<作業名>/plan.md`
- **design.md の絶対パス**: `.guri3/ai/<作業名>/design.md`
- **PR URL**: フェーズ8 で共有した PR（複数あれば全て）
- **問題・Issue 概要**: Issue URL または要望の要点

サブエージェントが `.guri3/ai/<作業名>/feedback.md` を生成するまで待ち、生成されたことをユーザーに通知する。

```
フィードバックを作成しました。

ファイル: .guri3/ai/<作業名>/feedback.md

ワークフローへの改善提案をまとめています。
```

## 重要な原則

### ユーザーとの協調

- plan.mdとdesign.mdはそれぞれユーザーの承認を得てから次フェーズへ進む
- 修正依頼があった場合は修正後に再度確認を求める
- 設計の根本的な問題に気づいた場合は実装を止めてユーザーに相談する

### Issue起点の場合のGitHub連携

- plan.md・design.mdはユーザーの承認後にIssueコメントとして投稿する
- 承認前に投稿しない

### 実装の品質

- 過剰な実装をしない。要求されていない機能は追加しない
- セルフレビューは形式的に行うのではなく、実際に問題を見つける意識で行う
- テストはTDDで先に書くことを守る

### エラーハンドリング

- `gh` コマンドが失敗した場合はエラー内容をユーザーに伝えて対処を求める
- ブランチが既に存在する場合はユーザーに確認してから処理を継続する
- テストやCIが失敗した場合は原因を調査して修正する。同じ失敗を繰り返さない
- **サブエージェントの成果物不達**: 以下の「期待した成果物」が得られない、または内容が明らかに不完全（空・必須セクション欠落・コード差分なし・レビュー指摘が未生成など）な場合は、同じサブエージェントを **1 回だけ再実行** する。再実行でも失敗したらユーザーに状況を報告してエスカレーションする
  - `planner`: `plan.md`
  - `system-designer`: `design.md`
  - `implementer`: 担当 PR のコード差分・テスト・コミット
  - `test-checker`: テスト品質レビューの指摘事項（問題なしの判定を含む）
  - `reviewer`: コードレビューの指摘事項（問題なしの判定を含む）
  - `feedback`: `feedback.md`

### ドキュメントの品質

- すべてのドキュメントはAGENTS.mdのドキュメント哲学に従う（「だ。」「である。」調）
- ファイル末尾に改行を含める
