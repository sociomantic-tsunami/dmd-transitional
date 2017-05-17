#!/bin/sh

set -xe

DLANG_BASE_VER="v2.070.2"
ROOT=`pwd`

rm -rf dmd
git clone --branch $DLANG_BASE_VER https://github.com/dlang/dmd.git --depth 1
cd dmd
git am ../patches/dmd/*
make -f posix.mak MODEL=64 RELEASE=1 AUTO_BOOTSTRAP=1
cd $ROOT

rm -rf druntime
git clone --branch $DLANG_BASE_VER https://github.com/dlang/druntime.git --depth 1
cd druntime
git am ../patches/druntime/*
make -f posix.mak MODEL=64 BUILD=debug
make -f posix.mak MODEL=64 BUILD=release
cd $ROOT

make pkg
