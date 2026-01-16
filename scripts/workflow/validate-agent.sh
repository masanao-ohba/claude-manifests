#!/bin/bash
# PreToolUse Hook: Validate Agent Call
# Usage: validate-agent.sh
# Environment: TOOL_INPUT (JSON with subagent_type)
# Exit: 0 = allow, 1 = block

set -euo pipefail

# Verbose logging (touch ~/.claude/scripts/workflow/.debug to enable)
WORKFLOW_DEBUG_FLAG="${HOME}/.claude/scripts/workflow/.debug"
log_debug() {
    if [[ -f "${WORKFLOW_DEBUG_FLAG}" ]]; then
        echo "[DEBUG][validate] $*" >&2
    fi
}

WORKFLOW_DIR="${TMPDIR:-/tmp}/claude-workflow"
CURRENT_SESSION_FILE="${WORKFLOW_DIR}/current-session"

# Check if workflow is active
if [[ ! -f "${CURRENT_SESSION_FILE}" ]]; then
    log_debug "No active workflow session, allowing any call"
    exit 0
fi

SESSION_ID=$(cat "${CURRENT_SESSION_FILE}")
STATE_FILE="${WORKFLOW_DIR}/${SESSION_ID}/state.json"

if [[ ! -f "${STATE_FILE}" ]]; then
    echo "ERROR: State file not found for session ${SESSION_ID}" >&2
    exit 1
fi

# Extract requested agent from TOOL_INPUT
REQUESTED_AGENT=$(echo "${TOOL_INPUT:-{}}" | jq -r '.subagent_type // empty')

if [[ -z "${REQUESTED_AGENT}" ]]; then
    echo "ERROR: No subagent_type in TOOL_INPUT" >&2
    exit 1
fi

# Check if agent is in allowed list
ALLOWED=$(jq -r --arg agent "${REQUESTED_AGENT}" \
    '.allowed_agents | map(select(. == $agent)) | length' \
    "${STATE_FILE}")

if [[ "${ALLOWED}" -eq 0 ]]; then
    CURRENT_PHASE=$(jq -r '.phase' "${STATE_FILE}")
    ALLOWED_LIST=$(jq -r '.allowed_agents | join(", ")' "${STATE_FILE}")

    echo "BLOCKED: Agent '${REQUESTED_AGENT}' not allowed in phase '${CURRENT_PHASE}'" >&2
    echo "Allowed agents: ${ALLOWED_LIST}" >&2
    exit 1
fi

# Agent is allowed
echo "ALLOWED: ${REQUESTED_AGENT} in phase $(jq -r '.phase' "${STATE_FILE}")"
exit 0
