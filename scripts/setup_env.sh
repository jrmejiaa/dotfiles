#!/usr/bin/bash

# Global variables
PWD="$(pwd)"
OH_MY_ZSH="${HOME}/.oh-my-zsh"
ZSH_CUSTOM="${OH_MY_ZSH}/custom"
MINICONDA_PATH="${HOME}/.miniconda/"
NVIM_PATH="/opt/nvim/"


install_apt_pkgs() {
    echo "Installing Debian/Ubuntu required packages..."
    sudo apt update
    sudo apt install -y stow git build-essential zsh curl tmux unzip python3-pip
}

install_omz() {
    if [ ! -d "$OH_MY_ZSH" ]; then
        echo "Installing Oh My Zsh..."
        git clone https://github.com/ohmyzsh/ohmyzsh.git "${OH_MY_ZSH}"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${OH_MY_ZSH}/custom/themes/powerlevel10k"
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
    fi
}

install_miniconda() {
    if [ ! -d "$MINICONDA_PATH" ]; then
        echo "Installing miniconda..."
        miniconda_sh="${PWD}/miniconda_latest.sh"
        curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o "${miniconda_sh}"
        chmod +x "${miniconda_sh}"
        "${miniconda_sh}" -b -s -p "${MINICONDA_PATH}"
        rm "${miniconda_sh}"
    fi
}

install_nvim() {
    if ! which nvim &> /dev/null; then
        echo "Installing latest NVIM on system..."
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
        tar -xzf nvim-linux-x86_64.tar.gz
        sudo mv nvim-linux-x86_64 "${NVIM_PATH}"
        rm nvim-linux-x86_64.tar.gz
    fi
}

install_fzf() {
    if ! which fzf &> /dev/null; then
        echo "Installing fzf: A command-line fuzzy finder"
        git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
        "${HOME}"/.fzf/install --bin
        sudo mv "${HOME}"/.fzf/bin/fzf /usr/bin
        rm -rf "${HOME}"/.fzf
    fi
}

install_fd() {
    if ! which fd &> /dev/null; then
        echo "Installing better find: fd..."
        curl -LO https://github.com/sharkdp/fd/releases/download/v10.2.0/fd_10.2.0_amd64.deb
        sudo dpkg -i fd_10.2.0_amd64.deb
        rm fd_10.2.0_amd64.deb
    fi
}

install_bat(){
    if ! which bat &> /dev/null; then
        echo "Installing bat a cat(1) clone with wings..."
        curl -LO https://github.com/sharkdp/bat/releases/download/v0.25.0/bat_0.25.0_amd64.deb
        sudo dpkg -i bat_0.25.0_amd64.deb
        rm bat_0.25.0_amd64.deb
    fi
}

install_cargo() {
    if ! which cargo &> /dev/null; then
        echo "Installing Rust and cargo..."
        rustup_sh="${PWD}/rustup.sh"
        curl -L https://sh.rustup.rs -o "${rustup_sh}"
        chmod +x "${rustup_sh}"
        "${rustup_sh}" -y
        rm "${rustup_sh}"
        # remove a file that creates cargo automatically
        rm -rf "${HOME}/.zshenv"
    fi
}

install_cargo_pkgs() {
    if [ -f "${HOME}/.cargo/env" ]; then
        # shellcheck disable=SC1091
        . "${HOME}/.cargo/env"
        echo "Installing packages via cargo..."
        cargo install eza
        cargo install zoxide --locked
        cargo install git-delta
    fi
}

install_tmuxp() {
    echo "Install tmuxp: a session manager for tmux"
    pip install --user --break-system-packages tmuxp
}

install_deps() {
    install_apt_pkgs
    install_omz
    install_miniconda
    install_nvim
    install_fzf
    install_fd
    install_ba
    install_cargo
    install_cargo_pkgs
    install_tmuxp
}

prepare_for_stow() {
    if [ ! -d "${HOME}/.config" ]; then
        echo "Creating .config file to avoid a complete symlink"
        mkdir "${HOME}/.config"
    fi
}

start_stow() {
    echo "Starting the stow of the repository"
    stow .
}

add_custom_theme_bat() {
    echo "Prepare bat to be able to use custom themes"
    bat cache --build
}

change_to_zsh() {
    echo "Changing to zsh as default shell. This will ask password"
    chsh -s "$(which zsh)"
}

main() {
    install_deps
    prepare_for_stow
    start_stow
    add_custom_theme_bat
    change_to_zsh
}

# Run main script
main
