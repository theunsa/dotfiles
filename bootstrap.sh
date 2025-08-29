#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"
DOTFILES_SECRETS="$HOME/dotfiles-secrets"
SECRETS_ENV="$DOTFILES_SECRETS/secrets.env"
SECRETS_ENC="$DOTFILES_SECRETS/secrets.env.enc"
AGE_KEY="$HOME/.config/sops/age/keys.txt"

# --- Helpers ---
info() { echo "[*] $*"; }
ok() { echo "[+] $*"; }
warn() { echo "[!] $*"; }

# --- Functions ---
clone_or_update_repo() {
  local dir=$1
  local url=$2

  if [[ -d "$dir/.git" ]]; then
    info "Updating $(basename "$dir")..."
    git -C "$dir" pull --rebase --autostash
    ok "$(basename "$dir") updated."
  else
    info "Cloning $(basename "$dir")..."
    git clone "$url" "$dir"
    ok "$(basename "$dir") cloned."
  fi
}

stow_dotfiles() {
  info "Linking dotfiles from $DOTFILES"

  cd "$DOTFILES"

  # Only stow directories (ignore files like bootstrap.sh)
  for dir in */; do
    dir="${dir%/}" # remove trailing slash
    stow "$dir"
  done

  ok "Dotfiles linked."
}

decrypt_secrets() {
  if [[ -f "$AGE_KEY" && -f "$SECRETS_ENC" ]]; then
    info "Decrypting secrets.env..."
    sops --decrypt --input-type dotenv --output-type dotenv "$SECRETS_ENC" >"$SECRETS_ENV"
    ok "Secrets decrypted at $SECRETS_ENV"
  else
    warn "Skipping secrets decryption (missing key or $SECRETS_ENC)."
  fi
}

encrypt_secrets() {
  if [[ -f "$SECRETS_ENV" ]]; then
    info "Encrypting secrets.env..."
    sops --encrypt --input-type dotenv --output-type dotenv "$SECRETS_ENV" >"$SECRETS_ENC"
    ok "Secrets encrypted at $SECRETS_ENC"
  else
    warn "No $SECRETS_ENV found to encrypt."
  fi
}

ensure_zshrc_loader() {
  local ZSHRC="$HOME/.zshrc"
  local SECRETS_SNIPPET="if [ -f \"$SECRETS_ENV\" ]; then export \$(grep -v '^#' \"$SECRETS_ENV\" | xargs); fi"

  if ! grep -Fxq "$SECRETS_SNIPPET" "$ZSHRC" 2>/dev/null; then
    echo "" >>"$ZSHRC"
    echo "# Load secrets from dotfiles-secrets" >>"$ZSHRC"
    echo "$SECRETS_SNIPPET" >>"$ZSHRC"
    ok "Added secrets loader to $ZSHRC"
  fi
}

git_commit_push() {
  local dir=$1
  local msg=$2
  cd "$dir"

  if [[ -n "$(git status --porcelain)" ]]; then
    git add -A
    git commit -m "$msg" || true
    git push
    ok "Pushed changes in $(basename "$dir")"
  else
    info "No changes in $(basename "$dir")"
  fi
}

# --- Main ---
COMMAND="${1:-install}"

case "$COMMAND" in
install)
  if [[ ! -d "$DOTFILES" ]]; then
    warn "No $DOTFILES directory found. Please clone your dotfiles repo first:"
    echo "    git clone git@github.com:you/dotfiles.git $DOTFILES"
    exit 1
  fi

  clone_or_update_repo "$DOTFILES_SECRETS" "git@github.com:you/dotfiles-secrets.git"

  if ! command -v stow >/dev/null 2>&1; then
    info "Installing stow..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
      brew install stow
    elif command -v apt >/dev/null 2>&1; then
      sudo apt update && sudo apt install -y stow
    elif command -v dnf >/dev/null 2>&1; then
      sudo dnf install -y stow
    else
      warn "Package manager not found. Install GNU stow manually."
    fi
  fi

  stow_dotfiles
  decrypt_secrets
  ensure_zshrc_loader
  ok "Bootstrap install complete!"
  ;;

update)
  clone_or_update_repo "$DOTFILES" "git@github.com:you/dotfiles.git"
  clone_or_update_repo "$DOTFILES_SECRETS" "git@github.com:you/dotfiles-secrets.git"
  stow_dotfiles
  decrypt_secrets
  ok "Dotfiles and secrets updated!"
  ;;

push)
  # Encrypt before committing
  encrypt_secrets

  # Safety check: forbid unencrypted .env in git
  if grep -q "secrets.env" "$DOTFILES_SECRETS/.gitignore" 2>/dev/null; then
    ok "Confirmed secrets.env is ignored by git."
  else
    warn "Add 'secrets.env' to $DOTFILES_SECRETS/.gitignore before pushing!"
    exit 1
  fi

  git_commit_push "$DOTFILES" "update dotfiles"
  git_commit_push "$DOTFILES_SECRETS" "update secrets"
  ok "Push complete!"
  ;;

*)
  echo "Usage: $0 [install|update|push]"
  exit 1
  ;;
esac
