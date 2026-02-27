---
name: issue-to-pr
description: GitHubのIssue URLを受け取り、タスク分解・プロジェクト割り当て・実装計画作成・実装・PR作成まで一貫して行う。「このIssueを実装して」「IssueからPRを作って」「Issue #123に対応して」「このIssueを進めて」「GitHubのIssueを元に開発を進めて」といった指示で使う。Issue URLやIssue番号が提供されてIssue起点の開発ワークフローを進めたいときは必ずこのスキルを使う。
---

# Issue → PR ワークフロー

## 概要

GitHubのIssueを起点に、タスク分解・プロジェクト割り当て・実装計画・実装・PR作成まで一貫して行うワークフローである。各フェーズは独立したサブエージェントに移譲して実行する。

## 入力

- Issue URL（例: `https://github.com/owner/repo/issues/123`）

## 出力先ディレクトリ

すべての成果物は `.guri3/ai/<issue_number>_<issue_slug>/` に保存する。

- `issue_number`: Issueの番号（例: `123`）
- `issue_slug`: Issueタイトルを英数字小文字・ハイフンに変換したもの（例: `add-user-auth`）
- ディレクトリが存在しない場合は自動作成する
- `.guri3` ディレクトリが存在しない場合はシンボリックリンクを作成する: `ln -s $HOME/.guri3 .guri3`

## ワークフロー

### フェーズ1: Issue読み取りと分析

`gh` コマンドでIssueの詳細を取得し、内容を理解する。

```bash
gh issue view <issue_number> --repo <owner/repo> \
  --json number,title,body,labels,assignees,milestone,comments
```

取得した情報を元に以下を把握する。

- Issueの目的と解決したい課題
- 実装範囲と技術的な制約
- 各タスクの複雑度（サブIssueにすべきか、チェックリストで足りるか）

### フェーズ1.5: 複数リポジトリの検出（該当時のみ）

フェーズ1の分析中に以下のいずれかに該当した場合、複数リポジトリが必要と判断する。

- Issueの本文が複数リポジトリへの変更を明示している
- タスク分解の結果、変更対象が複数リポジトリにまたがる
- 依存ライブラリや共通コンポーネントのリポジトリ変更が必要

複数リポジトリが必要と判明した場合は、以降のフェーズで以下の方針に従う。

**依存順序の決定**:

他のリポジトリから参照される側（ライブラリ、共通コンポーネント等）を先に実装する。依存関係をグラフ化してユーザーに確認し、実装順序を合意してから進む。

**出力先の整理**:

計画書はリポジトリごとにサブディレクトリを作成して管理する。

```
.guri3/ai/<issue_number>_<issue_slug>/
  repo-a/
    01_preliminary-research.md
    02_specification.md
    03_detailed-design.md
  repo-b/
    01_preliminary-research.md
    02_specification.md
    03_detailed-design.md
```

**ブランチ戦略**:

各リポジトリで同一名のブランチを作成する。

```bash
# 各リポジトリで実行
git checkout -b issue-<issue_number>-<issue_slug>
```

**PR間の連携**:

PRの本文に依存するPRへの参照を記述し、レビュアーが関連PRを把握できるようにする。

```
## 関連PR
- 依存: <repo-a> <PR URL>（先にマージが必要）
- 関連: <repo-b> <PR URL>
```

単一リポジトリの場合はこのフェーズをスキップして、そのままフェーズ2へ進む。

### フェーズ2: タスク分解

Issueの内容を具体的なタスクに分解し、粒度に応じて2種類の形式で管理する。

**粒度の判断基準**:

- **サブIssue（大きなタスク）**: 独立した機能単位、複数ファイルにまたがる変更、別途設計が必要な作業
- **チェックリスト（小さなタスク）**: 単一ファイルの変更、明確で原子的な作業項目、数時間以内で完了できる作業

**サブIssueの作成**:

```bash
gh issue create \
  --repo <owner/repo> \
  --title "<サブタスクのタイトル>" \
  --body "Parent: #<parent_issue_number>\n\n<詳細説明>"
```

**元のIssueへのタスク分解コメントの投稿**:

タスク分解の結果を元のIssueにコメントとして投稿する。サブIssueとチェックリストの両方をまとめて記述する。

```bash
gh issue comment <issue_number> --repo <owner/repo> \
  --body "## タスク分解\n\n### サブIssue\n- [ ] #<sub_issue_number> <タイトル>\n\n### チェックリスト\n- [ ] <タスク1>\n- [ ] <タスク2>"
```

### フェーズ3: GitHubプロジェクトへの割り当て

IssueをGitHubプロジェクトに追加する。

**プロジェクト一覧の取得**:

```bash
gh project list --owner @me
gh project list --owner <org_name>
```

プロジェクトが複数存在する場合はユーザーに選択を求める。プロジェクトが特定できたらIssueを追加する。

```bash
gh project item-add <project_number> --owner <owner> --url <issue_url>
```

### フェーズ4: 実装計画の作成

**サブエージェント**: `preliminary-research` → `specification` → `detailed-design`（順次実行）

出力先ディレクトリ: `.guri3/ai/<issue_number>_<issue_slug>/`

#### ステップ4-1: 事前調査

- `preliminary-research` サブエージェントを呼び出す
- Issue内容・リポジトリのコードベース・技術スタックを調査させる
- 出力先パスを `.guri3/ai/<issue_number>_<issue_slug>/01_preliminary-research.md` として伝える
- ファイルの生成を確認してから次のステップに進む

#### ステップ4-2: 仕様書作成

- `specification` サブエージェントを呼び出す
- 事前調査の結果（`01_preliminary-research.md`）を渡す
- 出力先パスを `.guri3/ai/<issue_number>_<issue_slug>/02_specification.md` として伝える
- ファイルの生成を確認してから次のステップに進む

#### ステップ4-3: 詳細設計書作成

- `detailed-design` サブエージェントを呼び出す
- 仕様書（`02_specification.md`）を渡す
- 出力先パスを `.guri3/ai/<issue_number>_<issue_slug>/03_detailed-design.md` として伝える
- ファイルの生成を確認してから次のステップに進む

### フェーズ5: ユーザーによる計画の確認・承認

3つの計画書が生成されたらユーザーに確認を求める。

```
実装計画書を生成しました。

- .guri3/ai/<dir>/01_preliminary-research.md（事前調査）
- .guri3/ai/<dir>/02_specification.md（仕様書）
- .guri3/ai/<dir>/03_detailed-design.md（詳細設計書）

内容をご確認ください。問題なければ実装を開始します。
修正が必要な場合はその旨をお伝えください。
```

**ユーザーの承認なしに実装フェーズへ進まないこと。**

### フェーズ6: 実装

ユーザーの承認後、実装を進める。各サブタスクは独立したサブエージェントに移譲する。

#### ステップ6-1: ブランチ作成

```bash
git checkout -b issue-<issue_number>-<issue_slug>
```

#### ステップ6-2: TDD実装

**サブエージェント**: `tdd-implementer`

- `tdd-implementer` サブエージェントを呼び出す
- 詳細設計書（`03_detailed-design.md`）の内容を渡す
- TDDサイクル（テスト作成 → 実行 → 実装 → リファクタリング）で進める

#### ステップ6-3: テスト品質チェック

**サブエージェント**: `test-quality-checker`

- `test-quality-checker` サブエージェントを呼び出す
- テストファイルと実装コードを渡す
- 指摘事項があれば修正する

#### ステップ6-4: コードレビュー

**サブエージェント**: `code-reviewer`

- `code-reviewer` サブエージェントを呼び出す
- 変更されたファイルを渡す
- 重大な問題があれば修正する

### フェーズ7: PR作成

`create-pr` スキルと同じ手順でPRを作成する。

**事前確認**:

```bash
git status
git push -u origin <branch>
```

**PR作成**:

```bash
gh pr create --draft \
  --title "<PRタイトル>" \
  --body "..." \
  --base <default_branch> \
  --assignee @me
```

- `.github/PULL_REQUEST_TEMPLATE.md` が存在する場合は必ず準拠する
- PRの本文に `Closes #<issue_number>` を含めてIssueと紐付ける
- ベースブランチは `gh repo view --json defaultBranchRef` で確認する
- 作業中を表すラベルがあれば付与する（`gh label list` で確認）

完了後、作成したPRのURLを出力する。

## 重要な原則

### 順次実行

- 各フェーズは前のフェーズが完了してから実行する
- 計画書の生成は `preliminary-research` → `specification` → `detailed-design` の順を守る

### ユーザーとの協調

- フェーズ5の計画承認は必ずユーザーに確認を取る
- プロジェクトの選択など判断が必要な場面ではユーザーに確認する
- 計画に修正が入った場合は修正後に再度承認を求める

### エラーハンドリング

- `gh` コマンドが失敗した場合はエラー内容をユーザーに伝えて対処を求める
- 認証エラーの場合は `gh auth status` で状態確認を促す
- ブランチが既に存在する場合は確認してから処理を継続する

### ドキュメントの品質

- すべてのドキュメントはAGENTS.mdのドキュメント哲学に従う
- ファイル末尾に改行を含める
