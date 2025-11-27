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
alias ll="ls -la"

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

# Init tmuxifier
export PATH=$PATH:"$HOME/.tmux/plugins/tmuxifier/bin"
eval "$(tmuxifier init -)"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$PATH:$BUN_INSTALL/bin"

# Turso
export PATH="$PATH:$HOME/.turso"

# Claude Code
alias claude-noyolo="~/.claude/local/claude"
alias claude="~/.claude/local/claude --dangerously-skip-permissions"

. "$HOME/.local/bin/env"
export PATH="$HOME/.local/bin:$PATH"

# Auto-load secrets from dotfiles-secrets
SECRETS_REPO="$HOME/dotfiles-secrets"
SECRETS_FILE="$SECRETS_REPO/secrets.env"
SECRETS_ENC="$SECRETS_REPO/secrets.env.enc"
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

if [ -f "$SECRETS_ENC" ]; then
  # If decrypted file missing, try to decrypt it
  if [ ! -f "$SECRETS_FILE" ]; then
    if command -v sops >/dev/null 2>&1; then
      echo "[*] Decrypting secrets.env..."
      sops --input-type dotenv --output-type dotenv --decrypt "$SECRETS_ENC" > "$SECRETS_FILE"
    else
      echo "[!] sops not installed, cannot decrypt secrets"
    fi
  fi

  # Export variables
  if [ -f "$SECRETS_FILE" ]; then
    export $(grep -v '^#' "$SECRETS_FILE" | xargs)
  fi
fi



# Load secrets from dotfiles-secrets
if [ -f "/Users/theuns/dotfiles-secrets/secrets.env" ]; then export $(grep -v '^#' "/Users/theuns/dotfiles-secrets/secrets.env" | xargs); fi
export TERM=xterm-256color
