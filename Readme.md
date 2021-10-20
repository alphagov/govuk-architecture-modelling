# GOV.UK architecture as code

This project models the services and boundaries of GOV.UK using C4 and Structurizr.

**Important!** This is a scratch-pad for exploration and modelling the organisation and applications within GOV.UK. It's a tool for learning, and shouldn't be taken to be accurate or in any way 'official'

# Prerequisites

- PlantUML
- Structurizr CLI (or Docker)

## Mac OSX

```bash
brew install structurizr-cli plantuml
```

## Ubuntu

The `structurizr-cli` binary is not available on Ubuntu - you'll need to run the provided Docker container instead.
So you'll need:

- Docker

To download the `structurizr/cli` docker container, run `make docker-pull`
When running make tasks, use `docker` as the first task in the list, and the `structurizr-cli` commands will be run via the docker container.
E.g.

Without docker: `make build`
With docker: `make docker build`


# Generating diagrams

- `make`: remove plantuml and diagrams, and generate new ones.
- `make (docker) build`: generate PlantUML output and generate PNG diagrams.
- `make (docker) clean`: remove generated outputfrom from `plantuml/` and `diagrams/`.

# Pushing diagrams to Structurizr

These diagrams are available on [Structurizr](https://structurizr.com/workspace/69782).

To push diagrams to Structurizr, you'll need a workspace, with a API key and secret. Then you can run the following:

```
STRUCTURIZR_KEY=XXXX STRUCTURIZR_SECRET=YYYY STRUCTURIZR_WORKSPACE=ZZZZ make push
```
