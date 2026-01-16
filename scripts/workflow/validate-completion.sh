#!/bin/bash
# Stop Hook: Validate workflow completion

LOG_FILE="${TMPDIR:-/tmp}/claude-workflow/hook-debug.log"
echo "[$(date)] validate-completion.sh CALLED" >> "$LOG_FILE"
echo "[$(date)] PWD: $(pwd)" >> "$LOG_FILE"
echo "[$(date)] TOOL_OUTPUT length: ${#TOOL_OUTPUT}" >> "$LOG_FILE"

WORKFLOW_DIR="${TMPDIR:-/tmp}/claude-workflow"
CURRENT_SESSION_FILE="${WORKFLOW_DIR}/current-session"

if [[ ! -f "${CURRENT_SESSION_FILE}" ]]; then
    echo "[$(date)] No current session file" >> "$LOG_FILE"
    exit 0
fi

SESSION_ID=$(cat "${CURRENT_SESSION_FILE}")
STATE_FILE="${WORKFLOW_DIR}/${SESSION_ID}/state.json"

if [[ ! -f "${STATE_FILE}" ]]; then
    echo "[$(date)] No state file" >> "$LOG_FILE"
    exit 0
fi

COMPLETED_COUNT=$(jq -r '.completed | length' "${STATE_FILE}" 2>/dev/null || echo "0")
PHASE=$(jq -r '.phase' "${STATE_FILE}" 2>/dev/null || echo "unknown")

echo "[$(date)] PHASE: $PHASE, COMPLETED_COUNT: $COMPLETED_COUNT" >> "$LOG_FILE"

if [[ "${COMPLETED_COUNT}" -eq 0 ]]; then
    echo "[$(date)] VALIDATION FAILED - no agents called" >> "$LOG_FILE"
    cat << 'ERRMSG'

╔══════════════════════════════════════════════════════════════════╗
║  ⛔ WORKFLOW VALIDATION FAILED                                   ║
║  main-orchestrator terminated without calling any agents.        ║
╚══════════════════════════════════════════════════════════════════╝

ERRMSG
    exit 1
fi

echo "[$(date)] VALIDATION PASSED" >> "$LOG_FILE"
exit 0
