#!/bin/bash
# Claude Code instance detector for tmux

readonly STATUS_WAITING=1
readonly STATUS_PROCESSING=2
readonly STATUS_ACTIVE=3

detect_provider() {
    local command=$1
    local content=$2

    case "$command" in
        claude-code) echo "Claude"; return ;;
        copilot) echo "GitHub"; return ;;
    esac

    if [[ "$content" =~ (Claude Code|claude-code|⎿) ]]; then
        echo "Claude"
    elif [[ "$content" =~ (copilot|github\.com) ]]; then
        echo "GitHub"
    elif [[ "$content" =~ (openai|codex) ]]; then
        echo "OpenAI"
    else
        echo "Unknown"
    fi
}

detect_status() {
    local content=$1

    if [[ "$content" =~ "⎿  Running…" ]]; then
        echo "$STATUS_PROCESSING"
    elif [[ "$content" =~ ("│ > "|"│ >"|"-- INSERT --") ]]; then
        echo "$STATUS_WAITING"
    else
        echo "$STATUS_ACTIVE"
    fi
}

format_instance() {
    local priority=$1
    local timestamp=$2
    local target=$3
    local session=$4
    local provider=$5
    local path=$6
    local status=$7

    local emoji color reset status_label

    case "$status" in
        "$STATUS_WAITING")
            emoji="⏳"
            color="\033[1;33m"
            status_label="Waiting For Input"
            ;;
        "$STATUS_PROCESSING")
            emoji="⚡"
            color="\033[1;32m"
            status_label="Processing"
            ;;
        *)
            emoji="💻"
            color=""
            status_label="Active"
            ;;
    esac
    reset="\033[0m"

    printf "%s|%s|%b%s %s | %s (%s) | %s | %s%b\n" \
        "$priority" "$timestamp" \
        "$color" "$emoji" "$status_label" "$target" "$session" "$provider" "$path" "$reset"
}

get_claude_instances() {
    local panes
    panes=$(tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}|#{pane_current_command}|#{pane_current_path}|#{window_activity}" 2>/dev/null) || return 1

    while IFS='|' read -r target command path timestamp; do
        [[ -z "$target" || -z "$command" || -z "$path" ]] && continue
        [[ ! "$command" =~ ^(node|claude-code|python|python3|copilot)$ ]] && continue

        local content
        content=$(tmux capture-pane -t "$target" -p 2>/dev/null) || continue

        local last_lines
        last_lines=$(echo "$content" | tail -n 8)

        local provider
        provider=$(detect_provider "$command" "$content")

        local status
        status=$(detect_status "$last_lines")

        local session="${target%%:*}"

        format_instance "$status" "$timestamp" "$target" "$session" "$provider" "$path" "$status"

    done <<< "$panes" | sort -t'|' -k1n -k2rn | cut -d'|' -f3-
}

main() {
    local instances
    instances=$(get_claude_instances)

    if [[ -z "$instances" ]]; then
        echo "No Claude Code instances found."
        exit 0
    fi

    echo "$instances"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
