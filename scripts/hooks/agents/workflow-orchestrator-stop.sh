#!/bin/bash
# Stop hook for workflow-orchestrator: Verify mandatory chain completion

set -euo pipefail

WORKFLOW_DIR="${TMPDIR:-/tmp}/claude-workflow"
CURRENT_SESSION_FILE="${WORKFLOW_DIR}/current-session"

check_parallel_execution() {
  if [[ ! -f "${CURRENT_SESSION_FILE}" ]]; then
    return 0
  fi

  local session_id
  session_id=$(cat "${CURRENT_SESSION_FILE}")
  local state_file="${WORKFLOW_DIR}/${session_id}/state.json"

  if [[ ! -f "${state_file}" ]]; then
    return 0
  fi

  local parallel_count
  parallel_count=$(jq -r '.scale.parallel_groups // [] | length' "${state_file}")

  if [[ "${parallel_count}" -eq 0 ]]; then
    return 0
  fi

  local wo_output
  wo_output=$(jq -r '.outputs["workflow-orchestrator"] // empty | tostring' "${state_file}")

  if ! echo "${wo_output}" | grep -q "parallel_execution"; then
    echo "WARNING: parallel_groups detected but no parallel_execution evidence found in workflow-orchestrator output." >&2
  fi
}

cat << 'EOF'
┌─────────────────────────────────────────────────────────────────┐
│  WORKFLOW-ORCHESTRATOR COMPLETION CHECK                         │
├─────────────────────────────────────────────────────────────────┤
│  Before completing, verify the MANDATORY chain was followed:    │
│                                                                 │
│  Required agents (in order):                                    │
│  - [ ] code-developer - Implementation complete?                │
│  - [ ] test-executor - Tests executed and passing?              │
│  - [ ] quality-reviewer - Code quality reviewed?                │
│  - [ ] deliverable-evaluator - Evaluated against criteria?      │
│                                                                 │
│  If ANY agent was skipped → Call the missing agent.             │
│                                                                 │
│  Only after ALL checks pass:                                    │
│  - Return completion status                                     │
│  - Report evaluation result (PASS/FAIL)                         │
└─────────────────────────────────────────────────────────────────┘
EOF

check_parallel_execution

exit 0
