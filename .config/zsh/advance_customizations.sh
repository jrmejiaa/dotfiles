#!/usr/bin/bash

#
# This file is meant for all those configuration that are found really cool on
# internet that improves my productivity but I did not create and most likely
# do not understand completely. In order to avoid making the zshrc file really
# big with these configurations, I prefer to put it here.
#

# This lines avoids that tmux creates auto titles on panes
export DISABLE_AUTO_TITLE='true'

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("${HOME}/.miniconda/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${HOME}/.miniconda/etc/profile.d/conda.sh" ]; then
        . "${HOME}/.miniconda/etc/profile.d/conda.sh"
    else
        export PATH="${HOME}/.miniconda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Trick to avoid fetching binaries that does not exists in container
if which fzf &> /dev/null; then
    # Set up fzf key bindings and fuzzy completion
    source <(fzf --zsh)

    # Say Bat that we want this theme
    export BAT_THEME=tokyonight_night

    # Using eza as the normal ls command
    alias ls="eza --color=always --icons=always"

    # ---- Zoxide (better cd) ----
    eval "$(zoxide init zsh)"
fi

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
        export|unset) fzf --preview "eval 'echo ${}'"           "$@" ;;
        ssh)          fzf --preview 'dig {}'                    "$@" ;;
        *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
    esac
}
