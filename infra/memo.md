# Terraform

## provider　ブロックの書き方
``` bash
# 注意点として、このブロック内は一切の変数が使用できない
# 変数ファイルよりも先にこちらが読み込まれるため

terraform {
  # terraform 本体のバージョン
  # バージョンの確認方法は、terraform --version
  required_version = ">= 1.14.4, < 2.0.0"

  # インフラプロバイダのバージョン(AWS)
  # バージョンの確認方法は、terraform レジストリから
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.30"
    }
  }

  # リモートバックエンドの指定
  backend "s3" {
    bucket       = "ecs-practice-remote-backend-boot"
    key          = "boot/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true # 排他制御用のDynamoDBの作成が不要になった
    encrypt      = true
  }
}
```

## リモートバックエンドの作成方法
手順として確立しておく
ローカルでS3, DynameDBを作成する
作成したものを、バックエンドに切り替える

## ECSに関するメモ
ECSが必要とする外部リソース
```
IAM Policy           : Secret Manager へアクセス
IAM Role             : ECSタスクの実行
CLoudwatch Log Group : ECSのログ出力
```

タスク定義は、Terraform の jsonencode 関数 を使うのが良い (以下に利点)
```
1. 変数が使える: var.image_uri などの Terraform の値をそのまま埋め込める
2. 構文エラー防止 : カンマの忘れや括弧の対応など、JSON 特有のミスを Terraform が防いでくれる
3. 可読性 : Terraform (HCL) の記法で統一して書けるため、読みやすくなる
```

イメージの更新 (最新イメージを反映させたい場合)  
```bash
# 開発環境で最新イメージを反映させたい場合は、
# apply の後に以下の AWS CLI コマンドを実行して、強制的に新しいデプロイを行うのが一般的
aws ecs update-service --cluster <クラスター名> --service <サービス名> --force-new-deployment

# 本番環境のベストプラクティス: 
# 本番環境では latest を使わず、Git のコミットハッシュやビルド番号（例: :v1.0.1, :a1b2c3d）をタグとして使い、Terraform に変数として渡す運用が推奨される。これにより、Terraform が確実に変更を検知し、安全にロールバックも可能になる。
```
ネットワーク設定について  
```
ECS Fargateでは、ネットワークモードとして awsvpc しか使えない。 このモードの仕様上、「コンテナポートとホストポートは必ず同じ値にする」 という絶対的なルールがある。
```

## Terraform: dynamic と content
- 1つのresource内である値だけを複製する

### 要点

- **dynamic** と **content** はペアで使う。
- **dynamic** はブロックの**中**で使い、その中で **content** によって「繰り返すブロックの中身」を定義する。
- リソースに **for_each** を付けると**リソース自体**が複製される（例: `aws_db_parameter_group` が複数できる）。ブロックだけ複製したい場合は **dynamic** を使う。

### 1. dynamic と content はペア

- **dynamic** で「どのブロックを繰り返すか」を指定する。
- **content** で「その 1 つ 1 つの中身」を書く。
- **content** は dynamic の直下に 1 つだけ書き、その中に繰り返したいブロックの属性を書く。

### 2. dynamic は「ブロックの中」で使う

- **dynamic** は、リソースや他のブロックの**内側**に書く。
- そうすることで「**リソースは 1 つ**で、その**中の子ブロック（ここでは parameter）だけ**が複数になる」形になる。

例（`aws_db_parameter_group`）:

```hcl
resource "aws_db_parameter_group" "main" {
  # リソースは 1 つ
  tags   = { Name = var.rds_conf.name }
  name   = var.rds_conf.parameter_group_name
  family = "mysql8.0"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.key
      value = parameter.value
    }
  }
}
```

### 3. for_each をリソースに付けるとリソース自体が複製される

- **for_each** を**リソース**（`resource "aws_db_parameter_group" "main"`）に付けると、**リソースごと**が複製される。
- つまり「パラメータグループ」が 1 つではなく、変数の要素数ぶん作られる（以前のエラーのときの状態）。

| 書き方 | 結果 |
|--------|------|
| **resource に for_each** | `aws_db_parameter_group.main["key1"]`, `main["key2"]`, ... と**リソースが複数**できる。パラメータグループが複数になる。 |
| **dynamic "parameter" で for_each** | **リソースは 1 つ**。その中の **parameter ブロックだけ**が複数になる。パラメータグループ 1 つにパラメータが複数、という正しい形。 |

### まとめ

- **dynamic** と **content** はペアで、ブロックの**中**で使い、**ブロックの中身（ここでは parameter）だけ**を複製する。
- **for_each** をリソースに付けると、**リソース自体**が複製される（パラメータグループが複数できてしまう）。

---

## RDS パラメータグループ: apply_method（pending-reboot）

### 何を指定しているか

**「このパラメータの変更を、いつ DB に反映するか」** を AWS に伝える設定。

| 値 | 意味 |
|----|------|
| **immediate** | 変更を**今すぐ**実行中の DB に反映する（再起動不要） |
| **pending-reboot** | 変更は「予約」だけして、**次に DB が再起動したとき**に反映する |

Terraform の `parameter` ブロックで、`name` / `value` と並べて指定する。

```hcl
content {
  name         = parameter.key
  value        = parameter.value
  apply_method = "pending-reboot"
}
```

### なぜ pending-reboot にしているか

RDS（MySQL）のパラメータには種類がある。

| 種類 | 説明 | 反映の仕方 |
|------|------|------------|
| **Dynamic** | 再起動なしで変更可能 | `immediate` で即時反映できる |
| **Static** | 再起動しないと反映されない | `immediate` は使えない。必ず `pending-reboot` |

`character_set_server` や `collation_server`、`lower_case_table_names` などは **Static**。  
ここに `immediate`（または未指定）を指定すると、AWS が「static パラメータには immediate は使えない」とエラーにする。  
そのため、Static が含まれる前提で **`apply_method = "pending-reboot"`** を付けておく。

### 実際の動き

- **初回作成時**: パラメータグループを作り、RDS インスタンスをそのグループで起動する場合、**初回起動時**にその設定が読み込まれるので、immediate / pending-reboot の違いはほぼ関係しない。
- **既存のパラメータを変更したとき**: Terraform で値を変えて apply すると、AWS は「その変更をいつ反映するか」を `apply_method` で判断する。`pending-reboot` なら「次に DB が再起動するまで待つ」と記録されるだけなので、Static パラメータでもエラーにならない。実際の反映は、手動やメンテナンスなどで RDS が再起動したタイミング。

### 注意: apply_method の指定場所

- **tfvars の `parameters`**: MySQL の**パラメータ名と値**だけ（`character_set_server`, `time_zone` など）。ここに `apply_method` を書くと「apply_method という名前の DB パラメータ」として送られ、無効になる。
- **モジュールの main.tf（content 内）**: Terraform / AWS API 用の属性。**`apply_method`** はここで指定する。

### まとめ

- **`apply_method = "pending-reboot"`** = 「このパラメータの変更は、**次回の DB 再起動時に反映する**」と指定している。
- Static パラメータには `immediate` が使えないため、Static を含む場合は **`pending-reboot`** にしておく。

---

## Secrets Manager

- アクセス制限は **IAM** で行う。
- アクセスには **HTTPS** で API エンドポイント経由。
- 可用性は、自動で複数 AZ にレプリケートされる。
- 監査ログが重要なサービス（だれが・いつアクセスしたかなど）。

### リソースの関係（箱と中身）

| リソース | 役割 |
|----------|------|
| **aws_secretsmanager_secret** | **箱**。シークレットの「名前・説明・復旧期間・タグ」などメタ情報だけ。**値は持たない**。 |
| **aws_secretsmanager_secret_version** | **箱の中身**。実際の値（secret_string）を入れた「1つのバージョン」。`secret_id` でどの箱か指定する。 |

### 保存と取り出し（jsonencode / jsondecode）

Secrets Manager の `secret_string` は **文字列** として保存される。object を渡すときは encode / decode で対応する。

| タイミング | 処理 | 役割 |
|------------|------|------|
| **保存するとき** | **jsonencode**(object) | Terraform の object を **JSON 文字列** に変換して Secrets Manager に渡す。 |
| **取り出すとき** | **jsondecode**(secret_string) | API から返ってきた **JSON 文字列** を **object** に戻し、`["key"]` でキー参照する。 |

- 保存: object → 文字列（jsonencode）
- 取り出し: 文字列 → object（jsondecode）

### 流れメモ: 保存 → 取り出し → 参照まで

#### 1. 値を保存する（Terraform で作成）

1. **object を用意する**  
   呼び出し側（例: dev/main.tf）で、tfvars の値と他リソースの出力を merge して 1 つの object にする。
   ```hcl
   secret_string = merge(var.secret_string, {
     username = var.db_conf.username
     password = var.db_conf.password
     database = var.db_conf.database
     hostname = module.rds.address
   })
   ```

2. **モジュールに渡す**  
   上記 object を `secret_string` 変数で Secrets Manager モジュールに渡す。

3. **モジュール内で保存**  
   - **aws_secretsmanager_secret**（箱）を作成  
   - **aws_secretsmanager_secret_version** の `secret_string` に **jsonencode(var.secret_string)** を渡す  
   → object が JSON 文字列になり、AWS に保存される。

#### 2. Terraform 内で「取り出して」参照する（output など）

- AWS の `secret_string` は **JSON 文字列** で返る。そのままでは `["key"]` で参照できない。
- **jsondecode(aws_secretsmanager_secret_version.main.secret_string)** で object に戻す。
- その後 `local.secret["username"]` のようにキーで参照できる。  
  → output で値を返すときはこの形。**ただし ECS の環境変数には「値」を渡さない（下記 3 参照）。**

#### 3. ECS から参照する（コンテナに環境変数として渡す）

- ECS のタスク定義では、**値そのもの**は渡さない。**「その値を取りにいくための ARN」** を渡す。
- キー名は **valueFrom**（valueFromSecret ではない）。
- 値は **Secrets Manager のシークレット ARN**。JSON シークレットの特定キーなら次の形式。
  ```
  <secret_arn>:key:<キー名>::
  ```
  例: `arn:aws:secretsmanager:ap-northeast-1:123456789012:secret:my-secret-AbCdEf:key:username::`

- Terraform での書き方の例:
  ```hcl
  secrets = [
    { name = "MYSQL_USER", valueFrom = "${var.mysql_secret_arn}:key:username::" },
  ]
  ```
- **mysql_secret_arn** は呼び出し側（dev）で `module.secrets_manager.secret_arn` を ECS モジュールに渡す。  
  → コンテナ起動時に ECS がこの ARN で Secrets Manager にアクセスし、タスク実行ロールの権限で値を取得して環境変数にセットする。

#### まとめ（3 段階）

| 段階 | どこで | 何をする |
|------|--------|----------|
| **保存** | 呼び出し側 + モジュール | object を merge で作る → モジュールで jsonencode して secret_version に渡す |
| **Terraform で取り出し** | モジュールの output など | secret_string を jsondecode して object に戻し、キーで参照 |
| **ECS で参照** | タスク定義の secrets | 値は渡さず **valueFrom** に **ARN（:key:キー名::）** を渡す。実行時に ECS が Secrets Manager から取得する。 |

### DB に接続できないときの確認（ECS → RDS）

原因になりやすい順に確認する。

#### 1. ネットワーク（セキュリティグループ）

- **やること**: RDS に付いている SG（database_sg）が、**webapp_sg からの 3306 インバウンド**を許可しているか。
- **本番の設定**: `sg.tf` で `database_sg` に `in_tcp_3306_from_webapp`（source = webapp_sg）が merge されている。
- **確認**: AWS コンソール → EC2 → セキュリティグループ → RDS に付与されている SG → インバウンドに 3306 / 送信元 = webapp_sg があるか。

#### 2. 同じ VPC・到達性

- **やること**: ECS タスクと RDS が**同じ VPC** にあり、**プライベートサブネット同士でルーティングできる**か。
- **本番の設定**: どちらも `module.vpc_base` のプライベートサブネットを使用している想定。
- **確認**: RDS の「サブネットグループ」と ECS サービスの「サブネット」が、同じ VPC のサブネットか。別 VPC だと疎通しない。

#### 3. Secrets Manager（環境変数がコンテナに渡っているか）

- **やること**: タスク定義の **secrets** で、**valueFrom** に正しい ARN（`:key:hostname::` など）が渡っているか。実行ロールが Secrets Manager を読めるか。
- **確認**:
  - ECS → タスク定義 → コンテナ定義 → **secrets** に MYSQL_HOST / MYSQL_USER / MYSQL_PASSWORD / MYSQL_DATABASE があり、valueFrom が `...:key:hostname::` 形式か。
  - タスクの **実行ロール** に、Secrets Manager の `GetSecretValue` と KMS の `Decrypt` が付いているか。
- **よくあるミス**: valueFrom に「値」を渡している（本来は ARN）。キー名を `valueFromSecret` にしている（正しくは `valueFrom`）。

#### 4. シークレットの中身（hostname が RDS のエンドポイントか）

- **やること**: Secrets Manager に保存されている JSON の **hostname** が、**RDS のエンドポイント**（例: `xxx.xxx.ap-northeast-1.rds.amazonaws.com`）になっているか。
- **確認**: AWS コンソール → Secrets Manager → 対象シークレット → 「シークレットの値を取得」で hostname / username / password / database を確認。hostname が RDS の「エンドポイント」と一致するか。
- **注意**: 初回 apply で RDS より先にシークレットが作られると、hostname が空や古い値のままになることがある。その場合は Terraform で再 apply するか、シークレットの新バージョンを手動で作成する。

#### 5. RDS の状態・DB 名

- **やること**: RDS が **利用可能** になっており、指定した **データベース名（例: todo）** が存在するか。
- **確認**: RDS → インスタンス → ステータスが「利用可能」か。必要なら RDS に接続して `CREATE DATABASE todo;` やスキーマ投入が済んでいるか。

#### 6. アプリのログ（実エラー内容）

- **やること**: コンテナがどのエラーで落ちているか確認する。
- **確認**: CloudWatch Logs → ロググループ（例: `/ecs/ecs-practice/dev/webapp`）→ 直近のログストリーム。`ECONNREFUSED` ならネットワーク/SG、`Access denied` ならユーザー/パスワード、`Unknown database` なら DB 名や未作成。

#### チェックリストまとめ

| 確認項目 | 見る場所 |
|----------|----------|
| SG: webapp → RDS 3306 許可 | RDS に付与されている SG のインバウンド |
| 同じ VPC | RDS のサブネットグループ / ECS のサブネット |
| valueFrom が ARN 形式 | タスク定義の secrets |
| 実行ロールで GetSecretValue | タスク定義の実行ロールのポリシー |
| シークレットの hostname = RDS エンドポイント | Secrets Manager のシークレット値 |
| RDS 利用可能・DB 作成済み | RDS コンソール / DB にログインして確認 |
| アプリのエラー内容 | CloudWatch Logs |

#### Secrets Manager にしたあとから DB が見えない場合

Secrets Manager 導入後にだけ DB に繋がらなくなったときは、次のどれかが疑わしい。

1. **シークレットがコンテナに渡っていない（タスクが起動時に失敗）**
   - **確認**: ECS → クラスター → サービス → タスク → 停止したタスクの「停止理由」を開く。
   - **例**: `ResourceInitializationError: unable to pull secrets` や `AccessDeniedException` → 実行ロールが Secrets Manager / KMS を参照できていない。
   - **対処**: タスク定義の実行ロールに、対象シークレット（または `*`）への `secretsmanager:GetSecretValue` と `kms:Decrypt` が付いているか確認する。

2. **シークレットの中身が間違っている（特に hostname）**
   - **確認**: Secrets Manager → 対象シークレット → 「シークレットの値を取得」で、**hostname** が RDS の「エンドポイント」と完全に一致しているか。
   - **よくある原因**: 初回 apply で RDS より先にシークレットが作られた、または RDS 作成直後で address が未設定のままだった → hostname が空や古い値のまま。
   - **対処**: Terraform で `terraform apply` をやり直してシークレットを更新したあと、**ECS サービスを強制再デプロイ**（「新しいデプロイの開始」）して、新しいタスクに最新シークレットを読ませる。

3. **valueFrom の ARN 形式**
   - **確認**: タスク定義のコンテナ定義 → **secrets** の **valueFrom** が `arn:aws:secretsmanager:...:secret:名前-6文字:key:hostname::` の形か（末尾 `::` を忘れない）。
   - **よくあるミス**: キー名を `valueFromSecret` にしている、値に「シークレットの値」を直書きしている（本来は ARN のみ）。

4. **Fargate のプラットフォームバージョン**
   - Secrets Manager の値を環境変数で注入するには **1.3.0 以降** が必要。1.2 だと動かない場合がある。
   - **確認**: ECS サービス／タスクのプラットフォームバージョンが 1.3 以上か。

5. **※ destroy したあとに「DB が見えない」場合**
   - **terraform destroy** すると **RDS インスタンスごと削除**されるため、**DB 内のテーブル・データもすべて消える**。
   - 「DB が見れなかった」が **destroy の直後**なら、Secrets Manager や SG ではなく **RDS（とデータ）が無いだけ**の可能性が高い。再度 apply して RDS を作り直したうえで、スキーマ・サンプルデータ（`db/initdb/01-schema.sql`, `02-sampledata.sql`）を流し直す必要がある。
