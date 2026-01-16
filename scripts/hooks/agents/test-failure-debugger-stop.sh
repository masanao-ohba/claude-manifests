#!/bin/bash
# Stop hook for test-failure-debugger: Provide diagnosis report

cat << 'EOF'
┌─────────────────────────────────────────────────────────────────┐
│  TEST-FAILURE-DEBUGGER COMPLETION CHECK                         │
├─────────────────────────────────────────────────────────────────┤
│  Provide diagnosis report:                                      │
│                                                                 │
│  1. Error classification (ERROR vs FAILURE)                     │
│  2. Root cause with evidence                                    │
│  3. Recommended fix location and approach                       │
│  4. Verification steps                                          │
│                                                                 │
│  Return structured diagnosis for code-developer.                │
└─────────────────────────────────────────────────────────────────┘
EOF

exit 0
