# Project-Specific Claude Code Guidelines

## 🔗 GLOBAL RULES INHERITANCE (MANDATORY - DO NOT REMOVE)

This project inherits and enforces ALL global rules from `~/.claude/CLAUDE.md`, including:

### ✅ Core Global Rules (Always Apply)
1. **RAI/RAO Framework** (Sections 11-12 of global CLAUDE.md)
   - Medium tasks (50-200 lines): RAI required
   - Large tasks (200+ lines): Full RAI/RAO with workflow-orchestrator
   - Evaluation against RAI criteria is mandatory

2. **Orchestrator Decision Matrix** (Section 11 of global CLAUDE.md)
   ```yaml
   Task Classification:
     trivial: < 3 lines → direct execution allowed
     small: < 50 lines → agent recommended, evaluation required
     medium: < 200 lines → agent mandatory, RAI required
     large: 200+ lines → workflow-orchestrator required
   ```

3. **5-Tool Check Rule** (Section 2 of global CLAUDE.md)
   - Every 5 tool uses → mandatory self-check
   - Check for required delegations
   - Verify evaluation completion

4. **Delegation Mapping** (Section 4 of global CLAUDE.md)
   - Git operations → workflow-orchestrator
   - Code implementation → code-developer
   - Deliverable verification → deliverable-evaluator (with RAI)

### ⚠️ Global Rule Violations
Failure to follow global rules = automatic violation, regardless of project settings

---

## 📋 Project Overview
<!-- Brief description of the project and its purpose -->

## 🛠️ Technology Stack
<!-- List the main technologies used in this project -->

## 📐 Project-Specific Rules

### 1. Additional Code Standards
<!-- Project-specific coding standards that EXTEND (not replace) global rules -->

### 2. Project Architecture Patterns
<!-- Specific patterns for THIS project -->

### 3. Testing Requirements
<!-- Project-specific testing requirements -->

### 4. Documentation Standards
<!-- Project-specific documentation requirements -->

## 🔄 RAI/RAO Framework Usage (Project Customization)

This project follows the global RAI/RAO framework with these adjustments:
<!-- Only list ADDITIONS or STRICTER requirements, never relaxations -->

- Small tasks (< 50 lines): [Keep global default or make stricter]
- Medium tasks (50-200 lines): [Keep global requirement]
- Large tasks (> 200 lines): [Keep global requirement]

## 🎯 Agent Usage Guidelines (Project Extensions)

### Required Delegations (In Addition to Global)
<!-- List any PROJECT-SPECIFIC agent requirements -->

### Direct Execution (Only When Global Rules Permit)
<!-- Cannot expand beyond global permissions -->
- Reading single files (per global rules)
- Trivial fixes < 3 chars (per global rules)
- [No additions that violate global rules]

## ✅ Quality Gates (Project Layer)

Must pass ALL global gates PLUS:
<!-- Project-specific additional requirements -->
- [ ] Global RAI criteria met (when applicable)
- [ ] Global evaluation passed
- [ ] Project-specific requirement 1
- [ ] Project-specific requirement 2

## 🔄 Workflow

### Standard Workflow (Inherited from Global)
1. **Analyze**: Check task size per global matrix
2. **RAI/RAO**: Generate for medium/large tasks
3. **Implement**: Use appropriate agent
4. **Evaluate**: Against RAI indicators
5. **Iterate**: If evaluation fails

### Project-Specific Workflow Extensions
<!-- Only additions, not replacements -->

## 📁 File Organization

### Global Structure (Required)
```
.work/
├── requirements/       # RAI/RAO documents (MANDATORY)
│   └── RAI-*.yaml
├── evaluation-history.yaml # Evaluation tracking (MANDATORY)
└── metrics.yaml       # Performance metrics (MANDATORY)
```

### Project-Specific Additions
```
.work/
└── project-specific/  # Additional project files
```

## 💬 Commit Message Format

### Global Requirement
Include RAI reference when applicable:
```
type: description [RAI-YYYY-MM-DD-XXX]
```

### Project Conventions
<!-- Additional conventions that don't conflict with global -->

## 🚨 Error Handling Policy

### Global Policy (MANDATORY)
- NO silent failures
- Explicit error messages required
- Log all errors with context

### Project-Specific Additions
<!-- Only additions, not replacements -->

## 📊 Metrics and Compliance

This project tracks:
- Global metrics (agent usage, RAI compliance, pass rate)
- Project metrics: [list any additional]

---

## ⚠️ IMPORTANT REMINDERS

1. **This file EXTENDS, never REPLACES global rules**
2. **When in doubt, global rules take precedence**
3. **RAI/RAO framework is MANDATORY for medium/large tasks**
4. **5-tool check rule is ALWAYS active**
5. **Check `~/.claude/CLAUDE.md` for complete global rules**

## Project-Specific Configuration Reference
- Config file: `.claude/config.yaml`
- Settings: `.claude/settings.json`
- Global rules: `~/.claude/CLAUDE.md` (MUST READ)