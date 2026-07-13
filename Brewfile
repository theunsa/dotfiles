# Homebrew is the declarative package source for macOS. Keep sections grouped
# by responsibility; `brew bundle` remains idempotent and never removes extras.

# Taps
tap "felixkratz/formulae"

# Shell and core CLI
brew "age"
brew "bat"
brew "eza"
brew "fd"
brew "fzf"
brew "gitleaks"
brew "gnu-getopt"
brew "jq"
brew "mise"
brew "ripgrep"
brew "starship"
brew "stow"
brew "tree"
brew "wget"
brew "zoxide"
brew "zsh"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# Development workflow
brew "atuin"
brew "gh"
brew "lazygit"
brew "neovim"
brew "oxfmt"
brew "oxlint"
brew "sesh"
brew "tmux"
brew "yazi"

# Terminal utilities and diagnostics
brew "btop"
brew "htop"
brew "midnight-commander"

# Yazi preview dependencies
brew "ffmpeg"
cask "font-symbols-only-nerd-font"
brew "imagemagick"
brew "poppler"
brew "resvg"
brew "sevenzip"

# macOS desktop
brew "felixkratz/formulae/borders"
cask "ghostty"
cask "hammerspoon"
# Preserve an existing direct-download installation; install it on fresh Macs.
cask "raycast" unless File.directory?("/Applications/Raycast.app")

# Developer applications
cask "codex"
cask "cursor-cli"
cask "meld"
cask "ngrok"
