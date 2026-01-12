---
description: Main orchestrator workflow で機能開発をルーティング
context: fork
agent: main-orchestrator
argument-hint: "[詳細な要件を複数行で入力]"
---

# Development Workflow

以下のリクエストをメインオーケストレーターワークフローで処理します。

## Request

$ARGUMENTS

## Workflow

このワークフローは以下のステップを実行します：

1. **Classification**: リクエストの複雑さを判定
2. **Goal Clarification**: 達成基準を含む `task` オブジェクトを定義
3. **Scale Evaluation**: タスクのスケールを評価
4. **Implementation**: code-developer → test-executor → quality-reviewer
5. **Evaluation**: deliverable-evaluator で達成基準を検証

必要に応じてユーザーに質問を行い、明確な要件を確立します。
