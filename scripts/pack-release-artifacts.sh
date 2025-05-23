#!/bin/bash
#
# release-build.sh
# (C) 2019, all rights reserved,
#
# This file is part of WinDivert.
#
# WinDivert is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
# License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# WinDivert is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc., 51
# Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# Script for building WinDivert binary packages.  This script assumes the
# binaries are already built and are in the Release/ subdirectory.

set -e

CWD=$(pwd)
cd $(dirname $0)
CURRENT_DIR=$(pwd)
PROJECT_DIR=$(dirname $CURRENT_DIR)
INSTALL_DIR=$PROJECT_DIR/install
INCLUDE_DIR=$PROJECT_DIR/include
RELEASE_DIR=$PROJECT_DIR/Release

LABEL=
if [ $# -ge 1 ]; then
    LABEL="-$1"
fi

VERSION=$(cat $PROJECT_DIR/VERSION)
NAME=WinDivert-$VERSION
LABELED_NAME="$NAME$LABEL"

echo "BUILD $LABELED_NAME"
INSTALL=$INSTALL_DIR/$LABELED_NAME
echo "Make $INSTALL..."
rm -rf $INSTALL
mkdir -p $INSTALL

PROJECT_ARTIFACTS=(
    README
    CHANGELOG
    LICENSE
    VERSION
)
INCLUDE_ARTIFACTS=(
    "windivert.h"
)
BINARY_ARTIFACTS=(
    "WinDivert.dll"
    "WinDivert.lib"
    "WinDivert.sys"
    "windivert.inf"
    "windivert.cat"
    "netdump.exe"
    "netfilter.exe"
    "passthru.exe"
    "webfilter.exe"
    "streamdump.exe"
    "flowtrack.exe"
    "socketdump.exe"
    "windivertctl.exe"
    "test.exe"
)

for ARTIFACT in "${PROJECT_ARTIFACTS[@]}"; do
    echo "Copy $ARTIFACT"
    cp $PROJECT_DIR/$ARTIFACT $INSTALL
done

for ARTIFACT in "${INCLUDE_ARTIFACTS[@]}"; do
    echo "Copy $(basename $ARTIFACT)"
    mkdir -p $INSTALL/include
    cp $INCLUDE_DIR/$ARTIFACT $INSTALL/include
done

for ARTIFACT in "${BINARY_ARTIFACTS[@]}"; do
    echo "Copy $(basename $ARTIFACT)"
    for ARCH in x86 x64; do
        mkdir -p $INSTALL/$ARCH

        item=$RELEASE_DIR/$ARCH/$ARTIFACT
        if [ -f $item ]; then
            cp $item $INSTALL/$ARCH
        else
            echo "Skipping: $item (does not exist)"
        fi
        if [ -f "$item.pdb" ]; then
            cp $item.pdb $INSTALL/$ARCH
        fi
    done
done

ARCHIVE=$LABELED_NAME.zip
echo "Building $ARCHIVE..."
(
    cd $INSTALL_DIR
    if [ $(command -v zip) ]; then
        echo "Using zip to create archive"
        zip -r $ARCHIVE $LABELED_NAME >/dev/null
    elif [ $(command -v tar.exe) ]; then
        echo "Using tar to create archive"
        tar.exe -acf $LABELED_NAME.zip $LABELED_NAME >/dev/null
    else
        echo "Neither zip nor tar found, cannot create archive"
        exit 1
    fi
)
# echo -n "\Clean $INSTALL..."
# rm -rf $INSTALL
echo "DONE"
