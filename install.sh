#!/usr/bin/env bash

# RPI Stack installer for Claude Code and Codex.
# Usage:
#   ./install.sh                    Install both Claude and Codex distributions
#   ./install.sh claude             Install Claude distribution only
#   ./install.sh codex              Install Codex distribution only
#   ./install.sh --dry-run          Show actions without writing
#   ./install.sh --clean            Remove installed RPI Stack skills
#   ./install.sh --no-claude-tools  Skip Claude hooks/templates/aliases setup

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SRC="$SCRIPT_DIR/skills/claude"
CODEX_SRC="$SCRIPT_DIR/skills/codex"
CLAUDE_DEST="$HOME/.claude/skills"
CODEX_DEST="$HOME/.codex/skills"
DRY_RUN=0
CLEAN=0
INSTALL_CLAUDE=1
INSTALL_CODEX=1
WITH_CLAUDE_TOOLS=1

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SKILL_DIRS=(
  rpi
  research
  audit
  plan
  implement
  code-review
  audit-security
  audit-performance
)

usage() {
  cat <<USAGE
RPI Stack installer

Usage:
  ./install.sh                         Install Claude + Codex skills
  ./install.sh claude                  Install Claude skills/tools only
  ./install.sh codex                   Install Codex skills only
  ./install.sh all                     Install Claude + Codex skills
  ./install.sh --dry-run               Show what would be installed
  ./install.sh --clean                 Remove installed RPI Stack skills
  ./install.sh --claude-dest DIR       Override Claude skills directory
  ./install.sh --codex-dest DIR        Override Codex skills directory
  ./install.sh --no-claude-tools       Skip Claude hooks/templates/aliases setup
  ./install.sh --help                  Show this help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    all)
      INSTALL_CLAUDE=1
      INSTALL_CODEX=1
      shift
      ;;
    claude)
      INSTALL_CLAUDE=1
      INSTALL_CODEX=0
      shift
      ;;
    codex)
      INSTALL_CLAUDE=0
      INSTALL_CODEX=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --clean)
      CLEAN=1
      shift
      ;;
    --claude-dest)
      if [[ $# -lt 2 ]]; then
        echo -e "${RED}Missing value for --claude-dest${NC}" >&2
        exit 1
      fi
      CLAUDE_DEST="$2"
      shift 2
      ;;
    --codex-dest|--dest)
      if [[ $# -lt 2 ]]; then
        echo -e "${RED}Missing value for $1${NC}" >&2
        exit 1
      fi
      CODEX_DEST="$2"
      shift 2
      ;;
    --no-claude-tools)
      WITH_CLAUDE_TOOLS=0
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown argument: $1${NC}" >&2
      usage
      exit 1
      ;;
  esac
done

require_skill_sources() {
  local src="$1"
  local label="$2"
  local missing=0

  if [[ ! -f "$src/SKILL.md" ]]; then
    echo -e "${RED}Missing $label root SKILL.md at $src/SKILL.md${NC}" >&2
    missing=1
  fi

  for skill in "${SKILL_DIRS[@]}"; do
    if [[ ! -f "$src/$skill/SKILL.md" ]]; then
      echo -e "${RED}Missing $label skill: $src/$skill/SKILL.md${NC}" >&2
      missing=1
    fi
  done

  if [[ "$missing" -ne 0 ]]; then
    exit 1
  fi
}

sync_skills() {
  local src="$1"
  local dest="$2"
  local label="$3"

  require_skill_sources "$src" "$label"

  echo -e "${BLUE}Installing $label skills to:${NC} $dest"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Would create: $dest"
    echo "Would copy: $src/SKILL.md -> $dest/SKILL.md"
    for skill in "${SKILL_DIRS[@]}"; do
      echo "Would copy: $src/$skill/ -> $dest/$skill/"
    done
    if [[ -d "$src/scripts" ]]; then
      echo "Would copy: $src/scripts/ -> $dest/scripts/"
    fi
    return
  fi

  mkdir -p "$dest"
  cp -f "$src/SKILL.md" "$dest/SKILL.md"

  for skill in "${SKILL_DIRS[@]}"; do
    echo "  -> $skill"
    rm -rf "$dest/$skill"
    cp -R "$src/$skill" "$dest/"
  done

  if [[ -d "$src/scripts" ]]; then
    echo "  -> scripts"
    rm -rf "$dest/scripts"
    cp -R "$src/scripts" "$dest/"
    chmod +x "$dest/scripts"/*.sh 2>/dev/null || true
  fi

  echo -e "${GREEN}$label skills installed.${NC}"
}

sync_claude_hooks() {
  local claude_home="$HOME/.claude"

  if [[ "$WITH_CLAUDE_TOOLS" -ne 1 || "$INSTALL_CLAUDE" -ne 1 ]]; then
    return
  fi

  echo -e "${BLUE}Installing Claude-specific RPI tools to:${NC} $claude_home"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Would copy hooks from: $SCRIPT_DIR/hooks"
    echo "Would initialize sessions from: $SCRIPT_DIR/templates/sessions"
    echo "Would configure native hooks and shell aliases when possible"
    return
  fi

  mkdir -p "$claude_home"

  if [[ -d "$SCRIPT_DIR/hooks" ]]; then
    for hook_file in "$SCRIPT_DIR/hooks"/hookify.*.md; do
      [[ -f "$hook_file" ]] || continue
      echo "  -> $(basename "$hook_file")"
      cp -f "$hook_file" "$claude_home/"
    done
  fi

  if [[ -d "$SCRIPT_DIR/templates/sessions" && ! -d "$claude_home/sessions" ]]; then
    echo "  -> sessions template"
    mkdir -p "$claude_home/sessions"
    cp -f "$SCRIPT_DIR/templates/sessions/index.json" "$claude_home/sessions/index.json"
  fi

  setup_claude_native_hooks
  setup_claude_aliases
}

setup_claude_native_hooks() {
  local settings_file="$HOME/.claude/settings.json"
  local rpi_save_cmd="~/.claude/skills/scripts/rpi-session-save.sh"

  if ! command -v jq >/dev/null 2>&1; then
    echo -e "${YELLOW}  jq not found; skipping Claude native hook setup.${NC}"
    return
  fi

  [[ -f "$settings_file" ]] || echo '{}' > "$settings_file"

  if jq -e ".hooks.PreCompact[]?.hooks[]? | select(.command == \"$rpi_save_cmd\")" "$settings_file" >/dev/null 2>&1; then
    echo "  -> native hooks already configured"
    return
  fi

  local rpi_hook='{"hooks": [{"type": "command", "command": "~/.claude/skills/scripts/rpi-session-save.sh"}]}'
  local updated
  updated=$(jq --argjson rpi_hook "$rpi_hook" '
    .hooks.PreCompact = (.hooks.PreCompact // []) + [$rpi_hook] |
    .hooks.SessionEnd = (.hooks.SessionEnd // []) + [$rpi_hook]
  ' "$settings_file")

  echo "$updated" > "$settings_file"
  echo "  -> native hooks configured"
}

setup_claude_aliases() {
  local shell_rc=""
  local marker="# RPI Stack Aliases"
  local legacy_marker="# RPI Skills Aliases"

  if [[ -n "${ZSH_VERSION:-}" || "${SHELL:-}" == *"zsh"* ]]; then
    shell_rc="$HOME/.zshrc"
  elif [[ -n "${BASH_VERSION:-}" || "${SHELL:-}" == *"bash"* ]]; then
    shell_rc="$HOME/.bashrc"
  else
    echo -e "${YELLOW}  Unknown shell; skipping aliases.${NC}"
    return
  fi

  if grep -q -e "$marker" -e "$legacy_marker" "$shell_rc" 2>/dev/null; then
    echo "  -> aliases already configured in $shell_rc"
    return
  fi

  cat >> "$shell_rc" <<'ALIASES'

# RPI Stack Aliases
alias rpi-tracker='~/.claude/skills/scripts/rpi-tracker.sh'
alias rpi-tracker-list='~/.claude/skills/scripts/rpi-tracker.sh --list'
alias rpi-status='~/.claude/skills/scripts/rpi-status.sh'
ALIASES

  echo "  -> aliases added to $shell_rc"
}

clean_skills() {
  local dest="$1"
  local label="$2"

  echo -e "${YELLOW}Removing $label RPI Stack skills from:${NC} $dest"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Would remove: $dest/SKILL.md"
    for skill in "${SKILL_DIRS[@]}"; do
      echo "Would remove: $dest/$skill"
    done
    echo "Would remove: $dest/scripts when present"
    return
  fi

  rm -f "$dest/SKILL.md"
  for skill in "${SKILL_DIRS[@]}"; do
    rm -rf "$dest/$skill"
  done
  rm -rf "$dest/scripts"

  echo -e "${GREEN}$label RPI Stack skills removed.${NC}"
}

if [[ "$CLEAN" -eq 1 ]]; then
  [[ "$INSTALL_CLAUDE" -eq 1 ]] && clean_skills "$CLAUDE_DEST" "Claude"
  [[ "$INSTALL_CODEX" -eq 1 ]] && clean_skills "$CODEX_DEST" "Codex"
else
  [[ "$INSTALL_CLAUDE" -eq 1 ]] && sync_skills "$CLAUDE_SRC" "$CLAUDE_DEST" "Claude"
  [[ "$INSTALL_CLAUDE" -eq 1 ]] && sync_claude_hooks
  [[ "$INSTALL_CODEX" -eq 1 ]] && sync_skills "$CODEX_SRC" "$CODEX_DEST" "Codex"

  if [[ "$DRY_RUN" -eq 0 ]]; then
    echo -e "${GREEN}RPI Stack install complete.${NC}"
    echo "Restart Claude Code and/or Codex if already running so skills reload."
  fi
fi
