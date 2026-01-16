#!/bin/bash
# Stop hook for deliverable-evaluator: Verify evaluation before termination

cat << 'EOF'
┌─────────────────────────────────────────────────────────────────┐
│  DELIVERABLE-EVALUATOR COMPLETION CHECK                         │
├─────────────────────────────────────────────────────────────────┤
│  Final evaluation verification:                                 │
│                                                                 │
│  For EACH acceptance criterion:                                 │
│  1. Was it achieved? (PASS/FAIL)                                │
│  2. What evidence supports this verdict?                        │
│                                                                 │
│  Overall verdict:                                               │
│  - PASS: All high-priority criteria pass                        │
│  - FAIL: Any high-priority criterion fails                      │
│                                                                 │
│  ROUTING:                                                       │
│  - If PASS → Return to workflow-orchestrator                    │
│  - If FAIL → Specify which agent should fix what                │
│                                                                 │
│  Return: verdict, criteria_results, recommendations.            │
└─────────────────────────────────────────────────────────────────┘
EOF

exit 0
