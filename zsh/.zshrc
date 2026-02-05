HISTFILE="$HOME/.zsh_history"
HISTSIZE=200000
SAVEHIST=200000
setopt APPEND_HISTORY INC_APPEND_HISTORY SHARE_HISTORY EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS HIST_FIND_NO_DUPS HIST_REDUCE_BLANKS
setopt HIST_FCNTL_LOCK

if [[ -z "$TMUX" ]]; then
  # Reuse existing session if one exists, otherwise create a new one
  if tmux has-session 2>/dev/null; then
    exec tmux attach
  else
    exec tmux new -s main
  fi
fi
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

autoload -Uz compinit
compinit

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light larkery/zsh-histdb


bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down


eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"
eval "$(mise activate zsh)"


av() {
  aws-vault exec "$1" -- zsh
}


export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/home/shakir/.local/bin"
export SOPS_AGE_KEY_FILE="$HOME/.config/mise/age.txt"
export EDITOR="nvim"
