#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Shared Agent Skills Installer
# ============================================================
#
# Run this script from the target project's root directory.
#
# Usage:
#   ../agent-skills/install.sh --all
#   ../agent-skills/install.sh --skills shadcn-vue,testing
#   ../agent-skills/install.sh --list
#
# Result:
#
#   project/
#   ├── .agents/
#   │   └── skills/
#   │       ├── shadcn-vue
#   │       │   -> /path/to/agent-skills/shadcn-vue
#   │       └── project-specific-skill/
#   │
#   └── .claude/
#       └── skills/
#           ├── shadcn-vue
#           │   -> ../../.agents/skills/shadcn-vue
#           └── claude-project-specific-skill/
#
# Shared skill flow:
#
#   agent-skills/<skill>
#           ↑
#   .agents/skills/<skill>
#           ↑
#   .claude/skills/<skill>
#
# Existing project-specific skills are preserved.
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(pwd)"

AGENTS_SKILLS_DIR="${PROJECT_DIR}/.agents/skills"
CLAUDE_SKILLS_DIR="${PROJECT_DIR}/.claude/skills"

usage() {
  cat <<'EOF'
Usage:
  install.sh --all
  install.sh --skills shadcn-vue,testing
  install.sh --list

Options:
  --all
      Link all available shared skills.

  --skills LIST
      Link selected shared skills.
      Use a comma-separated list.

      Example:
        --skills shadcn-vue,testing

  --list
      Show available shared skills.

  -h, --help
      Show this help.
EOF
}

# ------------------------------------------------------------
# List available shared skills
#
# A valid skill must be a top-level directory in the shared
# repository and contain SKILL.md.
# ------------------------------------------------------------
list_skills() {
  local dir

  for dir in "${SCRIPT_DIR}"/*; do
    [[ -d "$dir" ]] || continue
    [[ -f "$dir/SKILL.md" ]] || continue

    basename "$dir"
  done | sort
}

# ------------------------------------------------------------
# Ensure .agents/skills and .claude/skills are real directories.
#
# We intentionally do NOT allow either directory itself to be
# a symlink, because both locations may contain project-specific
# skills.
# ------------------------------------------------------------
prepare_directories() {
  local dir

  for dir in "$AGENTS_SKILLS_DIR" "$CLAUDE_SKILLS_DIR"; do
    if [[ -L "$dir" ]]; then
      echo "Error: ${dir#$PROJECT_DIR/} is currently a symlink." >&2
      echo "It must be a real directory so project-specific skills can coexist." >&2
      exit 1
    fi

    if [[ -e "$dir" && ! -d "$dir" ]]; then
      echo "Error: ${dir#$PROJECT_DIR/} exists but is not a directory." >&2
      exit 1
    fi

    mkdir -p "$dir"
  done
}

# ------------------------------------------------------------
# Link one skill into .agents/skills
#
# .agents/skills/<skill>
#   -> /absolute/path/to/agent-skills/<skill>
# ------------------------------------------------------------
link_agents_skill() {
  local skill="$1"
  local source="${SCRIPT_DIR}/${skill}"
  local target="${AGENTS_SKILLS_DIR}/${skill}"

  if [[ -L "$target" ]]; then
    local current_target
    current_target="$(readlink "$target")"

    if [[ "$current_target" == "$source" ]]; then
      echo "Already linked: .agents/skills/$skill"
      return 0
    fi

    echo "Conflict: .agents/skills/$skill is already a symlink to:"
    echo "  $current_target"
    echo "Expected:"
    echo "  $source"
    echo
    echo "Skipping this skill."
    return 1
  fi

  if [[ -e "$target" ]]; then
    echo "Preserved: .agents/skills/$skill"
    echo "  Existing project-specific skill was not overwritten."
    return 1
  fi

  ln -s "$source" "$target"

  echo "Linked: .agents/skills/$skill -> $source"
}

# ------------------------------------------------------------
# Link one skill into .claude/skills
#
# .claude/skills/<skill>
#   -> ../../.agents/skills/<skill>
# ------------------------------------------------------------
link_claude_skill() {
  local skill="$1"

  local source="../../.agents/skills/${skill}"
  local target="${CLAUDE_SKILLS_DIR}/${skill}"

  if [[ -L "$target" ]]; then
    local current_target
    current_target="$(readlink "$target")"

    if [[ "$current_target" == "$source" ]]; then
      echo "Already linked: .claude/skills/$skill"
      return 0
    fi

    echo "Conflict: .claude/skills/$skill is already a symlink to:"
    echo "  $current_target"
    echo "Expected:"
    echo "  $source"
    echo
    echo "Preserving existing Claude configuration."
    return 1
  fi

  if [[ -e "$target" ]]; then
    echo "Preserved: .claude/skills/$skill"
    echo "  Existing Claude-specific project skill was not overwritten."
    return 1
  fi

  ln -s "$source" "$target"

  echo "Linked: .claude/skills/$skill -> $source"
}

# ------------------------------------------------------------
# Install one shared skill.
# ------------------------------------------------------------
install_skill() {
  local skill="$1"
  local source="${SCRIPT_DIR}/${skill}"

  if [[ ! -d "$source" || ! -f "$source/SKILL.md" ]]; then
    echo "Skill not found: $skill" >&2
    return 1
  fi

  # Install into .agents first.
  #
  # If .agents already contains a project-specific skill with
  # the same name, do not create a Claude link pointing to it
  # while pretending it is the shared skill.
  if ! link_agents_skill "$skill"; then
    echo "Skipped Claude link for: $skill"
    return 0
  fi

  link_claude_skill "$skill" || true
}

# ------------------------------------------------------------
# Parse arguments
# ------------------------------------------------------------
mode=""
selected=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      mode="all"
      shift
      ;;

    --skills)
      if [[ $# -lt 2 ]]; then
        echo "Error: --skills requires a comma-separated list." >&2
        exit 1
      fi

      mode="selected"
      selected="$2"
      shift 2
      ;;

    --list)
      list_skills
      exit 0
      ;;

    -h|--help)
      usage
      exit 0
      ;;

    *)
      echo "Unknown option: $1" >&2
      echo
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$mode" ]]; then
  usage
  exit 1
fi

# ------------------------------------------------------------
# Prepare target project.
# ------------------------------------------------------------
prepare_directories

echo "Shared skills repository:"
echo "  $SCRIPT_DIR"
echo
echo "Target project:"
echo "  $PROJECT_DIR"
echo

# ------------------------------------------------------------
# Install skills.
# ------------------------------------------------------------
case "$mode" in
  all)
    found=false

    while IFS= read -r skill; do
      [[ -n "$skill" ]] || continue

      found=true
      install_skill "$skill"
      echo
    done < <(list_skills)

    if [[ "$found" == false ]]; then
      echo "No shared skills found."
      exit 0
    fi
    ;;

  selected)
    IFS=',' read -ra skills <<< "$selected"

    for skill in "${skills[@]}"; do
      # Trim leading whitespace.
      skill="${skill#"${skill%%[![:space:]]*}"}"

      # Trim trailing whitespace.
      skill="${skill%"${skill##*[![:space:]]}"}"

      [[ -n "$skill" ]] || continue

      install_skill "$skill"
      echo
    done
    ;;
esac

echo "Done."