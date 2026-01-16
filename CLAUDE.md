# CLAUDE.md - Agent Orchestration System

This is the development repository for the Claude Code Agent Orchestration System.

---

## 5 Core Principles (Primary Objectives)

These principles define what the orchestration system MUST achieve. All development decisions must serve these principles.

### Principle 1: Skill-Based Delegation

**Goal**: Tasks are delegated to agents with appropriate skills loaded from `.claude/config.yaml`.

**Enforcement Mechanisms**:
- Skills load project-specific rules via `SessionStart` hooks using `yq`
- Agent-skill mapping is defined in project's `.claude/config.yaml` under `agents.<name>.skills`
- Agents remain tech-stack agnostic; Skills adapt them to specific frameworks

**Verification**: Agent receives skill-injected context before processing any task.

### Principle 2: Autonomous Workflow

**Goal**: Each agent operates autonomously according to the defined workflow without requiring user intervention.

**Enforcement Mechanisms**:
- `PreToolUse` hooks validate agent calls (e.g., WO can only call implementation agents)
- `PostToolUse` hooks update workflow state
- `Stop` hooks verify completion conditions before allowing agent termination

**Verification**: Agent chain executes to completion without manual intervention.

### Principle 3: Achievement Criteria & Evaluation Loop

**Goal**: goal-clarifier defines acceptance criteria, deliverable-evaluator evaluates, workflow loops until PASS.

**Enforcement Mechanisms**:
- GC outputs mandatory `acceptance_criteria` with verification methods
- DE evaluates each criterion as PASS/FAIL with evidence
- WO retry loop continues until DE verdict is PASS
- `Stop` hook on WO prevents premature termination if evaluation incomplete

**Verification**: Every task produces a PASS verdict from DE before completion.

### Principle 4: Task Division

**Goal**: Prevent early termination by dividing tasks into achievable units.

**Enforcement Mechanisms**:
- task-scale-evaluator breaks medium/large tasks into subtasks
- Each subtask has clear dependencies and acceptance criteria
- WO iterates through subtasks, completing each before proceeding

**Verification**: Large tasks are broken into ≥2 subtasks with explicit dependencies.

### Principle 5: Parallel Processing

**Goal**: Independent tasks are processed in parallel to maximize efficiency.

**Enforcement Mechanisms**:
- TSE defines `parallel_groups` for independent subtasks
- WO executes parallel groups concurrently using multiple Task calls
- Dependencies are respected; parallel execution only for truly independent work

**Verification**: Independent subtasks execute in parallel, dependent ones execute sequentially.

---

## Principle Enforcement via Hooks

Hooks are the PRIMARY mechanism for enforcing principles. Agent prompts are the LAST resort.

### Available Hook Events

| Hook | Trigger | Use Case |
|------|---------|----------|
| `PreToolUse` | Before tool execution | Validate allowed operations |
| `PostToolUse` | After tool execution | Update state, log progress |
| `Stop` | Before main agent termination | Verify completion conditions |
| `SubagentStop` | Before subagent termination | Verify subagent completion |
| `SessionStart` | At session start | Load context, initialize state |

### Hook Types

| Type | Description | Supported Events |
|------|-------------|------------------|
| `type: command` | Executes shell script | All events |
| `type: prompt` | LLM evaluates context | PreToolUse, Stop, SubagentStop, UserPromptSubmit |

**Note**: Use `type: prompt` for intelligent, context-aware decisions. Use `type: command` for deterministic validation.

### Hook Examples by Principle

**Principle 2 (Autonomous Workflow) - PreToolUse validation:**
```yaml
hooks:
  PreToolUse:
    - matcher: "Task"
      hooks:
        - type: command
          command: |
            ALLOWED="code-developer test-executor quality-reviewer deliverable-evaluator"
            REQUESTED=$(echo "${TOOL_INPUT:-{}}" | jq -r '.subagent_type // empty')
            if ! echo "${ALLOWED}" | grep -qw "${REQUESTED}"; then
              echo "BLOCKED: Cannot call ${REQUESTED}" >&2
              exit 1
            fi
```

**Principle 3 (Evaluation Loop) - SubagentStop validation:**
```yaml
hooks:
  SubagentStop:
    - hooks:
        - type: prompt
          once: true
          prompt: |
            Before completing, verify the MANDATORY chain was followed:
            - [ ] code-developer - Implementation complete?
            - [ ] test-executor - Tests executed and passing?
            - [ ] quality-reviewer - Code quality reviewed?
            - [ ] deliverable-evaluator - Evaluated against acceptance_criteria?
            If ANY agent was skipped → respond {"ok": false, "reason": "..."}.
            Otherwise → respond {"ok": true}.
```

---

## Development Constraints

When developing agents, skills, or commands, follow these constraints:

### Constraint 1: Verify Before Describing

When describing file structures or system configurations, always verify the actual state beforehand.

```bash
# Good: Verify then describe
ls -la agents/generic/
# Then document based on actual output

# Bad: Assume structure exists
```

### Constraint 2: Consider Possibility Before Impossibility

Before concluding something is "impossible," consider the conditions that would make it possible.

**Example**: "Hooks cannot enforce X" → "What hook configuration WOULD enforce X?"

### Constraint 3: Justify Changes with Principles

Any changes must be justified with: "To achieve Principle X, we need..."

**Example**:
- "To achieve Principle 3 (Evaluation Loop), WO must retry until DE returns PASS"
- "To achieve Principle 5 (Parallel Processing), TSE must group independent subtasks"

### Constraint 4: Investigation → Specific Actions

After investigation and consideration, determine specific next actions.

**Template**:
1. Current state: [what exists now]
2. Gap: [what's missing for Principle X]
3. Action: [specific change to close the gap]

---

## Repository Structure

```
~/.dotfiles/claude/.claude/
├── agents/           # Agent definitions
│   └── generic/      # Generic agents for any project
├── skills/           # Skill definitions
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

## Agent Development

Agents are defined in `agents/generic/*.md` with YAML frontmatter:

```yaml
---
name: agent-name
description: Brief description
tools: Tool1, Tool2, Tool3
model: inherit
hooks:
  PreToolUse:
    - matcher: "ToolName"
      hooks:
        - type: command
          command: validation-script.sh
        - type: prompt
          prompt: "Verify this action is necessary."
  SubagentStop:
    - hooks:
        - type: prompt
          once: true
          prompt: |
            Verify completion before returning:
            1. Task completed successfully?
            2. Output meets requirements?
            Return summary.
---
```

**Hook Placement Guidelines**:
- **Agent hooks**: Control workflow behavior (completion verification, chain enforcement)
- **Skill hooks**: Inject project-specific rules (testing requirements, coding standards)

**Principles Applied**:
- Each agent has a single, clear responsibility (Principle 2)
- Use `type: prompt` for intelligent verification (Principle 3)
- Use `type: command` for deterministic workflow control (Principle 2)
- Agents do NOT load project rules - Skills do that (Principle 1)
- Keep tool access minimal (principle of least privilege)

## Skill Development

Skills are defined in `skills/<category>/*.md`:

```yaml
---
name: skill-name
description: Brief description
hooks:
  SessionStart:
    - type: command
      command: |
        # Load config from .claude/config.yaml (Principle 1)
        yq '.constraints.testing' .claude/config.yaml 2>/dev/null
---
```

**Principles Applied**:
- Skills load project-specific rules via `yq` from `.claude/config.yaml` (Principle 1)
- Skills are loaded per-agent via `agents.<name>.skills` in config (Principle 1)
- Generic skills work across all tech stacks
- Language-specific skills contain framework patterns

## Command Development

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

**Important**: Commands are provided by this repository. Avoid requiring users to modify other settings (like settings.json) to use these commands.

## Data Flow Design

The `task` object flows through the agent chain:

```
main-orchestrator
    ↓
goal-clarifier          → Produces: task.acceptance_criteria (Principle 3)
    ↓
task-scale-evaluator    → Adds: evaluation.subtasks, parallel_groups (Principles 4, 5)
    ↓
workflow-orchestrator   → Executes chain, loops until PASS (Principles 2, 3)
    ↓
    ├── code-developer
    ├── test-executor
    ├── quality-reviewer
    └── deliverable-evaluator → Returns: verdict PASS/FAIL (Principle 3)
```

**Task Object Structure:**
```yaml
task:
  description: "What needs to be done"
  goals: [...]
  acceptance_criteria:    # Principle 3: MANDATORY
    - criterion: "What must be true"
      verification: "How to verify"
      priority: high|medium|low
  assumptions: [...]

evaluation:
  task_scale: trivial|small|medium|large
  subtasks:               # Principle 4: For medium/large tasks
    - id: "1"
      description: "..."
      dependencies: []
  parallel_groups:        # Principle 5: Independent work
    - ["1", "3"]
    - ["2"]
```

## Testing Changes

After modifying agents or skills:

1. Test in a sample project with `/dev-workflow`
2. Verify agent chain executes correctly (Principle 2)
3. Check that hooks fire at appropriate times (Enforcement)
4. Confirm task object flows through chain intact (Principle 3)
5. Verify DE evaluates against acceptance criteria (Principle 3)
6. Test parallel execution for independent subtasks (Principle 5)

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
- **Skills are stateless** - they only inject rules at session start (Principle 1)
- **Agents don't know about specific tech stacks** - Skills adapt them (Principle 1)
- **config.yaml keys are the contract** between Skills and project config (Principle 1)
- **Hooks enforce workflow** - Prompts are last resort (Enforcement preference)
- **Every task needs acceptance criteria** - No criteria = no completion (Principle 3)
