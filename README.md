# dotfiles

## セットアップ

### 1. Homebrewをインストールする

インストール方法は変わる可能性があるため、[公式サイト](https://brew.sh/ja/)の手順に従う。

### 2. make installを実行する

```sh
curl -fsSL https://raw.githubusercontent.com/guri3/dotfiles/master/Makefile | make -f - install
```

Makefileがghqの規約に従い `~/ghq/github.com/guri3/dotfiles` へリポジトリをcloneし、そこでセットアップを実行する。Homebrewパッケージ・miseで管理するツール・各種設定ファイルのsymlinkまで、すべてこれで完了する。

手動でcloneした場合も、リポジトリ内で `make install` を実行すればよい。規約外の場所で実行した場合は、規約の場所へのcloneを済ませた上でそちらで実行し直される。

## 個別実行

セットアップはツール単位のMakeターゲットに分かれており、個別に実行できる。

```sh
make brew          # Homebrewパッケージのインストール
make mise-install  # miseで管理するツールのインストール
make claude        # Claude Codeの設定のsymlink
```

ターゲット一覧はMakefileを参照。
