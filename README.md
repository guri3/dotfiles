# dotfiles

## セットアップ

新しいMacでは以下を実行する。

```sh
curl -fsSL https://raw.githubusercontent.com/guri3/dotfiles/master/bootstrap.sh | bash
```

bootstrap.shは以下を行う。

- Homebrewが未インストールならインストールする
- ghqの規約に従い `~/ghq/github.com/guri3/dotfiles` にリポジトリをcloneする
- `make all` で全セットアップを実行する

## 個別実行

セットアップはツール単位のMakeターゲットに分かれており、個別に実行できる。

```sh
make brew          # Homebrewパッケージのインストール
make mise-install  # miseで管理するツールのインストール
make claude        # Claude Codeの設定のsymlink
```

ターゲット一覧はMakefileを参照。
