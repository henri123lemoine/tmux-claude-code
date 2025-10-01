#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get user configuration with defaults
key=$(tmux show-option -gqv "@claude-code-key")
popup_width=$(tmux show-option -gqv "@claude-code-popup-width")
popup_height=$(tmux show-option -gqv "@claude-code-popup-height")

# Apply defaults
key=${key:-C-e}
popup_width=${popup_width:-80%}
popup_height=${popup_height:-60%}

# Set up the key binding
tmux bind-key "$key" display-popup \
    -w "$popup_width" \
    -h "$popup_height" \
    -E "bash '$CURRENT_DIR/scripts/claude_popup.sh'"
