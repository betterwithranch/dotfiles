ulimit -n 65536

export PATH="$HOME/.local/bin:/usr/local/opt/openssl/bin:$PATH"
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/local/sbin:$PATH"

# Adds lsp to path for claude
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"

# Zsh history settings
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export HOMEBREW_NO_AUTO_UPDATE=1
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

installOhMyZsh() {
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}


export COMPOSE_BAKE=true

alias cdk="npx cdk"
alias dbm="bundle exec rails db:migrate"
alias s="bundle exec rspec spec"
alias pspec="bin/pspec"
alias vim=nvim
alias cat="bat"
alias ls="eza"
alias ll="eza -l"
alias la="eza -la"
alias tree="eza --tree"
alias tmux="TERM=screen-256color-bce tmux"
alias mux="tmuxinator"
alias rspec="bundle exec rspec"

alias pips="pipenv shell"
alias pm="python manage.py"
alias psh="python manage.py shell"
# requires django-extensions
alias pshp="python manage.py shell_plus"

# dotfile repo
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias brewdump='brew bundle dump --force'

alias dcw="docker compose watch"
alias gbdm='gfa && git branch --merged main | grep -v "^\*\|main" | xargs -r git branch -d'
alias lg=lazygit
alias lazycfg='GIT_DIR=$HOME/.dotfiles GIT_WORK_TREE=$HOME GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=status.showUntrackedFiles GIT_CONFIG_VALUE_0=all lg'
alias lcg=lazycfg

# Zsh plugins
plugins=(aws asdf direnv docker docker-compose git pipenv rails ruby)
source "$ZSH/oh-my-zsh.sh"

export PATH="$PATH:$(yarn global bin)"
export ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY=latest_installed

# Zoxide - smart cd
eval "$(zoxide init zsh)"

autoload -U edit-command-line
bindkey -M vicmd v edit-command-line
set -o vi

dcleanup(){
  echo "removing containers"
    docker rm -v $(docker ps --filter status=exited -q 2>/dev/null) 2>/dev/null
    echo "removing images"
    docker rmi $(docker images --filter dangling=true -q 2>/dev/null) 2>/dev/null
}

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
 fi

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true

# fzf shell integration (Ctrl+R, Ctrl+T, Alt+C, **<tab>)
source <(fzf --zsh)

# fzf Solarized Dark colors
export FZF_DEFAULT_OPTS='
  --color=bg+:#073642,bg:#002b36,spinner:#719e07,hl:#586e75
  --color=fg:#839496,header:#586e75,info:#cb4b16,pointer:#719e07
  --color=marker:#719e07,fg+:#839496,prompt:#719e07,hl+:#719e07
'

# Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

#export CLAUDE_CODE_USE_BEDROCK=1
#export AWS_DEFAULT_REGION='us-west-2'
#export ANTHROPIC_MODEL='default'
#export ANTHROPIC_SMALL_FAST_MODEL='default'
#
# Using the 'source' command (more readable in scripts)
if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi
# Load .env.claude from git root for Claude Code MCP servers
load_claude_env() {
  local git_root
  git_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -n "$git_root" ] && [ -f "$git_root/.env.claude" ]; then
    # Reject .env.claude files that set dangerous variables
    if grep -qiE '^\s*(export\s+)?(PATH|LD_PRELOAD|LD_LIBRARY_PATH|DYLD_|HOME|SHELL|USER)=' "$git_root/.env.claude"; then
      echo "Warning: $git_root/.env.claude contains unsafe variable assignments. Skipping."
      return 1
    fi
    set -a
    source "$git_root/.env.claude"
    set +a
  fi
}

# Auto-load .env.claude when starting claude
claude() {
  load_claude_env
  command claude "$@"
}
ENABLE_TOOL_SEARCH=true

# Enable task autocompletion
if type task &>/dev/null; then
    eval "$(task --completion zsh)"
fi

# Auto-open tmux when ghostty opens
if command -v tmux >/dev/null 2>&1; then
  if [ -z "$TMUX" ] && [ -n "$PS1" ]; then
    tmux attach || tmux new
  fi
fi
