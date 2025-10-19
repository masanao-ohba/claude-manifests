#!/bin/bash

# Color Condiguration:
#
# get_model_name(): #efb049
# get_hook_status(): #b6b5b5
# get_current_dir(): #00eeaa
# git_info: #da8a84

# Configuration: Set to "false" to disable colors if they don't render properly
USE_COLORS=true

# Read JSON input from stdin
input=$(cat)

# Extract data from JSON using jq
get_hook_status=$(echo "$input" | jq -r '.hook_event_name')

# 一般的な抽出のためのヘルパー関数
get_version() { echo "$input" | jq -r '.version'; }
get_model_name() { echo "$input" | jq -r '.model.display_name'; }
get_project_dir() { echo "$input" | jq -r '.workspace.project_dir'; }
get_current_dir() { echo "$input" | jq -r '.workspace.current_dir'; }
get_cost() { echo "$input" | jq -r '.cost.total_cost_usd'; }
get_duration() { echo "$input" | jq -r '.cost.total_duration_ms'; }
get_lines_added() { echo "$input" | jq -r '.cost.total_lines_added'; }
get_lines_removed() { echo "$input" | jq -r '.cost.total_lines_removed'; }

# Handle null values
if [[ "$get_hook_status" == "null" ]]; then
    get_hook_status=""
fi

# Get current directory (abbreviated like ~)
current_dir=$(get_current_dir)
if [[ "$current_dir" == "$HOME"* ]]; then
    display_dir="~${current_dir#$HOME}"
else
    display_dir="$current_dir"
fi

# Git information with enhanced status
git_info=""
if git -C "$current_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git -C "$current_dir" branch --show-current 2>/dev/null)
    if [[ -n "$branch" ]]; then
        # Get detailed git status
        status_info=""
        
        # Get local changes status
        git_status=$(git -C "$current_dir" status --porcelain 2>/dev/null)
        if [[ -n "$git_status" ]]; then
            # Count staged changes (index modified)
            staged=$(echo "$git_status" | grep -c "^[MADRC]" 2>/dev/null || echo 0)
            # Count unstaged changes (working tree modified)
            unstaged=$(echo "$git_status" | grep -c "^.[MD]" 2>/dev/null || echo 0)
            
            # Add status indicators
            if [[ "$staged" -gt 0 ]]; then
                status_info="${status_info} +${staged}"
            fi
            if [[ "$unstaged" -gt 0 ]]; then
                status_info="${status_info} ~${unstaged}"
            fi
        fi
        
        # Format git info without colors (git info always uncolored now)
        if [[ -n "$status_info" ]]; then
            git_info=" [${branch}${status_info}]"
        else
            git_info=" [${branch}]"
        fi
    fi
fi

# Build lines added/removed display
lines_display=""
lines_added_val=$(get_lines_added)
lines_removed_val=$(get_lines_removed)

# Only show if values exist and are greater than 0
if [[ "$lines_added_val" != "null" && "$lines_added_val" != "" && "$lines_added_val" -gt 0 ]] || \
   [[ "$lines_removed_val" != "null" && "$lines_removed_val" != "" && "$lines_removed_val" -gt 0 ]]; then
    lines_display=" ("
    
    if [[ "$lines_added_val" != "null" && "$lines_added_val" != "" && "$lines_added_val" -gt 0 ]]; then
        lines_display="${lines_display}+${lines_added_val}"
    fi
    
    if [[ "$lines_removed_val" != "null" && "$lines_removed_val" != "" && "$lines_removed_val" -gt 0 ]]; then
        if [[ "$lines_added_val" != "null" && "$lines_added_val" != "" && "$lines_added_val" -gt 0 ]]; then
            lines_display="${lines_display} "
        fi
        lines_display="${lines_display}-${lines_removed_val}"
    fi
    
    lines_display="${lines_display})"
fi

# Create enhanced status line with better formatting
if [[ "$USE_COLORS" == "true" ]]; then
    # Using hex colors from configuration: get_model_name()=#f7c15b, get_hook_status()=#b6b5b5, get_current_dir()=#00eeaa, git_info=#da8a84
    model_name=$(get_model_name)
    if [[ -n "$model_name" && -n "$get_hook_status" ]]; then
        printf "\033[38;2;247;193;91m%s\033[0m \033[38;2;182;181;181m%s\033[0m \033[38;2;0;238;170m%s\033[0m\033[38;2;218;138;132m%s\033[0m%s" \
            "$model_name" \
            "[${get_hook_status}] " \
            "$display_dir" \
            "$git_info" \
            "$lines_display"
    elif [[ -n "$model_name" ]]; then
        printf "\033[38;2;247;193;91m%s\033[0m \033[38;2;0;238;170m%s\033[0m\033[38;2;218;138;132m%s\033[0m%s" \
            "$model_name" \
            "$display_dir" \
            "$git_info" \
            "$lines_display"
    elif [[ -n "$get_hook_status" ]]; then
        printf "\033[38;2;182;181;181m%s\033[0m \033[38;2;0;238;170m%s\033[0m\033[38;2;218;138;132m%s\033[0m%s" \
            "[${get_hook_status}] " \
            "$display_dir" \
            "$git_info" \
            "$lines_display"
    else
        printf "\033[38;2;0;238;170m%s\033[0m\033[38;2;218;138;132m%s\033[0m%s" \
            "$display_dir" \
            "$git_info" \
            "$lines_display"
    fi
else
    # No colors version
    model_name=$(get_model_name)
    if [[ -n "$model_name" && -n "$get_hook_status" ]]; then
        printf "%s %s %s%s%s" \
            "$model_name" \
            "[${get_hook_status}] " \
            "$display_dir" \
            "$git_info" \
            "$lines_display"
    elif [[ -n "$model_name" ]]; then
        printf "%s %s%s%s" \
            "$model_name" \
            "$display_dir" \
            "$git_info" \
            "$lines_display"
    elif [[ -n "$get_hook_status" ]]; then
        printf "%s %s%s%s" \
            "[${get_hook_status}] " \
            "$display_dir" \
            "$git_info" \
            "$lines_display"
    else
        printf "%s%s%s" \
            "$display_dir" \
            "$git_info" \
            "$lines_display"
    fi
fi
