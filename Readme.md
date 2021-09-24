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