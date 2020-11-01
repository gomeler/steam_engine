# Set index for singular server commands.
SERVER_INDEX?=0
# Set number of expected servers to deploy.
SERVER_COUNT?=

base:
	docker build -t gomeler/steam_engine_base:latest -f base.dockerfile .

download: base
	docker build -t gomeler/steam_engine_download:latest -f downloadStage.dockerfile .

run: base
	docker build -t gomeler/steam_engine_server:latest -f runStage.dockerfile .

images: download run

install: download
	./scripts/manage_servers.sh COMMAND=download

start: images install 
ifdef SERVER_COUNT
	./scripts/manage_servers.sh COMMAND=deploy SERVER_COUNT=${SERVER_COUNT}
endif
ifndef SERVER_COUNT
	./scripts/manage_servers.sh COMMAND=deploy SERVER_INDEX=${SERVER_INDEX}
endif
	
stop:
ifdef SERVER_COUNT
	./scripts/manage_servers.sh COMMAND=teardown SERVER_COUNT=${SERVER_COUNT}
endif
ifndef SERVER_COUNT
	./scripts/manage_servers.sh COMMAND=teardown SERVER_INDEX=${SERVER_INDEX}
endif

clean:
	docker image rm gomeler/steam_engine_base:latest gomeler/steam_engine_download:latest gomeler/steam_engine_server:latest || true
#	docker volume rm kf2 || true