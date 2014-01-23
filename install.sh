#!/usr/bin/env bash
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

if [ "$1" = "vim" ]; then
    for i in _vim*
    do
       link_file $i
    done
elif [ "$1" = "restore" ]; then
    for i in _*
    do
        unlink_file $i
    done
    exit
else
    for i in _*
    do
        link_file $i
    done
fi

echo "Set up Vundle..."
VUNDLE_INSTALL_DIR=_vim/bundle/vundle
if [ -d "$VUNDLE_INSTALL_DIR" ]; then
    pushd $VUNDLE_INSTALL_DIR
    git pull
    popd
else
    git clone https://github.com/gmarik/vundle.git $VUNDLE_INSTALL_DIR
fi

echo "Install Vundle bundles..."
uname_str=`uname`
if [[ "$uname_str" == "Darwin" ]]; then
    mvim +BundleInstall +qall
else
    vi +BundleInstall +qall
fi
