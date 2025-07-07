# PR解説

GitHubのPull Request解説用のプロンプトテンプレートです。

## 使用方法

```
user:explain-pr https://github.com/{owner}/{repo}/pull/{pr_number}
```

## プロンプト内容

# PR解説

GitHubのPR #{pr_number} について、以下の手順で解説してください：

1. **PR情報の取得**
    - `gh pr view {pr_number} --repo {repository} --json title,body,state,commits,changedFiles,additions,deletions,mergeable,mergedAt,createdAt,closedAt,author,assignees,latestReviews,labels,milestone` を使用してPR詳細を取得
      - 注意: `reviewers` フィールドは利用できないため `latestReviews` を使用
    - `gh pr diff {pr_number} --repo {repository}` でコード変更の差分を取得
    - 関連するIssueがあれば確認

2. **解説の構成**
    以下の見出しで構造的に解説：

    ## 概要
    - PRのタイトルと状態（Open/Draft/Merged/Closed）
    - 作成者と作成日時、マージ日時（該当する場合）
    - 変更ファイル数、追加行数、削除行数
    - 関連するIssueやマイルストーン

    ## 変更内容
    - 主要な変更ポイントを機能別に整理
    - 新機能追加、バグ修正、リファクタリングなど変更の性質
    - 影響範囲（フロントエンド/バックエンド/インフラなど）

    ## 技術的詳細
    - 重要なコード変更の解説
    - アーキテクチャへの影響
    - 使用している技術やライブラリの変更
    - パフォーマンスやセキュリティへの影響

    ## テストとレビュー
    - 追加・変更されたテストの内容
    - レビューでの主要なコメントや議論
    - CI/CDでの検証結果

    ## 影響と注意点
    - 本番環境への影響
    - 既存機能への影響
    - デプロイ時の注意事項
    - 後方互換性の考慮

3. **解説のポイント**
    - コードの差分は重要な部分のみを抜粋して解説
    - 変更の背景や理由を明確に説明
    - 技術的な詳細は、背景知識がない人にも理解できるよう平易に説明
    - 重要な変更は太字や箇条書きで強調
    - 長い差分は要約し、ポイントのみ抽出

4. **追加情報**
    - 関連するPRやIssue
    - 参考になるドキュメントやリンク
    - フォローアップが必要な事項
    - 今後の改善予定

## 注意事項
- コードの機密性に配慮し、必要に応じて抽象化して説明
- 変更の規模に応じて解説の詳細度を調整
- PRの目的（機能追加/バグ修正/リファクタリング等）に応じて重点を置く部分を変える
