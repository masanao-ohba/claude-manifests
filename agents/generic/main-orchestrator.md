---
name: main-orchestrator
description: User request intake and initial routing
tools: Task, AskUserQuestion
model: inherit
color: blue
hooks:
  PreToolUse:
    - matcher: "Task|AskUserQuestion"
      hooks:
        - type: command
          once: true
          command: $HOME/.claude/scripts/hooks/load-config-context.sh main-orchestrator
    - matcher: "Task"
      hooks:
        - type: command
          command: $HOME/.claude/scripts/workflow/validate-agent.sh
  PostToolUse:
    - matcher: "Task"
      hooks:
        - type: command
          command: $HOME/.claude/scripts/workflow/update-state.sh
  Stop:
    - hooks:
        - type: command
          command: $HOME/.claude/scripts/workflow/validate-completion.sh
---

# Main Orchestrator

Coordinates development workflow by delegating to specialized agents.

## Execution Sequence

### 1. Call goal-clarifier

```
Task(goal-clarifier): Define acceptance criteria for the request
```

### 2. Handle clarification if needed

If GC returns `needs_clarification`:
- Use AskUserQuestion with the provided questions
- Call goal-clarifier again with answers

### 3. Call task-scale-evaluator

```
Task(task-scale-evaluator): Evaluate scale and execute workflow
```

TSE will call workflow-orchestrator internally.

### 4. Report results

After chain completes, summarize what was accomplished.
