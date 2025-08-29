# My Dotfiles

This repository contains my personal configuration for `zsh`, `tmux`, `nvim`, and other tools. It is designed to be **portable**, easy to install, and secure with **encrypted secrets** using [SOPS + Age](https://github.com/ProtonMail/go-crypto/tree/master/age).

---

## Repository Structure

```
dotfiles/
├── bootstrap.sh         # Bootstrap script
├── git/                 # Git configuration (.gitconfig, .gitignore_global)
├── nvim/                # Neovim configuration (~/.config/nvim)
├── tmux/                # Tmux configuration (~/.tmux.conf)
├── zsh/                 # Zsh configuration (~/.zshrc, plugins)
├── etc... 
```

Secrets are stored separately in a **private** repository:

```
dotfiles-secrets/
├── secrets.env          # Local unencrypted environment variables (ignored in git)
├── secrets.env.enc      # Encrypted secrets (committed to git)
```

---

## Bootstrap Script

The `bootstrap.sh` script handles installation, updates, and secure pushes. It ensures:

* `stow` links your dotfiles into your `$HOME`.
* `dotfiles-secrets` is cloned and decrypted (if you have the Age key).
* `.zshrc` loads your secrets automatically.
* Encryption of secrets before pushing.

### Commands

#### Install on a new machine

```bash
git clone git@github.com:you/dotfiles.git ~/dotfiles
bash ~/dotfiles/bootstrap.sh install
```

* Installs `stow` if needed.
* Links all dotfiles.
* Clones `dotfiles-secrets` and decrypts secrets.
* Ensures your shell loads secrets automatically.

---

#### Update dotfiles

```bash
bash ~/dotfiles/bootstrap.sh update
```

* Pulls latest changes from both repositories.
* Restows directories into `$HOME`.
* Decrypts secrets if keys are available.

---

#### Push changes

```bash
bash ~/dotfiles/bootstrap.sh push
```

* Encrypts secrets before committing.
* Commits and pushes **dotfiles** and **dotfiles-secrets**.
* Ensures unencrypted secrets are never pushed.

---

## Notes on Secrets

* Keep your **Age private key** safe outside the repository.
* Only encrypted files (`*.env.enc`) are committed.
* Example secrets file: `dotfiles-secrets/secrets.env`

```env
# secrets.env
OPENAI_API_KEY=sk-xxxx
GITHUB_TOKEN=ghp_xxxx
```

* `bootstrap.sh` automatically decrypts this into your `$HOME` environment.

---

## Notes on Stow

* Each directory inside `dotfiles/` is a **package** for `stow`.
* The bootstrap script automatically stows all directories, ignoring top-level files like `bootstrap.sh`.

---

## Usage

* Edit your dotfiles in `~/dotfiles/<package>/`.
* Add new notes, configurations, or scripts.
* Use `bootstrap.sh push` to sync securely across machines.

---

## Recommended Workflow

1. Clone `dotfiles` on a new machine.
2. Run `bootstrap.sh install`.
3. Edit configs as needed.
4. Commit and push changes with `bootstrap.sh push`.
5. On other machines, run `bootstrap.sh update` to pull and link everything.

---

This setup allows **full portability**, **secure secrets**, and **easy management** of dotfiles across multiple machines.

