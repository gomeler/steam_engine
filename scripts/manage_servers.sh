#!/bin/bash

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   
    case "$KEY" in
            SERVER_COUNT)    SERVER_COUNT=${VALUE} ;;
            SERVER_INDEX)    SERVER_INDEX=${VALUE} ;;
            COMMAND)         COMMAND=${VALUE} ;;
            *)   
    esac    
done

echo "SERVER_COUNT = ${SERVER_COUNT:-}"
echo "SERVER_INDEX = ${SERVER_INDEX:-}"
echo "COMMAND = ${COMMAND:-}"

function array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local found=1
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            found=0
            break
        fi
    done
    return ${found}
}

function deploy_server() {
    local idx
    idx=$1
    echo "Deploying SERVER_INDEX: ${idx}"
    docker run --mount 'type=volume,src=kf2,dst=/home/steam/server_data' \
	--tmpfs=/home/steam/server_data/KFGame/Config/Docker:uid=1000,gid=1000 \
	--tmpfs=/home/steam/server_data/KFGame/Logs:uid=1000,gid=1000 \
	--detach --rm --network=host --name kf2_server_${idx} \
	--env SERVER_INDEX=${idx} gomeler/steam_engine_server:latest
}

function teardown_server() {
    local idx
    idx=$1
    echo "Tearing down SERVER_INDEX: ${idx}"
    docker container stop kf2_server_${idx}
}

function download_server() {
    echo "Download game server from Steam"
    docker run --mount 'type=volume,src=kf2,dst=/home/steam/server_data' \
	--attach STDOUT --attach STDERR --name kf2_install --network=host --rm \
    gomeler/steam_engine_download:latest
}

# Validate the command
VALID_COMMANDS=(deploy teardown download)
result=$(array_contains VALID_COMMANDS ${COMMAND})
if [[ "$?" -ne 0 ]]; then
    echo "Invalid command: ${COMMAND}"
    exit 1
fi

if [[ "${COMMAND}" == "download" ]]; then
    download_server
    exit 0
fi


if [[ -n ${SERVER_INDEX} ]]; then
    echo "SERVER_INDEX: ${SERVER_INDEX}"
    ${COMMAND}_server ${SERVER_INDEX}
elif [[ -n ${SERVER_COUNT} ]]; then
    echo "SERVER_COUNT: ${SERVER_COUNT}"
    for idx in $(seq 0 $((SERVER_COUNT-1))); do
        ${COMMAND}_server ${idx}
    done
fi

