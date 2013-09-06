#!/usr/bin/env bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# We need to distinguish sources and binary packages for Brew & Cask on OSX
COMMON_PACKAGES="git git-extras legit vim jnettop hfsutils unrar subversion ack colordiff faac flac lame x264 inkscape graphviz qemu lftp shntool testdisk fdupes recode pngcrush exiftool rtmpdump optipng colortail colorsvn mercurial"
BIN_PACKAGES="audacity avidemux dropbox firefox gimp inkscape vlc blender thunderbird virtualbox bitcoin-qt wireshark"

# Define global Python packages
PYTHON_PACKAGES="readline pip setuptools distribute virtualenv virtualenvwrapper pep8 pylint pyflakes coverage"

# Search local dotfiles
DOT_FILES=`find . -depth 1 -not -name "\.DS_Store" -and -not -name "\.gitignore" -and -not -name "\.gitmodules" -and -not -name "*\.sh" -and -not -name "*\.swp" -and -not -name "*\.md" -and -not -name "\.git"`

for f in $DOT_FILES
do
    source="${PWD}/$f"
    target="${HOME}/$f"
    if [ "$1" = "restore" ]; then
        # Restore backups if found
        if [ -e "${target}.bak" ] && [ -L "${target}" ]; then
            unlink ${target}
            mv $target.df.bak $target
        fi
    else
        # Link files
        if [ -e "${target}" ] && [ ! -L "${target}" ]; then
            mv $target $target.bak
        fi
        ln -sf ${source} ${target}
    fi
done
