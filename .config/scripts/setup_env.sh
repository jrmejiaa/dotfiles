#!/usr/bin/bash

# Global variables
PWD="$(pwd)"
OH_MY_ZSH="${HOME}/.oh-my-zsh"
ZSH_CUSTOM="${OH_MY_ZSH}/custom"
MINICONDA_PATH="${HOME}/.miniconda/"
NVIM_PATH="/opt/nvim/"
CARGO_PATH="${HOME}/.cargo"

install_deps() {
    echo "Installing Debian/Ubuntu required packages..."
    sudo apt update
    sudo apt install -y stow git build-essential fzf zsh curl tmux

    if [ ! -d "$OH_MY_ZSH" ]; then
        echo "Installing Oh My Zsh..."
        git clone https://github.com/ohmyzsh/ohmyzsh.git $OH_MY_ZSH
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${OH_MY_ZSH}/custom/themes/powerlevel10k"
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
    fi

    if [ ! -d "$MINICONDA_PATH" ]; then
        echo "Installing miniconda..."
        miniconda_sh="${PWD}/miniconda_latest.sh"
        curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o "$miniconda_sh"
        chmod +x "$miniconda_sh"
        "${miniconda_sh}" -b -s -p "$MINICONDA_PATH"
    fi

    if [ ! -d "$NVIM_PATH" ]; then
        echo "Installing latest NVIM on system..."
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
        tar -xzf nvim-linux-x86_64.tar.gz
        mv nvim-linux-x86_64 "${NVIM_PATH}" 
    fi

    if [ ! -d "$CARGO_PATH" ]; then
        echo "Installing Rust and cargo..."
        rustup_sh="${PWD}/rustup.sh"
        curl -L https://sh.rustup.rs -o "${rustup_sh}"
        chmod +x "${rustup_sh}"
        "${rustup_sh}" -y
    fi
}

main() {
    install_deps
}

# Run main script
main