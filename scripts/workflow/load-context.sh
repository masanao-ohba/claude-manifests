#!/bin/bash
# SessionStart Hook: Load Context for Agent
# Usage: load-context.sh <agent_name>
# Output: Context to inject into agent prompt

set -euo pipefail

AGENT_NAME="${1:-unknown}"
CONTEXT_SCOPE="${CONTEXT_SCOPE:-agent}"
SKILL_CONFIG_KEYS="${SKILL_CONFIG_KEYS:-}"
WORKFLOW_DIR="${TMPDIR:-/tmp}/claude-workflow"
CURRENT_SESSION_FILE="${WORKFLOW_DIR}/current-session"
PROJECT_CONFIG=".claude/config.yaml"

# Function to load skills from config.yaml
load_skills() {
    local agent="$1"

    if [[ ! -f "${PROJECT_CONFIG}" ]]; then
        return
    fi

    if ! command -v yq &> /dev/null; then
        echo "## Loaded Skills"
        echo ""
        echo "(yq not available; unable to load skills from ${PROJECT_CONFIG})"
        echo ""
        return
    fi

    # Get skills for this agent from config
    local skills
    skills=$(yq -r ".agents.\"${agent}\".skills // [] | .[]" "${PROJECT_CONFIG}" 2>/dev/null || echo "")

    if [[ -n "${skills}" ]]; then
        echo "## Loaded Skills"
        echo ""
        for skill in ${skills}; do
            local skill_file="${HOME}/.claude/skills/${skill}.md"
            if [[ -f "${skill_file}" ]]; then
                echo "### Skill: ${skill}"
                # Extract content (skip frontmatter)
                sed -n '/^---$/,/^---$/!p' "${skill_file}" | head -50
                echo ""
            fi
        done
    fi
}

# Function to load workflow state
load_workflow_state() {
    if [[ ! -f "${CURRENT_SESSION_FILE}" ]]; then
        return
    fi

    local session_id
    session_id=$(cat "${CURRENT_SESSION_FILE}")
    local state_file="${WORKFLOW_DIR}/${session_id}/state.json"

    if [[ ! -f "${state_file}" ]]; then
        return
    fi

    echo "## Workflow Context"
    echo ""
    echo "### Current Phase"
    echo "$(jq -r '.phase' "${state_file}")"
    echo ""

    echo "### User Request"
    echo "$(jq -r '.user_request' "${state_file}")"
    echo ""

    # Load task object if available
    local task
    task=$(jq -r '.task // null' "${state_file}")
    if [[ "${task}" != "null" ]]; then
        echo "### Task Object"
        echo '```yaml'
        echo "${task}" | yq -P 2>/dev/null || echo "${task}"
        echo '```'
        echo ""
    fi

    # Load classification if available
    local classification
    classification=$(jq -r '.classification // null' "${state_file}")
    if [[ "${classification}" != "null" ]]; then
        echo "### Classification"
        echo '```yaml'
        echo "${classification}" | yq -P 2>/dev/null || echo "${classification}"
        echo '```'
        echo ""
    fi

    # Load scale if available
    local scale
    scale=$(jq -r '.scale // null' "${state_file}")
    if [[ "${scale}" != "null" ]]; then
        echo "### Scale Evaluation"
        echo '```yaml'
        echo "${scale}" | yq -P 2>/dev/null || echo "${scale}"
        echo '```'
        echo ""
    fi
}

# Function to load project constraints
load_constraints() {
    if [[ ! -f "${PROJECT_CONFIG}" ]]; then
        return
    fi

    if ! command -v yq &> /dev/null; then
        echo "## Project Constraints"
        echo ""
        echo "(yq not available; unable to load constraints from ${PROJECT_CONFIG})"
        echo ""
        return
    fi

    local constraints
    constraints=$(yq -r '.constraints // null' "${PROJECT_CONFIG}" 2>/dev/null)

    if [[ "${constraints}" != "null" && -n "${constraints}" ]]; then
        echo "## Project Constraints"
        echo ""
        echo '```yaml'
        echo "${constraints}"
        echo '```'
        echo ""
    fi
}

# Function to load skill-specific config keys
load_skill_config() {
    if [[ ! -f "${PROJECT_CONFIG}" ]]; then
        return
    fi

    if ! command -v yq &> /dev/null; then
        echo "## Skill Configuration"
        echo ""
        echo "(yq not available; unable to load skill config from ${PROJECT_CONFIG})"
        echo ""
        return
    fi

    if [[ -z "${SKILL_CONFIG_KEYS}" ]]; then
        return
    fi

    echo "## Skill Configuration"
    echo ""

    IFS=',' read -r -a keys <<< "${SKILL_CONFIG_KEYS}"
    for key in "${keys[@]}"; do
        local trimmed
        trimmed=$(echo "${key}" | xargs)
        if [[ -n "${trimmed}" ]]; then
            echo "### ${trimmed}"
            echo '```yaml'
            yq -P "${trimmed}" "${PROJECT_CONFIG}" 2>/dev/null || true
            echo '```'
            echo ""
        fi
    done
}

# Main output
echo "# Agent Context: ${AGENT_NAME}"
echo ""
echo "---"
echo ""

load_workflow_state
load_skills "${AGENT_NAME}"

if [[ "${CONTEXT_SCOPE}" == "skill" ]]; then
    load_skill_config
    load_constraints
fi

echo "---"
echo ""
echo "**Proceed with your designated task based on the context above.**"
