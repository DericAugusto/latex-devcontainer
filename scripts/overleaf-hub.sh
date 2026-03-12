#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECTS_DIR="${PROJECTS_DIR:-$ROOT_DIR/projects}"

mkdir -p "$PROJECTS_DIR"

list_projects() {
  find "$PROJECTS_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
}

run_action_menu() {
  local project="$1"

  while true; do
    echo
    echo "Project: $project"
    echo "  1) Build PDF"
    echo "  2) Watch (auto-compile)"
    echo "  3) Clean outputs"
    echo "  4) Back"
    echo "  q) Quit"
    read -r -p "Choose an action: " action

    case "$action" in
      1)
        make -C "$ROOT_DIR" build PROJECT="$project"
        ;;
      2)
        make -C "$ROOT_DIR" watch PROJECT="$project"
        ;;
      3)
        make -C "$ROOT_DIR" clean PROJECT="$project"
        ;;
      4)
        return 0
        ;;
      q|Q)
        exit 0
        ;;
      *)
        echo "Invalid action."
        ;;
    esac
  done
}

while true; do
  mapfile -t projects < <(list_projects)

  echo
  echo "Local LaTeX Hub"
  echo "==============="

  if [ "${#projects[@]}" -eq 0 ]; then
    echo "No projects yet."
  else
    for i in "${!projects[@]}"; do
      printf "  %2d) %s\n" "$((i + 1))" "${projects[$i]}"
    done
  fi

  echo "   n) New project"
  echo "   q) Quit"
  read -r -p "Select a project or command: " choice

  case "$choice" in
    q|Q)
      exit 0
      ;;
    n|N)
      read -r -p "New project name (letters, numbers, -, _): " new_project
      if [[ -z "$new_project" ]]; then
        echo "Project name cannot be empty."
        continue
      fi
      if ! [[ "$new_project" =~ ^[A-Za-z0-9_-]+$ ]]; then
        echo "Invalid project name. Use only letters, numbers, '-' or '_'."
        continue
      fi
      make -C "$ROOT_DIR" new PROJECT="$new_project"
      ;;
    *)
      if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo "Invalid selection."
        continue
      fi

      if (( choice < 1 || choice > ${#projects[@]} )); then
        echo "Selection out of range."
        continue
      fi

      run_action_menu "${projects[$((choice - 1))]}"
      ;;
  esac
done
