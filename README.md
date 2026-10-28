# init-repo

A skill that sets up a freshly cloned, empty repo for Claude Code, Codex and Antigravity at the same time. Each agent gets the same instructions and the same skills.

## Install (once per machine)

```
npx skills add adrielau/init-repo -g -a codex -a claude-code -a antigravity
```

Then, inside an empty clone, run `/init-repo` in any of the three agents.

Update it later with `npx skills update -g`.

## What it does to a repo

- **`AGENTS.md`**: a short router. Coding work goes to `docs/agents/coding-standards.md`, frontend work to `docs/agents/frontend-workflow.md`, and video to the `hyperframes` skill. `DESIGN.md` and `PRODUCT.md` are the only design sources of truth. There is no `CLAUDE.md`: Claude Code reads `AGENTS.md` when no `CLAUDE.md` exists.
- **`.agents/skills/`**: one committed copy of every skill. `.claude/skills` is a local link to it (a junction on Windows, gitignored). `scripts/link-skills.*` recreates the link after a fresh clone.
- **Skills installed:**
  - [unslop](https://github.com/cursor/plugins/tree/main/pstack/skills/unslop)
  - [Matt Pocock's skills](https://github.com/mattpocock/skills), all of them, with `/setup-matt-pocock-skills` run live
  - [ponytail](https://github.com/dietrichgebert/ponytail)
  - [taste](https://github.com/Leonxlnx/taste-skill) (`design-taste-frontend`)
  - [imagegen-frontend-web](https://github.com/Leonxlnx/imagegen-skills)
  - [ui-ux-pro-max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)
  - [impeccable](https://github.com/pbakaus/impeccable), with Claude and Codex hooks
  - [hyperframes](https://github.com/heygen-com/hyperframes) core 4
  - `raw-dog`, bundled here: you write the code while the agent plans, scaffolds, hints and reviews. Run `/raw-dog [raw|tease|stroke|edge]` or say "let me raw dog it". The assistance level goes from `raw` (you write everything, the agent reviews) to `edge` (the agent stubs the functions and tests, you fill the bodies). Hints climb nibble › lick › suck.
- **`docs/agents/coding-standards.md`**: Karpathy's four principles combined with Ponytail's ladder and its non-negotiables.
- **`docs/agents/frontend-workflow.md`**:
  - New surface: taste sets direction → ui-ux-pro-max builds the system and validates it → build → impeccable gate.
  - Changes to an existing surface take a fast path.
- **`scripts/update-skills.*`**: updates every skill in one command. Review the diff before committing.
- One local commit, never pushed.

## Requirements

- Node 22.20 or later, and git.
- Python 3 for ui-ux-pro-max, FFmpeg for hyperframes, and Chrome, Edge or Chromium for taste.

The skill checks these first and asks before installing anything.

## Layout

```
SKILL.md              agent instructions
scripts/              preflight + init (PowerShell and bash)
templates/            files copied into the target repo (skills/raw-dog.md becomes .agents/skills/raw-dog/SKILL.md)
```
