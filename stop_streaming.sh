#!/bin/bash -e

EXP_TYPE=${1:-"compose"}

DIR=$(dirname $(readlink -f "$0"))
BUILD_DIR=$DIR/build

cd $BUILD_DIR

if [ $EXP_TYPE == "compose" ]; then
    make stop_docker_compose
elif [ $EXP_TYPE == "k8" ]; then
    make stop_kubernetes
fi

cd $DIR
