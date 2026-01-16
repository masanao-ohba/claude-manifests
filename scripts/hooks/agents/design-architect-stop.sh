#!/bin/bash
# Stop hook for design-architect: Summarize architecture before termination

cat << 'EOF'
┌─────────────────────────────────────────────────────────────────┐
│  DESIGN-ARCHITECT COMPLETION CHECK                              │
├─────────────────────────────────────────────────────────────────┤
│  Summarize architecture design:                                 │
│                                                                 │
│  1. Key components and their responsibilities                   │
│  2. Database entities and relationships                         │
│  3. API endpoints (if applicable)                               │
│  4. Critical design decisions with rationale                    │
│                                                                 │
│  Format as structured YAML for code-developer.                  │
└─────────────────────────────────────────────────────────────────┘
EOF

exit 0
