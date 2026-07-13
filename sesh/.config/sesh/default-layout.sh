#!/usr/bin/env bash
set -euo pipefail

# Sesh creates and attaches the session. This script only defines its reusable
# default layout, keeping session selection and layout ownership separate.
root_pane="$(tmux display-message -p '#{pane_id}')"
window="$(tmux display-message -p '#{session_name}:#{window_index}')"
cwd="$(tmux display-message -p '#{pane_current_path}')"

tmux rename-window -t "$window" editor
tmux send-keys -t "$root_pane" nvim C-m

agent_pane="$(tmux split-window -v -p 20 -t "$root_pane" -c "$cwd" -P -F '#{pane_id}')"
tmux split-window -h -p 50 -t "$agent_pane" -c "$cwd"

if [[ "${SESH_GIT_WINDOW:-1}" == "1" ]]; then
    git_window="$(tmux new-window -d -n git -c "$cwd" -P -F '#{window_id}')"
    tmux send-keys -t "$git_window" lazygit C-m
fi

tmux select-window -t "$window"
tmux select-pane -t "$root_pane"
