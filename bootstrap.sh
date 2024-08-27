#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
STOWED="$SCRIPT_DIR/stowed"
INSTALL_LOG="$SCRIPT_DIR/install.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

padding=14

function darwin { [ "$(uname -s)" = "Darwin" ]; }
function linux { [ "$(uname -s)" = "Linux" ]; }
function checking() { echo -en "\r\033[K$program: ${YELLOW}Checking${NC}"; }
function installing() { echo -en "\r\033[K$(printf %-${padding}s """$program"""): ${YELLOW}Installing${NC}"; }
function installed() { echo -e "\r\033[K$(printf %-${padding}s """$program"""): ${GREEN}Installed${NC}"; }
function updating() { echo -en "\r\033[K$(printf %-${padding}s """$program"""): ${YELLOW}Updating${NC}"; }
function updated() { echo -e "\r\033[K$(printf %-${padding}s """$program"""): ${GREEN}Updated${NC}"; }
function failed() { echo -e "\r\033[K$(printf %-${padding}s """$program"""): ${RED}Failed${NC} - See $INSTALL_LOG for more details"; }

function install() {
  if command -v "$1" &>/dev/null; then
    installed
  else
    installing
    if darwin; then
      {
        brew install "$1" >>"$INSTALL_LOG" 2>&1 &&
          installed
      } || {
        failed
      }
    else
      {
        DEBIAN_FRONTEND=noninteractiv sudo apt install -y "$1" >>"$INSTALL_LOG" 2>&1 &&
          installed
      } || {
        failed
      }
    fi
  fi
}

function backup() {
  base="${1%/*}"
  file="${1##*/}"
  backupdir="$base/dotfiles-backup"
  mkdir -p $backupdir
  cp "$1" "$backupdir/$file"-backup-"$(date +%s)" && rm "$1"
}

# ###############################
#
# Enable Sudo
#
# ###############################

echo "Grand sudo access"
sudo ls &>/dev/null

# ###############################
#
# .config
#
# ###############################

mkdir -p "$HOME"/.config

# ###############################
#
# Homebrew
#
# ###############################

program="Homebrew"
if darwin; then
  checking
  if command -v brew &>/dev/null; then
    installed
  else
    installing
    {
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >>"$INSTALL_LOG" 2>&1 &&
        (
          echo
          echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
        ) >>/Users/levi/.zprofile &&
        eval "$(/opt/homebrew/bin/brew shellenv)" &&
        installed
    } || {
      failed
    }
  fi
fi

# ###############################
#
# Apt update
#
# ###############################

program="Apt"
if linux; then
  updating
  {
    sudo apt update >>"$INSTALL_LOG" 2>&1 &&
      updated
  } || {
    failed
  }
fi

# ###############################
#
# Curl
#
# ###############################

program="Curl" install curl

# ###############################
#
# GNU Stow
#
# ###############################

program="GNU Stow" install stow

# ###############################
#
# Ack
#
# ###############################

program="Ack" install ack
[[ ! -f $HOME/.ackrc ]] || backup "$HOME"/.ackrc
stow -d "$STOWED" -t "$HOME" ack

# ###############################
#
# Htop
#
# ###############################

program="Htop" install htop

# ###############################
#
# Eza
#
# ###############################

# This will work with Ubuntu 20.10+
program="Eza" install eza

# ###############################
#
# fzf
#
# ###############################

program="fzf" install fzf

# ###############################
#
# Bat
#
# ###############################

program="Bat" install bat

# ###############################
#
# Git
#
# ###############################

program="Git" install git
[[ ! -f $HOME/.gitconfig ]] || backup "$HOME"/.gitconfig
[[ ! -f $HOME/.gitignore_global ]] || backup "$HOME"/.gitignore_global
stow -d "$STOWED" -t "$HOME" git

# ###############################
#
# Git GUI
#
# ###############################

program="Git GUI" install git-gui

# ###############################
#
# Git Delta
#
# ###############################

program="Git Delta" install git-delta

# ###############################
#
# entr
#
# ###############################

program="entr" install entr

# ###############################
#
# Zsh
#
# ###############################

program="Zsh" install zsh

# ###############################
#
# Oh My Zsh
#
# ###############################

program="Oh My Zsh"
checking
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  installing
  {
    yes | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >>"$INSTALL_LOG" 2>&1 &&
      installed
  } || { failed; }
else
  installed
fi

[[ ! -f $HOME/.zshrc ]] || backup "$HOME"/.zshrc
stow -d "$STOWED" -t "$HOME" zshrc

# ###############################
#
# zshrc-tokens
#
# ###############################
#
# touch the tokens file to make sure it exists
touch ~/.zshrc-tokens

# ###############################
#
# macOs Typing Speed
#
# ###############################

program="Typing Speed"
if darwin; then
  {
    updating
    defaults write NSGlobalDomain InitialKeyRepeat -int 20 &&
      defaults write NSGlobalDomain KeyRepeat -int 2 &&
      updated
  } || {
    failed
  }
fi

# ###############################
#
# Python
#
# ###############################

program="Python" install python

# ###############################
#
# Go
#
# ###############################

program="Go" install go

# ###############################
#
# richgo
#
# ###############################

program="richgo"
checking
if command -v richgo &>/dev/null; then
  installed
else
  installing
  if true; then
    {
      go install github.com/kyoh86/richgo@latest >>"$INSTALL_LOG" 2>&1
      installed
    } || { failed; }
  fi
fi

# ###############################
#
# RustUp
#
# ###############################

program="rustup"
checking
if command -v rustup &>/dev/null; then
  installed
elif [[ "$SKIP" =~ .*"rust".* ]]; then
  skipping
else
  installing
  {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh /dev/stdin -y >>"$INSTALL_LOG" 2>&1 &&
      installed
  } || { failed; }
fi

# ###############################
#
# VIM
#
# ###############################

# Update the system VIM.
# Even though we plan to use nvim, this is needed
#   for vim-go to work correctly
program="VIM" install vim
[[ ! -f $HOME/.vimrc ]] || backup "$HOME"/.vimrc

# ###############################
#
# Neovim
#
# ###############################

program="neovim" install neovim
[[ ! -f $HOME/.config/nvim/init.vim ]] || backup "$HOME"/.config/nvim/init.vim
mkdir -p "$HOME"/.config/nvim
stow -d "$STOWED" -t "$HOME"/.config/nvim neovim

# ###############################
#
# Warp
#
# ###############################

program="warp" install warp

# ###############################
#
# Starship
#
# ###############################

program="starship"
checking
if command -v starship &>/dev/null; then
  installed
else
  installing
  {
    mkdir -p $HOME/.local/bin
    curl -sS https://starship.rs/install.sh | sh /dev/stdin -y -b $HOME/.local/bin >>"$INSTALL_LOG" 2>&1 &&
      installed
  } || { failed; }
fi

# ###############################
#
# Nerd Fonts
#
# ###############################

program="Nerd Fonts"
if darwin; then
  font_dir="$HOME/Library/Fonts"
else
  font_dir="$HOME/.local/share/fonts"
  mkdir -p "$font_dir"
fi

if ls "$font_dir/FiraCode*" &>/dev/null; then
  installed
else
  installing
  {
    curl -s -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.tar.xz | tar xz - -C $font_dir &&
      installed
  } || {
    failed
  }
fi
