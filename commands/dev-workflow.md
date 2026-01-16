---
description: Main orchestrator workflow で機能開発をルーティング
argument-hint: "[詳細な要件を複数行で入力]"
---

# Development Workflow

## User Request

$ARGUMENTS

---

## Initialization

```bash
~/.claude/scripts/workflow/init.sh "$(date +%s)" "$ARGUMENTS"
```

## Execution

```yaml
Task:
  subagent_type: main-orchestrator
  description: Execute development workflow
  prompt: |
    Execute the development workflow for:

    $ARGUMENTS
```

## Debug

```bash
~/.claude/scripts/workflow/status.sh
```
