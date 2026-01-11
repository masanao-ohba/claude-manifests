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
| Test comment format compliance | quality-reviewer | YES |
| Security check | quality-reviewer | YES |

---

## Review Guidelines

### Code Review (referenced by quality-reviewer)

| Aspect | Check Items |
|--------|-------------|
| Security | SQL injection, XSS, CSRF vulnerabilities |
| Performance | N+1 queries, large data processing considerations |
| Error Handling | No silent failures, appropriate logging |
| Readability | Naming conventions, comments, separation of concerns |
| Testability | Dependency injection, mockable design |

### Test Review (referenced by test-strategist)

| Aspect | Check Items |
|--------|-------------|
| Coverage | Major paths are covered |
| Boundary Values | Edge cases are tested |
| Error Cases | Error scenarios are verified |
| Independence | No inter-test dependencies |
| Reproducibility | No execution order dependencies |

### Deliverable Evaluation (referenced by deliverable-evaluator)

| Aspect | Check Items |
|--------|-------------|
| Requirements Met | Satisfies defined functionality |
| No Regression | No impact on existing features |
| Documentation | Necessary updates completed |
| Acceptance Criteria | Meets completion criteria |

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

### Build

```bash
{{BUILD_COMMAND}}
```

---

## Historical Context

| Decision | Reason | Date |
|----------|--------|------|
| {{DECISION_1}} | {{DECISION_REASON_1}} | {{DECISION_DATE_1}} |

---

## Related Documentation

- `.claude/config.yaml` - Testing configuration (only fields read by Skills)
- `tests/README.md` - Project-specific test rules
- `~/.claude/CLAUDE.md` - Global main-orchestrator configuration
- `~/.claude/agents/` - Agent definitions
- `~/.claude/skills/` - Skill definitions

---

## Configuration Note

`.claude/config.yaml` defines:
1. **agent_skills** - Which skills are used by which agents (implicitly defines tech stack)
2. **skills.\*** - Skill-specific customization rules
3. **testing.\*** - Test execution configuration

```yaml
agent_skills:
  code-developer:
    - php/coding-standards
    - php-cakephp/code-implementer

skills:
  test-validator:
    enabled: true

testing:
  command: "{{TEST_COMMAND}}"
  rules:
    documentation: "tests/README.md"
```

Project metadata (architecture, business rules, prohibited patterns) should be documented in this CLAUDE.md file.
