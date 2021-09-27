all: clean build

clean:
	rm plantuml/* diagrams/*

build:
	structurizr-cli export -workspace src/workspace.dsl -format plantuml -o plantuml
	plantuml plantuml/*.puml -o ${PWD}/diagrams/

push:
	structurizr-cli push -id ${STRUCTURIZR_WORKSPACE} -key ${STRUCTURIZR_KEY} -secret ${STRUCTURIZR_SECRET} -workspace src/workspace.dsl