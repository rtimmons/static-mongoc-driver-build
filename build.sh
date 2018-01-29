#!/usr/bin/env bash

mydir="$(dirname "$0")"
pushd "$mydir" > /dev/null
    mydir="$(pwd -P)"
popd > /dev/null

prefix="$mydir/lib"

if [ ! -d "$prefix" ]; then
    mkdir -p "$prefix"
fi

# C Driver

BASENAME="mongo-c-driver-1.9.2"
GZ_FILE="${BASENAME}.tar.gz"
URL="https://github.com/mongodb/mongo-c-driver/releases/download/1.9.2/${GZ_FILE}"

if [ ! -e "$GZ_FILE" ]; then
    wget "$URL"
fi

if [ ! -d "$BASENAME" ]; then
    tar xzf "$GZ_FILE"
fi

if [ ! -e "$prefix/lib/bin/mongoc-stat" ]; then
    pushd "$BASENAME" >/dev/null
        if [ ! -e "Makefile" ]; then
            ./configure \
                --prefix="$prefix" \
                --disable-automatic-init-and-cleanup \
                --enable-static \
                ;
        fi
        make
        make install
    popd >/dev/null
fi

# C++ Driver

REPO="mongo-cxx-driver"
REPO_URL="https://github.com/mongodb/${REPO}.git"

if [ ! -d "$REPO" ]; then
    git clone https://github.com/mongodb/mongo-cxx-driver.git \
        --branch releases/stable --depth 1
fi

pushd "$REPO" > /dev/null
    cmake -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$prefix" \
        -DCMAKE_PREFIX_PATH="$prefix" \
        -DLIBBSON_DIR="$prefix" \
        -DBUILD_SHARED_LIBS=OFF \
        ;
    make
    make install
popd >/dev/null
