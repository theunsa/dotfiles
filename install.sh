#!/usr/bin/env bash

# Link the dotfiles vim folder
rm -rf ~/.vim ~/.vimrc
ln -s `pwd`/vim ~/.vim
ln -s ~/.vim/vimrc ~/.vimrc

# Update and get the submodules
git submodule update --init --recursive
git submodule foreach --recursive git pull origin master

# Setup command-t for vim
#TA: Commenting this out for now (trying CtrlP as an alternative)
#cd .vim/bundle/command-t
#rake make
