# Theuns' dotfiles

My keyboard-first macOS setup for development.

It uses native macOS Desktops, Hammerspoon shortcuts, Ghostty, tmux, sesh,
LazyVim, and mise. There is no tiling window manager or custom menu bar.

## Get running

```bash
xcode-select --install
git clone git@github.com:theunsa/dotfiles.git ~/dotfiles
cd ~/dotfiles
./dot install
```

Run `./dot install` again whenever you want. It installs missing Homebrew
packages, links the dotfiles, installs language runtimes, and starts the desktop
helpers without removing unrelated software.

The first time Hammerspoon opens, allow it under **System Settings → Privacy &
Security → Accessibility**.

## Keep it healthy

```bash
./dot pull       # pull changes and apply them
./dot doctor     # check the setup
./dot audit      # check for secrets and oversized files
./dot push       # audit, commit, and push
```

Packages live in the root `Brewfile`. Language versions live in
`~/.config/mise/config.toml`.

## Move around macOS

Create five Desktops in Mission Control. In **System Settings → Keyboard →
Keyboard Shortcuts → Mission Control**, enable `Control-1` through `Control-5`.

Hammerspoon gives them shorter shortcuts:

| Keys | Action |
|---|---|
| `Alt-1…5` | Go to Desktop 1–5 |
| `Alt-H/J/K/L` | Focus the window left/down/up/right |
| `Alt-T` | Ghostty |
| `Alt-B` | Vivaldi |
| `Alt-A` | Codex |
| `Alt-D` | Docker |
| `Alt-P` | Preview |
| `Alt-E` | Finder |
| `Alt-Enter` | New Ghostty window |
| `Alt-/` | Show all Hammerspoon shortcuts |

Assign apps to Desktops once from **Dock icon → Options → Assign To → This
Desktop**. A useful starting point is Ghostty on 1, Vivaldi on 2, Codex on 3,
Docker on 4, and Preview/Finder on 5.

### Place windows

| Keys | Action |
|---|---|
| `Ctrl-Alt-H/L` | Left/right half; repeat for one-third or two-thirds |
| `Ctrl-Alt-J/K` | Bottom/top half |
| `Ctrl-Alt-Y/U/B/N` | Four corners |
| `Ctrl-Alt-C/F` | Centre/fill |

Raycast is still there for anything that does not deserve a permanent shortcut.

## Start work

Use `t` to open or switch projects:

```bash
t                    # choose with sesh and fzf
t ~/Projects/my-app  # open any directory
```

The standard layout is simple: LazyVim on top, two shells below, and lazygit in
a second window.

Configured sessions:

| Session | What opens |
|---|---|
| `dev` | Standard layout in the current directory |
| `batapp2` | Standard layout in Batapp |
| `marula-flow` | Standard layout without the lazygit window |
| `marula-smooth` | Standard layout in Marula Smooth |
| `remi` | Standard layout in Remi |
| `pl` | Avoda UI and Platform together |

`pl` opens LazyVim in Avoda UI, with UI and Platform shells below it. Its second
window opens LazyVim in Avoda Platform.

Sesh does not rebuild a session that is already running. Kill that tmux session
first when you want a changed layout to take effect.

Tmux restores the last saved set of sessions when it starts. After removing old
sessions, press `Ctrl-A Ctrl-S` to save the clean set.

## Use tmux

The prefix is `Ctrl-A` and window numbers start at zero.

| After `Ctrl-A` | Action |
|---|---|
| `h/j/k/l` | Move between panes |
| `H/J/K/L` | Resize the current pane |
| `%` / `"` | Split left-right / top-bottom |
| `v` / `V` | Same splits with easier keys |
| `c` | New window |
| `s` | Sesh switcher |
| `r` | Reload tmux config |
| `[` | Enter copy mode |

In copy mode, press `v` to select and `y` to copy to the macOS clipboard.

## Use the shell

| Keys | Action |
|---|---|
| `Ctrl-R` | Search history with Atuin |
| `Up` | Previous Zsh command |
| `Tab` | Accept the grey suggestion, or open completion |

Useful commands:

```bash
v              # LazyVim in the current directory
y              # Yazi, keeping the directory you leave it in
ask "question" # quick terminal answer
```

Ghostty uses `Cmd-R` to reload its config and `Ctrl-N` to open a new window.

## Secrets

Secrets belong in Passage, not this repository.

```bash
passage insert api-keys/openai
passage show api-keys/openai
passage edit api-keys/openai
```

The encrypted store is in `~/.passage/store`. The key that unlocks it is
`~/.config/age/keys.txt`. Back up that key somewhere private; losing it means
losing the store.

`ask` and `opencode` load their keys only when used. Run `load_work_secrets`
when a shell explicitly needs the work credentials.

## Linux

The shell, tmux, and editor configs are portable. The full installer is built
for macOS; Linux setup is best effort.
