# TA: trying out starship in favor of oh-my-zsh
eval "$(starship init zsh)"

# # Path to your oh-my-zsh installation.
# export ZSH="$HOME/.oh-my-zsh"
# # See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="pygmalion"
# source $ZSH/oh-my-zsh.sh

setopt HIST_IGNORE_SPACE

alias p="pnpm"
alias v="nvim"
alias vi="nvim"
alias ls="eza"
alias ll="eza -la"

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

# Claude Code
# alias claude-noyolo="~/.claude/local/claude"
# alias claude="~/.claude/local/claude --dangerously-skip-permissions"
alias claude="~/.claude/local/claude"

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

# Auto-load common API keys from passage (uncomment after migration)
# if command -v passage >/dev/null 2>&1; then
#   export OPENAI_API_KEY=$(passage show api-keys/openai 2>/dev/null)
#   export ANTHROPIC_API_KEY=$(passage show api-keys/anthropic 2>/dev/null)
#   export GITHUB_TOKEN=$(passage show api-keys/github-token 2>/dev/null)
# fi
export TERM=xterm-256color

