# My Dotfiles

Personal configuration for `git`, `zsh`, `tmux`, `nvim`, and other tools. Designed for portability with encrypted secrets using [passage](https://github.com/FiloSottile/passage) (Age-based password manager).

---

## Quick Start

### New Machine Setup

```bash
# 1. Install git (if needed)
# macOS: xcode-select --install
# Linux: sudo apt install git

# 2. Clone the repo
git clone git@github.com:youruser/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 3. If restoring existing secrets, restore your backed-up age key first
mkdir -p ~/.config/age
# Copy your backed-up key to ~/.config/age/keys.txt
[[ -f ~/.config/age/keys.txt ]] && chmod 600 ~/.config/age/keys.txt

# 4. Install tools, link dotfiles, and initialize passage
./dot install

# 5. Clone your secrets store (if you have one backed up)
rm -rf ~/.passage/store
git clone git@github.com:youruser/passage-store.git ~/.passage/store

# 6. Reload shell and test
exec zsh
passage show api-keys/openai
```

---

## Daily Workflow

```bash
# Pull latest configs and secrets
./dot pull

# ... make changes to configs or secrets ...

# Push everything
./dot push
```

---

## Working with Secrets

Secrets are managed with `passage` and stored in `~/.passage/store/` as `.age` files. That store can be synced with a private git repo because the file contents are encrypted.

The important pieces are:

- `~/.config/age/keys.txt` - the private age identity. Back this up; without it, existing secrets cannot be decrypted.
- `~/.passage/store/.age-recipients` - the public age recipient key used when encrypting new secrets.
- `~/.passage/store/**/*.age` - encrypted secret files managed by passage.
- `PASSAGE_IDENTITIES_FILE="$HOME/.config/age/keys.txt"` - set in `zsh/.zshrc` so passage knows which private key to use.
- `PASSAGE_DIR="$HOME/.passage/store"` - set in `zsh/.zshrc` so passage uses the expected store.

`age` does the encryption and decryption. `passage` gives the password-manager commands, folder structure, clipboard support, editing, and git workflow around those encrypted files.

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

## Dotfile Commands

| Command | Description |
|---------|-------------|
| `./dot install` | Install tools, link dotfiles, setup passage |
| `./dot pull` | Pull dotfiles + secrets, re-link configs |
| `./dot push` | Commit and push dotfiles + secrets |

---

## What Gets Installed

`./dot install` automatically installs all required tools:

**Core Tools:**
- **neovim** - Text editor
- **tmux** - Terminal multiplexer
- **zsh** - Shell
- **starship** - Prompt
- **ghostty** - Terminal emulator (macOS)

**CLI Utilities:**
- **eza** - Modern ls replacement
- **yazi** - Terminal file manager
- **zoxide** - Smart cd
- **nvm** - Node version manager
- **oxfmt** - OXC formatter for JS/TS and related files
- **oxlint** - OXC linter for JS/TS and related files

**Secrets Management:**
- **age** - Encryption
- **passage** - Password manager
- **stow** - Symlink manager

All configs, including `~/.gitconfig`, are linked to `$HOME` via stow.

### Yazi on macOS

Install Yazi and the optional preview/search dependencies with Homebrew:

```bash
brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide resvg imagemagick font-symbols-only-nerd-font
```

Ghostty supports Yazi image previews out of the box. The Zsh config in this repo intentionally avoids overwriting `TERM` so Ghostty can be detected correctly.

---

## Backup of Age Key

Age key (`~/.config/age/keys.txt`) is critical. Without it, no secrets can be decrypted.
Mine backed up in macOS Keychain.

---

## Platform Support

- macOS (Homebrew)
- Debian/Ubuntu (apt)
- Arch Linux (pacman)
