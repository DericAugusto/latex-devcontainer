SHELL := /bin/bash

PROJECTS_DIR ?= projects
PROJECT ?=
PROJECT_DIR := $(PROJECTS_DIR)/$(PROJECT)
PROJECT_CONFIG := $(PROJECT_DIR)/project.mk

MAIN :=
LATEX_ENGINE :=
BIB_TOOL :=
EXTRA_LATEXMK_FLAGS :=
REQUIRED_CMDS :=

-include $(PROJECT_CONFIG)

ifeq ($(strip $(MAIN)),)
MAIN := main.tex
endif
ifeq ($(strip $(LATEX_ENGINE)),)
LATEX_ENGINE := pdflatex
endif
ifeq ($(strip $(BIB_TOOL)),)
BIB_TOOL := auto
endif
ifeq ($(strip $(EXTRA_LATEXMK_FLAGS)),)
EXTRA_LATEXMK_FLAGS :=
endif
ifeq ($(strip $(REQUIRED_CMDS)),)
REQUIRED_CMDS :=
endif

TEX_MAIN := $(PROJECT_DIR)/$(MAIN)
OUT_DIR := $(PROJECT_DIR)/out
OUT_DIR_ABS := $(abspath $(OUT_DIR))
LATEXMK_COMMON_FLAGS := -interaction=nonstopmode -synctex=1
CONTAINER_MAKE := ./scripts/container-make.sh

ifeq ($(LATEX_ENGINE),pdflatex)
LATEXMK_MODE_FLAG := -pdf
LATEX_ENGINE_CMD := pdflatex
else ifeq ($(LATEX_ENGINE),xelatex)
LATEXMK_MODE_FLAG := -xelatex
LATEX_ENGINE_CMD := xelatex
else ifeq ($(LATEX_ENGINE),lualatex)
LATEXMK_MODE_FLAG := -lualatex
LATEX_ENGINE_CMD := lualatex
else
$(error LATEX_ENGINE must be one of: pdflatex, xelatex, lualatex)
endif

.DEFAULT_GOAL := help

.PHONY: help list new build watch clean hub doctor doctor-project doctor-all c-help c-list c-new c-build c-watch c-clean c-doctor c-doctor-project c-doctor-all c-hub c-shell ensure-project ensure-main

help:
	@echo "LaTeX multi-project workspace"
	@echo
	@echo "Usage:"
	@echo "  make list"
	@echo "  make new PROJECT=<project_name>"
	@echo "  make doctor"
	@echo "  make doctor-project PROJECT=<project_name>"
	@echo "  make doctor-all"
	@echo "  make build PROJECT=<project_name> [MAIN=main.tex]"
	@echo "  make watch PROJECT=<project_name> [MAIN=main.tex]"
	@echo "  make clean PROJECT=<project_name> [MAIN=main.tex]"
	@echo "  make hub"
	@echo
	@echo "Project config (optional): $(PROJECTS_DIR)/<project_name>/project.mk"
	@echo "  MAIN, LATEX_ENGINE, BIB_TOOL, EXTRA_LATEXMK_FLAGS, REQUIRED_CMDS"
	@echo
	@echo "Container workflow (Docker):"
	@echo "  make c-help"
	@echo "  make c-list"
	@echo "  make c-new PROJECT=<project_name>"
	@echo "  make c-doctor"
	@echo "  make c-doctor-project PROJECT=<project_name>"
	@echo "  make c-doctor-all"
	@echo "  make c-build PROJECT=<project_name> [MAIN=main.tex]"
	@echo "  make c-watch PROJECT=<project_name> [MAIN=main.tex]"
	@echo "  make c-clean PROJECT=<project_name> [MAIN=main.tex]"
	@echo "  make c-hub"
	@echo "  make c-shell"

list:
	@mkdir -p "$(PROJECTS_DIR)"
	@projects="$$(find "$(PROJECTS_DIR)" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)"; \
	if [ -z "$$projects" ]; then \
		echo "No projects found in $(PROJECTS_DIR)."; \
		echo "Create one with: make new PROJECT=my_project"; \
	else \
		echo "$$projects" | sed 's/^/- /'; \
	fi

ensure-project:
	@if [ -z "$(PROJECT)" ]; then \
		echo "Missing PROJECT."; \
		echo "Example: make build PROJECT=MND_complet"; \
		exit 1; \
	fi

ensure-main: ensure-project
	@if [ ! -f "$(TEX_MAIN)" ]; then \
		echo "File not found: $(TEX_MAIN)"; \
		echo "Use MAIN=<path_from_project_dir> if needed."; \
		exit 1; \
	fi

new: ensure-project
	@if ! [[ "$(PROJECT)" =~ ^[A-Za-z0-9_-]+$$ ]]; then \
		echo "Invalid PROJECT name: $(PROJECT)"; \
		echo "Use only letters, numbers, '-' or '_'."; \
		exit 1; \
	fi
	@if [ -e "$(PROJECT_DIR)" ]; then \
		echo "Project already exists: $(PROJECT_DIR)"; \
		exit 1; \
	fi
	@mkdir -p "$(PROJECT_DIR)/sections" "$(PROJECT_DIR)/figures" "$(PROJECT_DIR)/tables" "$(PROJECT_DIR)/bib" "$(OUT_DIR)"
	@cp templates/project/main.tex "$(PROJECT_DIR)/main.tex"
	@cp templates/project/project.mk "$(PROJECT_DIR)/project.mk"
	@touch "$(PROJECT_DIR)/sections/.gitkeep" "$(PROJECT_DIR)/figures/.gitkeep" "$(PROJECT_DIR)/tables/.gitkeep"
	@printf "%% Add bibliography entries here.\n" > "$(PROJECT_DIR)/bib/references.bib"
	@echo "Created project: $(PROJECT_DIR)"
	@echo "Build with: make build PROJECT=$(PROJECT)"

build: ensure-main
	@mkdir -p "$(OUT_DIR)"
	latexmk $(LATEXMK_MODE_FLAG) $(LATEXMK_COMMON_FLAGS) $(EXTRA_LATEXMK_FLAGS) -cd -outdir="$(OUT_DIR_ABS)" "$(TEX_MAIN)"

watch: ensure-main
	@mkdir -p "$(OUT_DIR)"
	latexmk $(LATEXMK_MODE_FLAG) $(LATEXMK_COMMON_FLAGS) $(EXTRA_LATEXMK_FLAGS) -cd -pvc -outdir="$(OUT_DIR_ABS)" "$(TEX_MAIN)"

clean: ensure-project
	@if [ -f "$(TEX_MAIN)" ]; then \
		latexmk -C -cd -outdir="$(OUT_DIR_ABS)" "$(TEX_MAIN)"; \
	else \
		rm -rf "$(OUT_DIR)"; \
		echo "Removed $(OUT_DIR)"; \
	fi

doctor:
	@echo "Checking workspace LaTeX toolchain..."
	@missing=0; \
	for cmd in latexmk pdflatex; do \
		if command -v "$$cmd" >/dev/null 2>&1; then \
			echo "  [ok] $$cmd"; \
		else \
			echo "  [missing] $$cmd"; \
			missing=1; \
		fi; \
	done; \
	if command -v biber >/dev/null 2>&1; then \
		echo "  [ok] biber"; \
	else \
		echo "  [warn] biber (required for biblatex projects)"; \
	fi; \
	if command -v kpsewhich >/dev/null 2>&1; then \
		if kpsewhich biblatex.sty >/dev/null 2>&1; then \
			echo "  [ok] biblatex.sty"; \
		else \
			echo "  [warn] biblatex.sty (required for biblatex projects)"; \
		fi; \
	fi; \
	if [ "$$missing" -ne 0 ]; then \
		exit 1; \
	fi

doctor-project: ensure-main
	@echo "Checking project requirements: $(PROJECT)"
	@if [ -f "$(PROJECT_CONFIG)" ]; then \
		echo "  [info] config file: $(PROJECT_CONFIG)"; \
	else \
		echo "  [info] config file: <defaults>"; \
	fi
	@missing=0; \
	for cmd in latexmk "$(LATEX_ENGINE_CMD)"; do \
		if command -v "$$cmd" >/dev/null 2>&1; then \
			echo "  [ok] $$cmd"; \
		else \
			echo "  [missing] $$cmd"; \
			missing=1; \
		fi; \
	done; \
	case "$(BIB_TOOL)" in \
	none) \
		echo "  [info] bibliography backend: none"; \
		;; \
	biber) \
		if command -v biber >/dev/null 2>&1; then \
			echo "  [ok] biber"; \
		else \
			echo "  [missing] biber"; \
			missing=1; \
		fi; \
		;; \
	bibtex) \
		if command -v bibtex >/dev/null 2>&1; then \
			echo "  [ok] bibtex"; \
		else \
			echo "  [missing] bibtex"; \
			missing=1; \
		fi; \
		;; \
	auto) \
		if grep -R --include='*.tex' -E -q 'backend[[:space:]]*=[[:space:]]*biber|\\usepackage(\[[^]]*\])?\{biblatex\}' "$(PROJECT_DIR)"; then \
			if command -v biber >/dev/null 2>&1; then \
				echo "  [ok] biber (auto-detected)"; \
			else \
				echo "  [missing] biber (auto-detected requirement)"; \
				missing=1; \
			fi; \
		fi; \
		;; \
	*) \
		echo "  [warn] unknown BIB_TOOL='$(BIB_TOOL)' (expected: auto|none|biber|bibtex)"; \
		;; \
	esac; \
	for cmd in $(REQUIRED_CMDS); do \
		if command -v "$$cmd" >/dev/null 2>&1; then \
			echo "  [ok] $$cmd"; \
		else \
			echo "  [missing] $$cmd"; \
			missing=1; \
		fi; \
	done; \
	if [ "$$missing" -ne 0 ]; then \
		exit 1; \
	fi

doctor-all:
	@mkdir -p "$(PROJECTS_DIR)"
	@projects="$$(find "$(PROJECTS_DIR)" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)"; \
	if [ -z "$$projects" ]; then \
		echo "No projects found in $(PROJECTS_DIR)."; \
		exit 0; \
	fi; \
	failed=0; \
	while IFS= read -r project; do \
		[ -z "$$project" ] && continue; \
		echo; \
		echo "==> $$project"; \
		if [ ! -f "$(PROJECTS_DIR)/$$project/project.mk" ]; then \
			echo "  [warn] missing $(PROJECTS_DIR)/$$project/project.mk"; \
			echo "  [hint] copy templates/project/project.mk"; \
		fi; \
		if ! $(MAKE) --no-print-directory doctor-project PROJECT="$$project"; then \
			failed=1; \
		fi; \
	done <<< "$$projects"; \
	if [ "$$failed" -ne 0 ]; then \
		exit 1; \
	fi

hub:
	@bash scripts/overleaf-hub.sh

c-help:
	@$(CONTAINER_MAKE) help

c-list:
	@$(CONTAINER_MAKE) list

c-new:
	@$(CONTAINER_MAKE) new PROJECT="$(PROJECT)"

c-doctor:
	@$(CONTAINER_MAKE) doctor

c-doctor-project:
	@$(CONTAINER_MAKE) doctor-project PROJECT="$(PROJECT)" MAIN="$(MAIN)"

c-doctor-all:
	@$(CONTAINER_MAKE) doctor-all

c-build:
	@$(CONTAINER_MAKE) build PROJECT="$(PROJECT)" MAIN="$(MAIN)"

c-watch:
	@$(CONTAINER_MAKE) watch PROJECT="$(PROJECT)" MAIN="$(MAIN)"

c-clean:
	@$(CONTAINER_MAKE) clean PROJECT="$(PROJECT)" MAIN="$(MAIN)"

c-hub:
	@$(CONTAINER_MAKE) hub

c-shell:
	@./scripts/container-shell.sh
