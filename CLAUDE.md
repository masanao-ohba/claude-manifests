# CLAUDE.md - Agent Orchestration System

This is the development repository for the Claude Code Agent Orchestration System.

---

## 5 Core Principles (Primary Objectives)

These principles define what the orchestration system MUST achieve. All development decisions must serve these principles.

### Principle 1: Skill-Based Delegation

**Goal**: Tasks are delegated to agents with appropriate skills loaded from `.claude/config.yaml`.

**Enforcement Mechanisms**:
- Agent `PreToolUse` hooks load **agent↔skill mapping** from `.claude/config.yaml` (using `yq` when available)
- Skill customization values are loaded by **skill hooks** when the skill runs (via the shared load-config-context hook with `scope=skill`)
- Agent-skill mapping is defined in project's `.claude/config.yaml` under `agents.<name>.skills`
- Agents remain tech-stack agnostic; Skills adapt them to specific frameworks

**Missing config handling**:
- If `.claude/config.yaml` or `yq` is unavailable, hooks log a warning and continue without blocking

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

**Agents/Skills (*.md files)** - Limited support:

| Hook | Trigger | Use Case |
|------|---------|----------|
| `PreToolUse` | Before tool execution | Validate allowed operations |
| `PostToolUse` | After tool execution | Update state, log progress |
| `Stop` | Before agent termination | Verify completion conditions |

**settings.json / settings.local.json only** - Full support:

| Hook | Trigger | Use Case |
|------|---------|----------|
| `SubagentStop` | Before subagent termination | Verify subagent completion |
| `SessionStart` | At session start | Load context, initialize state |
| `UserPromptSubmit` | Before user prompt processing | Validate/transform user input |

### Hook Types

| Type | Where Supported | Description |
|------|-----------------|-------------|
| `type: command` | Agents/Skills, settings.json | Executes shell script |
| `type: prompt` | settings.json only | LLM evaluates context |

**Note**: Agents/Skills support only `type: command`. Use `type: prompt` in settings.json for intelligent, context-aware decisions.

### Hook Environment Variables

Hooks receive context via environment variables. **Leverage these to maximize inter-agent collaboration.**

| Variable | Available In | Description |
|----------|--------------|-------------|
| `TOOL_NAME` | PreToolUse, PostToolUse | Name of the tool being called |
| `TOOL_INPUT` | PreToolUse, PostToolUse | JSON input to the tool |
| `TOOL_OUTPUT` | PostToolUse | JSON output from the tool |
| `CLAUDE_CONVERSATION` | All hooks | Full conversation context (JSON) |
| `CLAUDE_FILE_PATHS` | All hooks | Files mentioned in conversation |

**Inter-Agent Collaboration Examples:**

```yaml
# Extract subagent type and prompt for Task tool calls
hooks:
  PreToolUse:
    - matcher: "Task"
      hooks:
        - type: command
          command: |
            # Parse Task tool input for orchestration decisions
            SUBAGENT=$(echo "${TOOL_INPUT}" | jq -r '.subagent_type // empty')
            PROMPT=$(echo "${TOOL_INPUT}" | jq -r '.prompt // empty')
            DESCRIPTION=$(echo "${TOOL_INPUT}" | jq -r '.description // empty')

            # Log agent invocation for workflow tracking
            echo "[WORKFLOW] Calling ${SUBAGENT}: ${DESCRIPTION}" >> /tmp/agent-flow.log

            # Validate agent chain order
            LAST_AGENT=$(tail -1 /tmp/agent-chain.log 2>/dev/null || echo "")
            echo "${SUBAGENT}" >> /tmp/agent-chain.log
```

```yaml
# Capture agent results for downstream agents
hooks:
  PostToolUse:
    - matcher: "Task"
      hooks:
        - type: command
          command: |
            # Store agent output for next agent in chain
            SUBAGENT=$(echo "${TOOL_INPUT}" | jq -r '.subagent_type // empty')
            echo "${TOOL_OUTPUT}" > /tmp/last-${SUBAGENT}-output.json

            # Pass acceptance criteria between agents
            if [ "${SUBAGENT}" = "goal-clarifier" ]; then
              echo "${TOOL_OUTPUT}" | jq '.acceptance_criteria' > /tmp/acceptance-criteria.json
            fi
```

```yaml
# Validate completion with accumulated context
hooks:
  Stop:
    - hooks:
        - type: command
          command: |
            # Check if all required agents were called
            REQUIRED="goal-clarifier code-developer test-executor deliverable-evaluator"
            CALLED=$(cat /tmp/agent-chain.log 2>/dev/null | sort -u | tr '\n' ' ')

            for agent in ${REQUIRED}; do
              if ! echo "${CALLED}" | grep -qw "${agent}"; then
                echo "ERROR: ${agent} was not called" >&2
                exit 1
              fi
            done

            # Verify final evaluation passed
            VERDICT=$(cat /tmp/last-deliverable-evaluator-output.json | jq -r '.verdict // empty')
            if [ "${VERDICT}" != "PASS" ]; then
              echo "ERROR: Deliverable evaluation did not PASS" >&2
              exit 1
            fi
```

### Hook Examples by Principle

**Agents/Skills (type: command only):**

```yaml
# Principle 2 (Autonomous Workflow) - PreToolUse validation
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

**settings.json only (type: prompt, SubagentStop, SessionStart):**

```json
// Principle 3 (Evaluation Loop) - SubagentStop validation
{
  "hooks": {
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "once": true,
            "prompt": "Before completing, verify the MANDATORY chain was followed:\n- code-developer - Implementation complete?\n- test-executor - Tests executed and passing?\n- quality-reviewer - Code quality reviewed?\n- deliverable-evaluator - Evaluated against acceptance_criteria?\nIf ANY agent was skipped → respond {\"ok\": false, \"reason\": \"...\"}.\nOtherwise → respond {\"ok\": true}."
          }
        ]
      }
    ]
  }
}
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
  Stop:
    - hooks:
        - type: command
          command: |
            # Verify completion before allowing termination
            echo "Agent completing task"
---
```

**Supported hooks in Agents/Skills:**
- `PreToolUse`, `PostToolUse`, `Stop` only
- `type: command` only (no `type: prompt`)

**Hook Placement Guidelines**:
- **Agent hooks**: Control workflow behavior (completion verification, chain enforcement)
- **Skill hooks**: Inject project-specific rules (testing requirements, coding standards)

**Principles Applied**:
- Each agent has a single, clear responsibility (Principle 2)
- Use `type: command` for deterministic workflow control (Principle 2)
- Agents do NOT load project rules - Skills do that (Principle 1)
- Keep tool access minimal (principle of least privilege)
- For `type: prompt` hooks, use settings.json instead

## Skill Development

Skills are defined in `skills/<category>/*.md`:

```yaml
---
name: skill-name
description: Brief description
hooks:
  PreToolUse:
    - matcher: "Write"
      hooks:
        - type: command
          command: |
            # Validate file operations based on project rules
            FILE_PATH=$(echo "${TOOL_INPUT:-{}}" | jq -r '.file_path // empty')
            echo "Writing to: ${FILE_PATH}"
  Stop:
    - hooks:
        - type: command
          command: |
            echo "Skill cleanup complete"
---
```

**Supported hooks in Skills (same as Agents):**
- `PreToolUse`, `PostToolUse`, `Stop` only
- `type: command` only

**For SessionStart hooks** (loading project config at session start), use settings.json:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "yq '.constraints.testing' .claude/config.yaml 2>/dev/null"
      }
    ]
  }
}
```

**Principles Applied**:
- Skills are loaded per-agent via `agents.<name>.skills` in config (Principle 1)
- Generic skills work across all tech stacks
- Language-specific skills contain framework patterns
- Project-specific config loading requires SessionStart in settings.json

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
