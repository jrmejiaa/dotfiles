#!/usr/bin/bash

# This file contains all environmental variables that are machine dependent or private
if [ ! -f "${HOME}/.work.env" ]; then
    echo "NOT Work ENV found, do not forget to create one!!"
else
    . "${HOME}/.work.env"
fi

# a stupid alias to avoid that yangcli-pro uses a cache on the client side
# that do not allow to see the latest versions of the YANG files from the
# server
alias yangcli-pro="yangcli-pro --autoload-save-cache false --autoload-cache false --timeout 0 --log-stderr --log-level info"

# Vars to change download and state cache of bitbake to a common place
export YOCTO_EXPERT_MODE=1
export BB_ENV_PASSTHROUGH_ADDITIONS="DL_DIR SSTATE_DIR BB_NUMBER_THREADS PARALLEL_MAKE YOCTO_EXPERT_MODE SSTATE_MIRRORS"
export SSTATE_MIRRORS=""
export SSTATE_DIR="$STANDARD_SSTATE_DIR"
export DL_DIR="$STANDARD_DL_DIR"

# SSH and SCP connection when working with legacy devices
basic_params="-oKexAlgorithms=+diffie-hellman-group1-sha1 -oHostKeyAlgorithms=+ssh-rsa -oStrictHostKeyChecking=no"
devnull_params="-o UserKnownHostsFile=/dev/null -o IdentityFile=/dev/null"
alias scp-legacy="scp -O $basic_params $devnull_params"
alias ssh-legacy="ssh $basic_params $devnull_params"

alias fixdisplay='eval export $(tmux show-env | grep ^DISPLAY)'

# In case we are inside of docker, which means that we are building warrior
# This may not be compatible any longer with kirkstone, so we only share
# between 4.6.X and 4.8.X
if [[ ${HOST} == "docker_nrsw" ]]; then
    unset BB_ENV_PASSTHROUGH_ADDITIONS
    unset SSTATE_DIR
    unset DL_DIR
    export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE DL_DIR SSTATE_DIR BB_NUMBER_THREADS PARALLEL_MAKE SSTATE_MIRRORS"
    export SSTATE_DIR="$LEGACY_SSTATE_DIR"
    export DL_DIR="$LEGACY_DL_DIR"
fi

# This is an stupid things that I have to do in my work just to create a branch :D
mk_branch_name() {
    local big_name="$1"
    local small_name="$2"
    local tp_case="tp$3"
    local type_branch=${4:-"feature"}

    local pmd_num="000"
    local name_branch=""
    if [[ $# -eq 0 ]]; then
        name_branch="feature/bil/default_nb/000/belden_basic"
    else
        name_branch="${type_branch}/bil/${big_name}/${pmd_num}/${small_name}_${tp_case}"
    fi
    echo "$name_branch" | xclip -sel clip
}

# A bitbake helper that checks if this build is for NRSW or PRISM.
bbrootfs() {
    live_target="$1"
    is_nrsw="$(pwd | grep 'nrsw')"
    if [[ -n $is_nrsw ]]; then
        nice -n 19 bitbake nrsw-rootfs
        if [[ $# -ne 0 ]]; then
            scp "$NB_ROOTFS_IMG_PATH" "$live_target":
            if [[ $? -ne 0 ]]; then
                scp -O "$NB_ROOTFS_IMG_PATH" "$live_target":
            fi
            ssh "$live_target" -f "swupdate -r $NB_ROOTFS_IMG_NAME"
            echo "swupdate running, SW Update is in progress in $live_target"
        fi
    else
        nice -n 19 bitbake bil-image-default-dev
    fi
}
