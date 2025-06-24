# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Add OMZ, plugins and theme for a Zen ZSH experience
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source "$ZSH/oh-my-zsh.sh"

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
export PATH="${PATH}:${HOME}/.local/bin"
export PATH="${PATH}:/opt/nvim/bin"

# Only important if flatpak is installed. At the moment not part of setup env
export XDG_DATA_DIRS="${XDG_DATA_DIRS}:/var/lib/flatpak/exports/share:/home/mejia/.local/share/flatpak/exports/share"

# Aliases
alias up='sudo apt-get update && sudo apt-get upgrade'
alias rm='rm --preserve-root'
alias vi="nvim"
alias c="clear"

# Source Cargo Rust package manager
. "$HOME/.cargo/env"

# Source advance customizations
. "$HOME/.config/zsh/advance_customizations.sh"

# Source work things
. "$HOME/.work.sh"
