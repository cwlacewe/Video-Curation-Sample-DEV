#!/bin/bash -e

DIR=$(dirname $(readlink -f "$0"))
NCURATIONS=${2:-1}
INGESTION="$3"
IN_SOURCE="$4"
STREAM_URL="$5"
NCPU=$6
REGISTRY="$7"

find "${DIR}" -maxdepth 1 -mindepth 1 -name "*.yaml" -exec rm -rf "{}" \;
for template in $(find "${DIR}" -maxdepth 1 -mindepth 1 -name "*.yaml.m4" -print); do
    yaml=${template/.m4/}
    m4 -DREGISTRY_PREFIX=$REGISTRY -DINGESTION="$INGESTION" -DNCURATIONS=$NCURATIONS -DIN_SOURCE=$IN_SOURCE -DSTREAM_URL=$STREAM_URL -DNCPU=$NCPU -DUSERID=$(id -u) -DGROUPID=$(id -g) -I "${DIR}" "${template}" > "${yaml}"
    # m4 -DREGISTRY_PREFIX=$REGISTRY -DINGESTION="$INGESTION" -DNCURATIONS=$NCURATIONS -DIN_SOURCE=$IN_SOURCE -DSTREAM_URL=$STREAM_URL -I "${DIR}" "${template}" > "${yaml}"
done
