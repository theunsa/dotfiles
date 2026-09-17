# Theuns' dotfiles

My keyboard-first macOS setup for development.

It uses native macOS Desktops, Hammerspoon shortcuts, Ghostty, tmux, sesh,
LazyVim, and mise. There is no tiling window manager or custom menu bar.

These are personal, opinionated dotfiles rather than a universal installer. They
are useful to browse and copy from, but fork and customise them before installing
them as your own setup. The complete macOS setup is tested on Apple Silicon.

## Before you install

Install the Xcode command-line tools and [Homebrew](https://brew.sh), then fork
this repository into your own GitHub account.

The installer uses GNU Stow to link files into your home directory. It does not
delete unrelated files, but it will stop when an existing file conflicts with a
managed dotfile. Back up your current dotfiles first.

At minimum, review these personal settings in your fork:

- `git/.gitconfig`: Git name, email, and credential helper
- `sesh/.config/sesh/sesh.toml`: project names and paths
- `zsh/.zshrc`: name, work paths, aliases, and secret names
- `hammerspoon/.hammerspoon/init.lua`: application shortcuts
- `claude/.claude/settings.json`: local paths and permissions

## Get running

```bash
xcode-select --install
git clone https://github.com/YOUR-GITHUB-USER/dotfiles.git ~/dotfiles
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
./dot push       # audit, commit all local changes, and push
```

Packages live in the root `Brewfile`. Language versions live in
`~/.config/mise/config.toml`.

`./dot push` also commits and pushes the Passage store when that store has a Git
remote. Review `git status` first if you do not want every local change included.

## Move around macOS

Create five Desktops in Mission Control. In **System Settings → Keyboard →
Keyboard Shortcuts → Mission Control**, enable `Control-1` through `Control-5`.

Hammerspoon gives them shorter shortcuts:

| Keys | Action |
|---|---|
| `Ctrl-1…5` | Go to Desktop 1–5 |
| `Alt-H/J/K/L` | Focus the window left/down/up/right |
| `Alt-T` | Ghostty |
| `Alt-B` | Vivaldi |
| `Alt-A` | Codex |
| `Alt-D` | Docker |
| `Alt-P` | Preview |
| `Alt-E` | Finder |
| `Alt-Enter` | Focus or launch Ghostty |
| `Alt-/` | Show all Hammerspoon shortcuts |

Assign apps to Desktops once from **Dock icon → Options → Assign To → This
Desktop**. A useful starting point is Ghostty on 1, Vivaldi on 2, Codex on 3,
Docker on 4, and Preview/Finder on 5.

Vivaldi and Docker are optional and are not installed by the `Brewfile`. Install
them separately or change their bundle IDs in the Hammerspoon configuration.

### Place windows

| Keys | Action |
|---|---|
| `Ctrl-Alt-H/L` | Left/right half; repeat for one-third or two-thirds |
| `Ctrl-Alt-J/K` | Bottom/top half |
| `Ctrl-Alt-Y/U/B/N` | Four corners |
| `Ctrl-Alt-C/F` | Centre/fill |
| `Ctrl-Alt-M` | Move the window to the next monitor |
| `Ctrl-Alt-Shift-1…5` | Send the window to Desktop 1–5 |

Raycast is still there for anything that does not deserve a permanent shortcut.

## Start work

Use `t` to open or switch projects:

```bash
t                    # choose with sesh and fzf
t ~/Projects/my-app  # open any directory
```

The standard layout is simple: LazyVim on top, two shells below, and lazygit in
a second window.

My configured sessions:

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

These named sessions are examples tied to my project directories. Replace or
remove them in `~/.config/sesh/sesh.toml`; the generic `dev` session and
`t /path/to/project` work with any directory.

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
| `\` / `-` | Split left-right / top-bottom |
| `%` / `"` | Native tmux aliases for the same splits |
| `c` | New window |
| `s` | Sesh switcher |
| `r` | Reload tmux config |
| `[` | Enter copy mode |

In copy mode, press `v` to select and `y` to copy to the macOS clipboard.

## Use Herdr

Run `herdr` from a project directory. Herdr uses the same `Ctrl-A` prefix and
the familiar tmux navigation keys, while its sidebar tracks Codex and Claude
across workspaces.

| After `Ctrl-A` | Action |
|---|---|
| `h/j/k/l` | Move between panes |
| `H/J/K/L` | Resize the current pane by five cells |
| `\` / `-` | Split left-right / top-bottom |
| `c` | New tab |
| `1…9` | Switch tabs |
| `g` / `s` | Open the agent and workspace finder |
| `w` | Open workspace navigation |
| `b` | Toggle the agent sidebar |
| `r` | Reload Herdr config |
| `[` | Enter copy mode |
| `z` | Zoom the current pane |
| `d` / `q` | Detach and leave agents running |

`Ctrl-H/J/K/L` moves seamlessly through Neovim splits and Herdr panes, just
like `vim-tmux-navigator` does under tmux. In normal, insert, terminal, visual,
select, operator, and command-line modes, it traverses Neovim splits first and
only crosses into the neighboring Herdr pane at the edge. The pinned Herdr
navigation plugin is synchronized by `./dot install` and `./dot pull`.
The editor mappings live in `lua/config/keymaps.lua` so they load after
LazyVim's default window mappings.

`Ctrl-\` directly creates a left-right split without pressing the leader or
Shift.

Codex and Claude integrations are synchronized by `./dot install` and
`./dot pull`. They let Herdr identify agent sessions and resume supported
conversations after a server restart.

## Use the shell

| Keys | Action |
|---|---|
| `Ctrl-R` | Search history with Atuin |
| `Up` | Previous Zsh command |
| `Tab` | Complete the current command/path (directories after `cd`) |
| `Right` at end of line | Accept the grey history suggestion |

Useful commands:

```bash
v              # LazyVim in the current directory
y              # Yazi, keeping the directory you leave it in
ask "question" # quick terminal answer
```

Ghostty uses `Cmd-R` to reload its config and `Cmd-N` to open a new window.

## Secrets: Passage and Age

Secrets belong in Passage, not this repository.

Passage is the command-line password manager; Age provides its encryption. Each
secret is encrypted inside `~/.passage/store` for the public key listed in that
store's `.age-recipients` file. The matching private Age identity lives separately
at `~/.config/age/keys.txt` and decrypts the secrets.

`./dot install` installs both tools, generates the Age identity when it is
missing, adds its public recipient to the Passage store, and initializes that
store as a separate Git repository.

```bash
passage insert api-keys/gemini-api-key-ask
passage insert api-keys/opencode-api-key
passage show api-keys/gemini-api-key-ask
passage edit api-keys/gemini-api-key-ask
```

`ask` and `opencode` load their keys only when used. Run `load_work_secrets`
when a shell explicitly needs the work credentials after changing its
Passage paths to match your own.

### Back up the Passage store privately

The encrypted store and private Age identity are separate backups. The store
contains the encrypted secrets; the identity unlocks them. You need both to
recover your secrets.

Create a private GitHub repository for the encrypted store:

```bash
gh auth login
gh repo create passage-store \
  --private \
  --source="$HOME/.passage/store" \
  --remote=origin \
  --push
```

After that, `./dot push` commits and pushes Passage changes, and `./dot pull`
pulls them. Keep this repository private even though its entries are encrypted.
Never add `~/.config/age/keys.txt` to it—or to any Git repository.

Back up `~/.config/age/keys.txt` separately in a secure location and preserve its
`600` permissions. Losing that identity means the encrypted store cannot be
recovered. Anyone who obtains it together with the store can decrypt the
secrets.

## Linux

The shell, tmux, and editor configs are portable. The full installer is built
for macOS; Linux setup is best effort.
