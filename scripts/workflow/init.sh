#!/bin/bash
# Workflow State Initialization Script
# Usage: init.sh <session_id> <user_request>
# Specialized for development workflow (no classification step)

set -euo pipefail

SESSION_ID="${1:-$(date +%s)}"
USER_REQUEST="${2:-}"
WORKFLOW_DIR="${TMPDIR:-/tmp}/claude-workflow"
STATE_DIR="${WORKFLOW_DIR}/${SESSION_ID}"
STATE_FILE="${STATE_DIR}/state.json"

# Verbose logging (touch ~/.claude/scripts/workflow/.debug to enable)
WORKFLOW_DEBUG_FLAG="${HOME}/.claude/scripts/workflow/.debug"
log_debug() {
    if [[ -f "${WORKFLOW_DEBUG_FLAG}" ]]; then
        echo "[DEBUG][init] $*" >&2
    fi
}

# Create state directory
mkdir -p "${STATE_DIR}"

log_debug "Initializing workflow session: ${SESSION_ID}"

# Create initial state
# Start with goal_definition phase (skipping classification)
cat > "${STATE_FILE}" << EOF
{
  "session_id": "${SESSION_ID}",
  "phase": "goal_definition",
  "allowed_agents": ["goal-clarifier"],
  "completed": [],
  "task": null,
  "scale": null,
  "outputs": {},
  "error": null,
  "user_request": $(echo "${USER_REQUEST}" | jq -Rs .),
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

log_debug "State file created: ${STATE_FILE}"

# Output session info for the caller
echo "WORKFLOW_SESSION_ID=${SESSION_ID}"
echo "WORKFLOW_STATE_FILE=${STATE_FILE}"
echo "WORKFLOW_STATE_DIR=${STATE_DIR}"

# Also write to a known location for easy discovery
echo "${SESSION_ID}" > "${WORKFLOW_DIR}/current-session"
