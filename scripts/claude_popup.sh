#!/bin/bash
# Claude Code tmux popup with fzf selection

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get instances using bash script
instances=$("$SCRIPT_DIR/claude_instances.sh" 2>/dev/null)

# Check if we have instances
if [[ -z "$instances" ]]; then
    echo "No Claude Code instances found."
    read -p "Press Enter to continue..."
    exit 0
fi

# Exit if no instances
[[ -z "$instances" ]] && exit 0

# Show fzf selection with preview
preview_cmd="echo {} | cut -d'|' -f2 | awk '{print \$1}' | xargs -I {} bash '$SCRIPT_DIR/extract_pane_content.sh' {}"

# Get tmux configuration for popup dimensions and preview
popup_width=$(tmux show-option -gqv "@claude-code-popup-width")
popup_height=$(tmux show-option -gqv "@claude-code-popup-height")
preview_enabled=$(tmux show-option -gqv "@claude-code-preview")

# Set defaults
popup_width=${popup_width:-"80%"}
popup_height=${popup_height:-"60%"}
preview_enabled=${preview_enabled:-"on"}

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
    fzf_opts+=(
        --preview="$preview_cmd"
        --preview-window=right:50%:wrap
    )
fi

selected=$(echo "$instances" | fzf "${fzf_opts[@]}")

# Exit if nothing selected
[[ -z "$selected" ]] && exit 0

# Extract tmux target and switch
tmux_target=$(echo "$selected" | awk -F' \\| ' '{print $2}' | awk '{print $1}')
[[ -n "$tmux_target" ]] && tmux switch-client -t "$tmux_target"