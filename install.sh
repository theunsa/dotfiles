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
else
    echo "Linking _* files..."
    for i in _*
    do
        link_file $i
    done
fi

if [ ! -d "$VUNDLE_INSTALL_DIR" ]; then
    echo "Installing Vundle..."
    git clone https://github.com/gmarik/Vundle.vim.git $VUNDLE_INSTALL_DIR
fi

echo "Install/Update Vundle bundles..."
if [[ "$UNAME_STR" == "Darwin" ]]; then
    mvim -v +PluginInstall! +qall
else
    vi +PluginInstall! +qall
fi
