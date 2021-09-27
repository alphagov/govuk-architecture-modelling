# GOV.UK architecture as code

This project models the services and boundaries of GOV.UK using C4 and Structurizr. 

**Important!** This is a scratch-pad for modelling the organisation as I explore the applications within GOV.UK. It's a tool for my learning, and shouldn't be taken to be accurate!

# Prerequisites

- PlantUML
- Structurizr CLI

```bash
brew install structurizr-cli plantuml
```

# Generating diagrams

- `make`: remove plantuml and diagrams, and generate new ones.
- `make build`: generate PlantUML output and generate PNG diagrams.
- `make clean`: remove generated outputfrom from `plantuml/` and `diagrams/`.

# Pushing diagrams to Structurizr

These diagrams are available on [Structurizr](https://structurizr.com/workspace/69782).

To push diagrams to Structurizr, you'll need a workspace, with a API key and secret. Then you can run the following:

```
STRUCTURIZR_KEY=XXXX STRUCTURIZR_SECRET=YYYY STRUCTURIZR_WORKSPACE=ZZZZ make push
```