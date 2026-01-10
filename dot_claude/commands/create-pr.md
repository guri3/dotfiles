# Pull Request（PR）の作成

現状の作業ブランチのPRを作成する

## ルール

- `gh pr create --draft`でドラフトPRを作成
- **【重要】`.github/PULL_REQUEST_TEMPLATE.md`などのテンプレートが存在する場合は必ず準拠すること**
  - テンプレートを読み取り、すべてのセクションを含める
  - 情報が足りないセクションは編集せずにそのまま残す
- Assignees は`@me`とする
- Labels は作業中を表すものを指定する
  - `gh label list`でラベル一覧を取得し、作業中を表すものが存在しない場合は付与しない
- PRのタイトルにprefixは不要
- 口調はなるべくいつものPRに寄せて
