#!/usr/bin/env bash
set -x

# Install command line tools.
xcode-select --install

# A full installation of Xcode.app is required to compile some formulas like
# macvim. Installing the Command Line Tools only is not enough.
# Also, if Xcode is installed but the license is not accepted then brew will
# fail.
xcodebuild -version
# Accept Xcode license
if [[ $? -ne 0 ]]; then
    # TODO: find a way to install Xcode.app automatticaly
    # See: http://stackoverflow.com/a/18244349
    sudo xcodebuild -license
fi

# Update all OSX packages
sudo softwareupdate -i -a

# Install Homebrew if not found
brew --version 2>&1 >/dev/null
if [[ $? -ne 0 ]]; then
    # Clean-up failed Homebrew install
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
sudo chown -R $(whoami) /usr/local
brew update
brew upgrade --all

# Include duplicates packages
brew tap homebrew/dupes

# Install or upgrade Cask
brew tap caskroom/cask

# Install Mac App Store CLI and upgrade all apps.
brew install mas
mas upgrade

# Install OSX system requirements
brew cask install xquartz

# Install a brand new Python
brew install python
brew link --overwrite python
# Install python 3 too.
brew install python3

# Install common packages
brew install apple-gcc42
for PACKAGE in $COMMON_PACKAGES
do
   brew install "$PACKAGE"
done
brew install ack
brew install avidemux
brew install cassandra
brew install curl
brew link --force curl
brew install dockutil
brew install exiftool
brew install faad2
brew install gpg-agent
brew install keybase
brew install md5sha1sum
brew install --with-qt5 mkvtoolnix
brew install openssl
brew install osxutils
brew install pinentry-mac
brew install pstree
brew install ssh-copy-id
brew install watch
brew install webkit2png

# htop-osx requires root privileges to correctly display all running processes.
sudo chown root:wheel "$(brew --prefix)/bin/htop"
sudo chmod u+s "$(brew --prefix)/bin/htop"

# Install binary apps from homebrew.
for PACKAGE in $BIN_PACKAGES
do
   brew cask install "$PACKAGE"
done
brew cask install aerial
brew cask install android-file-transfer
brew cask install bitcoin-core
brew cask install chromium
brew cask install dropbox
brew cask install dupeguru
brew cask install flux
brew cask install ftdi-vcp-driver
brew cask install gitup
brew cask install google-drive
brew cask install google-play-music-desktop-player
brew cask install java
brew cask install keybase
brew cask install kiwix
brew cask install libreoffice
brew cask install musicbrainz-picard
brew cask install music-manager
brew cask install openemu
brew cask install openzfs
brew cask install rowanj-gitx
brew cask install spectacle
brew cask install steam
brew cask install torbrowser
brew cask install transmission
brew cask install tunnelblick
brew cask install virtualbox-extension-pack
brew cask install xbox360-controller-driver

# Install QuickLooks plugins
# Source: https://github.com/sindresorhus/quick-look-plugins
brew cask install epubquicklook
brew cask install qlcolorcode
brew cask install qlimagesize
brew cask install qlmarkdown
pip install docutils pygments
brew cask install qlrest
brew cask install qlstephen
brew cask install qlvideo
brew cask install quicklook-json
brew cask install suspicious-package
qlmanage -r

# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names

# Install more recent versions of some OS X tools.
brew install homebrew/dupes/grep
brew install homebrew/dupes/openssh

# Add extra filesystem support.
brew cask install osxfuse
brew install homebrew/fuse/ext2fuse
brew install homebrew/fuse/ext4fuse
brew install homebrew/fuse/ntfs-3g

# Install vim
brew install lua --completion
brew install cscope
VIM_FLAGS="--with-python --with-lua --with-cscope --override-system-vim"
#brew install macvim "$VIM_FLAGS"
# Always reinstall vim to fix Python links.
# See: https://github.com/yyuu/pyenv/issues/234
brew reinstall vim "$VIM_FLAGS"

# Install Atom and its plugins.
brew cask install atom
ATOM_PACKAGES="
atom-beautify
autocomplete-paths
autocomplete-python
color-picker
docblockr
file-icons
linter-flake8
minimap
python-isort
python-tools
tag
trailing-spaces
"
for PACKAGE in $ATOM_PACKAGES
do
   apm install "$PACKAGE"
done

# Use sha256sum from coreutils
sudo ln -s /usr/local/bin/gsha256sum /usr/local/bin/sha256sum

# Install runsnakeerun
brew install wxmac
brew install wxpython
pip install --upgrade RunSnakeRun

# Install uBlock for Safari.
defaults read ~/Library/Safari/Extensions/extensions | grep --quiet "net.gorhill.uBlock"
if [[ $? -ne 0 ]]; then
    curl -o "$TMPDIR/ublock-safari.safariextz" -O https://cloud.delosent.com/ublock-safari-0.9.5.2.safariextz
    open "$TMPDIR/ublock-safari.safariextz"
fi

# Set chromium as the default browser.
brew install duti
duti -s org.chromium.Chromium http

# Install mpv.app so we can set it as default player.
# Source: https://github.com/mpv-player/mpv/wiki/FAQ#how-can-i-make-mpv-the-default-application-to-open-movie-files-on-osx
brew install mpv --with-bundle
brew linkapps mpv
duti -s io.mpv api
duti -s io.mpv mkv
duti -s io.mpv mp4

# Install Popcorn Time.
rm -rf /Applications/Popcorn-Time.app
wget -O - "https://get.popcorntime.sh/build/Popcorn-Time-0.3.9-Mac.tar.xz" | tar -xvJ --directory /Applications -f -

# Install and configure bitbar.
brew cask install bitbar
defaults write com.matryer.BitBar pluginsDirectory "~/.bitbar"
wget -O "${HOME}/.bitbar/btc.17m.sh" https://github.com/matryer/bitbar-plugins/raw/master/Bitcoin/bitstamp.net/last.10s.sh
sed -i "s/Bitstamp: /Ƀ/" "${HOME}/.bitbar/btc.17m.sh"
wget -O "${HOME}/.bitbar/netinfo.3m.sh" https://github.com/matryer/bitbar-plugins/raw/master/Network/netinfo.60s.sh
wget -O "${HOME}/.bitbar/disk.13m.sh" https://github.com/matryer/bitbar-plugins/raw/master/System/mdf.1m.sh
wget -O "${HOME}/.bitbar/package_manager.7h.py" https://github.com/matryer/bitbar-plugins/raw/master/Dev/PackageManager/package_manager.7h.py
chmod +x ${HOME}/.bitbar/*.sh
open -a BitBar

# Show TorBrowser bookmark toolbar.
TB_CONFIG_DIR=$(find "${HOME}/Library/Application Support/TorBrowser-Data/Browser" -depth 1 -iname "*.default")
sed -i "s/\"PersonalToolbar\":{\"collapsed\":\"true\"}/\"PersonalToolbar\":{\"collapsed\":\"false\"}/" "$TB_CONFIG_DIR/xulstore.json"
# Set TorBrowser bookmarks in toolbar.
# Source: https://yro.slashdot.org/story/16/06/08/151245/kickasstorrents-enters-the-dark-web-adds-official-tor-address
BOOKMARKS="
http://lsuzvpko6w6hzpnn.onion,KickAss,ehmwyurmkort,eqeiuuEyivna
http://uj3wazyk5u4hnvtk.onion,PirateBay,nnypemktnpya,dvzeeooowsgx
"
TB_BOOKMARK_DB="$TB_CONFIG_DIR/places.sqlite"
# Remove all bookmarks from the toolbar.
sqlite3 -echo -header -column "$TB_BOOKMARK_DB" "DELETE FROM moz_bookmarks WHERE parent=(SELECT id FROM moz_bookmarks WHERE guid='toolbar_____'); SELECT * FROM moz_bookmarks;"
# Add bookmarks one by one.
for BM_INFO in $BOOKMARKS
do
    BM_URL=$(echo $BM_INFO | cut -d',' -f1)
    BM_TITLE=$(echo $BM_INFO | cut -d',' -f2)
    BM_GUID1=$(echo $BM_INFO | cut -d',' -f3)
    BM_GUID2=$(echo $BM_INFO | cut -d',' -f4)
    sqlite3 -echo -header -column "$TB_BOOKMARK_DB" "INSERT OR REPLACE INTO moz_places(url, hidden, guid, foreign_count) VALUES('$BM_URL', 0, '$BM_GUID1', 1); INSERT OR REPLACE INTO moz_bookmarks(type, fk, parent, title, guid) VALUES(1, (SELECT id FROM moz_places WHERE guid='$BM_GUID1'), (SELECT id FROM moz_bookmarks WHERE guid='toolbar_____'), '$BM_TITLE', '$BM_GUID2');"
done
sqlite3 -echo -header -column "$TB_BOOKMARK_DB" "SELECT * FROM moz_bookmarks; SELECT * FROM moz_places;"

# Force installation of uBlock origin
wget https://addons.mozilla.org/firefox/downloads/file/319372/ -O "$TB_CONFIG_DIR/extensions/uBlock0@raymondhill.net.xpi"

# Clean things up.
brew linkapps
brew cleanup
brew prune
brew cask cleanup
