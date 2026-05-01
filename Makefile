SHELL := /bin/bash

.PHONY: install claude codex dry-run clean diff help

CLAUDE_SKILLS ?= $(HOME)/.claude/skills
CODEX_SKILLS ?= $(HOME)/.codex/skills

install:
	./install.sh --claude-dest "$(CLAUDE_SKILLS)" --codex-dest "$(CODEX_SKILLS)"

claude:
	./install.sh claude --claude-dest "$(CLAUDE_SKILLS)"

codex:
	./install.sh codex --codex-dest "$(CODEX_SKILLS)"

dry-run:
	./install.sh --dry-run --claude-dest "$(CLAUDE_SKILLS)" --codex-dest "$(CODEX_SKILLS)"

clean:
	./install.sh --clean --claude-dest "$(CLAUDE_SKILLS)" --codex-dest "$(CODEX_SKILLS)"

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
		--exclude='hooks' \
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
		--exclude='hooks' \
		--exclude='templates' 2>/dev/null || true

help:
	@echo "RPI Stack"
	@echo ""
	@echo "Targets:"
	@echo "  make install  - Install Claude + Codex skills"
	@echo "  make claude   - Install Claude Code skills/hooks only"
	@echo "  make codex    - Install Codex skills only"
	@echo "  make dry-run  - Show install actions"
	@echo "  make clean    - Remove installed RPI Stack skills"
	@echo "  make diff     - Compare repo skills with installed skills"
