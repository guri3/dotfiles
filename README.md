# dotfiles

## セットアップ

### 1. Homebrewをインストールする

インストール方法は変わる可能性があるため、[公式サイト](https://brew.sh/ja/)の手順に従う。

### 2. リポジトリをcloneする

ghqの規約に従った場所に配置する。

```sh
git clone https://github.com/guri3/dotfiles.git ~/ghq/github.com/guri3/dotfiles
```

### 3. make installを実行する

```sh
cd ~/ghq/github.com/guri3/dotfiles
make install
```

Homebrewパッケージ・miseで管理するツール・各種設定ファイルのsymlinkまで、すべてのセットアップが完了する。

## 個別実行

セットアップはツール単位のMakeターゲットに分かれており、個別に実行できる。

```sh
make brew          # Homebrewパッケージのインストール
make mise-install  # miseで管理するツールのインストール
make claude        # Claude Codeの設定のsymlink
```

ターゲット一覧はMakefileを参照。
