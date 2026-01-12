# CLAUDE.md - {{PROJECT_NAME}}

**Configuration Status**: PERMANENT
**Main Agent**: You are **main-orchestrator** agent. (config: `~/.claude/CLAUDE.md`)

---

## Project Overview

{{PROJECT_DESCRIPTION}}

### Repository Structure (for multi-repository projects)

```
{{REPOSITORY_STRUCTURE}}
```

### Dependencies

| Direction | Repository |
|-----------|------------|
| **Referenced by** | {{REFERENCED_BY}} |
| **Depends on** | {{DEPENDS_ON}} |

---

## Architecture

### Technology Stack

| Item | Value |
|------|-------|
| Language | {{LANGUAGE}} {{LANGUAGE_VERSION}} |
| Framework | {{FRAMEWORK}} {{FRAMEWORK_VERSION}} |
| Test Framework | {{TEST_FRAMEWORK}} |
| Database | {{DATABASE_TYPE}} |

### Database Configuration (for multi-tenant)

| Schema | Database Name | Purpose |
|--------|---------------|---------|
| {{SCHEMA_NAME}} | {{DATABASE_PATTERN}} | {{SCHEMA_PURPOSE}} |

---

## Business Rules

### 1. {{BUSINESS_RULE_1_TITLE}}

{{BUSINESS_RULE_1_DESCRIPTION}}

### 2. {{BUSINESS_RULE_2_TITLE}}

{{BUSINESS_RULE_2_DESCRIPTION}}

---

## Prohibited Patterns

### 1. {{PROHIBITED_PATTERN_1_TITLE}}

```{{LANGUAGE_EXTENSION}}
// NG
{{PROHIBITED_EXAMPLE_1}}

// OK
{{CORRECT_EXAMPLE_1}}
```

**Reason**: {{PROHIBITION_REASON_1}}

### 2. {{PROHIBITED_PATTERN_2_TITLE}}

```{{LANGUAGE_EXTENSION}}
// NG
{{PROHIBITED_EXAMPLE_2}}

// OK
{{CORRECT_EXAMPLE_2}}
```

**Reason**: {{PROHIBITION_REASON_2}}

---

## Quality Gates

All checks must PASS before merge:

| Check Item | Assigned Agent | Required |
|------------|----------------|----------|
| All tests pass | test-executor | YES |
| No static analysis errors | quality-reviewer | YES |
| Coding standards compliance | quality-reviewer | YES |
| Security check | quality-reviewer | YES |

---

## Development Commands

### Run Tests

```bash
{{TEST_COMMAND}}
```

### Code Quality

```bash
{{LINT_COMMAND}}
```

---

## Historical Context

| Decision | Reason | Date |
|----------|--------|------|
| {{DECISION_1}} | {{DECISION_REASON_1}} | {{DECISION_DATE_1}} |

---

## Configuration Files

### Responsibility Separation

| File | Purpose | Content Type |
|------|---------|--------------|
| `CLAUDE.md` | Human-readable context | Project overview, code examples, reasons |
| `.claude/config.yaml` | Machine-readable config | Keys read by Skills via hooks |

### .claude/config.yaml Key Mapping

Keys are read by Skills via SessionStart hooks:

| Key | Read by Skill | Purpose |
|-----|---------------|---------|
| `output.language` | generic/git-operator | Commit message language |
| `testing.*` | generic/test-implementer | Test execution rules |
| `task_scaling.thresholds` | generic/task-scaler | Task scale classification |
| `coding_standards` | php/coding-standards, php-cakephp/code-implementer | Coding standards settings |
| `git.*` | generic/git-operator | Git operation policy |
| `constraints.testing` | generic/test-implementer, php-cakephp/test-validator | Test constraints |
| `constraints.architecture` | php-cakephp/code-implementer, php-cakephp/code-reviewer | Architecture constraints |
| `constraints.*` | generic/code-reviewer | All project constraints |
| `agents.<name>.skills` | Each agent (Context) | Skills to load |

### What Goes Where

**In CLAUDE.md (this file)**:
- Project overview and architecture
- Business rules with **reasons and context**
- Prohibited patterns with **code examples**
- Historical decisions and rationale

**In .claude/config.yaml**:
- Machine-parseable settings (commands, thresholds)
- Agent-skill assignments
- Constraints as **natural language rules** (without code examples)

---

## Related Documentation

- `.claude/config.yaml` - Project configuration (keys read by Skills)
- `tests/README.md` - Project-specific test rules
- `~/.claude/CLAUDE.md` - Global main-orchestrator configuration
- `~/.claude/agents/` - Agent definitions
- `~/.claude/skills/` - Skill definitions
