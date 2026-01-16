#!/bin/bash
# Workflow Status/Debug Script
# Usage: status.sh [session_id]
# Shows current workflow state for debugging

set -euo pipefail

WORKFLOW_DIR="${TMPDIR:-/tmp}/claude-workflow"
CURRENT_SESSION_FILE="${WORKFLOW_DIR}/current-session"

# Get session ID
if [[ -n "${1:-}" ]]; then
    SESSION_ID="$1"
elif [[ -f "${CURRENT_SESSION_FILE}" ]]; then
    SESSION_ID=$(cat "${CURRENT_SESSION_FILE}")
else
    echo "No active workflow session found."
    echo "Usage: status.sh [session_id]"
    exit 1
fi

STATE_FILE="${WORKFLOW_DIR}/${SESSION_ID}/state.json"

if [[ ! -f "${STATE_FILE}" ]]; then
    echo "State file not found: ${STATE_FILE}"
    exit 1
fi

echo "=============================================="
echo "  WORKFLOW STATUS (Dev-Only)"
echo "=============================================="
echo ""
echo "Session ID: ${SESSION_ID}"
echo "State File: ${STATE_FILE}"
echo ""
echo "----------------------------------------------"
echo "  CURRENT STATE"
echo "----------------------------------------------"
echo ""

# Show formatted state
if command -v yq &> /dev/null; then
    yq -P '.' "${STATE_FILE}"
else
    jq '.' "${STATE_FILE}"
fi

echo ""
echo "----------------------------------------------"
echo "  FLOW PROGRESS"
echo "----------------------------------------------"
echo ""

PHASE=$(jq -r '.phase' "${STATE_FILE}")
COMPLETED=$(jq -r '.completed | join(" → ")' "${STATE_FILE}")
ALLOWED=$(jq -r '.allowed_agents | join(", ")' "${STATE_FILE}")

echo "Phase: ${PHASE}"
echo "Completed: ${COMPLETED:-none}"
echo "Next allowed: ${ALLOWED:-none}"

echo ""
echo "----------------------------------------------"
echo "  EXPECTED FLOW (Dev-Only)"
echo "----------------------------------------------"
echo ""
echo "goal_definition → scale_evaluation → implementation → evaluation → complete"
echo ""
echo "  goal-clarifier → task-scale-evaluator → workflow-orchestrator"
echo "    → [code-developer → test-executor → quality-reviewer → deliverable-evaluator]"
echo ""

# Visual progress indicator
echo "Progress:"
case "${PHASE}" in
    "goal_definition")
        echo "  [●○○○○] Defining goals and acceptance criteria"
        ;;
    "user_clarification")
        echo "  [●◐○○○] Awaiting user input for clarification"
        ;;
    "scale_evaluation")
        echo "  [●●○○○] Evaluating task scale"
        ;;
    "implementation")
        echo "  [●●●○○] Implementation in progress"
        ;;
    "evaluation")
        echo "  [●●●●○] Evaluation in progress"
        ;;
    "complete")
        echo "  [●●●●●] Complete!"
        ;;
    "failed")
        echo "  [✗✗✗✗✗] Failed"
        ;;
    *)
        echo "  [???] Unknown phase: ${PHASE}"
        ;;
esac

echo ""
echo "=============================================="
