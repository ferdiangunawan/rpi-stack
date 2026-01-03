# Skills Repository - Auto-sync to Claude Code and Codex
# Usage:
#   make install    - Copy skills to both ~/.claude/skills and ~/.codex/skills
#   make claude     - Copy skills to ~/.claude/skills only
#   make codex      - Copy skills to ~/.codex/skills only
#   make clean      - Remove skills from both destinations (keeps system folders)
#   make diff       - Show differences between repo and installed skills

SHELL := /bin/bash

# Directories
SKILLS_DIR := $(shell pwd)
CLAUDE_SKILLS := $(HOME)/.claude/skills
CODEX_SKILLS := $(HOME)/.codex/skills

# Skills to sync (excludes hidden files and Makefile)
SKILLS := $(wildcard */SKILL.md)
SKILL_DIRS := $(dir $(SKILLS))
ROOT_SKILL := SKILL.md

.PHONY: all install claude codex clean diff help tracker tracker-list status

# Default target
all: install

help:
	@echo "Skills Repository - Commands"
	@echo ""
	@echo "Sync Commands:"
	@echo "  make install      - Copy skills to both ~/.claude/skills and ~/.codex/skills"
	@echo "  make claude       - Copy skills to ~/.claude/skills only"
	@echo "  make codex        - Copy skills to ~/.codex/skills only"
	@echo "  make clean        - Remove skills from destinations (preserves system folders)"
	@echo "  make diff         - Show differences between repo and installed skills"
	@echo ""
	@echo "RPI Session Tracker:"
	@echo "  make tracker      - Show active session (detailed view)"
	@echo "  make tracker-list - List all sessions with progress"
	@echo "  make status       - Quick one-liner status"
	@echo ""
	@echo "Current skills:"
	@for dir in $(SKILL_DIRS); do echo "  - $${dir%/}"; done

# Install to both destinations
install: claude codex
	@echo "✓ Skills synced to both ~/.claude/skills and ~/.codex/skills"

# Install to Claude Code
claude:
	@echo "Syncing to $(CLAUDE_SKILLS)..."
	@mkdir -p $(CLAUDE_SKILLS)
	@# Copy root SKILL.md
	@cp -f $(ROOT_SKILL) $(CLAUDE_SKILLS)/ 2>/dev/null || true
	@# Copy each skill directory
	@for skill in $(SKILL_DIRS); do \
		skill_name=$${skill%/}; \
		echo "  → $$skill_name"; \
		rm -rf $(CLAUDE_SKILLS)/$$skill_name; \
		cp -r $$skill_name $(CLAUDE_SKILLS)/; \
	done
	@echo "✓ Claude Code skills updated"

# Install to Codex
codex:
	@echo "Syncing to $(CODEX_SKILLS)..."
	@mkdir -p $(CODEX_SKILLS)
	@# Copy root SKILL.md
	@cp -f $(ROOT_SKILL) $(CODEX_SKILLS)/ 2>/dev/null || true
	@# Copy each skill directory
	@for skill in $(SKILL_DIRS); do \
		skill_name=$${skill%/}; \
		echo "  → $$skill_name"; \
		rm -rf $(CODEX_SKILLS)/$$skill_name; \
		cp -r $$skill_name $(CODEX_SKILLS)/; \
	done
	@echo "✓ Codex skills updated"

# Show diff between repo and installed
diff:
	@echo "=== Differences with ~/.claude/skills ==="
	@diff -rq . $(CLAUDE_SKILLS) --exclude='.git' --exclude='.DS_Store' --exclude='Makefile' --exclude='README.md' --exclude='.gitignore' --exclude='.claude' --exclude='.system' --exclude='install.sh' 2>/dev/null || true
	@echo ""
	@echo "=== Differences with ~/.codex/skills ==="
	@diff -rq . $(CODEX_SKILLS) --exclude='.git' --exclude='.DS_Store' --exclude='Makefile' --exclude='README.md' --exclude='.gitignore' --exclude='.claude' --exclude='.system' --exclude='install.sh' 2>/dev/null || true

# Clean installed skills (preserves system folders)
clean:
	@echo "Removing synced skills..."
	@for skill in $(SKILL_DIRS); do \
		skill_name=$${skill%/}; \
		rm -rf $(CLAUDE_SKILLS)/$$skill_name 2>/dev/null || true; \
		rm -rf $(CODEX_SKILLS)/$$skill_name 2>/dev/null || true; \
	done
	@rm -f $(CLAUDE_SKILLS)/$(ROOT_SKILL) 2>/dev/null || true
	@rm -f $(CODEX_SKILLS)/$(ROOT_SKILL) 2>/dev/null || true
	@echo "✓ Skills removed (system folders preserved)"

# RPI Session Tracker shortcuts
tracker:
	@./scripts/rpi-tracker.sh

tracker-list:
	@./scripts/rpi-tracker.sh --list

status:
	@./scripts/rpi-status.sh
