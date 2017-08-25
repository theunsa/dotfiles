#!/usr/bin/env bash

UNAME_STR=`uname`
VUNDLE_INSTALL_DIR=_vim/bundle/Vundle.vim

function link_file {
    source="${PWD}/$1"
    target="${HOME}/${1/_/.}"

    if [ -e "${target}" ] && [ ! -L "${target}" ]; then
        mv $target $target.bak
    fi

    ln -sf ${source} ${target}
}

function unlink_file {
    source="${PWD}/$1"
    target="${HOME}/${1/_/.}"

    if [ -e "${target}.bak" ] && [ -L "${target}" ]; then
        unlink ${target}
        mv $target.bak $target
    fi
}

if [ "$1" = "--unlink" ]; then
    echo "Unlinking _* files..."
    for i in _*
    do
        unlink_file $i
    done
    exit
elif [ "$1" = "--ycm" ]; then
    # See: https://github.com/Valloric/YouCompleteMe/README.md
    echo "Recompiling YouCompleteMe plugin..."
    pushd ~/.vim/bundle/YouCompleteMe
    git fetch
    git reset --hard HEAD^
    git submodule update --init --recursive
    ./install.sh --clang-completer
    popd
    exit
elif [ "$1" = "--wombat" ]; then
    # Install the wombat theme
    mkdir -p ~/.vim/colors
    pushd ~/.vim/colors
    wget -O wombat256mod.vim http://www.vim.org/scripts/download_script.php?src_id=13400
    popd
    exit
else
    echo "Linking _* files..."
    for i in _*
    do
        link_file $i
    done
fi

# Check to make sure vi is not 'Small version without GUI'
vi_version=`vi --version | grep "Small version without GUI"`
if [[ ! -z $vi_version ]]; then
   echo "ERROR! Wrong vi version. Current is small version without GUI"
   echo "- probably need to install vim-gui-common, vim-runtime"
   exit 9
fi

if [ ! -d "$VUNDLE_INSTALL_DIR" ]; then
    echo "Installing Vundle..."
    git clone https://github.com/gmarik/Vundle.vim.git $VUNDLE_INSTALL_DIR || echo "ERROR! Failed to install Vundle!" || exit 10
fi

echo "Install/Update Vundle bundles..."
if [[ "$UNAME_STR" == "Darwin" ]]; then
    mvim -v +PluginInstall! +qall
else
    vi +PluginInstall! +qall
fi


## TODO:
## install zsh
## install oh-my-zsh
## install pip
## pip install virtualenvwrapper
## apt-get install build-essential linux-headers-generic linux-headers-`uname -r`
