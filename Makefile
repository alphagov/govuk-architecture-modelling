CLI_CMD=structurizr-cli

.PHONY: docker docker-pull

all: clean build

clean:
	rm -f plantuml/* diagrams/*

docker:
	$(eval export CLI_CMD=docker run -it --rm -v ${PWD}:/usr/local/structurizr structurizr/cli)

docker-pull:
	docker pull structurizr/cli:latest

build:
	${CLI_CMD} export -workspace src/workspace.dsl -format plantuml -o plantuml
	plantuml plantuml/*.puml -o ${PWD}/diagrams/

push:
	${CLI_CMD} push -id ${STRUCTURIZR_WORKSPACE} -key ${STRUCTURIZR_KEY} -secret ${STRUCTURIZR_SECRET} -workspace src/workspace.dsl
