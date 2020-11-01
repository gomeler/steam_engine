FROM gomeler/steam_engine_base:latest

WORKDIR /home/steam
ADD --chown=steam:steam scripts/configure_server.sh .
RUN chmod a+x configure_server.sh

CMD /home/steam/configure_server.sh