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

# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"

# >>> vercel ai-gateway >>>
# Managed by `vercel ai-gateway coding-agents setup` — safe to remove this block.
export AI_GATEWAY_API_KEY='vck_8V8fLFoK5GTNwCGmQoKZdON1sE9cljCCzss0NcR9RGVpmXlqcb0UetqW'
# <<< vercel ai-gateway <<<

# Unity CLI
case ":${PATH}:" in *:"$HOME/.local/bin":*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac

# Pi
export PATH="/home/chrono/.pi/agent/bin:$PATH"
