# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # Using Starship instead

# Plugins
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

source $ZSH/oh-my-zsh.sh

# zsh-syntax-highlighting must be loaded last
source $ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null || \
source $ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null || \
echo "Warning: zsh-syntax-highlighting not found"

# Completions
fpath=(~/.zsh/completions $fpath)
autoload -U compinit && compinit

# Flux completions
[[ -n $(command -v flux) ]] && eval "$(flux completion zsh 2>/dev/null || true)"

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS HIST_IGNORE_SPACE HIST_VERIFY INC_APPEND_HISTORY

# Directory navigation
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT

# Other options
setopt CORRECT EXTENDED_GLOB NO_BEEP NOTIFY

# History substring search key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# Starship prompt (load after Oh My Zsh)
eval "$(starship init zsh)"

# Editor
export EDITOR=$([[ -n $SSH_CONNECTION ]] && echo 'nano' || echo 'nvim')

# PATH additions
export PATH="$HOME/.local/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
[[ -n $(command -v pnpm) ]] && eval "$(pnpm completion zsh 2>/dev/null || true)"

# bun
export PATH="$HOME/.bun/bin:$PATH"
[[ -n $(command -v bun) ]] && [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# deno
export PATH="$HOME/.deno/bin:$PATH"

# Rust/Cargo
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lah'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Load local overrides
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
