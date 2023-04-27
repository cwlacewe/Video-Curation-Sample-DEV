#!/bin/bash -e

EXP_TYPE=${1:-"compose"}
REGISTRY=${2:-"None"}
NCPU=${3:-0}

DIR=$(dirname $(readlink -f "$0"))
BUILD_DIR=$DIR/build

if [ -d "$BUILD_DIR" ]; then
    rm -rf $BUILD_DIR
fi

mkdir -p $BUILD_DIR
cd $BUILD_DIR

SOURCE="-DSTREAM_URL="udp://localhost:8088" -DIN_SOURCE=stream"

if [ $REGISTRY == "None" ]; then
    cmake  $SOURCE -DNCPU=$NCPU -DNCURATIONS=2 -DINGESTION=object ..
else
    cmake -DREGISTRY=$REGISTRY $SOURCE -DNCPU=$NCPU ..
fi
make

if [ $EXP_TYPE == "compose" ]; then
    make start_docker_compose
elif [ $EXP_TYPE == "k8" ]; then
    if [ $REGISTRY == "None" ]; then
        make update
    fi
    make start_kubernetes
fi
