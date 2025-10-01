#!/bin/bash
# Claude Code tmux popup with fzf selection

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

instances=$("$SCRIPT_DIR/claude_instances.sh" 2>/dev/null)

if [[ -z "$instances" ]]; then
    echo "No Claude Code instances found."
    read -p "Press Enter to continue..."
    exit 0
fi

# Get configuration with defaults
preview_enabled=$(tmux show-option -gqv "@claude-code-preview")
preview_enabled=${preview_enabled:-on}

# Setup fzf options
fzf_opts=(
    --height=100%
    --layout=reverse
    --header="Select Claude instance:"
    --prompt="Claude > "
    --border
    --ansi
    --no-sort
    --tiebreak=begin
)

# Add preview if enabled
if [[ "$preview_enabled" == "on" ]]; then
    preview_cmd="echo {} | awk -F' \\| ' '{print \$2}' | awk '{print \$1}' | xargs -I {} bash '$SCRIPT_DIR/extract_pane_content.sh' {}"
    fzf_opts+=(
        --preview="$preview_cmd"
        --preview-window=right:50%:wrap
    )
fi

selected=$(echo "$instances" | fzf "${fzf_opts[@]}")

[[ -z "$selected" ]] && exit 0

# Extract and switch to target
tmux_target=$(echo "$selected" | awk -F' \\| ' '{print $2}' | awk '{print $1}')
[[ -n "$tmux_target" ]] && tmux switch-client -t "$tmux_target"
