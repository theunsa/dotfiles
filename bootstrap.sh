#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"
LOCAL_BIN="$HOME/.local/bin"
AGE_KEY_DIR="$HOME/.config/age"
AGE_KEY_FILE="$AGE_KEY_DIR/keys.txt"

# --- Helpers ---
info() { echo "[*] $*"; }
ok() { echo "[+] $*"; }
warn() { echo "[!] $*"; }

is_macos() { [[ "$OSTYPE" == "darwin"* ]]; }
is_linux() { [[ "$OSTYPE" == "linux-gnu"* ]]; }

# --- Functions ---
ensure_local_bin() {
  mkdir -p "$LOCAL_BIN"
  if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    export PATH="$LOCAL_BIN:$PATH"
  fi
}

install_stow() {
  if command -v stow >/dev/null 2>&1; then return; fi

  info "Installing stow..."
  if is_macos; then
    brew install stow
  elif command -v apt >/dev/null 2>&1; then
    sudo apt update && sudo apt install -y stow
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm stow
  else
    warn "Package manager not found. Install GNU stow manually."
    exit 1
  fi
  ok "stow installed."
}

install_age() {
  if command -v age >/dev/null 2>&1; then return; fi

  info "Installing age..."
  if is_macos; then
    brew install age
  elif command -v apt >/dev/null 2>&1; then
    sudo apt update && sudo apt install -y age
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm age
  else
    warn "Package manager not found. Install age manually: https://github.com/FiloSottile/age"
    exit 1
  fi
  ok "age installed."
}

install_passage() {
  # macOS needs GNU getopt and tree for passage
  if is_macos; then
    if [[ ! -f "/opt/homebrew/opt/gnu-getopt/bin/getopt" ]]; then
      info "Installing gnu-getopt (required by passage)..."
      brew install gnu-getopt
    fi
    if ! command -v tree >/dev/null 2>&1; then
      info "Installing tree (required by passage)..."
      brew install tree
    fi
  fi

  if command -v passage >/dev/null 2>&1; then return; fi

  info "Installing passage..."
  ensure_local_bin

  local tmp_dir
  tmp_dir=$(mktemp -d)
  git clone --depth 1 https://github.com/FiloSottile/passage.git "$tmp_dir"
  make -C "$tmp_dir" install PREFIX="$HOME/.local"
  rm -rf "$tmp_dir"

  ok "passage installed to $LOCAL_BIN"
}

setup_age_key() {
  if [[ -f "$AGE_KEY_FILE" ]]; then
    info "Age key already exists at $AGE_KEY_FILE"
    return
  fi

  info "Generating new Age key..."
  mkdir -p "$AGE_KEY_DIR"
  age-keygen -o "$AGE_KEY_FILE"
  chmod 600 "$AGE_KEY_FILE"
  ok "Age key created at $AGE_KEY_FILE"
  warn "IMPORTANT: Back up this key! If lost, you cannot decrypt your secrets."
  echo ""
  echo "Your public key (for sharing/encrypting to yourself):"
  grep "public key:" "$AGE_KEY_FILE" | cut -d: -f2 | tr -d ' '
  echo ""
}

init_passage() {
  local store_dir="$HOME/.passage/store"

  if [[ -d "$store_dir/.git" ]]; then
    info "passage already initialized."
    return
  fi

  export PASSAGE_IDENTITIES_FILE="$AGE_KEY_FILE"

  info "Initializing passage store..."
  mkdir -p "$store_dir"

  # Create .age-recipients with public key
  local pub_key
  pub_key=$(grep "public key:" "$AGE_KEY_FILE" | cut -d: -f2 | tr -d ' ')
  echo "$pub_key" > "$store_dir/.age-recipients"

  # Initialize git
  git -C "$store_dir" init
  git -C "$store_dir" add .age-recipients
  git -C "$store_dir" commit -m "Initialize passage store"

  ok "passage initialized."
}

stow_dotfiles() {
  info "Linking dotfiles from $DOTFILES"
  cd "$DOTFILES"

  for dir in */; do
    dir="${dir%/}"
    stow "$dir"
  done

  ok "Dotfiles linked."
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
COMMAND="${1:--help}"

case "$COMMAND" in
install)
  if [[ ! -d "$DOTFILES" ]]; then
    warn "No $DOTFILES directory found. Please clone your dotfiles repo first:"
    echo "    git clone git@github.com:you/dotfiles.git $DOTFILES"
    exit 1
  fi

  # Install dependencies
  install_stow
  install_age
  install_passage

  # Link dotfiles
  stow_dotfiles

  # Setup secrets management
  setup_age_key
  init_passage

  ok "Bootstrap complete!"
  echo ""
  echo "Next steps:"
  echo "  1. Back up your Age key from $AGE_KEY_FILE"
  echo "  2. Add secrets: passage insert api-keys/openai"
  echo ""
  info "Run 'exec zsh' to reload your shell"
  ;;

update)
  # Pull dotfiles
  git -C "$DOTFILES" pull --rebase --autostash
  stow_dotfiles

  # Pull passage store (if it exists)
  if [[ -d "$HOME/.passage/store/.git" ]]; then
    info "Syncing passage store..."
    git -C "$HOME/.passage/store" pull --rebase --autostash
    ok "Passage store synced."
  fi

  ok "Everything updated!"
  ;;

push)
  # Push dotfiles
  git_commit_push "$DOTFILES" "update dotfiles"

  # Push passage store (if it exists and has changes)
  if [[ -d "$HOME/.passage/store/.git" ]]; then
    git_commit_push "$HOME/.passage/store" "update secrets"
  fi

  ok "Everything pushed!"
  ;;

*)
  echo "Usage: $0 [install|update|push]"
  echo ""
  echo "Commands:"
  echo "  install  - Install dependencies, link dotfiles, setup passage"
  echo "  update   - Pull latest dotfiles and re-link"
  echo "  push     - Commit and push dotfiles changes"
  exit 1
  ;;
esac
