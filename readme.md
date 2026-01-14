# My Dotfiles

Personal configuration for `zsh`, `tmux`, `nvim`, and other tools. Designed for portability with encrypted secrets using [passage](https://github.com/FiloSottile/passage) (Age-based password manager).

---

## Quick Start

### New Machine Setup

```bash
# 1. Install git (if needed)
# macOS: xcode-select --install
# Linux: sudo apt install git

# 2. Clone and bootstrap
git clone git@github.com:youruser/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh install

# 3. Reload shell
exec zsh

# 4. Clone your secrets (if you have them backed up)
rm -rf ~/.passage/store
git clone git@github.com:youruser/passage-store.git ~/.passage/store

# 5. Test
passage show api-keys/openai
```

---

## Daily Workflow

```bash
# Pull latest configs and secrets
./bootstrap.sh update

# ... make changes to configs or secrets ...

# Push everything
./bootstrap.sh push
```

---

## Working with Secrets

Secrets are managed with `passage` and stored in `~/.passage/store/` (encrypted git private repo).

```bash
# Add a secret
passage insert api-keys/openai

# View a secret
passage show api-keys/openai

# Edit a secret (opens in nvim)
passage edit api-keys/openai

# Copy to clipboard (auto-clears after 45s)
passage -c api-keys/github-token

# Sync secrets
passage git push
passage git pull
```

### Organized Structure

```
~/.passage/store/
├── api-keys/
│   ├── openai.age
│   ├── anthropic.age
│   └── github-token.age
├── projects/
│   └── myproject/
│       └── env.age
└── servers/
    └── ssh-keys.age
```

---

## Bootstrap Commands

| Command | Description |
|---------|-------------|
| `./bootstrap.sh install` | Install tools, link dotfiles, setup passage |
| `./bootstrap.sh update` | Pull dotfiles + secrets, re-link configs |
| `./bootstrap.sh push` | Push dotfiles + secrets to GitHub |

---

## What Gets Installed

Bootstrap automatically installs all required tools:

**Core Tools:**
- **neovim** - Text editor
- **tmux** - Terminal multiplexer
- **zsh** - Shell
- **starship** - Prompt
- **ghostty** - Terminal emulator (macOS)

**CLI Utilities:**
- **eza** - Modern ls replacement
- **zoxide** - Smart cd
- **nvm** - Node version manager

**Secrets Management:**
- **age** - Encryption
- **passage** - Password manager
- **stow** - Symlink manager

All configs linked to `$HOME` via stow.

---

## Backup of Age Key

Age key (`~/.config/age/keys.txt`) is critical. Without it, no secrets can be decrypted.
Mine backed up in macOS Keychain.

---

## Platform Support

- macOS (Homebrew)
- Debian/Ubuntu (apt)
- Arch Linux (pacman)

