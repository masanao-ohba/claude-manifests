#!/bin/bash
# Stop hook for goal-clarifier: Verify clarity before termination

cat << 'EOF'
┌─────────────────────────────────────────────────────────────────┐
│  GOAL-CLARIFIER COMPLETION CHECK                                │
├─────────────────────────────────────────────────────────────────┤
│  Verify goal clarity before returning:                          │
│                                                                 │
│  1. Are acceptance criteria SMART?                              │
│     (Specific, Measurable, Achievable, Relevant, Time-bound)    │
│  2. Are there any remaining ambiguous requirements?             │
│  3. Is the acceptance criteria measurable and verifiable?       │
│                                                                 │
│  Return the complete `task` object (including acceptance_criteria).
│  This task object will be passed through TSE → WO → DE unchanged.
└─────────────────────────────────────────────────────────────────┘
EOF

exit 0
