SHELL := /bin/bash

.PHONY: install all claude codex gemini antigravity dry-run clean diff help

CLAUDE_SKILLS ?= $(HOME)/.claude/skills
CODEX_SKILLS ?= $(HOME)/.codex/skills
GEMINI_SKILLS ?= $(HOME)/.gemini/config/skills

install:
	./install.sh all --claude-dest "$(CLAUDE_SKILLS)" --codex-dest "$(CODEX_SKILLS)" --gemini-dest "$(GEMINI_SKILLS)"

all: install

claude:
	./install.sh claude --claude-dest "$(CLAUDE_SKILLS)"

codex:
	./install.sh codex --codex-dest "$(CODEX_SKILLS)"

gemini antigravity:
	./install.sh gemini --gemini-dest "$(GEMINI_SKILLS)"

dry-run:
	./install.sh --dry-run --claude-dest "$(CLAUDE_SKILLS)" --codex-dest "$(CODEX_SKILLS)" --gemini-dest "$(GEMINI_SKILLS)"

clean:
	./install.sh --clean --claude-dest "$(CLAUDE_SKILLS)" --codex-dest "$(CODEX_SKILLS)" --gemini-dest "$(GEMINI_SKILLS)"

diff:
	@echo "=== Differences with Claude install ($(CLAUDE_SKILLS)) ==="
	@diff -rq . "$(CLAUDE_SKILLS)" \
		--exclude='.git' \
		--exclude='.DS_Store' \
		--exclude='.codex-plugin' \
		--exclude='Makefile' \
		--exclude='README.md' \
		--exclude='.gitignore' \
		--exclude='install.sh' \
		--exclude='docs' \
		--exclude='templates' 2>/dev/null || true
	@echo ""
	@echo "=== Differences with Codex install ($(CODEX_SKILLS)) ==="
	@diff -rq . "$(CODEX_SKILLS)" \
		--exclude='.git' \
		--exclude='.DS_Store' \
		--exclude='.codex-plugin' \
		--exclude='Makefile' \
		--exclude='README.md' \
		--exclude='.gitignore' \
		--exclude='install.sh' \
		--exclude='docs' \
		--exclude='templates' 2>/dev/null || true
	@echo ""
	@echo "=== Differences with Gemini install ($(GEMINI_SKILLS)) ==="
	@diff -rq . "$(GEMINI_SKILLS)" \
		--exclude='.git' \
		--exclude='.DS_Store' \
		--exclude='.codex-plugin' \
		--exclude='Makefile' \
		--exclude='README.md' \
		--exclude='.gitignore' \
		--exclude='install.sh' \
		--exclude='docs' \
		--exclude='templates' 2>/dev/null || true

help:
	@echo "RPI Stack"
	@echo ""
	@echo "Targets:"
	@echo "  make install     - Install Claude + Codex + Gemini/Antigravity skills"
	@echo "  make claude      - Install Claude Code skills only"
	@echo "  make codex       - Install Codex skills only"
	@echo "  make gemini      - Install Antigravity / Gemini CLI skills only"
	@echo "  make dry-run     - Show install actions without writing"
	@echo "  make clean       - Remove installed RPI Stack skills"
	@echo "  make diff        - Compare repo skills with installed skills"
