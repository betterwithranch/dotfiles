# Dotfiles

Personal dotfiles for macOS, managed as a [bare git repository](https://www.atlassian.com/git/tutorials/dotfiles) with the work tree at `$HOME`.

## Quick Start

Run this on a fresh Mac to bootstrap everything:

```sh
curl https://raw.githubusercontent.com/betterwithranch/dotfiles/main/scripts/init.sh | zsh
```

This single command will:

1. Enable Touch ID for `sudo`
2. Install Xcode Command Line Tools
3. Clone the dotfiles bare repo to `~/.dotfiles`
4. Install [Oh My Zsh](https://ohmyz.sh/)
5. Install [TPM](https://github.com/tmux-plugins/tpm) and tmux plugins
6. Install [Homebrew](https://brew.sh/) and all packages from the Brewfile
7. Link [Alfred](https://www.alfredapp.com/) workflows
8. Install [Claude Code](https://claude.ai/claude-code)
9. Install language runtimes via [asdf](https://asdf-vm.com/)
10. Configure [pam-reattach](https://github.com/fabianishere/pam-reattach) (Touch ID in tmux)
11. Apply macOS system preferences and menu bar configuration
12. Set up Finder sidebar favorites
13. Install [Neovim](https://neovim.io/) plugins
14. Launch and configure [Hammerspoon](https://www.hammerspoon.org/), [Alfred](https://www.alfredapp.com/), [Ghostty](https://ghostty.org/), and [Karabiner-Elements](https://karabiner-elements.pqrs.org/)
15. Grant macOS permissions (Accessibility, Input Monitoring, etc.)
16. Bootstrap workspace automation
17. Inject secrets from [1Password CLI](https://developer.1password.com/docs/cli/)
18. Generate an SSH key and register it with GitHub

## Managing Dotfiles

The repo uses a bare git repository pattern. A `config` alias replaces `git` for dotfiles operations:

```sh
# The alias (defined in .zshrc)
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Track a new file
config add ~/.some-config-file

# Commit and push
config commit -m "add some-config-file"
config push

# Check status (untracked files are hidden by default)
config status

# Use lazygit for the dotfiles repo
lazycfg
```

## What's Included

### Shell (Zsh)

- [Oh My Zsh](https://ohmyz.sh/) with the `robbyrussell` theme
- Plugins: `aws`, `asdf`, `direnv`, `docker`, `docker-compose`, `git`, `pipenv`, `rails`, `ruby`
- Vi mode (`set -o vi`) with vi keybindings in [readline](https://tiswww.case.edu/php/chet/readline/rltop.html) (`.inputrc`) and [editline](https://man.freebsd.org/cgi/man.cgi?editrc(5)) (`.editrc`)
- Deduped, shared history across sessions
- [fzf](https://github.com/junegunn/fzf) shell integration (Ctrl+R, Ctrl+T, Alt+C) with Solarized Dark colors
- [zoxide](https://github.com/ajdiber/zoxide) (`z`) for smart directory jumping
- [Yazi](https://yazi-rs.github.io/) wrapper function (`y`) that syncs the working directory on exit
- Auto-attach to [tmux](https://github.com/tmux/tmux) when Ghostty opens

### Terminal & Multiplexer

- [Ghostty](https://ghostty.org/) terminal with Solarized Dark Higher Contrast theme and [Hack Nerd Font](https://www.nerdfonts.com/)
- [tmux](https://github.com/tmux/tmux) with `C-u` prefix, vi copy mode, mouse support, and hjkl pane navigation
- [TPM](https://github.com/tmux-plugins/tpm) plugins:
  - [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) + [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) for session persistence (auto-save every 5 min, auto-restore on start)
  - [tmux-colors-solarized](https://github.com/seebi/tmux-colors-solarized) for consistent theming
- [tmuxinator](https://github.com/tmuxinator/tmuxinator) (`mux`) for project layouts

### Editor (Neovim)

- [LazyVim](https://www.lazyvim.org/) distribution with catppuccin-frappe colorscheme
- Leader key: `,`
- Plugins for Rails, Treesitter, Diffview, Yazi, auto-session, render-markdown, and more
- [Copilot](https://github.com/features/copilot) and [CodeCompanion](https://github.com/olimorris/codecompanion.nvim) integrations
- [conform.nvim](https://github.com/stevearc/conform.nvim) for formatting, [Solargraph](https://solargraph.org/) for Ruby LSP
- Legacy Vim config (`.vimrc`, `.vim/`) also included

### Git

- [git-delta](https://github.com/dandavella/delta) as pager for both `git` and `gh`
- `nvimdiff` for diffs, [Diffview](https://github.com/sindrets/diffview.nvim) for merges
- `zdiff3` conflict style, `histogram` diff algorithm
- `rerere` enabled for remembering conflict resolutions
- Auto-prune on fetch, rebase on pull with auto-stash
- Branches sorted by most recent commit
- Push defaults: `autoSetupRemote`, push to `current`
- SSH protocol enforced for GitHub URLs
- Local overrides via `~/.gitconfig.local` (gitignored)
- Global gitignore (`.config/git/ignore`): `.DS_Store`, `.env*`, `.idea/`, `.vscode/`, `*.log`, `.direnv/`, swap files

### CLI Tools

Installed via Homebrew ([`.Brewfile`](.Brewfile)):

| Tool | Description |
|------|-------------|
| [bat](https://github.com/sharkdp/bat) | `cat` replacement with syntax highlighting (aliased: `cat`) |
| [eza](https://github.com/eza-community/eza) | `ls` replacement with icons and git status (aliased: `ls`, `ll`, `la`, `tree`) |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder for files, history, and more |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast recursive grep (smart-case, searches hidden files) |
| [fd](https://github.com/sharkdp/fd) | Fast `find` replacement |
| [zoxide](https://github.com/ajdiber/zoxide) | Smarter `cd` that learns your habits |
| [yazi](https://yazi-rs.github.io/) | Terminal file manager |
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal UI for git |
| [git-delta](https://github.com/dandavella/delta) | Beautiful git diffs |
| [btop](https://github.com/aristocratos/btop) | System resource monitor |
| [httpie](https://httpie.io/) | User-friendly HTTP client |
| [tldr](https://tldr.sh/) | Simplified man pages |
| [jq](https://jqlang.github.io/jq/) | JSON processor |
| [gh](https://cli.github.com/) | GitHub CLI |
| [direnv](https://direnv.net/) | Per-directory environment variables (auto-loads `.env` files) |

### Version Management

[asdf](https://asdf-vm.com/) manages runtime versions for Ruby, Node.js, Python, and Terraform. See [`.tool-versions`](.tool-versions) for current versions.

### Karabiner-Elements

[Karabiner-Elements](https://karabiner-elements.pqrs.org/) remaps Caps Lock into a **Hyper key** (`ctrl+alt+cmd+shift`) when held, and **Escape** when tapped alone. This powers all workspace switching hotkeys. Config lives at `~/.config/karabiner/karabiner.json`.

### Hammerspoon (Workspace Manager)

[Hammerspoon](https://www.hammerspoon.org/) provides a full workspace management system. Config lives at `~/.config/hammerspoon/`.

Each workspace maps to a macOS Space and has an associated Chrome profile and tmux session:

| Workspace | Hotkey | Space | Chrome Profile | tmux Session |
|-----------|--------|-------|---------------|--------------|
| Personal | `Hyper+P` | 1 | craig@theisraels.net | personal |
| Sanctum | `Hyper+S` | 2 | craig@hellosanctum.com | sanctum |
| SendCarrot | `Hyper+C` | 3 | craig@sendcarrot.com | sendcarrot |
| MergeFreeze | `Hyper+M` | 4 | hello@mergefreeze.com | mergefreeze |

Additional hotkeys:

| Hotkey | Action |
|--------|--------|
| `Ctrl+Tab` | Next workspace |
| `Ctrl+Shift+Tab` | Previous workspace |
| `Hyper+R` | Reload Hammerspoon config |

Features:
- **Menu bar indicator** shows the current workspace name and icon, persists position across restarts
- **Auto-focus** brings the frontmost window on the target space into focus after switching
- **App bootstrapping** ensures Ghostty (with the correct tmux session) and Chrome (with the correct profile) are running when switching to a workspace
- **Chrome profile detection** uses `lsof` to reliably check which profiles are active
- **Space refresh** re-discovers macOS space IDs every 60 seconds (macOS renumbers them occasionally)

Workspace configs are individual Lua files in `~/.config/hammerspoon/workspaces/`.

### Alfred Workflow (Workspace Switcher)

An [Alfred](https://www.alfredapp.com/) workflow provides a searchable workspace picker. Type `ws` in Alfred to list all workspaces and switch to one. The workflow calls into Hammerspoon via `hs -c`, sharing the same switching logic as the hotkeys.

Workflow files live at `~/.alfred/workflows/workspace-switcher/` and are symlinked into Alfred's preferences.

### macOS Defaults

The `scripts/mac-defaults.sh` and `scripts/menubar.sh` scripts configure:

- **Finder**: Show hidden files, show all extensions, list view by default, no extension change warnings
- **Dock**: Only show running apps, auto-hide, don't rearrange Spaces
- **Menu bar**: Show Battery, WiFi, Clock (day + AM/PM); hide Sound, Focus, Screen Mirroring, Now Playing, Siri
- **System**: Disable smart quotes/dashes, expand save dialogs, auto light/dark mode, silence system sounds
- **Storage**: Don't create `.DS_Store` on network or USB volumes
- **Hot corners**: Bottom-right locks screen

### AI Tools

- [Claude Code](https://claude.ai/claude-code) with global instructions (`.claude.md`), custom skills, hooks, and MCP plugins
- [Codex](https://github.com/openai/codex) (`.codex/`)
- [Copilot](https://github.com/features/copilot) via Neovim
- [Ollama](https://ollama.ai/) for local models

### Networking

`scripts/networking.sh` sets DNS to [Cloudflare](https://1.1.1.1/) (1.1.1.1 / 1.0.0.1) on all Wi-Fi, Ethernet, and USB interfaces.

### Ruby / Rails

- `.gemrc`: Skip documentation on gem install
- `.rspec`: Color output
- `.irbrc`: Auto-enable ActiveRecord logging in Rails console, auto-start Pry
- `.pryrc`: Debugger aliases (`c`/`s`/`n`/`f`), ActiveRecord logging, repeat-last-command on Enter

## Secrets

Secrets are managed with [1Password CLI](https://developer.1password.com/docs/cli/) using template files. The `scripts/secrets.sh` script finds all `.tpl` files and uses `op inject` to populate the real config files with values from your 1Password vault.

### Adding a new secret

1. Create a template file alongside the real config file, with a `.tpl` extension:

   ```
   # ~/.aws/credentials.tpl
   [default]
   aws_access_key_id = {{ op://Personal/AWS/access_key_id }}
   aws_secret_access_key = {{ op://Personal/AWS/secret_access_key }}
   ```

2. The `op://` reference format is `op://Vault/Item/Field`. To find the right values:

   ```
   op vault list
   op item list --vault Personal
   op item get "AWS" --vault Personal
   ```

3. Track the template in your dotfiles (it contains no real secrets):

   ```
   config add ~/.aws/credentials.tpl
   ```

4. Run the secrets script to inject values:

   ```
   source ~/scripts/secrets.sh
   ```

   This also runs automatically during `init.sh`.

## Project Files

Project-specific files (secrets, local config, editor settings) are stored in `~/.project-templates/` and copied into `~/dev/` using the `create_project_files` script.

The directory structure under `~/.project-templates/<project>/` mirrors the project layout:

```
~/.project-templates/sanctum/otter/
  .env.tpl                          # template: secrets injected via op
  .claude/settings.local.json       # raw file: copied as-is
  settings/local.py                 # raw file: copied as-is
```

- **`.tpl` files** are processed with `op inject` -- use `{{ op://Vault/Item/Field }}` for secrets
- **All other files** are copied directly

### Adding project files

1. Create a template directory matching your project path:

   ```
   mkdir -p ~/.project-templates/sanctum/otter
   ```

2. Add files. For secrets, use a `.tpl` extension:

   ```ini
   # ~/.project-templates/sanctum/otter/.env.tpl
   DATABASE_URL={{ op://Development/Otter/database_url }}
   STRIPE_SECRET_KEY={{ op://Development/Otter/stripe_secret_key }}
   RAILS_ENV=development
   PORT=3000
   ```

   For non-secret files, just place them directly:

   ```
   cp ~/dev/sanctum/otter/.claude/settings.local.json \
      ~/.project-templates/sanctum/otter/.claude/settings.local.json
   ```

3. Track in your dotfiles:

   ```
   config add ~/.project-templates/sanctum/otter/
   ```

4. Populate the project:

   ```
   create_project_files sanctum/otter
   ```

### Conventions

- System secret templates (e.g. `~/.aws/credentials.tpl`) live next to the real config file and are injected by `scripts/secrets.sh`
- Project files live in `~/.project-templates/<project-path>/` and are populated by `create_project_files`
- Only `.tpl` files inside hidden directories under `$HOME` (max depth 3) are discovered automatically by `secrets.sh`
- Never track real files containing secrets in source control

## Key Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `config` | `git --git-dir=$HOME/.dotfiles/ ...` | Manage dotfiles repo |
| `vim` | `nvim` | Neovim |
| `cat` | `bat` | Syntax-highlighted cat |
| `ls` | `eza` | Modern ls |
| `ll` | `eza -l` | Long listing |
| `la` | `eza -la` | Long listing with hidden files |
| `tree` | `eza --tree` | Tree view |
| `lg` | `lazygit` | Git TUI |
| `lazycfg` | lazygit for dotfiles | Manage dotfiles in lazygit |
| `s` | `bundle exec rspec spec` | Run RSpec tests |
| `rspec` | `bundle exec rspec` | Run RSpec |
| `dbm` | `bundle exec rails db:migrate` | Rails migrations |
| `mux` | `tmuxinator` | Tmux session manager |
| `dcw` | `docker compose watch` | Docker Compose watch mode |
| `brewdump` | `brew bundle dump ...` | Update Brewfile |

## Refreshing an Existing Machine

To pull the latest dotfiles and re-run setup on a machine that's already configured:

```sh
source ~/scripts/refresh.sh
```

This fetches and runs `init.sh` from the remote, which handles pulling updates, reinstalling packages, and re-injecting secrets.
