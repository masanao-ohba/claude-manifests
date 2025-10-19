# Claude Code CLI - Global User Instructions

## Code Formatting
- Remove whitespace between EOL and non-whitespace characters

## Command Execution
- You can execute read-only commands, such as `find/rg/grep/Read/Find` or so, without waiting for approval.

## Development Methodology

### Universal Problem-Solving Protocol
1. **Observe Before Acting**
   - Document symptoms with concrete data, not assumptions
   - Trace data flow through the entire system
   - Verify every hypothesis with actual debugging

2. **Understand Existing Design**
   - Research why current implementation exists before changing
   - Identify intentional patterns (seemingly "strange" code often has reasons)
   - Document findings in `.work/` before modifications

3. **Minimize Change Scope**
   - Always prefer the smallest possible modification
   - Consider at least 3 approaches before choosing
   - Document why chosen approach is optimal

### Debug Checklist (Required Before Any Fix)
- [ ] Problem is reproducible with specific steps
- [ ] Data flow is documented at each stage
- [ ] Root cause is identified with evidence (not assumed)
- [ ] Solution's side effects are analyzed and listed
- [ ] Edge cases are considered (especially Ajax/form operations)
- [ ] Tests verify both the fix and no regressions

### Cognitive Bias Prevention
- Replace "probably/should/might" → "verified that..."
- Replace "this will fix it" → "testing if this fixes it"
- Replace "similar to last time" → "unique factors here are..."
- If using words like "assume" or "guess" → STOP and debug instead

### Red Flags (Stop and Reconsider)
- Modifying the same code for the 3rd time
- Fix requires more than 10 lines of changes
- Cannot explain all side effects
- Using array_values(), array_merge() without full impact analysis
- Disabling any hidden form fields

### Working Directory Best Practices
The `.work/` directory should always contain:
- `issue-solutions.yaml` - Historical record with root cause analysis
- `design.yaml` - Current specifications (always current state)
- `structure.yaml` - Internal architecture (always current state)
- `methodology.yaml` - Problem-solving templates and patterns (create if needed)

## Documentation Updates
Reference and update the following **YAML-formatted** files in the `.work` directory. These files must be in proper YAML syntax, not Markdown:

- `.work/issue-solutions.yaml` - Reference before starting work; update when new issues arise (record problem) and when issues are resolved (update with solution method)
  - Format: Structured YAML with `issues` array containing `problem`, `solution`, `resolved_date`, `files_changed`

- `.work/design.yaml` - Reference before starting work; update with current specifications and requirements (overwrite with latest state)
  - Format: Structured YAML with `requirements`, `architecture`, `data_flow`, `configuration`, `testing_strategy` sections

- `.work/structure.yaml` - Reference before starting work; update with current internal design and architecture (overwrite with latest state)
  - Format: Structured YAML with `internal_architecture`, `file_structure`, `class_design`, `database_design`, `gcs_design`, etc.

**Important**:
- All `.work/*.yaml` files must be valid YAML syntax, not Markdown content
- Use **English for all keys, values, and descriptions** in YAML files for better AI agent comprehension and international compatibility
- Use proper YAML data structures (objects, arrays, strings) for programmatic processing
- Japanese content can be included in comments or specific user-facing fields when necessary, but structure and technical descriptions should be in English

## Shell Scripts
- Use `#!/usr/bin/env bash` instead of `/bin/bash` for shell script shebangs

## Test Documentation
- For each test function, write a brief Japanese description of the test purpose from the perspective of "what would not be guaranteed if this test didn't exist"
- Apply the same approach to test classes

## Testing Principles (Critical - Apply to All Projects)
- **NO test-specific configuration overrides** - Always use actual production configuration (e.g., Configure::write in tests)
- **NO mocking of production code return values** - Only mock external dependencies (email, API calls, file I/O, etc.)
- **Use real Fixture data** - Tests must verify actual production code behavior with real database data
- **Follow production code flow** - Tests should execute the same code paths as production
- **Validate actual business logic** - Tests should verify the actual algorithms and data transformations
- This ensures tests accurately validate production behavior and catch real integration issues

## Language/Framework-Specific Configuration
- **Test execution methods**: Check project's `.claude/config.yaml` for language/framework settings
- **Output language**: Specified in project's `.claude/config.yaml` under `output.language`
- **Documentation language**: Check `.work/*.yaml` files - structure should be in English, content can be in project's preferred language
- For language-specific rules (PHPUnit, pytest, Jest, etc.), refer to loaded skills from configuration

## Error Handling and Fallback Policy (Critical - Apply to All Projects)
- **CRITICAL: Only use fallback mechanisms when the fallback result is clearly specified as part of requirements/specifications**
- **Database connection failures must throw exceptions immediately** - Never silently create automatic connections or return null
- **Fallback patterns that hide real problems are prohibited** - Such patterns can mask critical system failures
- Avoid excessive use of fallback mechanisms that can mask critical exceptions or unintended behaviors
- When database connections fail: either retry with proper backoff or throw exceptions - silent failures are not acceptable
- External resource failures should be explicitly handled with proper error reporting, not hidden by fallbacks
