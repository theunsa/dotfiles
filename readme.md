# Theuns' Dotfiles

Keyboard-first macOS development environment with portable terminal defaults.
The repository favors declarative dependencies, explicit ownership, idempotent
setup, and secrets that never live in Git.

## Principles

- `Brewfile` declares macOS packages; it never removes unrelated packages.
- GNU Stow links an explicit list of configuration packages.
- `./dot install` is safe to run repeatedly.
- Passage encrypts secrets outside this repository.
- One tool owns each concern: macOS for Spaces, Hammerspoon for global hotkeys,
  sesh for sessions, mise for language runtimes, and tmux for terminal layout.
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
needed, synchronizes tmux plugins and mise runtimes, and starts Hammerspoon and
JankyBorders on macOS. Existing packages and initialized stores are left intact.

On first launch, grant Hammerspoon Accessibility access in **System Settings →
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

The desktop layer intentionally includes Hammerspoon, Raycast, and JankyBorders
but not a tiling window manager or SketchyBar. Nord remains the shared palette
across Ghostty, tmux, Neovim, Starship, and focused-window borders.

## macOS desktop

Native macOS Spaces own workspace state and ordinary windows retain their chosen
size. Hammerspoon provides the small keyboard layer missing from macOS:

| Keys | Action |
|---|---|
| `Alt-H/J/K/L` | Focus the nearest window left/down/up/right |
| `Alt-1…5` | Select native Desktop 1–5 |
| `Alt-T/B/A/D/P/E` | Focus/open Ghostty, Vivaldi, Codex, Docker, Preview, Finder |
| `Alt-Enter` | Open a Ghostty window |
| `Alt-/` | Show the Hammerspoon keymap |
| `Ctrl-Alt-H/L` | Left/right; repeat to cycle among halves and thirds |
| `Ctrl-Alt-J/K` | Bottom/top half |
| `Ctrl-Alt-Y/U/B/N` | Top-left/top-right/bottom-left/bottom-right quarter |
| `Ctrl-Alt-C/F` | Centre/fill |

Create five native Desktops in Mission Control, then enable **Switch to Desktop
1…5** under **System Settings → Keyboard → Keyboard Shortcuts → Mission
Control**. Keep their native `Control-1…5` bindings: Hammerspoon maps
`Alt-1…5` onto them without using private Spaces APIs.

Assign applications once through **Dock icon → Options → Assign To → This
Desktop**. These assignments are machine-local because native Space identifiers
are not portable. Recommended assignments are Ghostty → 1, Vivaldi → 2, Codex →
3, Docker → 4, and Preview/Finder → 5.

Raycast remains available for richer manual window layouts and searchable window
switching. Critical global hotkeys remain auditable in
`~/.hammerspoon/init.lua`; no private Raycast export is committed.

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
| `%` / `"` | Split horizontally / vertically in the current directory |
| `v` / `V` | Alternative horizontal / vertical splits |
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
