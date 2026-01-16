#!/bin/bash
# Stop hook for code-developer: Verify completion before termination
# Outputs verification checklist to stdout (shown to model)

cat << 'EOF'
┌─────────────────────────────────────────────────────────────────┐
│  CODE-DEVELOPER COMPLETION CHECK                                │
├─────────────────────────────────────────────────────────────────┤
│  Before completing, verify:                                     │
│                                                                 │
│  1. All required functionality implemented?                     │
│  2. Code follows project patterns and standards?                │
│  3. No obvious bugs or issues introduced?                       │
│  4. Tests updated/created if needed?                            │
│                                                                 │
│  Return: files modified, key changes, any issues.               │
└─────────────────────────────────────────────────────────────────┘
EOF

exit 0
