#!/bin/bash

PORT_ARRAY=
echo "SERVER_INDEX: ${SERVER_INDEX}"
function create_port_array() {
    local idx
    idx=$1
    local port_array=
    port_array="$((8000 + 3*${idx})):UDP $((8001 + 3*${idx})):UDP $((8002 + 3*${idx})):TCP $((20783 + ${idx})):UDP"
    echo -n ${port_array}
}

PORT_ARRAY=$(create_port_array ${SERVER_INDEX})
echo "PORT_ARRAY: ${PORT_ARRAY}"

# Copy the Killing Floor 2 configuration data
cp -r /home/steam/server_data/KFGame/Config/{LinuxServer-*,KF*} /home/steam/server_data/KFGame/Config/Docker

# Enable web admin
sed -i.bak 's/bEnabled=false/bEnabled=true/' /home/steam/server_data/KFGame/Config/Docker/KFWeb.ini

# Set admin password, Server Name, and MOTD
sed -i.bak -e "s/AdminPassword=.*/AdminPassword=SuperSecurePassword/" -e "s/^ServerName=.*/ServerName=Red Panda Killing Floor #${SERVER_INDEX}/" -e "s/ServerMOTD=.*/ServerMOTD=Deployed via Steam Engine. Enjoy!/" /home/steam/server_data/KFGame/Config/Docker/LinuxServer-KFGame.ini

# Temporarily disable the server for external use
sed -i.bak -e 's/bUsedForTakeover=TRUE/bUsedForTakeover=False/' -e 's/GamePassword=.*/GamePassword=SuperSecurePassword/' /home/steam/server_data/KFGame/Config/Docker/LinuxServer-KFGame.ini

# Kick off the game server
game_port=$(echo ${PORT_ARRAY} | cut -d' ' -f1 | cut -d':' -f1)
query_port=$(echo ${PORT_ARRAY} | cut -d' ' -f2 | cut -d':' -f1)
admin_port=$(echo ${PORT_ARRAY} | cut -d' ' -f3 | cut -d':' -f1)
/home/steam/server_data/Binaries/Win64/KFGameSteamServer.bin.x86_64 KF-BurningParis -Port=${game_port} -QueryPort=${query_port} -WebAdminPort=${admin_port} -ConfigSubDir=Docker