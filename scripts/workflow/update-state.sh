#!/bin/bash
# PostToolUse Hook: Update Workflow State
# Usage: update-state.sh
# Environment: TOOL_INPUT (request), TOOL_OUTPUT (result)

set -euo pipefail

WORKFLOW_DIR="${TMPDIR:-/tmp}/claude-workflow"
CURRENT_SESSION_FILE="${WORKFLOW_DIR}/current-session"

# Verbose logging (touch ~/.claude/scripts/workflow/.debug to enable)
WORKFLOW_DEBUG_FLAG="${HOME}/.claude/scripts/workflow/.debug"
log_debug() {
    if [[ -f "${WORKFLOW_DEBUG_FLAG}" ]]; then
        echo "[DEBUG][update-state] $*" >&2
    fi
}

# Check if workflow is active
if [[ ! -f "${CURRENT_SESSION_FILE}" ]]; then
    exit 0
fi

SESSION_ID=$(cat "${CURRENT_SESSION_FILE}")
STATE_FILE="${WORKFLOW_DIR}/${SESSION_ID}/state.json"

if [[ ! -f "${STATE_FILE}" ]]; then
    exit 0
fi

# Extract agent that was called
CALLED_AGENT=$(echo "${TOOL_INPUT:-{}}" | jq -r '.subagent_type // empty')

if [[ -z "${CALLED_AGENT}" ]]; then
    exit 0
fi

log_debug "Agent completed: ${CALLED_AGENT}"

# Read current state
CURRENT_PHASE=$(jq -r '.phase' "${STATE_FILE}")
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Add agent to completed list and store output
jq --arg agent "${CALLED_AGENT}" \
   --arg output "${TOOL_OUTPUT:-}" \
   --arg now "${NOW}" \
   '.completed += [$agent] |
    .outputs[$agent] = ($output | try fromjson catch $output) |
    .updated_at = $now' \
   "${STATE_FILE}" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "${STATE_FILE}"

# Determine next phase based on completed agent
case "${CALLED_AGENT}" in
    "goal-clarifier")
        # Check if clarification is needed or task is ready
        STATUS=$(echo "${TOOL_OUTPUT:-}" | jq -r '.task.status // "clear"' 2>/dev/null || echo "clear")
        log_debug "GC status: ${STATUS}"

        if [[ "${STATUS}" == "needs_clarification" ]]; then
            # MO will ask user, then call GC again
            jq --arg now "${NOW}" \
               '.phase = "user_clarification" |
                .allowed_agents = ["goal-clarifier"] |
                .updated_at = $now' \
               "${STATE_FILE}" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "${STATE_FILE}"
        else
            # Task object ready - proceed to scale evaluation
            TASK_OBJ=$(echo "${TOOL_OUTPUT:-}" | jq '.task // null' 2>/dev/null || echo "null")
            jq --arg now "${NOW}" \
               --argjson task "${TASK_OBJ}" \
               '.phase = "scale_evaluation" |
                .allowed_agents = ["task-scale-evaluator"] |
                .task = $task |
                .updated_at = $now' \
               "${STATE_FILE}" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "${STATE_FILE}"
        fi
        ;;

    "task-scale-evaluator")
        # Extract scale and proceed to implementation
        SCALE_OBJ=$(echo "${TOOL_OUTPUT:-}" | jq '.evaluation // null' 2>/dev/null || echo "null")
        jq --arg now "${NOW}" \
           --argjson scale "${SCALE_OBJ}" \
           '.phase = "implementation" |
            .allowed_agents = ["workflow-orchestrator"] |
            .scale = $scale |
            .updated_at = $now' \
           "${STATE_FILE}" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "${STATE_FILE}"
        ;;

    "workflow-orchestrator")
        # WO manages implementation chain; evaluation happens via main-orchestrator
        # When WO completes, move to evaluation (deliverable-evaluator)
        jq --arg now "${NOW}" \
           '.phase = "evaluation" |
            .allowed_agents = ["deliverable-evaluator"] |
            .updated_at = $now' \
           "${STATE_FILE}" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "${STATE_FILE}"
        ;;

    "deliverable-evaluator")
        # Check evaluation result
        VERDICT=$(echo "${TOOL_OUTPUT:-}" | jq -r '.verdict // .evaluation.verdict // "FAIL"' 2>/dev/null || echo "FAIL")
        log_debug "DE verdict: ${VERDICT}"

        if [[ "${VERDICT}" == "PASS" ]]; then
            jq --arg now "${NOW}" \
               '.phase = "complete" |
                .allowed_agents = [] |
                .updated_at = $now' \
               "${STATE_FILE}" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "${STATE_FILE}"
        else
            # Failed - allow retry through workflow-orchestrator
            jq --arg now "${NOW}" \
               '.phase = "implementation" |
                .allowed_agents = ["workflow-orchestrator"] |
                .updated_at = $now' \
               "${STATE_FILE}" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "${STATE_FILE}"
        fi
        ;;

    "code-developer"|"test-executor"|"quality-reviewer"|"design-architect"|"test-failure-debugger")
        # These are managed by workflow-orchestrator, don't change main state
        log_debug "Implementation agent - no state change"
        ;;

    *)
        # Unknown agent, log but don't block
        log_debug "Unknown agent completed: ${CALLED_AGENT}"
        ;;
esac

# Output current state for debugging
NEW_PHASE=$(jq -r '.phase' "${STATE_FILE}")
NEW_ALLOWED=$(jq -r '.allowed_agents | join(",")' "${STATE_FILE}")
log_debug "State updated: phase=${NEW_PHASE}, allowed=${NEW_ALLOWED}"
echo "STATE_UPDATED: phase=${NEW_PHASE}, allowed=${NEW_ALLOWED}"
exit 0
