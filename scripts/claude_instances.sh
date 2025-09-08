#!/bin/bash
# Claude Code instance detector for tmux
# Bash equivalent of claude_instances.py

get_claude_instances() {
    # Get all tmux panes with node processes
    local panes
    if ! panes=$(tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}|#{pane_current_command}|#{pane_current_path}" 2>/dev/null); then
        return 1
    fi

    # Arrays to store instance data
    local targets=()
    local sessions=()
    local paths=()
    local statuses=()
    local priorities=()

    # Process each pane
    while IFS='|' read -r target command path; do
        [[ -z "$target" || -z "$command" || -z "$path" ]] && continue
        
        # Skip non-Claude processes
        [[ "$command" != "node" && "$command" != "claude-code" ]] && continue

        # Get pane content to determine status
        local content
        if ! content=$(tmux capture-pane -t "$target" -p 2>/dev/null); then
            continue
        fi

        # Get last 8 lines for status detection
        local last_lines
        last_lines=$(echo "$content" | tail -n 8)

        # Determine status from content
        local status priority
        if echo "$last_lines" | grep -q "⎿  Running…"; then
            status="processing"
            priority=2
        elif echo "$last_lines" | grep -q "│ > \|│ >\|-- INSERT --"; then
            status="waiting_for_input"
            priority=1
        else
            status="active"
            priority=3
        fi

        # Store instance data
        targets+=("$target")
        sessions+=("${target%%:*}")  # Extract session name
        paths+=("$path")
        statuses+=("$status")
        priorities+=("$priority")

    done <<< "$panes"

    # Sort by priority (bubble sort for simplicity)
    local n=${#targets[@]}
    for ((i = 0; i < n - 1; i++)); do
        for ((j = 0; j < n - i - 1; j++)); do
            if [[ ${priorities[j]} -gt ${priorities[j+1]} ]]; then
                # Swap all arrays
                local temp_target=${targets[j]}
                local temp_session=${sessions[j]}
                local temp_path=${paths[j]}
                local temp_status=${statuses[j]}
                local temp_priority=${priorities[j]}

                targets[j]=${targets[j+1]}
                sessions[j]=${sessions[j+1]}
                paths[j]=${paths[j+1]}
                statuses[j]=${statuses[j+1]}
                priorities[j]=${priorities[j+1]}

                targets[j+1]=$temp_target
                sessions[j+1]=$temp_session
                paths[j+1]=$temp_path
                statuses[j+1]=$temp_status
                priorities[j+1]=$temp_priority
            fi
        done
    done

    # Output instances in fzf-friendly format
    for ((i = 0; i < n; i++)); do
        local emoji
        case "${statuses[i]}" in
            "waiting_for_input") emoji="⏳" ;;
            "processing") emoji="⚡" ;;
            "active") emoji="💻" ;;
            *) emoji="❓" ;;
        esac

        local color reset
        case "${statuses[i]}" in
            "waiting_for_input")
                color="\033[1;33m"  # Yellow
                reset="\033[0m"
                ;;
            "processing")
                color="\033[1;32m"  # Green
                reset="\033[0m"
                ;;
            *)
                color=""
                reset=""
                ;;
        esac

        local status_display
        status_display=$(echo "${statuses[i]}" | sed 's/_/ /g' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) }}1')

        printf "%b%s %s | %s (%s) | %s%b\n" \
            "$color" "$emoji" "$status_display" "${targets[i]}" "${sessions[i]}" "${paths[i]}" "$reset"
    done
}

main() {
    # Check if we have any instances
    if ! get_claude_instances; then
        echo "No Claude Code instances found."
        exit 0
    fi
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi