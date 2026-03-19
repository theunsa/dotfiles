# TA: trying out starship in favor of oh-my-zsh
eval "$(starship init zsh)"

# # Path to your oh-my-zsh installation.
# export ZSH="$HOME/.oh-my-zsh"
# # See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="pygmalion"
# source $ZSH/oh-my-zsh.sh

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
alias gst="git status"
alias gcm="git commit -m"
alias gcam="git commit -a -m"
alias gcad="git commit -a --amend"
alias ta='tmux attach || tmux new -s Work'

function sesh_default_layout() {
  printf "%s" "tmux send-keys -t 0 'nvim' C-m && tmux split-window -v -p 20 && tmux send-keys -t 1 'clear && claude' C-m && tmux split-window -h -p 50 -t 1 && tmux send-keys -t 2 'clear' C-m && tmux select-pane -t 0"
}

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
    sesh connect -c "$(sesh_default_layout)" "$target"
  fi
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
export PLATFORM=`uname`
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

# nvm setup
export NVM_DIR="$HOME/.nvm"
if [[ "$PLATFORM" == "Darwin" ]]; then
  # macOS with Homebrew
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
else
  # Linux or other systems
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

# PATH
export PATH=$PATH:"$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
# NODE_PATH
export NODE_PATH=$(npm root -g)

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$PATH:$BUN_INSTALL/bin"

# Turso
export PATH="$PATH:$HOME/.turso"

# Init zoxide
eval "$(zoxide init zsh)"

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
alias claude="~/.claude/local/claude"
alias claude-yolo="~/.claude/local/claude --dangerously-skip-permissions"
alias haiku="~/.claude/local/claude --print --model=haiku"
alias sonnet="~/.claude/local/claude --print --model=sonnet"
alias claude-a="CLAUDE_CONFIG_DIR=~/.claude-albertec claude --dangerously-skip-permissions"

# ask to use Codex (fast) for now
ask() {
  codex exec -m gpt-5.4-mini --json --skip-git-repo-check -c reasoning_effort=low "$*" | \
  jq -r 'select(.item.type == "agent_message") | .item.text'
}

# Stop Zsh from complaining if ?? doesn't match a file
setopt nonomatch
??() {
  claude -p "$*"
}

. "$HOME/.local/bin/env"
export PATH="$HOME/.local/bin:$PATH"

# Passage (Age-based password manager)
export PASSAGE_IDENTITIES_FILE="$HOME/.config/age/keys.txt"
export PASSAGE_DIR="$HOME/.passage/store"

export OPENCODE_API_KEY="$(passage show api-keys/opencode-api-key)"
export PLUMBLINE_GIT_TOKEN="$(passage show business/plumb-line/plumbline-git-token)"
export PLUMBLINE_GPG_KEY="$(passage show business/plumb-line/plumbline-gpg-key)"

# Increase open-file limit on osx
if [[ "$PLATFORM" == "Darwin" ]]; then
  ulimit -n 4096
fi

# Preserve the terminal's own TERM (needed for Ghostty-aware apps like Yazi).
: "${TERM:=xterm-256color}"
export TERM
eval "$(~/.local/bin/mise activate)"
