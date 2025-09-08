#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Default configuration values
default_key="C-e"
default_popup_width="80%"
default_popup_height="60%"
default_preview="on"

# Get user configuration or use defaults
key=$(tmux show-option -gqv "@claude-code-key")
popup_width=$(tmux show-option -gqv "@claude-code-popup-width")
popup_height=$(tmux show-option -gqv "@claude-code-popup-height")
preview=$(tmux show-option -gqv "@claude-code-preview")

key=${key:-$default_key}
popup_width=${popup_width:-$default_popup_width}
popup_height=${popup_height:-$default_popup_height}
preview=${preview:-$default_preview}

# Set up the key binding
tmux bind-key "$key" display-popup \
    -w "$popup_width" \
    -h "$popup_height" \
    -E "bash '$CURRENT_DIR/scripts/claude_popup.sh'"