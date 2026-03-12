# latex-devcontainer

Multi-project LaTeX workspace for macOS, Linux, and Windows (WSL/Git Bash).

All projects must be inside `projects/`.

## Project layout

```text
projects/<project_name>/
├── main.tex
├── project.mk
├── sections/
├── figures/
├── tables/
├── bib/
└── out/
```

- Default entrypoint: `main.tex`
- PDF output: `projects/<project_name>/out/main.pdf`

## Per-project requirements (`project.mk`)

Each project defines its build requirements in `projects/<project_name>/project.mk`.

Supported variables:

- `MAIN`
- `LATEX_ENGINE` (`pdflatex`, `xelatex`, `lualatex`)
- `BIB_TOOL` (`auto`, `none`, `biber`, `bibtex`)
- `EXTRA_LATEXMK_FLAGS`
- `REQUIRED_CMDS`

Template:

- `templates/project/project.mk`

## Prerequisites

Local:

- `make`
- `latexmk`
- tools required by each project `project.mk`

Container:

- Docker Desktop (macOS/Windows) or Docker Engine + Compose plugin (Linux)
- `make`

## Quick start (local)

```bash
cd /path/to/latex-devcontainer
make doctor
make doctor-project PROJECT=<project_name>
make build PROJECT=<project_name>
```

## Quick start (container)

```bash
make c-doctor
make c-doctor-project PROJECT=<project_name>
make c-build PROJECT=<project_name>
```

## Create project

```bash
make new PROJECT=<project_name>
```

This creates `project.mk` from the template automatically.

## Validate all projects

```bash
make doctor-all
```

```bash
make c-doctor-all
```

## Main commands

Local:

```bash
make list
make new PROJECT=<project_name>
make doctor
make doctor-project PROJECT=<project_name>
make doctor-all
make build PROJECT=<project_name>
make watch PROJECT=<project_name>
make clean PROJECT=<project_name>
make hub
```

Container:

```bash
make c-list
make c-new PROJECT=<project_name>
make c-doctor
make c-doctor-project PROJECT=<project_name>
make c-doctor-all
make c-build PROJECT=<project_name>
make c-watch PROJECT=<project_name>
make c-clean PROJECT=<project_name>
make c-hub
make c-shell
```

## VS Code

Included:

- `.vscode/extensions.json`
- `.vscode/settings.json`
- `.vscode/tasks.json`

## Troubleshooting

- Run `make doctor` first.
- Run `make doctor-project PROJECT=<project_name>` to validate project requirements.
- If local tools are missing, install them or use container commands (`make c-*`).
- If container commands fail, check Docker daemon and Compose availability.
