# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load (we're using Starship, so set to empty)
ZSH_THEME=""

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# Note: zsh-syntax-highlighting must be loaded last, so we load it separately
plugins=(
  git
  sudo
  dnf
  rust
  deno
  bun
  history-substring-search
  zsh-autosuggestions
  extract
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Load zsh-syntax-highlighting last (must be loaded after all other plugins)
source $ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null || \
source $ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null || \
echo "Warning: zsh-syntax-highlighting not found"

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Other useful options
setopt CORRECT
setopt EXTENDED_GLOB
setopt NO_BEEP
setopt NOTIFY

# History substring search key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# Starship prompt (load after Oh My Zsh)
eval "$(starship init zsh)"

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lah'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Git aliases (Oh My Zsh git plugin provides many, but we add some extras)
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'

# Directory shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='nano'
else
   export EDITOR='nvim'
fi

# PATH additions for package managers
export PATH="$HOME/.local/bin:$PATH"
# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
# bun
export PATH="$HOME/.bun/bin:$PATH"
# deno
export PATH="$HOME/.deno/bin:$PATH"

# Rust/Cargo environment (rust plugin provides completions, but we still need to source cargo env)
if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi

# pnpm completions
if command -v pnpm &> /dev/null; then
    # pnpm shell completion
    eval "$(pnpm completion zsh 2>/dev/null || true)"
fi

# bun completions (bun plugin should handle this, but ensure it's set up)
if command -v bun &> /dev/null; then
    [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
fi

# deno completions (deno plugin should handle this, but ensure PATH is set)
if command -v deno &> /dev/null; then
    # deno plugin provides completions
    :
fi

# Load local zshrc if it exists
if [[ -f ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi
export PATH="$HOME/.local/bin:$PATH"
