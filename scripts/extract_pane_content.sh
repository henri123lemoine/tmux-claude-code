#!/bin/bash
# Extract tmux pane content for preview

target="$1"
lines="${2:-}"

[[ -z "$target" ]] && echo "Usage: $0 <tmux_target> [lines]" && exit 1

output=$(tmux capture-pane -t "$target" -e -p 2>/dev/null) || {
    echo "Pane $target not found"
    exit 1
}

[[ -n "$lines" ]] && echo "$output" | tail -n "$lines" || echo "$output"
