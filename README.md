# steam_engine

## What This Is
Steam Engine was built so that I could deploy numerous Killing Floor 2 servers to support the community. Some friends and I really enjoyed the game, so it only seemed fair to try to give back to the community. The resource requirements are pretty lightweight to support 6 players per server, maybe 1GB of ram, and a portion of one core on a modern desktop processor. However, the server files are ~22GB in size.

## How It Works
Steam Engine deploys a single container to pull the server files from Steam, based off of the steamcmd container by cm2network. The server files are placed in a volume named kf2. Then a run container is deployed, mounting the kf2 volume, and mounting tmpfs volumes over the Config and Log directories. This way N number of servers can all share the same base server files. Updates can be applied by redeploying the servers.

I built this to spin up servers primarily to support the matchmaking Server Takeover in KF2. Some real jerks were spawning servers that auto-kicked players, so I spun up a few servers to help dilute out the trolls. Because of this motivation, there is very minimal server configuration. If you want a single dedicated server for you and your friends, this is probably not the deployment process for you.

## How To Run This
The makefile contains various targets for building the images, downloading the server files from Steam, and spinning up servers. You can run *make start SERVER_COUNT=x* where X is the number of duplicate servers you want to deploy. Alternatively, *make start* will create a single server, useful for testing purposes or if you just prefer a single instance. *make start SERVER_INDEX=y* will create a server with the index y, useful for selectively redeploying a single instance that maybe have hung.

Conversely, *make stop SERVER_COUNT=x* will stop X number servers. Same goes for *make stop* and *make stop SERVER_INDEX=y*.

## Necessary Ports
Killing Floor 2 uses four ports. Starting for server index 0, ports 8000:UDP, 8001:UDP, 8002:TCP, and 20783:UDP are used. The first port is the game server port, the second is the matchmaking server query port, the third is the web admin port, and the fourth is the "Steam Port", whatever that is. Further indexed servers ports follow this ugly bit of bash "$((8000 + 3*${idx})):UDP $((8001 + 3*${idx})):UDP $((8002 + 3*${idx})):TCP $((20783 + ${idx})):UDP". So index 1 is 8003, 8004, 8005, 20784. From what I can tell, I cannot define the Steam Port, it is a value based on the game server port.

## Upcoming Features and Fixes
Several hard-coded config values should be set via arguments. More config values should be available for adjustment. There is no graceful shutdown option for the servers.
