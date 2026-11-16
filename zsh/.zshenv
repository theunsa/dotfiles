[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
export PATH="$HOME/.local/share/mise/shims:$PATH"
(( $+commands[mise] )) && eval "$(mise activate zsh --shims)"

# Opt out of CLI telemetry (Modern Web Guidance, Claude Code, others that honour it)
export DISABLE_TELEMETRY=1
