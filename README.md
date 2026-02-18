# ToDo Application

## 利用アーキテクチャ

- Node.js v20
- MySQL v8

## 利用方法

### 1. データベースの準備

1. database を最初に準備  
   名前は任意でOK。以下の例では `todo` で作成。

   ```sql
   CREATE DATABASE todo;
   ```

2. 作成したデータベースにスキーマを作成  
   `db/initdb/01-schema.sql` を実行

3. サンプルデータの投入  
   `db/initdb/02-sampledata.sql` を実行

### 2. アプリの実行準備

1. 環境変数ファイル `.env` を用意

   ```
   MYSQL_HOST=<YOUR_HOST_NAME>
   MYSQL_USER=<USERNAME>
   MYSQL_PASSWORD=<PASSWORD>
   MYSQL_DATABASE=<DATABASE_NAME>
   ```

2. パッケージのインストール

   ```bash
   cd app && npm install
   ```

### 3. アプリの実行

```bash
cd app && npm start
```

## GitHub Actions へのシークレット設定

```
IMAGE_NAME
ACR_SERVER
ACR_USERNAME
ACR_PASSWORD
WEBAPP_NAME
WEBAPP_PUBLISH_PROFILE
```