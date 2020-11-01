#FROM cm2network/steamcmd:root
FROM cm2network/steamcmd as baseStage
LABEL project="steam_engine"

ENV STEAMAPPID 232130
ENV STEAMAPP KF2

# Create mount-point for server data volume.
RUN mkdir /home/steam/server_data
RUN chown steam:steam /home/steam/server_data

USER steam:steam