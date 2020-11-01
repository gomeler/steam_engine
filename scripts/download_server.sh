#!/bin/bash

/bin/bash /home/steam/steamcmd/steam.sh \
    +login anonymous \
    +force_install_dir /home/steam/server_data/ \
    +app_update ${STEAMAPPID:=232130} \
    +quit