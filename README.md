# dotfiles

Dotfiles repository managed by `stow` with all my relevant dotfiles.

## Requirements

* Debian based system. The `setup_env` script uses the APT utility.
* User with `sudo` privilege, ideally without password.
* Internet access

## Installation

The installation is straight-forward by using the `setup_env`:

```bash
cd $HOME
git clone --recursive https://github.com/jrmejiaa/dotfiles.git .dotfiles
cd ${HOME}/.dotfiles
sh scripts/setup_env.sh
```

### How to install on docker for testing

Make a container run

```bash
# Run a vanilla docker ubuntu
docker run -it ubuntu:22.04
```

Installing dependencies and *fixing* environment

```bash
apt update && apt install -y git vim sudo locales
locale-gen en_US.UTF-8

# Fix UTF8, local and TERM
echo 'LC_ALL=en_US.UTF-8' >> /etc/environment
echo 'LANG=en_US.UTF-8' >> /etc/environment
echo 'TERM=xterm-256color' >> /etc/environment
```

Create user and make it able to use `sudo` without password

```
adduser mejia
echo "mejia ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
```

Change to created user and start the git repository from it

```
su mejia
cd $HOME
git clone --recursive https://github.com/jrmejiaa/dotfiles.git .dotfiles
cd $HOME/.dotfiles
sh scripts/setup_env.sh
```

Enjoy 🥂
