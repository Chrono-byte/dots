zmodload zsh/zprof

# ============================================================================
# 1. BASIC SETTINGS (Fast - no external commands)
# ============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="" # Using Starship instead

# Plugins
plugins=(
  git
  sudo
  dnf
  rust
  deno
  history-substring-search
  zsh-autosuggestions
  extract
)

# ============================================================================
# 2. OH MY ZSH (May take time, but necessary)
# ============================================================================
# Disable oh-my-zsh's compinit since we have our own optimized version
DISABLE_AUTO_COMPINIT=true
source $ZSH/oh-my-zsh.sh

# ============================================================================
# 3. SYNTAX HIGHLIGHTING (Load last, but not in critical path)
# ============================================================================
source $ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null || \
source $ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null || \
echo "Warning: zsh-syntax-highlighting not found"

# ============================================================================
# 4. OPTIMIZED COMPLETIONS (Aggressive caching)
# ============================================================================
fpath=(~/.zsh/completions $fpath)
autoload -U compinit

# Skip compaudit on cached runs (major speedup)
# -C flag skips security audit (saves ~15ms)
# Only do full compinit if cache is older than 24 hours
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(Nmh+24) ]]; then
  compinit
else
  compinit -C
fi

# ============================================================================
# 5. HISTORY CONFIGURATION (Fast)
# ============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS HIST_IGNORE_SPACE HIST_VERIFY INC_APPEND_HISTORY

# ============================================================================
# 6. DIRECTORY NAVIGATION (Fast)
# ============================================================================
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT

# ============================================================================
# 7. OTHER OPTIONS (Fast)
# ============================================================================
setopt CORRECT EXTENDED_GLOB NO_BEEP NOTIFY

# ============================================================================
# 8. HISTORY SUBSTRING SEARCH KEY BINDINGS (Fast)
# ============================================================================
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# ============================================================================
# 9. STARSHIP PROMPT (Relatively fast, but can defer if needed)
# ============================================================================
eval "$(starship init zsh)"

# ============================================================================
# 10. EDITOR CONFIGURATION (Fast)
# ============================================================================
export EDITOR=$([[ -n $SSH_CONNECTION ]] && echo 'nano' || echo 'nvim')

# ============================================================================
# 11. PATH ADDITIONS (Fast - just exports)
# ============================================================================
export PATH="$HOME/.local/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# bun
export PATH="$HOME/.bun/bin:$PATH"

# deno
export PATH="$HOME/.deno/bin:$PATH"

# Rust/Cargo (fast check, source if exists)
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# npm global
export PATH=~/.npm-global/bin:$PATH

# ============================================================================
# 12. ALIASES (Fast)
# ============================================================================
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

# ============================================================================
# 13. LAZY LOADING (Defer slow operations)
# ============================================================================
# Load local overrides (if it's heavy, consider deferring this too)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Defer slow completion loading until after prompt appears
# Uses zsh's built-in sched command to load after shell initialization
sched +0 'source ~/.zshrc.lazy'
