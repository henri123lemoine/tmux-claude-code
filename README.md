# tmux-claude-code

A tmux plugin for managing Claude Code instances with a fuzzy-finding popup interface.

## Features

- Interactive popup to view and switch between Claude Code instances
- Real-time status detection (waiting for input, processing, active)
- Preview pane showing current Claude session content
- Configurable keybindings and popup dimensions

## Requirements

- tmux 3.2+ (for popup support)
- fzf
- bash

## Installation

### Using TPM (recommended)

Add plugin to your `~/.tmux.conf`:

```bash
set -g @plugin 'username/tmux-claude-code'
```

Press `prefix + I` to fetch and source the plugin.

### Manual Installation

Clone the repository:
```bash
git clone https://github.com/username/tmux-claude-code ~/.tmux/plugins/tmux-claude-code
```

Add to `~/.tmux.conf`:
```bash
run-shell ~/.tmux/plugins/tmux-claude-code/tmux-claude-code.tmux
```

## Usage

Default keybinding: `prefix + C-e`

This opens a popup showing all Claude Code instances sorted by status:
- ⏳ Waiting for input
- ⚡ Processing 
- 💻 Active

Use `j/k` or arrow keys to navigate, `Enter` to switch to selected instance, `Esc` to cancel.

## Configuration

Available options (add to `~/.tmux.conf`):

```bash
# Custom keybinding (default: C-e)
set -g @claude-code-key 'C-e'

# Popup dimensions (default: 80% width, 60% height)
set -g @claude-code-popup-width '80%'
set -g @claude-code-popup-height '60%'

# Enable/disable preview pane (default: on)
set -g @claude-code-preview 'on'
```

## How It Works

The plugin detects Claude Code instances by:
1. Finding tmux panes running `node` or `claude-code` processes
2. Analyzing pane content to determine status
3. Sorting by priority and presenting in fzf interface

## License

MIT License - see [LICENSE](LICENSE) file.