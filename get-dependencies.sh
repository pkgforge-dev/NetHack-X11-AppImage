#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm setconf

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
# make-aur-package

# If the application needs to be manually built that has to be done down here
mkdir -p ./AppDir/bin
VERSION=5.0.0
wget https://github.com/NetHack/NetHack/archive/refs/tags/NetHack-${VERSION}_Released.tar.gz
tar -xvf ./*.tar.gz
rm -f ./*.tar.gz
cd NetHack-NetHack-${VERSION}_Released
patch -NP1 -i ../nethack-x11.patch
cd sys/unix
./setup.sh
cd ../..
make fetch-lua
patch -NP1 -i ../2ndpatch.patch
make -j$(nproc)
mv -v src/nethack dat/* ../AppDir/bin
