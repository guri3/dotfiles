---
name: ci-watch.work
description: GitHub ActionsのCIワークフローを監視し、完了したら結果を報告するスキル。「CI見て」「CI監視して」「ワークフロー見て」「ci watch」「CIの結果教えて」「CI通ったか確認して」「pushしたからCI見といて」「デプロイの状況教えて」といった指示で積極的に使用すること。CIやGitHub Actionsに関する監視・結果確認の文脈であれば幅広く対応する。
---

# ci-watch.work

## 目的

GitHub Actions のワークフロー実行を監視し、完了したら成否・所要時間・失敗時のログ抜粋をまとめて報告するスキルである。
push 直後の CI 結果を待つ作業を自動化することで、ユーザーが他の作業に集中できる状態をつくる。

## 使うタイミング

- 「CI 見て」「CI 監視して」「ワークフロー見て」「ci watch」と言われたとき
- 「CI の結果教えて」「CI 通ったか確認して」と聞かれたとき
- 「push したから CI 見といて」「デプロイの状況教えて」のような依頼があったとき
- PR を作成・更新した直後にチェックの通過確認が必要なとき

## 手順

1. 監視対象を特定する
    - 明示指定（PR 番号 / run ID / commit SHA）があればそれを使う
    - 指定がなければ現在のブランチと最新コミット SHA を取得する
        - `git rev-parse --abbrev-ref HEAD`
        - `git rev-parse HEAD`
2. 該当する run を列挙する
    - ブランチから: `gh run list -b <branch> --limit 5`
    - コミットから: `gh run list --commit <SHA>`
    - PR から: `gh pr checks <pr>` で必須チェック一覧を確認する
3. 候補が複数ある場合は最新の run を採用する。判断に迷うときはユーザーに確認する
4. run が `in_progress` / `queued` の場合は完了まで待つ
    - 基本は `gh run watch <run-id> --exit-status` でブロッキング監視する
    - 長時間に及ぶ場合や非ブロッキングで進めたい場合は、`gh run view <run-id> --json status,conclusion` をポーリングする
5. 完了後に結果を報告する
    - `conclusion`（success / failure / cancelled / skipped）
    - 開始〜終了時刻と所要時間
    - 失敗時は失敗ジョブ名と失敗ログ抜粋
        - `gh run view <run-id> --log-failed | head -n 50`
6. 複数のワークフローが走っていた場合は、それぞれの結果を 1 行ずつまとめて報告する

## 注意

- 同一ブランチで複数の最近の run がある場合は最新を選ぶ。意図と異なる可能性があれば確認する
- PR の文脈ではすべてのワークフローではなく必須チェック（`gh pr checks`）を優先して見るほうがノイズが少ない
- 失敗したワークフローを再実行（`gh run rerun`）するのは本スキルの責務ではない。あくまで監視と報告までに留める
- ログ抜粋は長くなりがちなので `head` などで適度に切り詰める
- ワークフローが見つからない場合（push が反映されていない / Actions 無効など）は、その旨を素直に報告する
