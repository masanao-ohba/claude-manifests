---
name: safe-editing
description: Enforces safe file editing practices - read before write
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: $HOME/.claude/scripts/hooks/verify-file-read.sh
---

# Safe Editing

A generic skill that enforces safe file editing practices across all agents.

## Core Principle

> **Read Before Write**
>
> Always read and understand existing code before modifying it.
> Never edit files blindly based on assumptions.

## When This Skill Applies

This skill should be loaded by any agent that modifies files:
- code-developer
- design-architect
- test-strategist
- Any custom agent with Write/Edit tools

## Configuration

Add this skill to agents in `.claude/config.yaml`:

```yaml
agents:
  code-developer:
    skills:
      - generic/safe-editing
      - # other skills...
```

## Hook Behavior

### PreToolUse (Write|Edit)

Before any Write or Edit operation:
1. Logs the target file path
2. Validates the operation is intentional
3. Allows the operation to proceed (logging for audit)

Future enhancements could:
- Check conversation context for prior Read of the file
- Block edits to files not yet read
- Require explicit confirmation for new file creation

## Why This Matters

1. **Prevents Blind Edits**: Ensures understanding of existing code
2. **Reduces Errors**: Context-aware modifications are safer
3. **Audit Trail**: Logs all file modifications for review
4. **Reusable**: Applies to any agent, not just code-developer
