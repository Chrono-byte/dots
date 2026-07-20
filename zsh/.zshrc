zmodload zsh/zprof

# flux hook
# flux remote check 2>&1

# Plugins
plugins=(
  git
  fnm
  sudo
  dnf
  rust
  history-substring-search
  zsh-autosuggestions
  extract
  zsh-syntax-highlighting
)

source "$HOME/.zshrc.common"

# Linux/GNU-specific aliases.
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias oc-clean-models="rm $HOME/.local/state/opencode/model.json $HOME/.cache/opencode/models.json"

# zprof
