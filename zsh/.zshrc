# Put user-installed commands first and initialize tools only when available.
export PATH="$HOME/.local/bin:$PATH"

(( $+commands[mise] )) && eval "$(mise activate zsh)"
(( $+commands[starship] )) && eval "$(starship init zsh)"
(( $+commands[fzf] )) && eval "$(fzf --zsh)"
(( $+commands[atuin] )) && eval "$(atuin init zsh)"

# Share command history across shells and tmux panes.
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS

alias p="pnpm"
function r() {
  local dir="$PWD"

  while [[ "$dir" != "/" ]]; do
    if [[ -x "$dir/bin/rails" ]]; then
      "$dir/bin/rails" "$@"
      return
    fi

    dir="${dir:h}"
  done

  command rails "$@"
}

alias lsa="ls -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias lta="lt -a"
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias eff='$EDITOR "$(ff)"'
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias d="docker"
alias g="git"
alias ta='tmux attach || tmux new -s Work'

function t() {
  local target

  if [[ $# -gt 0 ]]; then
    target="$1"
  else
    target="$(sesh list | fzf)"
  fi

  [[ -z "$target" ]] && return

  if sesh list -c | command grep -Fxq -- "$target"; then
    sesh connect "$target"
  else
    sesh connect -c "$HOME/.config/sesh/default-layout.sh" "$target"
  fi
}

# Show the keybindings AeroSpace actually loaded. Pass resize or service to
# inspect those modes; main is the default.
aero-keys() {
  local mode="${1:-main}"

  if ! (( $+commands[aerospace] )); then
    echo "aero-keys: AeroSpace is unavailable" >&2
    return 1
  fi

  aerospace config --get "mode.${mode}.binding" --json | jq -r '
    to_entries
    | sort_by(.key)[]
    | [
        .key,
        (.value | if type == "array" then join(" → ") else . end)
      ]
    | @tsv
  ' | column -t -s $'\t'
}

function v() {
  if [[ $# -eq 0 ]]; then
    command nvim .
  else
    command nvim "$@"
  fi
}

alias vi="nvim"
alias vi-a="CLAUDE_CONFIG_DIR=~/.claude-albertec nvim"
alias ls="eza"
alias ll="eza -la"
alias yz="yazi"

export EDITOR='nvim'
export PLATFORM="$(uname)"
export PROJECT_HOME=$HOME/Projects
export USER_NAME="Theuns Alberts"

if [[ "$PLATFORM" == "Darwin" ]]; then
  # macOS Android SDK paths
  export ANDROID_HOME=$HOME/Library/Android/sdk
  export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
else
  # Linux Android SDK paths (if installed)
  export ANDROID_HOME=$HOME/Android/Sdk
  export JAVA_HOME="/usr/lib/jvm/default-java"
fi

# PATH
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

# Add Postgres.app to path
export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin"
# Set postgres as default db
export PGDATABASE="postgres"

# Turso
export PATH="$PATH:$HOME/.turso"

# Init zoxide
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# Yazi shell wrapper: keep the shell's cwd in sync after quitting.
function y() {
  local tmp cwd exit_code
  tmp="$(mktemp "${TMPDIR:-/tmp}/yazi-cwd.XXXXXX")" || return 1

  command yazi "$@" --cwd-file="$tmp"
  exit_code=$?

  cwd="$(command cat -- "$tmp" 2>/dev/null)"
  if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && [ -d "$cwd" ]; then
    builtin cd -- "$cwd"
  fi

  rm -f -- "$tmp"
  return $exit_code
}

# Claude Code
alias claude-yolo="claude --dangerously-skip-permissions"
alias haiku="claude --print --model=haiku"
alias sonnet="claude --print --model=sonnet"
alias claude-a="CLAUDE_CONFIG_DIR=~/.claude-albertec claude --dangerously-skip-permissions"

# ask — quick questions via Gemini Flash-Lite (free tier)
export ASK_MODEL="${ASK_MODEL:-gemini-3.1-flash-lite}"
_ask() {
  [[ $# -eq 0 ]] && { echo "usage: ask [-v] <prompt>" >&2; return 1; }
  local verbose=0
  if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
    verbose=1; shift
  fi
  [[ $# -eq 0 ]] && { echo "usage: ask [-v] <prompt>" >&2; return 1; }
  local api_key="${GEMINI_API_KEY:-}"
  [[ -n "$api_key" ]] || api_key="$(passage show api-keys/gemini-api-key-ask 2>/dev/null)"
  [[ -n "$api_key" ]] || { echo "ask: Gemini API key is unavailable" >&2; return 1; }
  local escaped sys payload response_file http_code
  escaped=$(printf '%s' "$*" | python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))")
  if (( verbose )); then
    payload="{\"contents\":[{\"parts\":[{\"text\":${escaped}}]}]}"
  else
    sys='Answer like a terse expert terminal helper in caveman-lite style. Few words, full technical accuracy. Prefer exact command first. Drop filler, preamble, disclaimers, pep talk, recap, and headings. No markdown unless code improves clarity. For commands: command first, then one short context line only if needed. For concepts: max 3 short sentences. For "how do I X": exact command or keystrokes first; explain only if asked. If unsure, ask one short question.'
    sys=$(printf '%s' "$sys" | python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))")
    payload="{\"systemInstruction\":{\"parts\":[{\"text\":${sys}}]},\"generationConfig\":{\"maxOutputTokens\":120,\"temperature\":0.2},\"contents\":[{\"parts\":[{\"text\":${escaped}}]}]}"
  fi

  response_file="$(mktemp "${TMPDIR:-/tmp}/ask-response.XXXXXX")" || return 1
  http_code="$(
    curl -sS -o "$response_file" -w "%{http_code}" \
      "https://generativelanguage.googleapis.com/v1beta/models/${ASK_MODEL}:generateContent" \
      -H 'Content-Type: application/json' \
      -H "x-goog-api-key: ${api_key}" \
      -d "$payload"
  )"

  if [[ "$http_code" != 2* ]]; then
    jq -r '.error.message // "ask: Gemini API HTTP error"' "$response_file" >&2
    rm -f "$response_file"
    return 1
  fi

  if ! jq -er '.candidates[0].content.parts[]?.text' "$response_file"; then
    jq -r '
      .error.message //
      .promptFeedback.blockReason //
      .candidates[0].finishReason //
      "ask: no text returned by Gemini"
    ' "$response_file" >&2
    rm -f "$response_file"
    return 1
  fi

  rm -f "$response_file"
}
alias ask='noglob _ask'

# Stop Zsh from complaining if ?? doesn't match a file
setopt nonomatch
??() {
  claude -p "$*"
}

[[ -r "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# Passage (Age-based password manager)
export PASSAGE_IDENTITIES_FILE="$HOME/.config/age/keys.txt"
export PASSAGE_DIR="$HOME/.passage/store"

# Sensitive work credentials are opt-in, not inherited by every shell process.
load_work_secrets() {
  local git_token gpg_key
  git_token="$(passage show business/plumb-line/plumbline-git-token)" || return
  gpg_key="$(passage show business/plumb-line/plumbline-gpg-key)" || return
  export PLUMBLINE_GIT_TOKEN="$git_token"
  export PLUMBLINE_GPG_KEY="$gpg_key"
}

# Keep the OpenCode key scoped to the OpenCode process.
opencode() {
  local api_key="${OPENCODE_API_KEY:-}"
  [[ -n "$api_key" ]] || api_key="$(passage show api-keys/opencode-api-key 2>/dev/null)"
  [[ -n "$api_key" ]] || { echo "opencode: API key is unavailable" >&2; return 1; }
  OPENCODE_API_KEY="$api_key" command opencode "$@"
}

# Increase open-file limit on osx
if [[ "$PLATFORM" == "Darwin" ]]; then
  ulimit -n 4096
fi

# Preserve the terminal's own TERM (needed for Ghostty-aware apps like Yazi).
: "${TERM:=xterm-256color}"
export TERM

# These must be sourced last so highlighting sees all widgets and aliases.
if [[ "$PLATFORM" == "Darwin" ]] && (( $+commands[brew] )); then
  _brew_prefix="$(brew --prefix)"
  [[ -r "$_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "$_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -r "$_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
    source "$_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  unset _brew_prefix
fi
