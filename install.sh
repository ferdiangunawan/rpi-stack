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

    # Copy each skill directory (directories with SKILL.md)
    for skill_dir in "$SCRIPT_DIR"/*/; do
        skill_name=$(basename "$skill_dir")
        # Skip hidden directories and non-skill directories
        if [[ "$skill_name" != .* ]] && [[ -f "$skill_dir/SKILL.md" ]]; then
            echo "  → $skill_name"
            rm -rf "$dest/$skill_name"
            cp -r "$skill_dir" "$dest/"
        fi
    done

    # Copy scripts directory (utility scripts for RPI workflow)
    if [[ -d "$SCRIPT_DIR/scripts" ]]; then
        echo "  → scripts (CLI utilities)"
        rm -rf "$dest/scripts"
        cp -r "$SCRIPT_DIR/scripts" "$dest/"
        chmod +x "$dest/scripts/"*.sh 2>/dev/null || true
    fi

    echo -e "${GREEN}✓ $name skills updated${NC}"
}

sync_hooks() {
    local dest="$HOME/.claude"

    echo -e "${BLUE}Syncing hooks to $dest...${NC}"
    mkdir -p "$dest"

    # Copy hookify files from skills/hooks/
    if [[ -d "$SCRIPT_DIR/hooks" ]]; then
        for hook_file in "$SCRIPT_DIR/hooks/"hookify.*.md; do
            if [[ -f "$hook_file" ]]; then
                hook_name=$(basename "$hook_file")
                echo "  → $hook_name"
                cp -f "$hook_file" "$dest/"
            fi
        done
        echo -e "${GREEN}✓ Hooks synced to ~/.claude/${NC}"
    else
        echo -e "${BLUE}No hooks directory found, skipping...${NC}"
    fi
}

sync_templates() {
    local dest="$HOME/.claude"

    echo -e "${BLUE}Syncing templates to $dest...${NC}"

    # Copy sessions template (only if sessions/ doesn't exist)
    if [[ -d "$SCRIPT_DIR/templates/sessions" ]]; then
        if [[ ! -d "$dest/sessions" ]]; then
            echo "  → sessions/ (initializing session tracker)"
            mkdir -p "$dest/sessions"
            cp -f "$SCRIPT_DIR/templates/sessions/index.json" "$dest/sessions/"
            echo -e "${GREEN}✓ Sessions initialized${NC}"
        else
            echo -e "${BLUE}  Sessions directory already exists, skipping...${NC}"
        fi
    fi
}

setup_native_hooks() {
    echo -e "${BLUE}Setting up native Claude Code hooks...${NC}"

    local settings_file="$HOME/.claude/settings.json"
    local rpi_save_cmd="~/.claude/skills/scripts/rpi-session-save.sh"

    # Ensure settings.json exists
    if [[ ! -f "$settings_file" ]]; then
        echo '{}' > "$settings_file"
    fi

    # Check if RPI hooks specifically are already configured
    if jq -e ".hooks.PreCompact[]?.hooks[]? | select(.command == \"$rpi_save_cmd\")" "$settings_file" >/dev/null 2>&1; then
        echo -e "${BLUE}  RPI native hooks already configured${NC}"
        return
    fi

    # RPI hook entry to add
    local rpi_hook='{"hooks": [{"type": "command", "command": "~/.claude/skills/scripts/rpi-session-save.sh"}]}'

    # Add RPI hooks to PreCompact and SessionEnd (preserving existing hooks)
    local updated=$(jq --argjson rpi_hook "$rpi_hook" '
      .hooks.PreCompact = (.hooks.PreCompact // []) + [$rpi_hook] |
      .hooks.SessionEnd = (.hooks.SessionEnd // []) + [$rpi_hook]
    ' "$settings_file")

    echo "$updated" > "$settings_file"

    echo -e "${GREEN}✓ Native hooks configured:${NC}"
    echo "    PreCompact  → Auto-save RPI session before context compaction"
    echo "    SessionEnd  → Auto-save RPI session when Claude Code exits"
}

setup_aliases() {
    echo -e "${BLUE}Setting up shell aliases...${NC}"

    # Determine shell config file
    local shell_rc=""
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == *"bash"* ]]; then
        shell_rc="$HOME/.bashrc"
    else
        echo -e "${BLUE}  Unknown shell, skipping alias setup...${NC}"
        return
    fi

    # Alias definitions
    local aliases=(
        "alias rpi-tracker='~/.claude/skills/scripts/rpi-tracker.sh'"
        "alias rpi-tracker-list='~/.claude/skills/scripts/rpi-tracker.sh --list'"
        "alias rpi-status='~/.claude/skills/scripts/rpi-status.sh'"
        "alias rpi-progress='~/.claude/skills/scripts/rpi-progress.sh'"
    )

    # Marker to identify our aliases block
    local marker="# RPI Skills Aliases"

    # Check if aliases already exist
    if grep -q "$marker" "$shell_rc" 2>/dev/null; then
        echo -e "${BLUE}  Aliases already configured in $shell_rc${NC}"
    else
        # Add aliases to shell config
        echo "" >> "$shell_rc"
        echo "$marker" >> "$shell_rc"
        for alias_def in "${aliases[@]}"; do
            echo "$alias_def" >> "$shell_rc"
        done
        echo -e "${GREEN}✓ Aliases added to $shell_rc${NC}"
        echo -e "${BLUE}  Run 'source $shell_rc' or restart terminal to use:${NC}"
        echo "    rpi-tracker       # Active session (detailed)"
        echo "    rpi-tracker-list  # All sessions"
        echo "    rpi-status        # Quick status"
        echo "    rpi-progress      # Update session progress"
    fi
}

case "${1:-all}" in
    claude)
        sync_skills "$CLAUDE_SKILLS" "Claude Code"
        echo ""
        sync_hooks
        echo ""
        sync_templates
        echo ""
        setup_native_hooks
        echo ""
        setup_aliases
        ;;
    codex)
        sync_skills "$CODEX_SKILLS" "Codex"
        ;;
    hooks)
        sync_hooks
        echo ""
        setup_native_hooks
        ;;
    templates)
        sync_templates
        ;;
    aliases)
        setup_aliases
        ;;
    all|"")
        sync_skills "$CLAUDE_SKILLS" "Claude Code"
        echo ""
        sync_skills "$CODEX_SKILLS" "Codex"
        echo ""
        sync_hooks
        echo ""
        sync_templates
        echo ""
        setup_native_hooks
        echo ""
        setup_aliases
        echo ""
        echo -e "${GREEN}✓ All skills, hooks, templates, aliases, and native hooks synced!${NC}"
        ;;
    *)
        echo "Usage: $0 [claude|codex|hooks|templates|aliases|all]"
        echo ""
        echo "  claude    - Sync to ~/.claude/skills (includes hooks, templates, aliases & native hooks)"
        echo "  codex     - Sync to ~/.codex/skills only"
        echo "  hooks     - Sync hooks to ~/.claude/ only (includes native hooks)"
        echo "  templates - Sync templates (sessions) to ~/.claude/ only"
        echo "  aliases   - Setup shell aliases (rpi-tracker, rpi-tracker-list, rpi-status)"
        echo "  all       - Sync everything (default)"
        exit 1
        ;;
esac
