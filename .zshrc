# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

# Add ZSH plugins and theme
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Make zsh behaves as bash in some bind keys
bindkey -v
bindkey '^R' history-incremental-search-backward

# Set vi for bash editing mode
set -o vi
# Set vi as the default editor for all apps that check this
EDITOR=nvim

# See: https://unix.stackexchange.com/questions/232782
export PATH="${PATH}:/usr/local/sbin:/usr/sbin:/sbin"
export PATH="${PATH}:/opt/nvim/bin"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/mejia/.miniconda/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/mejia/.miniconda/etc/profile.d/conda.sh" ]; then
        . "/home/mejia/.miniconda/etc/profile.d/conda.sh"
    else
        export PATH="/home/mejia/.miniconda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Trick to avoid fetching binaries that does not exists in container
if [[ $HOSTNAME != "bitbake" ]]; then
  # ---- FZF -----
  # Set up fzf key bindings and fuzzy completion
  source <(fzf --zsh)

  # ----- Bat (better cat) -----
  export BAT_THEME=tokyonight_night

  # ---- Eza (better ls) -----
  alias ls="eza --color=always --icons=always"

  # ---- Zoxide (better cd) ----
  eval "$(zoxide init zsh)"
fi

# ---- FLATPAK -----
export XDG_DATA_DIRS="${XDG_DATA_DIRS}:/var/lib/flatpak/exports/share:/home/mejia/.local/share/flatpak/exports/share"

# -- Use fd instead of fzf --
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# Aliases
alias up='sudo apt-get update && sudo apt-get upgrade'
alias rm='rm --preserve-root'
alias vi="nvim"

if [ -f "$HOME/.cargo/env" ]; then
  # Cargo Rust package manager
  . "$HOME/.cargo/env"
fi

# Source work things
. "$HOME/.work.sh"
