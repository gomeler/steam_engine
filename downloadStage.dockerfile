FROM gomeler/steam_engine_base:latest

WORKDIR /home/steam
ADD --chown=steam:steam scripts/download_server.sh .
RUN chmod a+x download_server.sh

CMD /home/steam/download_server.sh