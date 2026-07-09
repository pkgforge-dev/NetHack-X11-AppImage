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

# Fix: NetHack's HACKDIR is "." (current directory), so sharun
# must cd to $APPDIR/bin (where data files are) before launching.
# SHARUN_WORKING_DIR tells the sharun binary to chdir there first.
# NETHACKDIR is a runtime override NetHack honors for HACKDIR.
{
    echo 'SHARUN_WORKING_DIR=${SHARUN_DIR}/bin'
    echo 'NETHACKDIR=${SHARUN_DIR}/bin'
} >> ./AppDir/.env

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the app normally quits before that time
# then skip this or check if some flag can be passed that makes it stay open
quick-sharun --simple-test ./dist/*.AppImage
