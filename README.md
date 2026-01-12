# Claude Code Agent Orchestration System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude-Code-blueviolet)](https://claude.ai/code)
[![Version](https://img.shields.io/badge/version-2.1.0-blue)](#)
[![Maintained](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](#)
[![macOS](https://img.shields.io/badge/macOS-compatible-brightgreen)](#)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#)
[![Made with Claude](https://img.shields.io/badge/Made%20with-Claude-orange)](https://claude.ai)

A multi-agent orchestration system for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that enables consistent, reusable AI-assisted development across multiple projects and technology stacks.

## Why This System?

When using Claude Code for complex projects, you may face these challenges:

| Challenge | Without This System | With This System |
|-----------|---------------------|------------------|
| **Inconsistent quality** | AI may skip tests or reviews | Enforced quality gates before completion |
| **Repeated explanations** | Re-explain project rules every session | Rules loaded automatically from config |
| **Complex task handling** | Manual breakdown of large tasks | Automatic routing to specialized agents |
| **Technology switching** | Different prompts for each stack | Skills adapt agents to any technology |

## Table of Contents

- [Quick Start](#quick-start)
- [Key Features](#key-features)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Architecture Overview](#architecture-overview)
- [Reference](#reference)
- [License](#license)

## Quick Start

```bash
# 1. Clone to ~/.claude/
git clone https://github.com/your-repo/claude-orchestration.git ~/.claude

# 2. Install yq (required for config loading)
brew install yq

# 3. Copy templates to your project
cp ~/.claude/templates/CLAUDE.md /path/to/your/project/
mkdir -p /path/to/your/project/.claude
cp ~/.claude/templates/.claude/config.yaml /path/to/your/project/.claude/

# 4. Edit the templates for your project, then start Claude Code
cd /path/to/your/project
claude
```

That's it! The system activates automatically when Claude Code starts.

## Key Features

| Feature | Description |
|---------|-------------|
| **Two-Phase Triage** | Simple requests execute immediately; complex ones get full analysis |
| **Skill-Based Adaptation** | Same agents work with PHP, TypeScript, React, etc. via loadable skills |
| **Quality Gates** | Automatic code review and acceptance criteria verification |
| **Project Rules as Config** | Define constraints in YAML, enforced automatically |
| **Multi-Project Support** | One system, multiple projects with different tech stacks |

## Installation

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) - Anthropic's CLI tool
- **yq** - YAML processor (used by skills to read config)
  ```bash
  brew install yq   # macOS
  # or: pip install yq
  ```

### Setup

```bash
# Clone this repository to ~/.claude/
git clone https://github.com/your-repo/claude-orchestration.git ~/.claude

# Verify installation
ls ~/.claude/agents/    # Should show agent definitions
ls ~/.claude/skills/    # Should show skill definitions
```

## Getting Started

### 1. Copy templates to your project

```bash
cp ~/.claude/templates/CLAUDE.md /path/to/project/CLAUDE.md
mkdir -p /path/to/project/.claude
cp ~/.claude/templates/.claude/config.yaml /path/to/project/.claude/config.yaml
```

### 2. Configure your project

**CLAUDE.md** - Human-readable project context:
- Business rules with reasons and code examples
- Prohibited patterns with explanations
- Architecture decisions

**`.claude/config.yaml`** - Machine-readable settings:
- Agent skill assignments (defines your tech stack)
- Test commands
- Constraints as natural language rules

### 3. Start Claude Code

```bash
cd /path/to/project
claude
```

The main-orchestrator automatically:
1. Classifies your request (trivial or complex)
2. Routes to appropriate agents
3. Enforces quality gates before completion

## Configuration

Configuration lives in `.claude/config.yaml`. Here's what each section does:

| Section | Purpose | Example |
|---------|---------|---------|
| `agents.*` | Which skills each agent loads | `code-developer: [php/coding-standards]` |
| `constraints.*` | Rules enforced during development | Natural language prohibitions |
| `testing.*` | Test execution settings | Docker command, documentation path |
| `git.*` | Git operation policy | auto/user_request_only/prohibited |

### Example Configuration

```yaml
# Define your tech stack via agent skills
agents:
  code-developer:
    skills:
      - php/coding-standards
      - php-cakephp/code-implementer

# Project constraints (natural language rules)
constraints:
  architecture:
    layers:
      - "Controller must not contain business logic."
    dependencies:
      - "No circular dependencies between Models."
  testing:
    prohibited:
      - "Do not mock production code."

# Git settings
git:
  operations:
    commit: user_request_only
    push: user_request_only
```

### Where to Put Information

| Information | Location | Read By |
|-------------|----------|---------|
| Business rules with code examples | `CLAUDE.md` | Human context |
| Constraints as rules | `.claude/config.yaml` | Skills via hooks |
| Test commands | `.claude/config.yaml` | test-implementer skill |
| Agent skill assignments | `.claude/config.yaml` | Each agent |

## Architecture Overview

```mermaid
flowchart TD
    subgraph Entry["🚪 Entry Layer"]
        A[User Request] --> B[quick-classifier]
    end

    subgraph Analysis["🔍 Analysis Layer"]
        B --> C{Trivial?}
        C -->|Yes| D[main-orchestrator<br/>Direct Execution]
        C -->|No| G[goal-clarifier]
        G --> H{Needs<br/>Clarification?}
        H -->|Yes| I[main-orchestrator<br/>Ask User]
        I --> G
        H -->|No| J[task-scale-evaluator]
        J --> K{Scale?}
    end

    subgraph Implementation["⚙️ Implementation Layer"]
        K -->|Complex| M[workflow-orchestrator]
        K -->|Simple| L[code-developer]
        M --> L
        L --> N[test-executor]
        N --> O{Tests Pass?}
        O -->|No| P[test-failure-debugger]
        P --> L
    end

    subgraph Quality["✅ Quality Layer"]
        O -->|Yes| Q[quality-reviewer]
        Q --> R[deliverable-evaluator]
        R --> S{Criteria<br/>Met?}
        S -->|No| L
    end

    G -.->|Acceptance Criteria| R

    subgraph Report["📋 Report Layer"]
        S -->|Yes| T[main-orchestrator<br/>Report Results]
        D --> T
        T --> U[Complete]
    end

    style Entry fill:#e3f2fd,stroke:#1976d2
    style Analysis fill:#fff8e1,stroke:#f9a825
    style Implementation fill:#e8f5e9,stroke:#388e3c
    style Quality fill:#fce4ec,stroke:#c2185b
    style Report fill:#f3e5f5,stroke:#7b1fa2
```

### How It Works

1. **Entry**: Your request goes to `quick-classifier`
2. **Triage**: Simple tasks execute directly; complex ones go through full analysis
3. **Implementation**: `code-developer` writes code, `test-executor` runs tests
4. **Quality**: `quality-reviewer` checks code, `deliverable-evaluator` verifies acceptance criteria
5. **Report**: Results returned to you

### Key Agents

| Agent | What It Does |
|-------|--------------|
| quick-classifier | Decides if request is simple or complex |
| goal-clarifier | Defines what "done" looks like (acceptance criteria) |
| code-developer | Writes code following loaded skills |
| test-executor | Runs tests and reports results |
| quality-reviewer | Reviews code for quality and security |
| deliverable-evaluator | Final check against acceptance criteria |

## Reference

<details>
<summary><strong>Agent Reference (12 agents)</strong></summary>

| Agent | Responsibility | Action |
|-------|----------------|--------|
| quick-classifier | Request classification | Direct execution eligibility |
| goal-clarifier | Requirement analysis | Acceptance criteria definition |
| main-orchestrator | Task routing | Delegate to appropriate agents |
| task-scale-evaluator | Complexity assessment | Simple/complex determination |
| design-architect | Architecture design | Technical design and patterns |
| code-developer | Code implementation | Write code following skills |
| test-strategist | Test planning | Test strategy and case design |
| test-executor | Test execution | Run tests and determine pass/fail |
| test-failure-debugger | Failure analysis | Root cause investigation |
| quality-reviewer | Quality review | Code quality and security check |
| deliverable-evaluator | Acceptance verification | Match against criteria |
| workflow-orchestrator | Workflow coordination | Multi-agent collaboration |

</details>

<details>
<summary><strong>Skill Reference (37 skills)</strong></summary>

### Generic Skills (12)

| Skill | Description |
|-------|-------------|
| acceptance-criteria | Acceptance criteria patterns |
| code-reviewer | Universal code review patterns |
| completion-evaluator | Task completion verification |
| delegation-router | Agent delegation patterns |
| deliverable-validator | Deliverable validation rules |
| design-patterns | SOLID, DRY, KISS patterns |
| evaluation-criteria | Final evaluation standards |
| git-operator | Git operation patterns |
| requirement-analyzer | Requirement analysis patterns |
| task-scaler | Task complexity evaluation |
| test-implementer | Test implementation patterns |
| workflow-patterns | Workflow coordination patterns |

### PHP Skills (3)

| Skill | Description |
|-------|-------------|
| coding-standards | PSR-12 and PHP best practices |
| security-patterns | OWASP, input validation |
| testing-standards | PHPUnit best practices |

### PHP-CakePHP Skills (12)

| Skill | Description |
|-------|-------------|
| code-implementer | CakePHP MVC patterns |
| code-reviewer | CakePHP code review |
| database-designer | Database schema design |
| fixture-generator | Test fixture generation |
| functional-designer | Functional specification |
| migration-checker | Migration validation |
| multi-tenant-db-handler | Multi-tenant patterns |
| refactoring-advisor | Refactoring recommendations |
| requirement-analyzer | CakePHP requirements |
| test-case-designer | Test case design |
| test-validator | Test quality validation |

### TypeScript Skills (10)

| Skill | Description |
|-------|-------------|
| typescript/coding-standards | TypeScript best practices |
| typescript-react/* | React patterns (5 skills) |
| typescript-nextjs/* | Next.js patterns (3 skills) |
| typescript-react-query/patterns | TanStack Query patterns |
| typescript-zustand/patterns | Zustand state patterns |

</details>

<details>
<summary><strong>Hook Usage Matrix (Advanced)</strong></summary>

### Agent Hooks

| Agent | SessionStart | PreToolUse | SubagentStop | Stop |
|-------|:------------:|:----------:|:------------:|:----:|
| quick-classifier | - | - | - | - |
| goal-clarifier | - | - | ✅️ | - |
| main-orchestrator | - | - | - | ✅️ |
| task-scale-evaluator | - | - | ✅️ | - |
| design-architect | - | - | ✅️ | - |
| code-developer | - | ✅️ | ✅️ | - |
| test-strategist | - | - | ✅️ | - |
| test-executor | - | - | ✅️ | - |
| test-failure-debugger | - | - | ✅️ | - |
| quality-reviewer | - | - | ✅️ | - |
| deliverable-evaluator | ✅️ | ✅️ | ✅️ | - |
| workflow-orchestrator | - | - | ✅️ | - |

### Skill Hooks (Config Loading)

| Skill | SessionStart | PostToolUse | config.yaml Key |
|-------|:------------:|:-----------:|-----------------|
| generic/git-operator | ✅️ | - | `.output.language`, `.git` |
| generic/test-implementer | ✅️ | - | `.testing`, `.constraints.testing` |
| generic/task-scaler | ✅️ | - | `.task_scaling.thresholds` |
| generic/code-reviewer | ✅️ | - | `.constraints` |
| php/coding-standards | ✅️ | ✅️ | `.coding_standards` |
| typescript/coding-standards | ✅️ | ✅️ | `.coding_standards` |
| php-cakephp/test-validator | ✅️ | - | `.constraints.testing`, `.constraints.schema` |
| php-cakephp/code-implementer | ✅️ | - | `.constraints.architecture` |
| php-cakephp/code-reviewer | ✅️ | - | `.constraints.architecture`, `.constraints` |

**Architecture Principle:**
- **Skills**: Load project-specific rules via `yq` from `.claude/config.yaml`
- **Agents**: Chain control only (SubagentStop, Stop) - no rule-based hooks

</details>

<details>
<summary><strong>Skill Usage Matrix (Advanced)</strong></summary>

| Agent | Uses Skills |
|-------|-------------|
| goal-clarifier | requirement-analyzer, acceptance-criteria |
| main-orchestrator | workflow-patterns, task-scaler, delegation-router |
| task-scale-evaluator | requirement-analyzer, task-scaler |
| design-architect | design-patterns |
| test-executor | test-implementer |
| quality-reviewer | code-reviewer |
| deliverable-evaluator | completion-evaluator, evaluation-criteria, deliverable-validator |
| workflow-orchestrator | git-operator |

Language/Framework skills (e.g., `php-cakephp/*`) are loaded per-project via `agents.*.skills` in config.yaml.

</details>

## License

MIT License - See [LICENSE](LICENSE) file for details.

---

**Version**: 2.1.0
**Last Updated**: 2025-01-12
