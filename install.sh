#!/usr/bin/env bash

# RPI Stack installer for Claude Code and Codex.
# Installs the simplified 6-skill RPI stack from this repository into
# each agent's computer-level skills directory.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SKILLS="$HOME/.claude/skills"
CODEX_SKILLS="$HOME/.codex/skills"
DRY_RUN=0
CLEAN=0
INSTALL_CLAUDE=1
INSTALL_CODEX=1

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SKILL_DIRS=(rpi research audit plan implement code-review)

usage() {
  cat <<USAGE
RPI Stack installer

Usage:
  ./install.sh                    Install Claude + Codex skills
  ./install.sh claude             Install Claude Code skills/hooks only
  ./install.sh codex              Install Codex skills only
  ./install.sh --dry-run          Show actions without writing
  ./install.sh --clean            Remove installed RPI Stack skills
  ./install.sh --claude-dest DIR  Override Claude skills directory
  ./install.sh --codex-dest DIR   Override Codex skills directory
  ./install.sh --help             Show this help
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
      CLAUDE_SKILLS="$2"
      shift 2
      ;;
    --codex-dest|--dest)
      if [[ $# -lt 2 ]]; then
        echo -e "${RED}Missing value for $1${NC}" >&2
        exit 1
      fi
      CODEX_SKILLS="$2"
      shift 2
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

require_sources() {
  local missing=0

  if [[ ! -f "$SCRIPT_DIR/SKILL.md" ]]; then
    echo -e "${RED}Missing root SKILL.md${NC}" >&2
    missing=1
  fi

  for skill in "${SKILL_DIRS[@]}"; do
    if [[ ! -f "$SCRIPT_DIR/$skill/SKILL.md" ]]; then
      echo -e "${RED}Missing $skill/SKILL.md${NC}" >&2
      missing=1
    fi
  done

  if [[ "$missing" -ne 0 ]]; then
    exit 1
  fi
}

sync_skills() {
  local dest="$1"
  local label="$2"

  require_sources

  echo -e "${BLUE}Installing $label skills to:${NC} $dest"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Would create: $dest"
    echo "Would copy: SKILL.md"
    for skill in "${SKILL_DIRS[@]}"; do
      echo "Would copy: $skill/"
    done
    return
  fi

  mkdir -p "$dest"
  cp -f "$SCRIPT_DIR/SKILL.md" "$dest/SKILL.md"

  for skill in "${SKILL_DIRS[@]}"; do
    echo "  -> $skill"
    rm -rf "$dest/$skill"
    cp -R "$SCRIPT_DIR/$skill" "$dest/"
  done

  # Remove obsolete RPI Stack extras from older installs. These were removed by
  # the simplified PR #2 flow and should not be resurrected by this installer.
  rm -rf "$dest/audit-security" "$dest/audit-performance" "$dest/scripts"

  echo -e "${GREEN}$label skills installed.${NC}"
}

sync_claude_hooks() {
  local claude_home="$HOME/.claude"

  echo -e "${BLUE}Installing Claude Code hooks to:${NC} $claude_home"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Would copy hookify files from hooks/"
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
}

clean_skills() {
  local dest="$1"
  local label="$2"

  echo -e "${YELLOW}Removing $label RPI Stack skills from:${NC} $dest"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Would remove: SKILL.md"
    for skill in "${SKILL_DIRS[@]}" audit-security audit-performance scripts; do
      echo "Would remove: $skill/"
    done
    return
  fi

  rm -f "$dest/SKILL.md"
  for skill in "${SKILL_DIRS[@]}" audit-security audit-performance scripts; do
    rm -rf "$dest/$skill"
  done

  echo -e "${GREEN}$label RPI Stack skills removed.${NC}"
}

if [[ "$CLEAN" -eq 1 ]]; then
  [[ "$INSTALL_CLAUDE" -eq 1 ]] && clean_skills "$CLAUDE_SKILLS" "Claude Code"
  [[ "$INSTALL_CODEX" -eq 1 ]] && clean_skills "$CODEX_SKILLS" "Codex"
  exit 0
fi

if [[ "$INSTALL_CLAUDE" -eq 1 ]]; then
  sync_skills "$CLAUDE_SKILLS" "Claude Code"
  sync_claude_hooks
fi

if [[ "$INSTALL_CODEX" -eq 1 ]]; then
  sync_skills "$CODEX_SKILLS" "Codex"
fi

if [[ "$DRY_RUN" -eq 0 ]]; then
  echo -e "${GREEN}RPI Stack install complete.${NC}"
  echo "Restart Claude Code and/or Codex if already running so skills reload."
fi
