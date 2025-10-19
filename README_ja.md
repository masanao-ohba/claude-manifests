# スキル駆動エージェント設定ガイド

## 概要

このガイドでは、`~/.claude/agents`、`~/.claude/skills`、`.claude/config.yaml`、`CLAUDE.md` の設定方法と、それぞれの責任範囲を定義します。

### アーキテクチャ原則

```
エージェント = 汎用プロセス実行者
スキル = ドメイン知識提供者
config.yaml = バインディング層
CLAUDE.md = プロジェクト固有ルール
```

### 責任レイヤーモデル（4層）

| レイヤー | 配置場所 | 責任範囲 | 再利用性 | 例 |
|---------|---------|---------|---------|-----|
| **Level 1: Generic** | `~/.claude/skills/generic/` | 普遍的パターン | ⭐⭐⭐⭐⭐ 全技術スタック | MoSCoW、SMART、AAA |
| **Level 2: Language** | `~/.claude/skills/[言語]/` | 言語レベル標準 | ⭐⭐⭐⭐ 全[言語]プロジェクト | PSR-12、PHPUnit、PEP-8 |
| **Level 3: Framework** | `~/.claude/skills/[言語]-[FW]/` | フレームワーク規約 | ⭐⭐⭐ 全[FW]プロジェクト | CakePHP MVC、Django MVT |
| **Level 4: Project** | `CLAUDE.md`、`config.yaml` | プロジェクト固有ルール | ⭐ 当該プロジェクトのみ | テストコメント形式、マルチリポジトリ構成 |

---

## 1. 責任範囲の定義

### 1.1 CLAUDE.md の責任範囲

**役割**: プロジェクト固有ルールの定義（デフォルト動作のオーバーライド）

**含めるべき内容**:
- プロジェクト固有の規約（他プロジェクトでは通用しない独自ルール）
- チーム固有のワークフロー（標準フレームワークパターン外）
- プロジェクト固有の制約（マルチリポジトリ構成、レガシーパターン）
- カスタムドキュメント形式
- プロジェクト固有の品質ゲート
- リポジトリ固有のファイルパス・構造
- プロジェクト固有の承認フロー

**含めてはいけない内容**:
- 言語コーディング規約 → `[言語]/coding-standards` スキル
- フレームワーク規約 → `[言語]-[FW]/` スキル
- テストフレームワークパターン → `[言語]/testing-standards` スキル
- セキュリティベストプラクティス → `[言語]/security-patterns` スキル
- 汎用パターン → `generic/` スキル

### 1.2 config.yaml の責任範囲

**役割**: エージェントとスキルのバインディング定義

**主要セクション**:

| セクション | 役割 | 必須/任意 |
|-----------|------|---------|
| `repo_metadata` | プロジェクト情報・技術スタック定義 | 必須 |
| `agent_skills` | 汎用エージェントへのスキル割り当て | 必須 |
| `agents` | 技術固有エージェントの設定 | 任意 |
| `database` | データベース設定 | 任意 |
| `test` | テスト実行設定 | 任意 |
| `paths` | ファイルパス設定 | 任意 |
| `dependencies` | 依存関係定義 | 任意 |

### 1.3 スキルの責任範囲

**役割**: 再利用可能なドメイン知識・パターンの提供

**スキルディレクトリ構成**:
```
~/.claude/skills/
├── generic/
│   ├── requirement-analyzer/     # 普遍的要件分析パターン
│   ├── test-planner/             # 普遍的テスト計画パターン
│   └── code-reviewer/            # 普遍的コードレビューパターン
│
├── [言語]/                        # 例: php, python, javascript
│   ├── coding-standards/         # 言語レベルコーディング規約
│   ├── testing-standards/        # 言語レベルテスト規約
│   └── security-patterns/        # 言語レベルセキュリティパターン
│
└── [言語]-[フレームワーク]/        # 例: php-cakephp, python-django
    ├── functional-designer/      # フレームワークMVC設計
    ├── database-designer/        # フレームワークORM/マイグレーション
    └── test-case-designer/       # フレームワークテストパターン
```

### 1.4 エージェントの責任範囲

**役割**: 汎用プロセスの実行（技術非依存）

**エージェント分類**:

| 種類 | 配置場所 | 技術依存性 | スキル読み込み |
|-----|---------|-----------|-------------|
| **汎用エージェント** | `~/.claude/agents/generic/` | なし | config.yamlから動的 |
| **技術固有エージェント** | `~/.claude/agents/[言語]-[FW]/` | あり | 固定または設定 |

**汎用エージェント一覧**:
- `workflow-orchestrator` - ワークフロー統制
- `requirement-analyst` - 要件分析
- `design-architect` - ソフトウェア設計
- `test-strategist` - テスト戦略策定
- `code-developer` - コード実装
- `quality-reviewer` - 品質レビュー
- `deliverable-evaluator` - 成果物評価

**技術固有エージェントの判断基準**:

✅ **技術固有エージェントとして定義すべき場合**:
- フレームワーク固有のワークフロー（他フレームワークでは存在しない）
- プロジェクト固有のプロセス（マルチリポジトリ検証など）
- フレームワーク固有のツール統合

❌ **汎用エージェント + スキルで対応すべき場合**:
- プロセスは汎用的だが、技術スタックで実装が異なる
- スキルの組み合わせで対応可能

---

## 2. スキル駆動アーキテクチャの仕組み

### 2.1 動作フロー

```
1. エージェント起動
   ↓
2. config.yaml読み込み
   ↓
3. 割り当てられたスキル検出
   agent_skills:
     requirement-analyst:
       - generic/requirement-analyzer
       - [言語]/requirement-patterns
       - [言語]-[FW]/requirement-analyzer
   ↓
4. スキルを順番に読み込み
   ↓
5. 読み込まれたスキルを使用して汎用プロセス実行
   ↓
6. 技術スタック固有の成果物を出力
```

### 2.2 スキル読み込み順序

```yaml
agent_skills:
  code-developer:
    - generic/code-implementer          # 1番目: 普遍的パターン
    - php/coding-standards              # 2番目: 言語固有（genericを上書き可）
    - php/security-patterns             # 3番目: 言語固有（generic, phpを上書き可）
    - php-cakephp/code-implementer      # 4番目: FW固有（すべてを上書き可）
    - php-cakephp/multi-tenant-handler  # 5番目: プロジェクト固有（最優先）
```

**読み込み戦略**:
1. 汎用スキル → ベースパターン提供
2. 言語スキル → 言語固有パターン追加
3. フレームワークスキル → FW固有パターン追加
4. プロジェクトスキル → プロジェクト固有パターン追加（最も具体的なものが優先）

---

## 3. CLAUDE.md 設定定義

### 3.1 必須セクション

#### 設定ステータス

```markdown
# CLAUDE.md - [プロジェクト名]設定

**設定ステータス**: [PERMANENT|TEMPORARY]
**目的**: [この設定が達成する内容]

[一時的な設定の場合]
**有効期間**: YYYY-MM-DD ~ [終了条件]
**置き換え対象**: [何を置き換えているか]
```

#### 絶対ルール

```markdown
## 絶対ルール - プロジェクト優先原則

### ルール優先順位

**重要**: プロジェクトドキュメントとAI一般知識が矛盾する場合、プロジェクトドキュメントに従う

優先順位（高 → 低）:
1. 明示的プロジェクトルール（CLAUDE.md、README.md）← 最高権限
2. 本番コード動作（実際に存在するもの）
3. AI一般知識（Docker、フレームワークなど）← 最低権限

**この階層が存在する理由**:
- [プロジェクト固有理由1]
- [プロジェクト固有理由2]
```

#### プロジェクト固有標準

```markdown
## プロジェクト固有標準

### [標準名]（必須）

**このフォーマットはこのプロジェクト固有です**:

[具体的な定義]

**なぜプロジェクト固有か**: [理由の説明]
```

### 3.2 任意セクション

#### マルチリポジトリ構成（該当する場合）

```markdown
## マルチリポジトリ構成

このプロジェクトはマルチリポジトリシステムの一部:

[リポジトリ構成図]

**リポジトリ間依存関係**:
- [依存関係ドキュメント]

**本番コード検証**: 全リポジトリを横断検索
```

#### カスタムワークフローパターン

```markdown
## カスタムワークフローパターン

### [パターン名]

**適用タイミング**: [いつこのパターンを使うか]

**プロセス**:
1. [ステップ1]
2. [ステップ2]

**根拠**: [なぜこのプロジェクトがこの特定パターンを使うか]
```

---

## 4. config.yaml 設定定義

### 4.1 必須セクション定義

#### リポジトリメタデータ

```yaml
repo_metadata:
  name: [プロジェクト名]
  type: [プロジェクトタイプ]
  description: [簡潔な説明]

  tech_stack:
    language: [言語名]                    # PHP, Python, JavaScript等
    language_version: "[バージョン]"      # "8.2", "3.11", "20.x"
    framework: [フレームワーク名]         # CakePHP, Django, React等
    framework_version: "[バージョン]"     # "4.4", "4.2", "18.0"
    test_framework: [テストFW名]          # PHPUnit, pytest, Jest
    test_framework_version: "[バージョン]" # "11.5", "7.4", "29.0"
```

#### エージェント-スキル割り当て（最重要）

```yaml
agent_skills:
  [エージェント名]:
    - [スキルパス1]  # 最初に読み込み
    - [スキルパス2]  # 2番目（スキル1を上書き可）
    - [スキルパス3]  # 3番目（スキル1,2を上書き可）
```

**スキルパス形式**:
```
[スコープ]/[スキル名]

スコープ:
  - generic       (普遍的パターン)
  - [言語]        (言語レベルパターン)
  - [言語]-[FW]   (フレームワークレベルパターン)
```

**標準的なエージェント-スキル割り当てテンプレート**:

```yaml
agent_skills:
  workflow-orchestrator:
    - generic/workflow-patterns

  requirement-analyst:
    - generic/requirement-analyzer
    - [言語]/requirement-patterns
    - [言語]-[FW]/requirement-analyzer

  design-architect:
    - generic/software-designer
    - [言語]/architectural-patterns
    - [言語]-[FW]/functional-designer
    - [言語]-[FW]/database-designer

  test-strategist:
    - generic/test-planner
    - [言語]/testing-standards
    - [言語]-[FW]/test-case-designer

  code-developer:
    - generic/code-implementer
    - [言語]/coding-standards
    - [言語]/security-patterns
    - [言語]-[FW]/code-implementer

  quality-reviewer:
    - generic/code-reviewer
    - [言語]/coding-standards
    - [言語]/security-patterns
    - [言語]-[FW]/code-reviewer

  deliverable-evaluator:
    - generic/evaluation-criteria
    - [言語]-[FW]/deliverable-criteria
```

#### 技術固有エージェント設定

```yaml
agents:
  [エージェント名]:
    enabled: true|false
    [エージェント固有設定]
    skills:
      - [スキルパス]
```

**`agents` vs `agent_skills` 使い分け**:

| セクション | 使用タイミング | 例 |
|-----------|-------------|-----|
| `agent_skills` | エージェントが汎用的で、スキルで適応 | requirement-analyst, code-developer |
| `agents` | エージェントが本質的に技術固有 | test-guardian（特定形式検証）、migration-validator |

### 4.2 任意セクション定義

#### データベース設定

```yaml
database:
  architecture: [single-tenant|multi-tenant]
  pattern: "[パターン文字列]"
  schemas:
    - name: [スキーマ名]
      type: [shared|per-tenant]
      database: [データベース名またはパターン]
```

#### テスト設定

```yaml
test:
  docker_command: "[Dockerコマンド]"
  test_database_prefix: [プレフィックス]
  fixture_namespaces:
    - [名前空間1]
    - [名前空間2]
  constants:
    [定数名]: [値]
```

#### パス設定

```yaml
paths:
  controllers: [パス]
  models: [パス]
  components: [パス]
  fixtures: [パス]
  test_cases: [パス]
  migrations: [パス]
  routes: [パス]
```

#### 依存関係

```yaml
dependencies:
  depends_on:
    - [依存先1]
    - [依存先2]
  referenced_by:
    - [参照元1]
    - [参照元2]
```

---

## 5. 設定例

### 5.1 シンプルなWebアプリケーション

```yaml
# .claude/config.yaml

repo_metadata:
  name: simple-blog
  type: web-app
  description: シンプルなブログアプリケーション

  tech_stack:
    language: PHP
    language_version: "8.2"
    framework: CakePHP
    framework_version: "4.4"
    test_framework: PHPUnit
    test_framework_version: "11.5"

agent_skills:
  requirement-analyst:
    - generic/requirement-analyzer
    - php-cakephp/requirement-analyzer

  design-architect:
    - generic/software-designer
    - php-cakephp/functional-designer
    - php-cakephp/database-designer

  code-developer:
    - generic/code-implementer
    - php/coding-standards
    - php/security-patterns
    - php-cakephp/code-implementer

  quality-reviewer:
    - generic/code-reviewer
    - php/coding-standards
    - php-cakephp/code-reviewer

agents: {}  # 技術固有エージェント不要
```

### 5.2 マルチテナント対応プロジェクト

```yaml
# .claude/config.yaml

repo_metadata:
  name: saas-platform
  type: saas
  description: マルチテナント対応SaaSプラットフォーム

  tech_stack:
    language: PHP
    language_version: "8.2"
    framework: CakePHP
    framework_version: "4.4"
    test_framework: PHPUnit
    test_framework_version: "11.5"

  database:
    architecture: multi-tenant
    pattern: "db_company_%d"
    schemas:
      - name: SharedSchema
        type: shared
        database: shared_account_db
      - name: TenantSchema
        type: per-tenant
        database: "db_company_%d"

agent_skills:
  code-developer:
    - generic/code-implementer
    - php/coding-standards
    - php/security-patterns
    - php-cakephp/code-implementer
    - php-cakephp/multi-tenant-handler  # マルチテナント固有

agents:
  test-guardian:
    enabled: true
    auto_run:
      - pre_commit: true
    severity_levels:
      missing_documentation: error
    skills:
      - php-cakephp/test-validator

  migration-validator:
    enabled: true
    auto_clear_cache: true
    skills:
      - php-cakephp/migration-checker
```

### 5.3 Python/Djangoプロジェクト（仮想例）

```yaml
# .claude/config.yaml

repo_metadata:
  name: ecommerce-platform
  type: e-commerce
  description: Eコマースプラットフォーム

  tech_stack:
    language: Python
    language_version: "3.11"
    framework: Django
    framework_version: "4.2"
    test_framework: pytest
    test_framework_version: "7.4"

agent_skills:
  requirement-analyst:
    - generic/requirement-analyzer
    - python/requirement-patterns
    - python-django/requirement-analyzer

  design-architect:
    - generic/software-designer
    - python/architectural-patterns
    - python-django/functional-designer
    - python-django/database-designer

  code-developer:
    - generic/code-implementer
    - python/coding-standards      # PEP-8
    - python/security-patterns
    - python-django/code-implementer  # Django MVT

  test-strategist:
    - generic/test-planner
    - python/testing-standards    # pytest規約
    - python-django/test-case-designer

  quality-reviewer:
    - generic/code-reviewer
    - python/coding-standards
    - python/security-patterns
    - python-django/code-reviewer

agents: {}
```

### 5.4 CLAUDE.md 例（最小構成）

```markdown
# CLAUDE.md - ブログアプリケーション

**設定ステータス**: PERMANENT
**目的**: ブログアプリケーション固有規約

## プロジェクトコンテキスト

シングルリポジトリのブログアプリケーション

## プロジェクト固有標準

### ブログ記事スラグ形式
- 小文字必須
- ハイフン使用（アンダースコア不可）
- 公開日ごとにユニーク
- 例: `2025-10-19-my-blog-post`

**根拠**: SEO最適化とURL可読性

### カスタム承認ワークフロー
ブログ記事には2つの承認が必要:
1. 編集レビュー（コンテンツ品質）
2. 技術レビュー（XSS対策、適切なエスケープ）

## 品質ゲート

記事は以下を通過必須:
- [ ] 編集チェックリスト
- [ ] 技術セキュリティスキャン
- [ ] SEOメタデータ完備
```

### 5.5 CLAUDE.md 例（マルチリポジトリプロジェクト）

```markdown
# CLAUDE.md - 管理画面プロジェクト

**設定ステータス**: PERMANENT
**目的**: マルチリポジトリプロジェクト固有規約

## マルチリポジトリ構成

このプロジェクトはマルチリポジトリシステムの一部:

```
プロジェクトグループ/
├── admin/      # 管理インターフェース（現在のリポジトリ）
├── user/       # ユーザー向けアプリケーション
└── batch/      # バックグラウンドジョブ処理

共通ライブラリ/
├── message/    # 共有メッセージ処理
└── deliver/    # 共有配信システム
```

**リポジトリ間依存関係**:
- admin → message, deliver に依存
- user → message, deliver に依存
- batch → message, deliver に依存

**本番コード検証**: テスト作成前に全リポジトリを検索して本番コード存在確認

## プロジェクト固有標準

### テストコメント形式（必須）

**このフォーマットはこのプロジェクト固有です**:

```php
/**
 * [機能説明]
 *
 * 保証対象:
 * 1. [具体的な保証内容 - 番号付きリスト必須]
 * 2. [別の保証内容]
 * 失敗時の損失:
 * - [テストが存在しない場合のビジネス影響]
 */
public function testSomething(): void
```

**なぜプロジェクト固有か**: ビジネス影響の文書化を求めるプロジェクト方針。PHPUnit標準ではない。

### 本番コード検証プロトコル

**理由**: コードが admin, user, batch に分散
テスト作成前に、いずれかのリポジトリに本番コードが存在することを検証

**手順**: production-verifier エージェントのマルチリポジトリ検索パターンを使用

## 禁止パターン

### テストでの設定上書き（禁止）

❌ **禁止**: `Configure::write()` をテストメソッド内で使用

✅ **必須**: `Configure::read()` で本番設定値を取得

**根拠**: テストは本番動作を検証すべきで、テスト固有動作を検証すべきでない
```

---

## 6. よくある間違いと修正方法

### 6.1 CLAUDE.md の間違い

#### ❌ 間違い1: フレームワーク標準を含める

**間違い**:
```markdown
## CAKEPHP MVC パターン

コントローラーはCakePHP規約に従うべき...
```

**修正**: `~/.claude/skills/php-cakephp/` に移動
- これはフレームワークレベルであり、プロジェクトレベルではない
- `php-cakephp/functional-designer` スキルに属する

#### ❌ 間違い2: 言語標準を含める

**間違い**:
```markdown
## PHPコーディング規約

すべてのコードはPSR-12に従う...
```

**修正**: `~/.claude/skills/php/coding-standards/` に移動
- これは言語レベルであり、プロジェクトレベルではない
- `php/coding-standards` スキルに属する

#### ❌ 間違い3: コンテキストのないルール

**間違い**:
```markdown
## テストルール

テストは良質であるべき
```

**修正**:
```markdown
## プロジェクト固有テスト要件

### テストコメント形式（保証対象/失敗時の損失）

**理由**: テストメンテナンスコストを正当化するビジネス影響文書化が必要

**形式**:
```php
/**
 * 保証対象: [このテストがない場合に保証されないこと]
 * 失敗時の損失: [テストが存在しない場合のビジネスコスト]
 */
```

**例**: [具体例]

**実施**: test-guardian エージェントがこの形式を検証
```

### 6.2 config.yaml の間違い

#### ❌ 間違い1: スキル読み込み順序が逆

**間違い**:
```yaml
agent_skills:
  code-developer:
    - php-cakephp/code-implementer      # 最も具体的を最初に
    - php/coding-standards
    - generic/code-implementer          # 最も抽象的を最後に
```

**修正**:
```yaml
agent_skills:
  code-developer:
    - generic/code-implementer          # 最も抽象的を最初に
    - php/coding-standards
    - php-cakephp/code-implementer      # 最も具体的を最後に
```

**理由**: 後から読み込まれたスキルが前のスキルを上書き。最も具体的なものを最後に読み込むべき。

#### ❌ 間違い2: 汎用エージェントを `agents` セクションに配置

**間違い**:
```yaml
agents:
  code-developer:  # これは汎用エージェント！
    enabled: true
    skills:
      - php-cakephp/code-implementer
```

**修正**:
```yaml
agent_skills:
  code-developer:  # 汎用エージェントは agent_skills へ
    - generic/code-implementer
    - php/coding-standards
    - php-cakephp/code-implementer

agents:
  test-guardian:  # 本質的に技術固有のエージェントのみ
    enabled: true
    skills:
      - php-cakephp/test-validator
```

**理由**: `agents` セクションは本質的に技術固有のエージェント専用（test-guardian、migration-validator）。汎用エージェントは `agent_skills` を使用。

#### ❌ 間違い3: スキル内容を config.yaml に重複

**間違い**:
```yaml
agent_skills:
  code-developer:
    - generic/code-implementer
    - php/coding-standards

# PSR-12ルールをここに重複（既に php/coding-standards スキルにある）
code_standards:
  indentation: 4
  line_length: 120
  naming_convention: camelCase
```

**修正**:
```yaml
agent_skills:
  code-developer:
    - generic/code-implementer
    - php/coding-standards  # PSR-12ルールはスキルで定義

# プロジェクト固有のオーバーライドのみ
code_standards:
  custom_rule: [プロジェクト固有値]
```

**理由**: config.yaml はエージェントとスキルをバインド。スキル内容はスキルディレクトリに存在。

#### ❌ 間違い4: スキルレイヤーの欠落

**間違い**:
```yaml
agent_skills:
  code-developer:
    - php-cakephp/code-implementer  # generic層とlanguage層をスキップ！
```

**修正**:
```yaml
agent_skills:
  code-developer:
    - generic/code-implementer          # Layer 1: 普遍的
    - php/coding-standards              # Layer 2: 言語
    - php-cakephp/code-implementer      # Layer 3: フレームワーク
```

**理由**: 各レイヤーは前のレイヤー上に構築。レイヤーをスキップするとベースパターンを失う。

---

## 7. トラブルシューティング

### 7.1 エージェントがスキルを見つけられない

**症状**: エージェントが「スキルXが見つかりません」と報告

**確認項目**:
1. スキルディレクトリが存在するか: `ls ~/.claude/skills/[スコープ]/[スキル名]/`
2. SKILL.mdファイルが存在するか: `ls ~/.claude/skills/[スコープ]/[スキル名]/SKILL.md`
3. config.yaml のパスがディレクトリ構造と一致するか

### 7.2 間違ったパターンが適用される

**症状**: エージェントが間違ったフレームワークスタイルで出力

**確認項目**:
1. スキル読み込み順序（generic → language → framework）
2. tech_stack メタデータが実際のプロジェクトと一致
3. 最も具体的なスキルが最後に読み込まれているか

### 7.3 スキルが読み込まれない

**症状**: エージェントがスキルが読み込まれていないかのように動作

**確認項目**:
1. config.yaml が正しい場所にあるか: `.claude/config.yaml`
2. config.yaml の構文が正しいか（YAML形式）
3. agent_skills セクションが存在し、内容があるか

---

## 8. 検証チェックリスト

### 8.1 CLAUDE.md 検証

- [ ] **スコープ確認**: すべてのルールがプロジェクト固有（汎用フレームワークルールではない）
- [ ] **根拠文書化**: 各ルールがなぜ存在するかを説明
- [ ] **具体例含む**: 複雑なルールに具体例
- [ ] **一時/恒久明示**: 一時的な場合は明確にマーク
- [ ] **相互参照**: 関連ドキュメントへのリンク
- [ ] **優先順位明示**: AI一般知識を上書きするタイミングを明記
- [ ] **重複なし**: スキル内容と重複しない
- [ ] **メンテナンス計画**: 一時的ルールに期限条件

### 8.2 config.yaml 検証

- [ ] **メタデータ完備**: 必須メタデータフィールドすべて入力
- [ ] **技術スタック正確**: 言語/フレームワークバージョンが実態と一致
- [ ] **エージェントスキル順序**: Generic → Language → Framework → Project
- [ ] **冗長エージェントなし**: `agents` セクションに本質的に技術固有のエージェントのみ
- [ ] **スキル存在確認**: 参照されるすべてのスキルに対応ディレクトリ
- [ ] **プロジェクトパス正確**: すべてのパス設定が実際のプロジェクト構造と一致
- [ ] **依存関係文書化**: リポジトリ間依存関係すべてリスト

---

## 9. 判断基準フローチャート

### 9.1 新しいルール/パターンをどこに定義すべきか

```
新しいルール/パターンを定義する
  ↓
[Q1] すべての[言語]プロジェクトで適用可能か？
  ↓ YES → ~/.claude/skills/[言語]/[スキル名]/
  ↓ NO
  ↓
[Q2] すべての[フレームワーク]プロジェクトで適用可能か？
  ↓ YES → ~/.claude/skills/[言語]-[FW]/[スキル名]/
  ↓ NO
  ↓
[Q3] このプロジェクト固有のルールか？
  ↓ YES → CLAUDE.md または config.yaml
  ↓ NO
  ↓
すべてのプロジェクトで適用可能
  ↓
~/.claude/skills/generic/[スキル名]/
```

### 9.2 新しいエージェントを作成すべきか

```
新しいエージェントが必要と感じる
  ↓
[Q1] このプロセスは技術スタックに関係なく普遍的か？
  ↓ YES → 汎用エージェント作成
  |        場所: ~/.claude/agents/generic/[エージェント名].md
  |        config.yaml: agent_skills セクションで設定
  ↓ NO
  ↓
[Q2] スキルを変更するだけで既存の汎用エージェントで対応可能か？
  ↓ YES → 新しいスキル作成
  |        場所: ~/.claude/skills/[スコープ]/[スキル名]/
  |        config.yaml: 既存エージェントにスキル追加
  ↓ NO
  ↓
[Q3] このエージェントは特定フレームワーク/プロジェクトでのみ必要か？
  ↓ YES → 技術固有エージェント作成
           場所: ~/.claude/agents/[言語]-[FW]/[エージェント名].md
           config.yaml: agents セクションで設定
```

---

## 10. まとめ

### 10.1 重要原則

1. **config.yaml = バインディング層**
   - エージェントとスキルをバインド
   - 技術スタック定義
   - 技術固有エージェント設定

2. **agent_skills = スキル割り当て**
   - 汎用エージェントにスキルをマッピング
   - 順序重要: Generic → Language → Framework → Project
   - 最も具体的なスキルが優先

3. **agents = 本質的に技術固有のエージェント専用**
   - フレームワーク/プロジェクト固有性により存在するエージェントのみ
   - 例: test-guardian、migration-validator、production-verifier
   - 汎用エージェントは `agent_skills` に属する

4. **スキルは ~/.claude/skills/ に配置**
   - 汎用スキル: `~/.claude/skills/generic/`
   - 言語スキル: `~/.claude/skills/[言語]/`
   - フレームワークスキル: `~/.claude/skills/[言語]-[FW]/`

5. **CLAUDE.md はプロジェクト固有ルールのみ**
   - フレームワーク規約 → スキルへ
   - 言語標準 → スキルへ
   - 汎用パターン → スキルへ

### 10.2 設定ワークフロー

```
1. 技術スタック定義（repo_metadata.tech_stack）
   ↓
2. エージェントにスキル割り当て（agent_skills）
   ↓
3. 技術固有エージェント設定（agents - 必要な場合のみ）
   ↓
4. プロジェクト固有設定（paths、database等）
   ↓
5. 設定検証
   ↓
6. 実際のエージェント起動でテスト
```

### 10.3 キーポイント

| 項目 | 内容 |
|------|------|
| **再利用性向上** | スキルを適切なレイヤーに配置し、複数プロジェクトで再利用 |
| **メンテナンス性** | 汎用エージェント + スキル構成により、修正が全プロジェクトに波及 |
| **拡張性** | 新しい技術スタック = スキル追加 + config更新のみ |
| **明確な責任範囲** | 4層モデルにより、どこに何を定義すべきか明確 |

---

## 付録: config.yaml 完全テンプレート

```yaml
# .claude/config.yaml

repo_metadata:
  name: [プロジェクト名]
  type: [プロジェクトタイプ]
  description: [説明]

  tech_stack:
    language: [言語]
    language_version: "[バージョン]"
    framework: [フレームワーク]
    framework_version: "[バージョン]"
    test_framework: [テストFW]
    test_framework_version: "[バージョン]"

agent_skills:
  requirement-analyst:
    - generic/requirement-analyzer
    - [言語]/requirement-patterns
    - [言語]-[FW]/requirement-analyzer

  design-architect:
    - generic/software-designer
    - [言語]/architectural-patterns
    - [言語]-[FW]/functional-designer
    - [言語]-[FW]/database-designer

  test-strategist:
    - generic/test-planner
    - [言語]/testing-standards
    - [言語]-[FW]/test-case-designer

  code-developer:
    - generic/code-implementer
    - [言語]/coding-standards
    - [言語]/security-patterns
    - [言語]-[FW]/code-implementer

  quality-reviewer:
    - generic/code-reviewer
    - [言語]/coding-standards
    - [言語]/security-patterns
    - [言語]-[FW]/code-reviewer

  deliverable-evaluator:
    - generic/evaluation-criteria
    - [言語]-[FW]/deliverable-criteria

agents:
  # 本質的に技術固有のエージェントのみ
  [技術固有エージェント]:
    enabled: true
    [エージェント固有設定]
    skills:
      - [言語]-[FW]/[スキル名]
```
