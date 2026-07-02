# Chrome bookmarklets

Chromeのブックマークレットとして登録しているスクリプト集である。

## 使い方

1. Chromeでブックマークバーに新しいブックマークを追加する
2. 名前は任意、URLフィールドに各`.js`ファイルの中身（`javascript:`から始まる1行）をそのまま貼り付ける
3. 保存後、対象ページでブックマークをクリックすると実行される

## 一覧

### copy-issue-pr-link-as-markdown.js

GitHubのIssue/Pull Request、GitLabのMerge Requestページで、タイトルとURLをMarkdown形式のリンク（`[タイトル](URL)`）としてクリップボードにコピーする。ページの種類に応じてタイトルの余分な部分（` · Issue`や` by 〜 · Pull Request`など）を除去してから整形する。

### copy-pr-title-with-number.js

GitHubのPull Requestページで、タイトルの表示形式（`<タイトル> by <author> · Pull Request #<番号>`）からタイトルと番号を抽出し、`<タイトル> #<番号>`とURLを改行区切りでクリップボードにコピーする。

### copy-link-as-html.js

現在のページのタイトルとURLから`<a href="URL">タイトル</a>`形式のHTMLと、`タイトル URL`形式のプレーンテキストを両方クリップボードにコピーする。HTML形式のペーストに対応したアプリ（Slack、Notionなど）ではリンク付きテキストとして貼り付けられる。Clipboard APIが使えない場合はプレーンテキストのみコピーする。
