#!/bin/bash
# Stop hook for test-executor: Analyze results before termination

cat << 'EOF'
┌─────────────────────────────────────────────────────────────────┐
│  TEST-EXECUTOR COMPLETION CHECK                                 │
├─────────────────────────────────────────────────────────────────┤
│  Analyze test execution results:                                │
│                                                                 │
│  1. How many tests passed/failed?                               │
│  2. What types of failures (ERROR vs FAILURE)?                  │
│  3. Should delegate to test-failure-debugger?                   │
│                                                                 │
│  Return structured test results:                                │
│  - total, passed, failed                                        │
│  - failure details with file:line                               │
│  - recommendation for next action                               │
└─────────────────────────────────────────────────────────────────┘
EOF

exit 0
