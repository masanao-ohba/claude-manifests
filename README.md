# Skill-Driven Agent Configuration Guide

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=flat&logo=gnu-bash&logoColor=white)
![YAML](https://img.shields.io/badge/yaml-%23ffffff.svg?style=flat&logo=yaml&logoColor=151515)
![Documentation](https://img.shields.io/badge/documentation-guide-blue.svg)

## Overview

This guide defines how to configure `~/.claude/agents`, `~/.claude/skills`, `.claude/config.yaml`, and `CLAUDE.md`, along with their respective areas of responsibility.

### Architecture Principles

```
Agent = Generic Process Executor
Skill = Domain Knowledge Provider
config.yaml = Binding Layer
CLAUDE.md = Project-Specific Rules
```

### Responsibility Layer Model (4 Layers)

| Layer | Location | Responsibility | Reusability | Examples |
|-------|----------|---------------|-------------|----------|
| **Level 1: Generic** | `~/.claude/skills/generic/` | Universal Patterns | ⭐⭐⭐⭐⭐ All Tech Stacks | MoSCoW, SMART, AAA |
| **Level 2: Language** | `~/.claude/skills/[language]/` | Language-Level Standards | ⭐⭐⭐⭐ All [language] Projects | PSR-12, PHPUnit, PEP-8 |
| **Level 3: Framework** | `~/.claude/skills/[language]-[FW]/` | Framework Conventions | ⭐⭐⭐ All [FW] Projects | CakePHP MVC, Django MVT |
| **Level 4: Project** | `CLAUDE.md`, `config.yaml` | Project-Specific Rules | ⭐ Project Only | Test Comment Format, Multi-Repo Config |

---

## 1. Responsibility Definition

### 1.1 CLAUDE.md Responsibility Scope

**Role**: Define project-specific rules (override default behavior)

**Should Include**:
- Project-specific conventions (unique rules not applicable to other projects)
- Team-specific workflows (outside standard framework patterns)
- Project-specific constraints (multi-repository configuration, legacy patterns)
- Custom documentation formats
- Project-specific quality gates
- Repository-specific file paths and structure
- Project-specific approval flows

**Should NOT Include**:
- Language coding standards → `[language]/coding-standards` skill
- Framework conventions → `[language]-[FW]/` skill
- Test framework patterns → `[language]/testing-standards` skill
- Security best practices → `[language]/security-patterns` skill
- Generic patterns → `generic/` skill

### 1.2 config.yaml Responsibility Scope

**Role**: Agent and skill binding definition

**Main Sections**:

| Section | Role | Required/Optional |
|---------|------|------------------|
| `repo_metadata` | Project info & tech stack definition | Required |
| `agent_skills` | Skill assignment to generic agents | Required |
| `agents` | Technology-specific agent settings | Optional |
| `database` | Database settings | Optional |
| `test` | Test execution settings | Optional |
| `paths` | File path settings | Optional |
| `dependencies` | Dependency definitions | Optional |

### 1.3 Skills Responsibility Scope

**Role**: Provide reusable domain knowledge and patterns

**Skill Directory Structure**:
```
~/.claude/skills/
├── generic/
│   ├── requirement-analyzer/     # Universal requirement analysis patterns
│   ├── test-planner/             # Universal test planning patterns
│   └── code-reviewer/            # Universal code review patterns
│
├── [language]/                    # e.g., php, python, javascript
│   ├── coding-standards/         # Language-level coding standards
│   ├── testing-standards/        # Language-level test standards
│   └── security-patterns/        # Language-level security patterns
│
└── [language]-[framework]/        # e.g., php-cakephp, python-django
    ├── functional-designer/      # Framework MVC design
    ├── database-designer/        # Framework ORM/migrations
    └── test-case-designer/       # Framework test patterns
```

### 1.4 Agents Responsibility Scope

**Role**: Execute generic processes (technology-agnostic)

**Agent Classification**:

| Type | Location | Tech Dependency | Skill Loading |
|------|----------|----------------|---------------|
| **Generic Agents** | `~/.claude/agents/generic/` | None | Dynamic from config.yaml |
| **Tech-Specific Agents** | `~/.claude/agents/[language]-[FW]/` | Yes | Fixed or configured |

**Generic Agent List**:
- `workflow-orchestrator` - Workflow coordination
- `requirement-analyst` - Requirements analysis
- `design-architect` - Software design
- `test-strategist` - Test strategy planning
- `code-developer` - Code implementation
- `quality-reviewer` - Quality review
- `deliverable-evaluator` - Deliverable evaluation

**Tech-Specific Agent Criteria**:

✅ **Should define as tech-specific agent when**:
- Framework-specific workflow (doesn't exist in other frameworks)
- Project-specific process (e.g., multi-repository validation)
- Framework-specific tool integration

❌ **Should use generic agent + skills when**:
- Process is generic but implementation differs by tech stack
- Can be handled by skill combinations

---

## 2. Skill-Driven Architecture Mechanism

### 2.1 Operation Flow

```
1. Agent startup
   ↓
2. Load config.yaml
   ↓
3. Detect assigned skills
   agent_skills:
     requirement-analyst:
       - generic/requirement-analyzer
       - [language]/requirement-patterns
       - [language]-[FW]/requirement-analyzer
   ↓
4. Load skills in order
   ↓
5. Execute generic process using loaded skills
   ↓
6. Output tech-stack-specific deliverables
```

### 2.2 Skill Loading Order

```yaml
agent_skills:
  code-developer:
    - generic/code-implementer          # 1st: Universal patterns
    - php/coding-standards              # 2nd: Language-specific (can override generic)
    - php/security-patterns             # 3rd: Language-specific (can override generic, php)
    - php-cakephp/code-implementer      # 4th: FW-specific (can override all)
    - php-cakephp/multi-tenant-handler  # 5th: Project-specific (highest priority)
```

**Loading Strategy**:
1. Generic skills → Provide base patterns
2. Language skills → Add language-specific patterns
3. Framework skills → Add FW-specific patterns
4. Project skills → Add project-specific patterns (most specific takes priority)

---

## 3. CLAUDE.md Configuration Definition

### 3.1 Required Sections

#### Configuration Status

```markdown
# CLAUDE.md - [Project Name] Configuration

**Configuration Status**: [PERMANENT|TEMPORARY]
**Purpose**: [What this configuration achieves]

[For temporary configurations]
**Validity Period**: YYYY-MM-DD ~ [End Condition]
**Replaces**: [What it replaces]
```

#### Absolute Rules

```markdown
## Absolute Rules - Project Priority Principle

### Rule Priority

**Important**: When project documentation conflicts with AI general knowledge, follow project documentation

Priority (High → Low):
1. Explicit project rules (CLAUDE.md, README.md) ← Highest Authority
2. Production code behavior (what actually exists)
3. AI general knowledge (Docker, frameworks, etc.) ← Lowest Authority

**Reason for this hierarchy**:
- [Project-specific reason 1]
- [Project-specific reason 2]
```

#### Project-Specific Standards

```markdown
## Project-Specific Standards

### [Standard Name] (Required)

**This format is project-specific**:

[Specific definition]

**Why project-specific**: [Explanation of reason]
```

### 3.2 Optional Sections

#### Multi-Repository Configuration (if applicable)

```markdown
## Multi-Repository Configuration

This project is part of a multi-repository system:

[Repository structure diagram]

**Inter-Repository Dependencies**:
- [Dependency documentation]

**Production Code Verification**: Cross-repository search
```

#### Custom Workflow Patterns

```markdown
## Custom Workflow Patterns

### [Pattern Name]

**Application Timing**: [When to use this pattern]

**Process**:
1. [Step 1]
2. [Step 2]

**Rationale**: [Why this project uses this specific pattern]
```

---

## 4. config.yaml Configuration Definition

### 4.1 Required Section Definition

#### Repository Metadata

```yaml
repo_metadata:
  name: [Project Name]
  type: [Project Type]
  description: [Brief Description]

  tech_stack:
    language: [Language Name]                    # PHP, Python, JavaScript, etc.
    language_version: "[Version]"                # "8.2", "3.11", "20.x"
    framework: [Framework Name]                  # CakePHP, Django, React, etc.
    framework_version: "[Version]"               # "4.4", "4.2", "18.0"
    test_framework: [Test Framework Name]        # PHPUnit, pytest, Jest
    test_framework_version: "[Version]"          # "11.5", "7.4", "29.0"
```

#### Agent-Skill Assignment (Most Important)

```yaml
agent_skills:
  [Agent Name]:
    - [Skill Path 1]  # Load first
    - [Skill Path 2]  # 2nd (can override skill 1)
    - [Skill Path 3]  # 3rd (can override skills 1,2)
```

**Skill Path Format**:
```
[scope]/[skill-name]

Scope:
  - generic       (universal patterns)
  - [language]    (language-level patterns)
  - [language]-[FW]   (framework-level patterns)
```

**Standard Agent-Skill Assignment Template**:

```yaml
agent_skills:
  workflow-orchestrator:
    - generic/workflow-patterns

  requirement-analyst:
    - generic/requirement-analyzer
    - [language]/requirement-patterns
    - [language]-[FW]/requirement-analyzer

  design-architect:
    - generic/software-designer
    - [language]/architectural-patterns
    - [language]-[FW]/functional-designer
    - [language]-[FW]/database-designer

  test-strategist:
    - generic/test-planner
    - [language]/testing-standards
    - [language]-[FW]/test-case-designer

  code-developer:
    - generic/code-implementer
    - [language]/coding-standards
    - [language]/security-patterns
    - [language]-[FW]/code-implementer

  quality-reviewer:
    - generic/code-reviewer
    - [language]/coding-standards
    - [language]/security-patterns
    - [language]-[FW]/code-reviewer

  deliverable-evaluator:
    - generic/evaluation-criteria
    - [language]-[FW]/deliverable-criteria
```

#### Tech-Specific Agent Settings

```yaml
agents:
  [Agent Name]:
    enabled: true|false
    [Agent-specific settings]
    skills:
      - [Skill Path]
```

**`agents` vs `agent_skills` Usage**:

| Section | When to Use | Examples |
|---------|-------------|----------|
| `agent_skills` | Agent is generic, adapts via skills | requirement-analyst, code-developer, quality-reviewer |
| `agents` | Framework-unique workflows only | Extremely rare - use `agents: {}` in most cases |

### 4.2 Optional Section Definition

#### Database Settings

```yaml
database:
  architecture: [single-tenant|multi-tenant]
  pattern: "[Pattern String]"
  schemas:
    - name: [Schema Name]
      type: [shared|per-tenant]
      database: [Database Name or Pattern]
```

#### Test Settings

```yaml
test:
  docker_command: "[Docker Command]"
  test_database_prefix: [Prefix]
  fixture_namespaces:
    - [Namespace 1]
    - [Namespace 2]
  constants:
    [Constant Name]: [Value]
```

#### Path Settings

```yaml
paths:
  controllers: [Path]
  models: [Path]
  components: [Path]
  fixtures: [Path]
  test_cases: [Path]
  migrations: [Path]
  routes: [Path]
```

#### Dependencies

```yaml
dependencies:
  depends_on:
    - [Dependency 1]
    - [Dependency 2]
  referenced_by:
    - [Reference 1]
    - [Reference 2]
```

---

## 5. Configuration Examples

### 5.1 Simple Web Application

```yaml
# .claude/config.yaml

repo_metadata:
  name: simple-blog
  type: web-app
  description: Simple blog application

  tech_stack:
    language: PHP
    language_version: "8.2"
    framework: CakePHP
    framework_version: "4.4"
    test_framework: PHPUnit
    test_framework_version: "11.5"

agent_skills:
  requirement-analyst:
    - generic/requirement-analyzer
    - php-cakephp/requirement-analyzer

  design-architect:
    - generic/software-designer
    - php-cakephp/functional-designer
    - php-cakephp/database-designer

  code-developer:
    - generic/code-implementer
    - php/coding-standards
    - php/security-patterns
    - php-cakephp/code-implementer

  quality-reviewer:
    - generic/code-reviewer
    - php/coding-standards
    - php-cakephp/code-reviewer

agents: {}  # No tech-specific agents needed
```

### 5.2 Multi-Tenant Project

```yaml
# .claude/config.yaml

repo_metadata:
  name: saas-platform
  type: saas
  description: Multi-tenant SaaS platform

  tech_stack:
    language: PHP
    language_version: "8.2"
    framework: CakePHP
    framework_version: "4.4"
    test_framework: PHPUnit
    test_framework_version: "11.5"

  database:
    architecture: multi-tenant
    pattern: "db_company_%d"
    schemas:
      - name: SharedSchema
        type: shared
        database: shared_account_db
      - name: TenantSchema
        type: per-tenant
        database: "db_company_%d"

agent_skills:
  code-developer:
    - generic/code-implementer
    - php/coding-standards
    - php/security-patterns
    - php-cakephp/code-implementer
    - php-cakephp/multi-tenant-handler  # Multi-tenant specific

  quality-reviewer:
    - generic/code-reviewer
    - php/coding-standards
    - php/security-patterns
    - php-cakephp/code-reviewer
    - php-cakephp/test-validator       # Test quality validation
    - php-cakephp/migration-checker    # Migration validation

agents: {}  # Generic agents + skills handle all use cases
```

### 5.3 Python/Django Project (Example)

```yaml
# .claude/config.yaml

repo_metadata:
  name: ecommerce-platform
  type: e-commerce
  description: E-commerce platform

  tech_stack:
    language: Python
    language_version: "3.11"
    framework: Django
    framework_version: "4.2"
    test_framework: pytest
    test_framework_version: "7.4"

agent_skills:
  requirement-analyst:
    - generic/requirement-analyzer
    - python/requirement-patterns
    - python-django/requirement-analyzer

  design-architect:
    - generic/software-designer
    - python/architectural-patterns
    - python-django/functional-designer
    - python-django/database-designer

  code-developer:
    - generic/code-implementer
    - python/coding-standards      # PEP-8
    - python/security-patterns
    - python-django/code-implementer  # Django MVT

  test-strategist:
    - generic/test-planner
    - python/testing-standards    # pytest conventions
    - python-django/test-case-designer

  quality-reviewer:
    - generic/code-reviewer
    - python/coding-standards
    - python/security-patterns
    - python-django/code-reviewer

agents: {}
```

### 5.4 CLAUDE.md Example (Minimal)

```markdown
# CLAUDE.md - Blog Application

**Configuration Status**: PERMANENT
**Purpose**: Blog application specific conventions

## Project Context

Single-repository blog application

## Project-Specific Standards

### Blog Post Slug Format
- Lowercase required
- Use hyphens (no underscores)
- Unique per publication date
- Example: `2025-10-19-my-blog-post`

**Rationale**: SEO optimization and URL readability

### Custom Approval Workflow
Blog posts require two approvals:
1. Editorial review (content quality)
2. Technical review (XSS protection, proper escaping)

## Quality Gates

Posts must pass:
- [ ] Editorial checklist
- [ ] Technical security scan
- [ ] SEO metadata complete
```

### 5.5 CLAUDE.md Example (Multi-Repository Project)

```markdown
# CLAUDE.md - Admin Project

**Configuration Status**: PERMANENT
**Purpose**: Multi-repository project specific conventions

## Multi-Repository Configuration

This project is part of a multi-repository system:

```
Project Group/
├── admin/      # Admin interface (current repository)
├── user/       # User-facing application
└── batch/      # Background job processing

Common Libraries/
├── message/    # Shared message handling
└── deliver/    # Shared delivery system
```

**Inter-Repository Dependencies**:
- admin → depends on message, deliver
- user → depends on message, deliver
- batch → depends on message, deliver

**Production Code Verification**: Search all repositories for production code existence before test creation

## Project-Specific Standards

### Test Comment Format (Required)

**This format is project-specific**:

```php
/**
 * [Feature description]
 *
 * Guarantees:
 * 1. [Specific guarantee - numbered list required]
 * 2. [Another guarantee]
 * Loss on Failure:
 * - [Business impact if test doesn't exist]
 */
public function testSomething(): void
```

**Why project-specific**: Project policy requires documenting business impact. Not PHPUnit standard.

### Production Code Verification Protocol

**Reason**: Code is distributed across admin, user, batch
Verify production code exists in any repository before test creation

**Procedure**: Use quality-reviewer agent with multi-repository search skills

## Prohibited Patterns

### Configuration Override in Tests (Prohibited)

❌ **Prohibited**: Using `Configure::write()` in test methods

✅ **Required**: Use `Configure::read()` to get production config values

**Rationale**: Tests should verify production behavior, not test-specific behavior
```

---

## 6. Common Mistakes and Fixes

### 6.1 CLAUDE.md Mistakes

#### ❌ Mistake 1: Including Framework Standards

**Wrong**:
```markdown
## CAKEPHP MVC Pattern

Controllers should follow CakePHP conventions...
```

**Fix**: Move to `~/.claude/skills/php-cakephp/`
- This is framework-level, not project-level
- Belongs in `php-cakephp/functional-designer` skill

#### ❌ Mistake 2: Including Language Standards

**Wrong**:
```markdown
## PHP Coding Standards

All code should follow PSR-12...
```

**Fix**: Move to `~/.claude/skills/php/coding-standards/`
- This is language-level, not project-level
- Belongs in `php/coding-standards` skill

#### ❌ Mistake 3: Rules Without Context

**Wrong**:
```markdown
## Test Rules

Tests should be high quality
```

**Fix**:
```markdown
## Project-Specific Test Requirements

### Test Comment Format (Guarantees/Loss on Failure)

**Reason**: Need to document business impact to justify test maintenance cost

**Format**:
```php
/**
 * Guarantees: [What won't be guaranteed if this test doesn't exist]
 * Loss on Failure: [Business cost if test doesn't exist]
 */
```

**Example**: [Concrete example]

**Implementation**: quality-reviewer agent with test-validator skill validates this format
```

### 6.2 config.yaml Mistakes

#### ❌ Mistake 1: Reverse Skill Loading Order

**Wrong**:
```yaml
agent_skills:
  code-developer:
    - php-cakephp/code-implementer      # Most specific first
    - php/coding-standards
    - generic/code-implementer          # Most abstract last
```

**Fix**:
```yaml
agent_skills:
  code-developer:
    - generic/code-implementer          # Most abstract first
    - php/coding-standards
    - php-cakephp/code-implementer      # Most specific last
```

**Reason**: Later-loaded skills override earlier ones. Most specific should load last.

#### ❌ Mistake 2: Generic Agents in `agents` Section

**Wrong**:
```yaml
agents:
  code-developer:  # This is a generic agent!
    enabled: true
    skills:
      - php-cakephp/code-implementer
```

**Fix**:
```yaml
agent_skills:
  code-developer:  # Generic agents go in agent_skills
    - generic/code-implementer
    - php/coding-standards
    - php-cakephp/code-implementer

  quality-reviewer:  # quality-reviewer handles validation
    - generic/code-reviewer
    - php/coding-standards
    - php-cakephp/test-validator  # Test validation via skill

agents: {}  # Extremely rare - Generic agents + skills handle 99%+ of cases
```

**Reason**: `agents` section is reserved for truly framework-unique workflows. Most validation use cases are handled by generic agents (e.g., quality-reviewer) with appropriate skills.

#### ❌ Mistake 3: Duplicating Skill Content in config.yaml

**Wrong**:
```yaml
agent_skills:
  code-developer:
    - generic/code-implementer
    - php/coding-standards

# Duplicating PSR-12 rules here (already in php/coding-standards skill)
code_standards:
  indentation: 4
  line_length: 120
  naming_convention: camelCase
```

**Fix**:
```yaml
agent_skills:
  code-developer:
    - generic/code-implementer
    - php/coding-standards  # PSR-12 rules defined in skill

# Only project-specific overrides
code_standards:
  custom_rule: [Project-specific value]
```

**Reason**: config.yaml binds agents and skills. Skill content exists in skill directories.

#### ❌ Mistake 4: Missing Skill Layers

**Wrong**:
```yaml
agent_skills:
  code-developer:
    - php-cakephp/code-implementer  # Skipping generic and language layers!
```

**Fix**:
```yaml
agent_skills:
  code-developer:
    - generic/code-implementer          # Layer 1: Universal
    - php/coding-standards              # Layer 2: Language
    - php-cakephp/code-implementer      # Layer 3: Framework
```

**Reason**: Each layer builds on previous layers. Skipping layers loses base patterns.

---

## 7. Troubleshooting

### 7.1 Agent Cannot Find Skill

**Symptom**: Agent reports "Skill X not found"

**Check**:
1. Does skill directory exist: `ls ~/.claude/skills/[scope]/[skill-name]/`
2. Does SKILL.md file exist: `ls ~/.claude/skills/[scope]/[skill-name]/SKILL.md`
3. Does config.yaml path match directory structure

### 7.2 Wrong Pattern Applied

**Symptom**: Agent outputs in wrong framework style

**Check**:
1. Skill loading order (generic → language → framework)
2. tech_stack metadata matches actual project
3. Most specific skill loads last

### 7.3 Skills Not Loading

**Symptom**: Agent behaves as if skills aren't loaded

**Check**:
1. Is config.yaml in correct location: `.claude/config.yaml`
2. Is config.yaml syntax correct (YAML format)
3. Does agent_skills section exist with content

---

## 8. Validation Checklist

### 8.1 CLAUDE.md Validation

- [ ] **Scope check**: All rules are project-specific (not generic framework rules)
- [ ] **Rationale documented**: Each rule explains why it exists
- [ ] **Concrete examples**: Complex rules include examples
- [ ] **Temporary/permanent marked**: Temporary cases clearly marked
- [ ] **Cross-references**: Links to related documentation
- [ ] **Priority explicit**: When to override AI general knowledge
- [ ] **No duplication**: Doesn't duplicate skill content
- [ ] **Maintenance plan**: Temporary rules have expiration conditions

### 8.2 config.yaml Validation

- [ ] **Complete metadata**: All required metadata fields filled
- [ ] **Accurate tech stack**: Language/framework versions match reality
- [ ] **Agent skill order**: Generic → Language → Framework → Project
- [ ] **No redundant agents**: Only inherently tech-specific agents in `agents` section
- [ ] **Skills exist**: All referenced skills have corresponding directories
- [ ] **Accurate project paths**: All path settings match actual project structure
- [ ] **Dependencies documented**: All inter-repository dependencies listed

---

## 9. Decision Flowcharts

### 9.1 Where to Define New Rules/Patterns

```
Define new rule/pattern
  ↓
[Q1] Applicable to all [language] projects?
  ↓ YES → ~/.claude/skills/[language]/[skill-name]/
  ↓ NO
  ↓
[Q2] Applicable to all [framework] projects?
  ↓ YES → ~/.claude/skills/[language]-[FW]/[skill-name]/
  ↓ NO
  ↓
[Q3] Project-specific rule?
  ↓ YES → CLAUDE.md or config.yaml
  ↓ NO
  ↓
Applicable to all projects
  ↓
~/.claude/skills/generic/[skill-name]/
```

### 9.2 Should You Create a New Agent

```
Feel need for new agent
  ↓
[Q1] Is this process universal regardless of tech stack?
  ↓ YES → Create generic agent
  |        Location: ~/.claude/agents/generic/[agent-name].md
  |        config.yaml: Configure in agent_skills section
  ↓ NO
  ↓
[Q2] Can existing generic agent handle this with skill changes?
  ↓ YES → Create new skill
  |        Location: ~/.claude/skills/[scope]/[skill-name]/
  |        config.yaml: Add skill to existing agent
  ↓ NO
  ↓
[Q3] Is this agent needed only for specific framework/project?
  ↓ YES → Create tech-specific agent
           Location: ~/.claude/agents/[language]-[FW]/[agent-name].md
           config.yaml: Configure in agents section
```

---

## 10. Summary

### 10.1 Key Principles

1. **config.yaml = Binding Layer**
   - Bind agents and skills
   - Define tech stack
   - Configure tech-specific agents

2. **agent_skills = Skill Assignment**
   - Map skills to generic agents
   - Order matters: Generic → Language → Framework → Project
   - Most specific skill takes priority

3. **agents = Reserved for Truly Framework-Unique Workflows**
   - **Use only when all other approaches are exhausted**
   - In practice: Generic agents + skills handle 99%+ of use cases
   - Consider creating a tech-specific agent ONLY if the workflow is:
     - Unique to one framework (no analog in others)
     - Requires runtime framework integration (not just CLI)
     - Cannot be expressed as skill rules
   - Generic agents belong in `agent_skills`

4. **Skills Go in ~/.claude/skills/**
   - Generic skills: `~/.claude/skills/generic/`
   - Language skills: `~/.claude/skills/[language]/`
   - Framework skills: `~/.claude/skills/[language]-[FW]/`

5. **CLAUDE.md = Project-Specific Rules Only**
   - Framework conventions → Skills
   - Language standards → Skills
   - Generic patterns → Skills

### 10.2 Configuration Workflow

```
1. Define tech stack (repo_metadata.tech_stack)
   ↓
2. Assign skills to agents (agent_skills)
   ↓
3. Configure tech-specific agents (agents - if needed)
   ↓
4. Project-specific settings (paths, database, etc.)
   ↓
5. Validate configuration
   ↓
6. Test with actual agent startup
```

### 10.3 Key Points

| Item | Description |
|------|-------------|
| **Improved Reusability** | Place skills in appropriate layers for multi-project reuse |
| **Maintainability** | Generic agent + skill composition allows changes to propagate across projects |
| **Extensibility** | New tech stack = Add skills + Update config only |
| **Clear Responsibilities** | 4-layer model clarifies what goes where |

---

## Appendix: Complete config.yaml Template

```yaml
# .claude/config.yaml

repo_metadata:
  name: [Project Name]
  type: [Project Type]
  description: [Description]

  tech_stack:
    language: [Language]
    language_version: "[Version]"
    framework: [Framework]
    framework_version: "[Version]"
    test_framework: [Test Framework]
    test_framework_version: "[Version]"

agent_skills:
  requirement-analyst:
    - generic/requirement-analyzer
    - [language]/requirement-patterns
    - [language]-[FW]/requirement-analyzer

  design-architect:
    - generic/software-designer
    - [language]/architectural-patterns
    - [language]-[FW]/functional-designer
    - [language]-[FW]/database-designer

  test-strategist:
    - generic/test-planner
    - [language]/testing-standards
    - [language]-[FW]/test-case-designer

  code-developer:
    - generic/code-implementer
    - [language]/coding-standards
    - [language]/security-patterns
    - [language]-[FW]/code-implementer

  quality-reviewer:
    - generic/code-reviewer
    - [language]/coding-standards
    - [language]/security-patterns
    - [language]-[FW]/code-reviewer

  deliverable-evaluator:
    - generic/evaluation-criteria
    - [language]-[FW]/deliverable-criteria

agents:
  # Inherently tech-specific agents only
  [Tech-Specific Agent]:
    enabled: true
    [Agent-specific settings]
    skills:
      - [language]-[FW]/[skill-name]
```
