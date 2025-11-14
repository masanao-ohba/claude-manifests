# Test Specification Validator Skill

**Skill Type**: Code Quality Validation
**Tech Stack**: PHP/CakePHP/PHPUnit
**Version**: 1.0.0
**Last Updated**: 2025-10-21

---

## Purpose

This skill validates the alignment between test specifications in `tests/TestCase/README.md` and the actual test implementation code. It ensures that documentation accurately reflects implementation reality, preventing documentation drift and maintaining specification integrity.

**Key Value**:
- Prevents documentation from becoming outdated
- Catches discrepancies between design and implementation
- Enforces test consolidation philosophy (Option 3: behavioral grouping)
- Maintains README.md as authoritative test specification

---

## Used By Agents

This skill is loaded by the following agents:

### 1. quality-reviewer
**Trigger**: After test code is written or modified
**Purpose**: Validate test implementation matches README.md specification

### 2. deliverable-evaluator
**Trigger**: Before committing test changes or creating PR
**Purpose**: Gate-check that test deliverables meet specification alignment criteria

---

## Validation Scope

### What This Skill Validates

1. **Test Function Name Alignment**
   - README.md table lists test function names
   - Actual test class contains those exact function names
   - No naming discrepancies (e.g., testIndexRequiresAuth vs testIndexRequiresAuthentication)

2. **Implementation Status Accuracy**
   - README.md marks tests as "✅実装済" or "⚠️未実装"
   - Actual code presence/absence matches those markers
   - Test count matches between documentation and code

3. **Consolidation Documentation**
   - If tests were consolidated (Option 3), README.md documents:
     - Original individual test count
     - Consolidated test count
     - Consolidation note explaining the grouping
     - "Note:" section explaining consolidation philosophy

4. **Phase/Category Organization**
   - Tests are grouped correctly (Phase 1, Phase 2, Phase 3)
   - Category labels match (A1, A2, B1, B2, etc.)
   - Test counts per category are accurate

5. **Test Metadata Accuracy**
   - Total test count in header
   - Implemented vs unimplemented breakdown
   - Production code line count
   - Consolidation summary (if applicable)

---

## Validation Criteria

### Scoring System

**Integrity Score**: 0-100 based on alignment percentage

**Score Calculation**:
```
Integrity Score = (Matching Functions / Total Functions in README) × 100
```

**Severity Levels**:
- **100**: Perfect alignment - no action needed
- **90-99**: Minor discrepancies - low priority fixes
- **70-89**: Moderate misalignment - should fix soon
- **50-69**: Significant misalignment - fix before PR
- **0-49**: Critical misalignment - fix immediately

### Critical Issues (Block Commit/PR)

These issues should prevent commits or PR creation:

1. **Function Name Mismatch** (Severity: ERROR)
   - README.md lists `testFooBar` but code has `testFooBaz`
   - Causes confusion about what is actually tested

2. **Implementation Status Lie** (Severity: ERROR)
   - README.md marks test as "✅実装済" but function doesn't exist in code
   - Or marks as "⚠️未実装" but function exists
   - Misleads about test coverage

3. **Missing Consolidation Documentation** (Severity: ERROR)
   - Code has consolidated tests (e.g., 8→2) but README.md still shows 8 individual tests
   - Violates transparency principle of Option 3 consolidation

4. **Test Count Mismatch in Header** (Severity: ERROR)
   - Header says "107テスト関数" but actual count is 97
   - Causes confusion about project scope

### Warning Issues (Should Fix)

1. **Vague Test Description** (Severity: WARNING)
   - Role/Purpose column is too generic
   - Scenario column doesn't describe concrete steps
   - Guarantee column uses vague language

2. **Missing Production Code Reference** (Severity: WARNING)
   - Complex tests should reference production code line numbers
   - Helps future maintainers understand what code is being tested

3. **Inconsistent Consolidation Notes** (Severity: WARNING)
   - Some consolidated categories document rationale, others don't
   - Inconsistent style reduces maintainability

---

## Validation Process

### Input Requirements

1. **README.md File Path**: `tests/TestCase/README.md`
2. **Test Class File Path**: e.g., `tests/TestCase/Controller/User/CollectRegistControllerTest.php`
3. **Section Identifier**: e.g., "CollectRegistControllerTest"

### Validation Steps

1. **Parse README.md Test Specification**
   - Extract all test function names from tables
   - Extract implementation status markers (✅/⚠️)
   - Extract test counts per category
   - Extract consolidation notes

2. **Parse Test Class Implementation**
   - Extract all actual test function names (`public function test*()`)
   - Count actual test functions per category (by PHPDoc comments)
   - Detect consolidation patterns (multiple scenarios in one test)

3. **Compare and Score**
   - Match function names (exact string match)
   - Verify implementation status accuracy
   - Check test counts
   - Validate consolidation documentation

4. **Generate Report**
   - List all mismatches with severity
   - Calculate integrity score
   - Provide actionable recommendations

### Output Format

```yaml
validation_result:
  integrity_score: 42/100
  severity: CRITICAL

  mismatches:
    function_names:
      - category: A1
        readme: testUnauthenticatedAccessToIndexRedirectsToLogin
        code: testIndexRequiresAuthentication
        severity: ERROR
        recommendation: "Update README.md function name to match actual implementation"

    implementation_status:
      - category: A2
        readme_status: "✅実装済 (8テスト関数)"
        code_status: "3 functions implemented"
        severity: ERROR
        recommendation: "Update README.md to show 3 tests with consolidation note"

    test_counts:
      - location: header
        readme_count: 107
        actual_count: 97
        severity: ERROR
        recommendation: "Update header to '97テスト関数 - 35実装済 + 62未実装'"

  summary:
    total_functions_in_readme: 107
    total_functions_in_code: 35
    matching_functions: 10
    missing_in_code: 72
    extra_in_code: 0

  recommendations:
    urgent:
      - "Update all A1 function names in README.md to match actual implementation"
      - "Document A2 consolidation (8→3 tests) with Option 3 philosophy note"
      - "Update header test count to reflect consolidation (107→97)"

    important:
      - "Mark B2-B5 tests as ⚠️未実装 in README.md"
      - "Add consolidation summary section to README.md header"
```

---

## Integration with Agents

### quality-reviewer Usage

**When**: After test code is written or modified

**Invocation**:
```markdown
After writing or modifying test code, quality-reviewer should:
1. Load test-spec-validator skill
2. Run validation: README.md ↔ Test Code
3. Report misalignments with severity
4. Block commit if integrity score < 70
```

**Example Agent Prompt**:
```
You have just completed implementing tests for CollectRegistControllerTest.
Use the test-spec-validator skill to verify alignment with README.md specification.

Skill parameters:
- readme_path: tests/TestCase/README.md
- test_class: tests/TestCase/Controller/User/CollectRegistControllerTest.php
- section: CollectRegistControllerTest

Report any misalignments and suggest fixes.
```

### deliverable-evaluator Usage

**When**: Before creating PR or committing test changes

**Invocation**:
```markdown
Before finalizing test deliverables, deliverable-evaluator should:
1. Load test-spec-validator skill
2. Run comprehensive validation
3. Assess readiness for commit/PR
4. Require fixes if integrity score < 90 for PR
```

**Example Agent Prompt**:
```
You are evaluating test deliverables for PR creation.
Use the test-spec-validator skill to assess specification alignment.

Deliverable criteria:
- Integrity score must be ≥ 90 for PR approval
- All ERROR severity issues must be resolved
- All WARNING issues should be documented

Report assessment with pass/fail recommendation.
```

---

## Consolidation Philosophy Enforcement

This skill specifically enforces **Option 3: Behavioral Grouping** consolidation philosophy.

### What Option 3 Means

Instead of testing individual parameters separately:
```
❌ testIndexInvalidId
❌ testRegistInvalidId
❌ testProvisionalInvalidId
```

Group by observable behavior:
```
✅ testInvalidUrlParametersRedirectToSafeScreen
   → Tests 7 scenarios: invalid id/date/select_method across 3 actions
```

### Validation Rules for Consolidation

1. **Consolidation Must Be Documented**
   - README.md must show consolidated function with note
   - Must list previous individual test names (strikethrough)
   - Must explain consolidation rationale

2. **Test Count Must Reflect Consolidation**
   - Category header shows consolidated count (e.g., "3テスト関数 - consolidated from 8")
   - Header metadata updated (107→97)

3. **Test Function Name Must Reflect Grouping**
   - Name should describe behavioral pattern, not single parameter
   - Example: `testInvalidUrlParameters*` not `testIndexInvalidId`

---

## False Positive Prevention

### Acceptable Discrepancies

These are **NOT** validation errors:

1. **Helper/Utility Methods**
   - Private methods starting with `_` or `__`
   - setUp/tearDown methods
   - Data provider methods

2. **Test Documentation Order**
   - README.md lists tests in logical order
   - Code lists tests in different order
   - **Only function names matter, not order**

3. **Comment Differences**
   - Code has more detailed PHPDoc than README.md description
   - README.md is intentionally concise

4. **Implementation Notes**
   - Code has `// Note:` comments explaining implementation
   - These don't need to be in README.md

### Edge Cases

1. **Placeholder Tests (@skip)**
   - README.md shows test function name
   - Code has test with `$this->markTestSkipped()`
   - **This is valid** - test exists but is skipped

2. **Pending Tests**
   - README.md marks as "⚠️未実装"
   - Code has empty test function with `// TODO`
   - **This is valid** - function exists but not implemented

---

## Usage Examples

### Example 1: After Implementing New Tests

```php
// Developer just added 15 new tests to CollectRegistControllerTest.php

// quality-reviewer agent invocation:
Use test-spec-validator skill to verify:
- All 15 new test functions are documented in README.md
- Implementation status markers are accurate
- Category test counts are updated
- No function name typos
```

### Example 2: After Consolidating Tests

```php
// Developer consolidated 8 parameter tests into 2 behavioral tests

// quality-reviewer agent invocation:
Use test-spec-validator skill to verify:
- README.md documents consolidation (8→2)
- Consolidation note explains Option 3 philosophy
- Previous individual test names are listed (strikethrough)
- Category header updated with new count
- Header metadata updated (total test count reduced)
```

### Example 3: Before Creating PR

```php
// Developer is ready to create PR with new tests

// deliverable-evaluator agent invocation:
Use test-spec-validator skill to assess PR readiness:
- Integrity score must be ≥ 90
- All ERROR severity issues must be resolved
- README.md accurately reflects all changes
- Test consolidation is properly documented

Output: PASS/FAIL with specific issues to fix
```

---

## Configuration in .claude/config.yaml

This skill should be configured in the repository's config.yaml:

```yaml
agent_skills:
  quality-reviewer:
    - generic/code-reviewer
    - php/coding-standards
    - php/security-patterns
    - php-cakephp/code-reviewer
    - php-cakephp/refactoring-advisor
    - php-cakephp/test-spec-validator  # ← Add this

  deliverable-evaluator:
    - generic/evaluation-criteria
    - php-cakephp/deliverable-criteria
    - php-cakephp/test-spec-validator  # ← Add this

skills:
  test-spec-validator:
    enabled: true
    auto_run_after:
      - test_implementation
      - test_modification
    severity_thresholds:
      block_commit: 70      # Block if integrity < 70
      block_pr: 90          # Block PR if integrity < 90
      warning_only: 95      # Just warn if 90-95
    validation_targets:
      - tests/TestCase/README.md
    consolidation_philosophy: option_3  # Behavioral grouping
```

---

## Maintenance

### When to Update This Skill

1. **New Consolidation Philosophy**
   - If project adopts different consolidation approach
   - Update validation rules accordingly

2. **New Test Documentation Format**
   - If README.md structure changes
   - Update parsing logic

3. **New Validation Criteria**
   - If project adds new quality gates
   - Add to validation scope

### Skill Evolution

**Version 1.0.0** (Current):
- Function name alignment
- Implementation status accuracy
- Option 3 consolidation enforcement
- Basic integrity scoring

**Future Enhancements**:
- v1.1.0: Validate test description quality
- v1.2.0: Validate production code references
- v1.3.0: Validate fixture data alignment
- v2.0.0: Support multiple consolidation philosophies

---

## Related Skills

- **php-cakephp/test-validator**: Validates test code quality (PHPDoc, assertions)
- **php-cakephp/deliverable-criteria**: Evaluates overall deliverable quality
- **php-cakephp/code-reviewer**: Reviews code compliance with standards

**Skill Hierarchy**:
```
test-spec-validator (THIS SKILL)
  ├─ Validates: README.md ↔ Test Code alignment
  └─ Used by: quality-reviewer, deliverable-evaluator

test-validator
  ├─ Validates: Test code quality (PHPDoc, assertions, labels)
  └─ Used by: test-guardian agent

deliverable-criteria
  ├─ Validates: Overall deliverable completeness
  └─ Used by: deliverable-evaluator agent
```

---

## Success Criteria

This skill is successful when:

1. **Zero Alignment Drift**
   - README.md always matches actual test implementation
   - Integrity score consistently ≥ 95

2. **Consolidation Transparency**
   - All test consolidations are documented
   - Rationale is clear for future maintainers

3. **Automated Enforcement**
   - Validation runs automatically after test changes
   - Blocks commits/PRs with critical misalignments

4. **Developer Confidence**
   - Developers trust README.md as source of truth
   - No confusion about what tests exist vs what's documented

---

## Example Validation Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Test Specification Validation Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Test Class: CollectRegistControllerTest
README Section: tests/TestCase/README.md (L130-308)
Validation Date: 2025-10-21

─────────────────────────────────────────────────────
 Integrity Score: 98/100 ✅ EXCELLENT
─────────────────────────────────────────────────────

Category Breakdown:
  A1 (認証制御): 4/4 functions ✅ 100%
  A2 (パラメータ検証): 3/3 functions ✅ 100%
  A3 (認可制御): 2/2 functions ✅ 100%
  A4 (ヘルパー): 14/14 functions ✅ 100%
  B1 (カレンダー): 12/12 functions ✅ 100%
  B2 (入力検証): 0/15 functions ⚠️ Not Implemented
  B3 (仮押さえキャンセル): 0/8 functions ⚠️ Not Implemented
  B4 (仮押さえ削除): 0/8 functions ⚠️ Not Implemented
  B5 (仮押さえ解放): 0/10 functions ⚠️ Not Implemented
  C1-C3 (統合テスト): 0/22 functions ⚠️ Placeholder

─────────────────────────────────────────────────────
 Issues Found: 1 WARNING
─────────────────────────────────────────────────────

⚠️  WARNING (L148): Consolidation note style inconsistent
    Category: A2
    Issue: Consolidation note uses "consolidated from 8" but A3 uses
           "CONSOLIDATED" in caps
    Recommendation: Use consistent style: "consolidated from X"
    Impact: Low - style inconsistency only

─────────────────────────────────────────────────────
 Summary
─────────────────────────────────────────────────────

✅ All implemented tests are documented
✅ All documented tests match actual function names
✅ Implementation status markers are accurate
✅ Test counts are correct
✅ Consolidation philosophy is documented
⚠️ Minor style inconsistency (non-blocking)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Recommendation: APPROVE FOR PR ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Integrity score (98) exceeds PR threshold (90).
One minor warning can be addressed in future cleanup.
```

---

**END OF SKILL DOCUMENTATION**
