#!/usr/bin/env bash
set -euo pipefail

root_pane="$(tmux display-message -p '#{pane_id}')"
window="$(tmux display-message -p '#{session_name}:#{window_index}')"
ui_cwd="$(tmux display-message -p '#{pane_current_path}')"
platform_cwd="$(cd "$ui_cwd/../avoda-platform" && pwd -P)"

tmux rename-window -t "$window" editor
tmux send-keys -t "$root_pane" nvim C-m

# Keep LazyVim across the top, with UI and platform shells below it.
ui_pane="$(tmux split-window -v -p 20 -t "$root_pane" -c "$ui_cwd" -P -F '#{pane_id}')"
tmux split-window -h -p 50 -t "$ui_pane" -c "$platform_cwd"

platform_window="$(tmux new-window -d -n platform -c "$platform_cwd" -P -F '#{window_id}')"
tmux send-keys -t "$platform_window" nvim C-m

tmux select-window -t "$window"
tmux select-pane -t "$root_pane"
