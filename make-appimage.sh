#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=5.0.0
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export STARTUPWMCLASS=
export ALWAYS_SOFTWARE=1

# Deploy dependencies
quick-sharun ./AppDir/bin

# Additional changes can be done in between here

# Fix: NetHack's HACKDIR is "." (current directory), so the AppRun
# must cd to $APPDIR/bin (where data files are) before launching.
# Also set NETHACKDIR env var which NetHack honors as HACKDIR override.
# This runs after quick-sharun in case it regenerated the AppRun.
sed -i 's|^APPDIR=.*|&\ncd "$APPDIR/bin"\nexport NETHACKDIR="$APPDIR/bin"|' ./AppDir/AppRun

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the app normally quits before that time
# then skip this or check if some flag can be passed that makes it stay open
quick-sharun --simple-test ./dist/*.AppImage
