#!/usr/bin/env bash

# RPI Stack installer for Claude Code, Codex, and Antigravity / Gemini CLI.
# Installs the modernized 6-skill RPI stack and domain profiles into
# each agent's skills directory.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SKILLS="$HOME/.claude/skills"
CODEX_SKILLS="$HOME/.codex/skills"
GEMINI_SKILLS="$HOME/.gemini/config/skills"
PROJECT_SKILLS=""

DRY_RUN=0
CLEAN=0
SPECIFIC_TARGET=0
INSTALL_CLAUDE=0
INSTALL_CODEX=0
INSTALL_GEMINI=0
INSTALL_PROJECT=0

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
  ./install.sh                    Auto-detect installed agents and install
  ./install.sh all                Install Claude, Codex, and Gemini skills
  ./install.sh claude             Install Claude Code skills only
  ./install.sh codex              Install Codex skills only
  ./install.sh gemini             Install Antigravity / Gemini CLI skills only
  ./install.sh --project [DIR]    Install skills into a local project directory (default: .agents/skills)
  ./install.sh --dry-run          Show actions without writing
  ./install.sh --clean            Remove installed RPI Stack skills
  ./install.sh --claude-dest DIR  Override Claude skills directory
  ./install.sh --codex-dest DIR   Override Codex skills directory
  ./install.sh --gemini-dest DIR  Override Gemini skills directory
  ./install.sh --help             Show this help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    all)
      INSTALL_CLAUDE=1
      INSTALL_CODEX=1
      INSTALL_GEMINI=1
      SPECIFIC_TARGET=1
      shift
      ;;
    claude)
      INSTALL_CLAUDE=1
      SPECIFIC_TARGET=1
      shift
      ;;
    codex)
      INSTALL_CODEX=1
      SPECIFIC_TARGET=1
      shift
      ;;
    gemini|antigravity)
      INSTALL_GEMINI=1
      SPECIFIC_TARGET=1
      shift
      ;;
    --project)
      INSTALL_PROJECT=1
      SPECIFIC_TARGET=1
      if [[ $# -ge 2 && "$2" != --* ]]; then
        PROJECT_SKILLS="$2"
        shift 2
      else
        PROJECT_SKILLS="$(pwd)/.agents/skills"
        shift
      fi
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
    --gemini-dest)
      if [[ $# -lt 2 ]]; then
        echo -e "${RED}Missing value for --gemini-dest${NC}" >&2
        exit 1
      fi
      GEMINI_SKILLS="$2"
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

# Auto-detect agents if no specific target requested
if [[ "$SPECIFIC_TARGET" -eq 0 && "$CLEAN" -eq 0 ]]; then
  [[ -d "$HOME/.claude" ]] && INSTALL_CLAUDE=1
  [[ -d "$HOME/.codex" ]] && INSTALL_CODEX=1
  [[ -d "$HOME/.gemini" ]] && INSTALL_GEMINI=1

  # If none detected, enable all
  if [[ "$INSTALL_CLAUDE" -eq 0 && "$INSTALL_CODEX" -eq 0 && "$INSTALL_GEMINI" -eq 0 ]]; then
    INSTALL_CLAUDE=1
    INSTALL_CODEX=1
    INSTALL_GEMINI=1
  fi
fi

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

  if [[ ! -d "$SCRIPT_DIR/profiles" ]]; then
    echo -e "${RED}Missing profiles directory${NC}" >&2
    missing=1
  fi

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
    echo "Would copy: profiles/"
    return
  fi

  mkdir -p "$dest"
  cp -f "$SCRIPT_DIR/SKILL.md" "$dest/SKILL.md"

  for skill in "${SKILL_DIRS[@]}"; do
    echo "  -> $skill"
    rm -rf "$dest/$skill"
    cp -R "$SCRIPT_DIR/$skill" "$dest/"
  done

  if [[ -d "$SCRIPT_DIR/profiles" ]]; then
    echo "  -> profiles"
    rm -rf "$dest/profiles"
    cp -R "$SCRIPT_DIR/profiles" "$dest/"
  fi

  echo -e "${GREEN}$label skills installed.${NC}"
}

clean_skills() {
  local dest="$1"
  local label="$2"

  echo -e "${YELLOW}Removing $label RPI Stack skills from:${NC} $dest"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Would remove: SKILL.md"
    for skill in "${SKILL_DIRS[@]}" profiles; do
      echo "Would remove: $skill/"
    done
    return
  fi

  rm -f "$dest/SKILL.md"
  for skill in "${SKILL_DIRS[@]}" profiles; do
    rm -rf "$dest/$skill"
  done

  echo -e "${GREEN}$label RPI Stack skills removed.${NC}"
}

if [[ "$CLEAN" -eq 1 ]]; then
  if [[ "$SPECIFIC_TARGET" -eq 0 ]]; then
    INSTALL_CLAUDE=1
    INSTALL_CODEX=1
    INSTALL_GEMINI=1
  fi
  if [[ "$INSTALL_CLAUDE" -eq 1 ]]; then
    clean_skills "$CLAUDE_SKILLS" "Claude Code"
  fi
  if [[ "$INSTALL_CODEX" -eq 1 ]]; then
    clean_skills "$CODEX_SKILLS" "Codex"
  fi
  if [[ "$INSTALL_GEMINI" -eq 1 ]]; then
    clean_skills "$GEMINI_SKILLS" "Antigravity/Gemini"
  fi
  if [[ "$INSTALL_PROJECT" -eq 1 ]]; then
    clean_skills "$PROJECT_SKILLS" "Project-Local"
  fi
  exit 0
fi

if [[ "$INSTALL_CLAUDE" -eq 1 ]]; then
  sync_skills "$CLAUDE_SKILLS" "Claude Code"
fi

if [[ "$INSTALL_CODEX" -eq 1 ]]; then
  sync_skills "$CODEX_SKILLS" "Codex"
fi

if [[ "$INSTALL_GEMINI" -eq 1 ]]; then
  sync_skills "$GEMINI_SKILLS" "Antigravity/Gemini"
fi

if [[ "$INSTALL_PROJECT" -eq 1 ]]; then
  sync_skills "$PROJECT_SKILLS" "Project-Local"
fi

if [[ "$DRY_RUN" -eq 0 ]]; then
  echo -e "${GREEN}RPI Stack install complete.${NC}"
  echo "Restart active agent sessions if running so skills reload."
fi
