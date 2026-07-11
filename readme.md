# Theuns' Dotfiles

Keyboard-first macOS development environment with portable terminal defaults.
The repository favors declarative dependencies, explicit ownership, idempotent
setup, and secrets that never live in Git.

## Principles

- `Brewfile` declares macOS packages; it never removes unrelated packages.
- GNU Stow links an explicit list of configuration packages.
- `./dot install` is safe to run repeatedly.
- Passage encrypts secrets outside this repository.
- One tool owns each concern: AeroSpace for windows, sesh for sessions, mise for
  language runtimes, and tmux for terminal layout.
- Optional visual polish must not obscure or complicate the workflow.

## Install

```bash
xcode-select --install
git clone git@github.com:theunsa/dotfiles.git ~/dotfiles
cd ~/dotfiles
./dot install
```

The installer reconciles the `Brewfile`, installs Passage and TPM, explicitly
stows the supported packages, initializes the encrypted secret store when
needed, synchronizes tmux plugins and mise runtimes, and starts AeroSpace on
macOS. Existing packages and initialized stores are left intact.

On first AeroSpace launch, grant Accessibility access in **System Settings →
Privacy & Security → Accessibility**.

## Commands

| Command | Purpose |
|---|---|
| `./dot install` | Reconcile packages, links, plugins, and secret storage |
| `./dot pull` | Pull changes, reconcile packages, and restow configs |
| `./dot push` | Audit, commit, and push dotfiles and encrypted secrets |
| `./dot audit` | Scan commit-eligible files for secrets and large files |
| `./dot doctor` | Verify packages, commands, links, and repository hygiene |

## macOS packages

The root `Brewfile` is grouped into taps, core shell tools, development tools,
terminal utilities, preview dependencies, desktop tools, and applications.

```bash
brew bundle install --file ~/dotfiles/Brewfile --no-upgrade
```

The desktop layer intentionally includes AeroSpace and JankyBorders but not
SketchyBar. Nord remains the shared palette across Ghostty, tmux, Neovim,
Starship, and focused-window borders.

## AeroSpace

AeroSpace provides five deliberately generic workspaces so routing remains
manual while learning the window model:

| Keys | Action |
|---|---|
| `Alt-H/J/K/L` | Focus a window |
| `Alt-Shift-H/J/K/L` | Move a window |
| `Alt-1…5` | Select a workspace |
| `Alt-Shift-1…5` | Move a window to a workspace |
| `Alt-/` | Toggle tile orientation |
| `Alt-,` | Toggle accordion orientation |
| `Alt-Shift-Space` | Toggle floating layout |
| `Alt-F` | Toggle AeroSpace fullscreen |
| `Alt-R` | Enter resize mode |
| `Alt-Shift-;` | Enter service mode |
| `Alt-Enter` | Open a Ghostty window |
| `Alt-Q` | Close the focused window |

The hierarchy is intentional: `Alt-H/J/K/L` navigates macOS windows while
`Ctrl-H/J/K/L` continues navigating tmux and Neovim panes.

Inspect the bindings AeroSpace actually loaded at any time:

```bash
aero-keys          # main mode
aero-keys resize
aero-keys service
```

## Sessions

`t` is the single entry point for project sessions:

```bash
t                    # select through sesh + fzf
t ~/Projects/my-app  # connect to a specific project
```

New sessions use `~/.config/sesh/default-layout.sh`: an editor window with two
supporting shell panes plus a detached Lazygit window. Project-specific layouts
remain in `sesh.toml`. Existing sessions are reattached rather than rebuilt.

Inside tmux, use prefix `Ctrl-A`, then:

| Keys | Action |
|---|---|
| `h/j/k/l` | Navigate panes |
| `H/J/K/L` | Resize panes repeatedly |
| `v` / `x` | Split horizontally / vertically in the current directory |
| `c` | Create a window in the current directory |
| `s` | Open the sesh switcher |
| `[` then `v`, `y` | Select and copy to the macOS clipboard |

## Language runtimes

mise owns Bun, Node, pnpm, Python, and Ruby versions. `./dot install` and
`./dot pull` install anything declared but missing. After changing
`~/.config/mise/config.toml`, you can also reconcile directly:

```bash
mise install
```

## Secrets

Passage stores Age-encrypted values in `~/.passage/store`; the Age identity is
`~/.config/age/keys.txt`. Neither belongs in this repository. Back up the Age
identity separately—without it, encrypted values cannot be recovered.

```bash
passage insert api-keys/openai
passage show api-keys/openai
passage edit api-keys/openai
passage -c api-keys/github-token
```

Secrets are loaded only when needed. `ask` reads its API key for that request,
`opencode` scopes its key to the child process, and `load_work_secrets` is an
explicit opt-in for business credentials. They are not exported during every
shell startup.

The encrypted Passage store may use its own private Git remote:

```bash
git clone git@github.com:YOUR_USER/YOUR_PRIVATE_PASSAGE_STORE.git ~/.passage/store
```

## Linux

The terminal configurations remain broadly portable, but the complete,
declarative bootstrap is macOS-first. The Debian/Ubuntu and Arch installer
branches currently install only a minimal shell/editor subset and should be
treated as best-effort support.
