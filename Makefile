SHELL := /bin/bash

.PHONY: install claude codex dry-run clean help diff

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
	@diff -rq skills/claude "$(CLAUDE_SKILLS)" 2>/dev/null || true
	@echo ""
	@echo "=== Differences with Codex install ($(CODEX_SKILLS)) ==="
	@diff -rq skills/codex "$(CODEX_SKILLS)" 2>/dev/null || true

help:
	@echo "RPI Stack"
	@echo ""
	@echo "Targets:"
	@echo "  make install  - Install Claude + Codex distributions"
	@echo "  make claude   - Install Claude distribution only"
	@echo "  make codex    - Install Codex distribution only"
	@echo "  make dry-run  - Show install actions"
	@echo "  make clean    - Remove installed RPI Stack skills"
	@echo "  make diff     - Compare repo distributions with installed skills"
