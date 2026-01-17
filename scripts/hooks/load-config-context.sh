#!/bin/bash
# PreToolUse Hook: Load agent context from project config
# Usage: load-config-context.sh <name> [scope] [config_keys]
#   scope: agent|skill (default: agent)
#   config_keys: comma-separated yq paths (skill scope only)
# Behavior:
#   - If .claude/config.yaml exists and yq is available, print context.
#   - If missing, print a warning and continue (non-blocking).

set -euo pipefail

NAME="${1:-unknown}"
SCOPE="${2:-agent}"
CONFIG_KEYS="${3:-}"
PROJECT_CONFIG=".claude/config.yaml"
LOAD_CONTEXT_SCRIPT="${HOME}/.claude/scripts/workflow/load-context.sh"

if [[ ! -f "${PROJECT_CONFIG}" ]]; then
  echo "[config] .claude/config.yaml not found; skipping config load for ${NAME}." >&2
  exit 0
fi

if ! command -v yq &> /dev/null; then
  echo "[config] yq not available; cannot load .claude/config.yaml for ${NAME}." >&2
  exit 0
fi

if [[ -x "${LOAD_CONTEXT_SCRIPT}" ]]; then
  CONTEXT_SCOPE="${SCOPE}" SKILL_CONFIG_KEYS="${CONFIG_KEYS}" "${LOAD_CONTEXT_SCRIPT}" "${NAME}"
  exit 0
fi

echo "[config] load-context.sh not found at ${LOAD_CONTEXT_SCRIPT}; skipping context load." >&2
exit 0
