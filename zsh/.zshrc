# Path to your oh-my-zsh installation.
# export ZSH="$HOME/.oh-my-zsh"

# TA: trying out starship in favor of oh-my-zsh
eval "$(starship init zsh)"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="pygmalion"

# Add wisely, as too many plugins slow down shell startup.
#plugins=(git colorize github vagrant virtualenv pip python brew yarn npm)

#source $ZSH/oh-my-zsh.sh

# ###########################################
# TA configuration
# ###########################################

alias p="pnpm"
alias v="nvim"
alias vi="nvim"
alias ll="ls -la"

# ENV
export EDITOR='nvim'
export PLATFORM=`uname`
export PROJECT_HOME=$HOME/Projects
export USER_NAME="Theuns Alberts"

export ANDROID_HOME=$HOME/Library/Android/sdk
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"

# nvm setup
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# PATH
export PATH=$PATH:"$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
# NODE_PATH
export NODE_PATH=$(npm root -g)

# Init tmuxifier
export PATH=$PATH:"$HOME/.tmux/plugins/tmuxifier/bin"
eval "$(tmuxifier init -)"

# bun completions
[ -s "/Users/theuns/.bun/_bun" ] && source "/Users/theuns/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$PATH:$BUN_INSTALL/bin"

# Turso
export PATH="$PATH:/Users/theuns/.turso"
setopt HIST_IGNORE_SPACE

alias claude-noyolo="/Users/theuns/.claude/local/claude"
alias claude="/Users/theuns/.claude/local/claude --dangerously-skip-permissions"

. "$HOME/.local/bin/env"
export PATH="$HOME/.local/bin:$PATH"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

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
