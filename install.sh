#!/bin/bash

# Skills Repository - Auto-sync to Claude Code and Codex
# Usage:
#   ./install.sh           - Copy to both ~/.claude/skills and ~/.codex/skills
#   ./install.sh claude    - Copy to ~/.claude/skills only
#   ./install.sh codex     - Copy to ~/.codex/skills only

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SKILLS="$HOME/.claude/skills"
CODEX_SKILLS="$HOME/.codex/skills"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

sync_skills() {
    local dest="$1"
    local name="$2"

    echo -e "${BLUE}Syncing to $dest...${NC}"
    mkdir -p "$dest"

    # Copy root SKILL.md if exists
    if [[ -f "$SCRIPT_DIR/SKILL.md" ]]; then
        cp -f "$SCRIPT_DIR/SKILL.md" "$dest/"
    fi

    # Copy each skill directory
    for skill_dir in "$SCRIPT_DIR"/*/; do
        skill_name=$(basename "$skill_dir")
        # Skip hidden directories and non-skill directories
        if [[ "$skill_name" != .* ]] && [[ -f "$skill_dir/SKILL.md" ]]; then
            echo "  → $skill_name"
            rm -rf "$dest/$skill_name"
            cp -r "$skill_dir" "$dest/"
        fi
    done

    echo -e "${GREEN}✓ $name skills updated${NC}"
}

case "${1:-all}" in
    claude)
        sync_skills "$CLAUDE_SKILLS" "Claude Code"
        ;;
    codex)
        sync_skills "$CODEX_SKILLS" "Codex"
        ;;
    all|"")
        sync_skills "$CLAUDE_SKILLS" "Claude Code"
        echo ""
        sync_skills "$CODEX_SKILLS" "Codex"
        echo ""
        echo -e "${GREEN}✓ All skills synced!${NC}"
        ;;
    *)
        echo "Usage: $0 [claude|codex|all]"
        echo ""
        echo "  claude  - Sync to ~/.claude/skills only"
        echo "  codex   - Sync to ~/.codex/skills only"
        echo "  all     - Sync to both (default)"
        exit 1
        ;;
esac
