#!/bin/bash
# Stop hook for test-strategist: Summarize test strategy

cat << 'EOF'
┌─────────────────────────────────────────────────────────────────┐
│  TEST-STRATEGIST COMPLETION CHECK                               │
├─────────────────────────────────────────────────────────────────┤
│  Summarize test strategy:                                       │
│                                                                 │
│  1. Test levels and coverage goals                              │
│  2. Key test cases (prioritized)                                │
│  3. Test data requirements                                      │
│  4. Test commands to execute                                    │
│                                                                 │
│  Return actionable test plan for test-executor.                 │
└─────────────────────────────────────────────────────────────────┘
EOF

exit 0
