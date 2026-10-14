# AppImage launchers export ARGV0, which Zsh also uses for child command names.
# Clear the inherited launcher name before plugins invoke tools such as Rustup.
if [[ -n "$APPIMAGE" && "$ARGV0" == "$APPIMAGE" ]]; then
  unset ARGV0
fi

zmodload zsh/zprof


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

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias oc-clean-models="rm $HOME/.local/state/opencode/model.json $HOME/.cache/opencode/models.json"


. "$HOME/.vite-plus/env"

if [[ -r "$HOME/.zshrc.secrets" ]]; then
  source "$HOME/.zshrc.secrets"
fi

case ":${PATH}:" in *:"$HOME/.local/bin":*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac

export PATH="/home/chrono/.pi/agent/bin:$PATH"
