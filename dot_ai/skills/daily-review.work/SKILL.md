---
name: daily-review.work
description: GitHub、Slack、Claude Codeなどの活動履歴から今日1日の仕事を振り返るスキル。「振り返り」「日報」「今日何した」「daily review」「1日のまとめ」「KPT」「ふりかえり」といった指示で使う。終業時や日次の振り返りをしたい場面で積極的に使用すること。
---

# daily-review.work

## 目的

GitHub・Slack・Claude Code といった複数の活動ソースから今日 1 日の仕事を集約し、KPT 形式で振り返りを生成するスキルである。
終業時に自分の動きを俯瞰し、明日へつなげる学びを引き出す作業を自動化する。

## 使うタイミング

- 「振り返り」「ふりかえり」「日報」「今日何した」と言われたとき
- 「daily review」「1 日のまとめ」「KPT」のような依頼があったとき
- 終業時や日次でその日の活動を整理したいとき
- 週次振り返りの素材として日次サマリが必要なとき

## 手順

1. 対象日を確定する
    - 指定がなければ今日（ローカルタイムゾーン）を対象とする
    - `today=$(date +%Y-%m-%d)` を起点にする
2. GitHub の活動を収集する
    - 自分が作成・更新した PR: `gh search prs --owner @me --updated ">=${today}" --json number,title,state,updatedAt,url`
    - 自分がコメントした PR: `gh search prs --commenter @me --updated ">=${today}" --json number,title,state,url`
    - 自分がクローズした Issue: `gh search issues --closed ">=${today}" --owner @me --json number,title,url`
    - 必要に応じて自分のコミット数を追加で取得する
3. Slack の活動を収集する（Slack MCP が有効な場合のみ）
    - 自分が投稿したメッセージ
    - 自分宛のメンション・反応
    - MCP が無効・未接続のときはこのステップをスキップし、出力にもその旨を明記する
4. Claude Code の活動を収集する
    - 直近の会話履歴・transcript から今日扱ったトピックや成果物を要約する
    - 触ったファイル・リポジトリ・呼び出した skill を具体的に列挙する
5. 収集結果を KPT に整理して出力する
    - 重複や些末な活動はまとめて簡潔にする
    - 数値（PR 件数・コメント件数など）はサマリに添える

## 出力フォーマット

```
## 今日の振り返り（YYYY-MM-DD）

### 活動サマリ
- GitHub: 作成 PR <件>, 更新 PR <件>, クローズ Issue <件>
- Slack: 投稿 <件>, メンション <件>（取得不可ならその旨）
- Claude Code: 主に扱ったトピック / リポジトリ / skill

### 主な成果
- <PR / Issue / 会話で達成した具体的な事柄をリンク付きで>

### KPT

#### K (Keep)
- 良かったこと・継続したいこと

#### P (Problem)
- 課題・うまくいかなかったこと

#### T (Try)
- 明日試したいこと
```

## 注意

- 出力はチャットへの提示のみとする。ファイル化・PR 起票・Slack 投稿はユーザーから明示指示があるまで行わない。
- Slack MCP が無効・権限不足の場合は Slack セクションをスキップし、その旨を出力に書く。
- Claude Code の会話履歴にアクセスできない場合は GitHub・Slack のみで振り返りを構成する。
- KPT の各項目は活動から論理的に導けるものに限定し、根拠のない感想は書かない。
- 個人情報や機微情報（顧客名・未公開情報）は要約段階でマスクする。
