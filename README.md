# Claude Code DevContainer

Claude Code をセキュアに動かすための DevContainer 設定。Squid プロキシによるネットワークサンドボックスを備えており、GitHub Codespaces および ローカル VS Code DevContainer の両方で動作する。

## アーキテクチャ

```
                ┌─────────────────────────────┐
                │      internal network        │
  VS Code ──── │  code ──────► proxy ──────── │──► インターネット
  (remoteUser)  │  (Claude Code)  (Squid)       │   (ホワイトリストのみ)
                └─────────────────────────────┘
```

| コンテナ | ベースイメージ | 役割 |
|---|---|---|
| `code` | `node:22-bookworm-slim` | Claude Code 実行環境 |
| `proxy` | `debian:bookworm-slim` | Squid プロキシ（ホワイトリスト制限） |

**ネットワーク構成:**
- `code` コンテナは `internal` ネットワークのみ接続（外部に直接出られない）
- `proxy` コンテナが `internal` + `external` に接続し、許可ドメインへのみ中継

## ディレクトリ構成

```
.devcontainer/
├── devcontainer.json
├── docker-compose.yml
├── code/
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── managed-settings.json    # Claude Code 組織レベル設定
│   └── statusline.sh            # ステータスライン表示
├── proxy/
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── squid.conf               # Squid 設定
│   ├── whitelist.txt            # 許可ドメインリスト
│   └── logs/                   # アクセスログ（gitignore 推奨）
└── workspace/                  # 旧ローカル用マウントポイント
```

## GitHub Codespaces での使い方

### 1. リポジトリを GitHub に公開する

このリポジトリを GitHub にプッシュする（Public / Private どちらでも可）。

### 2. Codespace を作成する

1. リポジトリページで **Code** ボタン → **Codespaces** タブを開く
2. **Create codespace on main** をクリック
3. コンテナのビルドを待つ（初回は 5〜10 分程度）

VS Code の Dev Containers 拡張機能が自動的に `code` コンテナに接続し、ワークスペースが `/workspaces/<repo-name>` に開く。

### 3. Claude Code を認証する

ターミナルで以下を実行：

```bash
claude
```

**claude.ai アカウント（Pro / Max）を使う場合:**
- ブラウザ認証フローが始まる。Codespaces がポートフォワーディングして URL を表示するので、それを開いて認証する。

**API キーを使う場合:**
- リポジトリの **Settings > Secrets and variables > Codespaces** に `ANTHROPIC_API_KEY` を追加する。
- 環境変数として自動注入されるため、認証不要で Claude Code が起動する。

### 4. 作業を始める

```bash
claude          # Claude Code を起動
```

## ローカル VS Code DevContainer での使い方

1. [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) 拡張機能をインストール
2. このリポジトリをクローン
3. VS Code で開き、コマンドパレットから **Dev Containers: Reopen in Container** を実行

## ネットワークサンドボックス

Claude Code がアクセスできるドメインは `proxy/whitelist.txt` で管理する。

**デフォルト許可リスト:**

| ドメイン | 用途 |
|---|---|
| `.anthropic.com` | Claude API |
| `.claude.com` / `.claude.ai` | claude.ai 認証・利用 |
| `.github.com` | GitHub 操作 |
| `.npmjs.org` | npm パッケージ取得 |

ドメインを追加する場合は `whitelist.txt` を編集してコンテナを再ビルドする。

## Claude Code 設定（managed-settings.json）

`code/managed-settings.json` は Claude Code の組織レベル設定で、コンテナ内の `/etc/claude-code/managed-settings.json` に配置される。ユーザーが上書きできない設定を定義できる。

**主な設定内容:**
- 危険コマンドの禁止（`rm -rf`、`sudo`、`git push --force` 等）
- プロキシ環境変数の強制適用
- テレメトリ・エラーレポートの無効化
- ステータスラインのカスタマイズ

## 設定のカスタマイズ

| 目的 | 編集するファイル |
|---|---|
| 許可ドメインの追加 | `proxy/whitelist.txt` |
| 禁止コマンドの変更 | `code/managed-settings.json` |
| インストールパッケージの追加 | `code/Dockerfile` |
| ステータスラインの変更 | `code/statusline.sh` |
