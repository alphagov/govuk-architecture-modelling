all: clean build

clean:
	rm plantuml/* diagrams/*

build:
	structurizr-cli export -workspace src/workspace.dsl -format plantuml -o plantuml
	plantuml plantuml/*.puml -o ${PWD}/diagrams/
