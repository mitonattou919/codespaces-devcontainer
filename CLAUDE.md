# CLAUDE.md

セットアップ手順・アーキテクチャの詳細は @README.md を参照。

## このリポジトリについて

Claude Code をセキュアに動かすための DevContainer 設定リポジトリ。主な構成要素は以下の2点：

- **`code` コンテナ**: Claude Code の実行環境
- **`proxy` コンテナ**: Squid プロキシによるネットワークサンドボックス（ホワイトリスト制限）

## 作業上の注意

**ネットワーク制限について**
このコンテナは Squid プロキシ経由でのみ外部通信できる。`proxy/whitelist.txt` に記載されていないドメインへのアクセスは全て遮断される。ネットワーク疎通エラーが出た場合は whitelist.txt の確認を先に行う。

**設定変更後の再ビルド**
`code/Dockerfile`・`proxy/Dockerfile`・`managed-settings.json` を変更した場合は、Codespaces の **Rebuild Container** が必要。`whitelist.txt` や `squid.conf` は bind mount なので、プロキシコンテナの再起動のみで反映される。

**UID について**
コンテナユーザー `ccode` は UID 1000 で動作する（Codespaces デフォルトと一致）。
