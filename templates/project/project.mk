# Optional per-project build requirements.
# This file is read automatically by the root Makefile.
#
# Command line values still override these values, for example:
# make build PROJECT=my_project LATEX_ENGINE=xelatex

# Main TeX entrypoint, relative to the project folder.
MAIN = main.tex

# Allowed values: pdflatex, xelatex, lualatex
LATEX_ENGINE = pdflatex

# Allowed values: auto, none, biber, bibtex
BIB_TOOL = auto

# Extra flags passed to latexmk for this project (optional).
EXTRA_LATEXMK_FLAGS =

# Extra required commands for this project (space-separated), optional.
# Example: REQUIRED_CMDS = makeglossaries pygmentize
REQUIRED_CMDS =
