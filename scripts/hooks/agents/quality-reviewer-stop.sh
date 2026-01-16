#!/bin/bash
# Stop hook for quality-reviewer: Verify comprehensive review

cat << 'EOF'
┌─────────────────────────────────────────────────────────────────┐
│  QUALITY-REVIEWER COMPLETION CHECK                              │
├─────────────────────────────────────────────────────────────────┤
│  Verify review is comprehensive:                                │
│                                                                 │
│  1. All critical issues identified?                             │
│  2. Security vulnerabilities checked?                           │
│  3. Performance concerns noted?                                 │
│  4. Actionable recommendations provided?                        │
│                                                                 │
│  Return: status, issues by severity, quality score.             │
└─────────────────────────────────────────────────────────────────┘
EOF

exit 0
