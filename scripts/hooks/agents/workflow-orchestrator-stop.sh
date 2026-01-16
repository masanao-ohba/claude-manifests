#!/bin/bash
# Stop hook for workflow-orchestrator: Verify mandatory chain completion

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

exit 0
