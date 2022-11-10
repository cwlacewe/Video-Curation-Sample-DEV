#!/bin/bash -e

DIR=$(dirname $(readlink -f "$0"))
NCURATIONS=${2:-1}
INGESTION="$3"
IN_SOURCE="$4"
STREAM_URL="$5"
NCPU=$6 
REGISTRY="$7"

if [[ $IN_SOURCE == *"videos"* ]]; then
    if test -f "${DIR}/docker-compose.yml.m4"; then
        echo "Generating docker-compose.yml"
        m4 -DREGISTRY_PREFIX=$REGISTRY -DINGESTION="$INGESTION" -DNCURATIONS="${NCURATIONS}" -DIN_SOURCE="${IN_SOURCE}" -DSTREAM_URL="${STREAM_URL}" -DNCPU="${NCPU}" -I "${DIR}" "${DIR}/docker-compose.yml.m4" > "${DIR}/docker-compose.yml"
    fi
else
    if test -f "${DIR}/docker-compose_stream.yml.m4"; then
        echo "Generating docker-compose.yml"
        m4 -DREGISTRY_PREFIX=$REGISTRY -DINGESTION="$INGESTION" -DNCURATIONS="${NCURATIONS}" -DIN_SOURCE="${IN_SOURCE}" -DSTREAM_URL="${STREAM_URL}" -DNCPU="${NCPU}" -I "${DIR}" "${DIR}/docker-compose_stream.yml.m4" > "${DIR}/docker-compose.yml"
    fi
fi
