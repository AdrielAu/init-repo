# AGENTS.md

Instructions for every coding agent in this repo (Claude Code, Codex, Antigravity, and others).

## Before you start

- **Any code change** (writing, editing, refactoring or reviewing code): read `docs/agents/coding-standards.md` first and follow it.
- **Any frontend, UI or visual design work**: read `docs/agents/frontend-workflow.md` first and follow its steps in order.
- **Any video, motion graphic, captions or overlay**: load the `hyperframes` skill and read it before doing anything else.

## Design truth

- `DESIGN.md` (visual system) and `PRODUCT.md` (audience, purpose, voice) at the repo root are the only design sources of truth.
- Never create another theme, palette, token or design-spec file (`design-system/`, `MASTER.md`, `theme.md`, `brand.md` and the like). If a skill wants to write one, put that content into `DESIGN.md` instead.
- In code, design tokens live in exactly one file, which `DESIGN.md` names.

## Skills

- Skills live once, in `.agents/skills/`, and are committed. `.claude/skills` is a local link to that folder. If it is missing, run `scripts/link-skills.ps1` (Windows) or `scripts/link-skills.sh`.
- Install new skills with `npx skills add <source> -a codex -y` so they land in `.agents/skills/` only.
- Update every skill with `scripts/update-skills.ps1` or `scripts/update-skills.sh`.
- Only use the `unslop` skill when the user explicitly asks for it.

## Project

Not set up yet. Add the stack and the build, test and run commands here once they exist.
