# CLAUDE.md - Agent Orchestration System

This is the development repository for the Claude Code Agent Orchestration System.

## Repository Structure

```
~/.claude/
├── agents/           # Agent definitions (12 agents)
│   └── generic/      # Generic agents for any project
├── skills/           # Skill definitions (37 skills)
│   ├── generic/      # Universal skills
│   ├── php/          # PHP-specific skills
│   ├── php-cakephp/  # CakePHP-specific skills
│   └── typescript*/  # TypeScript/React/Next.js skills
├── commands/         # Custom slash commands
│   └── dev-workflow.md
└── templates/        # Configuration templates
    └── .claude/
        └── config.yaml
```

## Development Guidelines

### Agent Development

Agents are defined in `agents/generic/*.md` with YAML frontmatter:

```yaml
---
name: agent-name
description: Brief description
tools: Tool1, Tool2, Tool3
model: inherit
hooks:
  SubagentStop:
    - type: prompt
      prompt: |
        Verification prompt here
---
```

**Principles:**
- Each agent has a single, clear responsibility
- Use `SubagentStop` hooks for chain control (pass task to next agent)
- Agents do NOT load project rules - Skills do that via `SessionStart` hooks
- Keep tool access minimal (principle of least privilege)

### Skill Development

Skills are defined in `skills/<category>/*.md`:

```yaml
---
name: skill-name
description: Brief description
hooks:
  SessionStart:
    - type: command
      command: |
        # Load config from .claude/config.yaml
        yq '.constraints.testing' .claude/config.yaml 2>/dev/null
---
```

**Principles:**
- Skills load project-specific rules via `yq` from `.claude/config.yaml`
- Skills are loaded per-agent via `agents.<name>.skills` in config
- Generic skills work across all tech stacks
- Language-specific skills (php/, typescript/) contain framework patterns

### Command Development

Custom commands are defined in `commands/*.md`:

```yaml
---
description: Command description
context: fork
agent: target-agent
argument-hint: "[hint for user]"
---

# Command Title

$ARGUMENTS
```

### Data Flow Design

The `task` object flows through the agent chain:

```
goal-clarifier → task-scale-evaluator → workflow-orchestrator → deliverable-evaluator
                        (task object passed via prompt)
```

**Task Object Structure:**
```yaml
task:
  description: "What needs to be done"
  goals: [...]
  acceptance_criteria:
    - criterion: "What must be true"
      verification: "How to verify"
      priority: high|medium|low
  assumptions: [...]
```

## Testing Changes

After modifying agents or skills:

1. Test in a sample project with `/dev-workflow`
2. Verify agent chain executes correctly
3. Check that hooks fire at appropriate times
4. Confirm task object flows through chain intact

## File Naming Conventions

| Type | Location | Naming |
|------|----------|--------|
| Agent | `agents/generic/` | `<role>.md` (e.g., `code-developer.md`) |
| Generic Skill | `skills/generic/` | `<function>.md` (e.g., `code-reviewer.md`) |
| Language Skill | `skills/<lang>/` | `<function>.md` |
| Framework Skill | `skills/<lang>-<framework>/` | `<function>.md` |
| Command | `commands/` | `<command-name>.md` |

## Architecture Constraints

- **No circular dependencies** between agents
- **Skills are stateless** - they only inject rules at session start
- **Agents don't know about specific tech stacks** - Skills adapt them
- **config.yaml keys are the contract** between Skills and project config
