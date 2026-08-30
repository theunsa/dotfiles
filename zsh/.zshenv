[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
export PATH="$HOME/.local/share/mise/shims:$PATH"
eval "$(mise activate zsh --shims)"
