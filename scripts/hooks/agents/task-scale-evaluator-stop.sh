#!/bin/bash
# Stop hook for task-scale-evaluator: Ensure WO is called

cat << 'EOF'
┌─────────────────────────────────────────────────────────────────┐
│  TASK-SCALE-EVALUATOR COMPLETION CHECK                          │
├─────────────────────────────────────────────────────────────────┤
│  You have completed the scale evaluation.                       │
│                                                                 │
│  CRITICAL: You MUST call workflow-orchestrator using Task tool. │
│                                                                 │
│  Include in your call:                                          │
│  - ENTIRE `task` object (from goal-clarifier)                   │
│  - Your evaluation (scale, complexity, subtasks)                │
│                                                                 │
│  The task object contains acceptance_criteria needed by DE.     │
│                                                                 │
│  Do NOT return without calling workflow-orchestrator.           │
└─────────────────────────────────────────────────────────────────┘
EOF

exit 0
