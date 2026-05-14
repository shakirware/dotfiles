HISTFILE="$HOME/.zsh_history"
HISTSIZE=200000
SAVEHIST=200000
setopt APPEND_HISTORY INC_APPEND_HISTORY SHARE_HISTORY EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS HIST_FIND_NO_DUPS HIST_REDUCE_BLANKS
setopt HIST_FCNTL_LOCK

if [[ -z "$TMUX" ]] && command -v tmux >/dev/null; then
  exec tmux new-session -A -s main
fi
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

if [[ -n "$TMUX" ]]; then
  _tmux_sync_env() {
    local v val
    for v in DISPLAY WAYLAND_DISPLAY XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS SSH_AUTH_SOCK; do
      val="$(tmux show-environment -g "$v" 2>/dev/null | sed -n "s/^${v}=//p")"
      [[ -n "$val" ]] && export "$v=$val"
    done
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _tmux_sync_env
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
  local profile="${1:?usage: av <profile>}"
  (
    export AWS_PROFILE="$profile"
    aws sso login --profile "$profile" || return 1
    exec env AWS_PROFILE="$profile" zsh
  )
}

alias mi='fd package.json --exec mise exec --cd={//} -- npm install'

export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/home/shakir/.local/bin"

if [[ -z "$SWAYSOCK" ]]; then
  export SWAYSOCK="$(ls /run/user/$(id -u)/sway-ipc.*.sock 2>/dev/null | head -n1)"
fi

export SOPS_AGE_KEY_FILE="$HOME/.config/mise/age.txt"
export EDITOR="nvim"
