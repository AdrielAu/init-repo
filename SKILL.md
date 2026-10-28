---
name: init-repo
description: Set up a freshly cloned, empty repo for agent-agnostic work (Claude Code, Codex, Antigravity) - AGENTS.md, shared .agents/skills, coding standards, frontend design workflow and video skills. Use only when the user runs /init-repo.
disable-model-invocation: true
---

# init-repo

Set up the current repo so Claude Code, Codex and Antigravity share one instruction file (`AGENTS.md`) and one skills folder (`.agents/skills/`).

`<skill-dir>` below means the folder containing this SKILL.md. The scripts do the fixed work; you handle every step that needs judgment or the user. Follow the steps in order.

## 1. Guard

Run from the repo root (`git rev-parse --show-toplevel`). If this is not a git repo, stop and say so.

List the root. Allowed before init: `.git`, `README*`, `LICENSE*`, `.gitignore`.

- **Anything else, or an existing `AGENTS.md`:** ask the user whether to **merge** (continue; the script never overwrites existing files, and you then fold any missing sections from `<skill-dir>/templates/` into the existing files by hand) or **abort**.
- **Re-run in an already initialised repo:** the script is safe to re-run; it skips what exists.

## 2. Preflight

Run, and read the JSON lines:

- Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>\scripts\preflight.ps1"`
- macOS/Linux: `bash "<skill-dir>/scripts/preflight.sh"`

For each tool with `"ok": false`, ask the user whether to install it, naming what needs it. Never install without a yes.

- Yes on Windows: `winget install --id <winget id> -e --accept-package-agreements --accept-source-agreements`. Then refresh PATH in the same shell (`$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')`) and re-run the preflight.
- Yes on macOS/Linux: run the `install` command from the JSON.
- No: record what to skip.

| Missing and declined | Consequence |
|---|---|
| `git` or `node` (or node below 22.20) | Stop. Nothing can install. |
| `python3` | Skip `uipro` |
| `ffmpeg` | Skip `hyperframes` |
| `chrome` | Skip `taste` |

## 3. Run the setup script

- Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>\scripts\init.ps1" -Skip <comma list>`
- macOS/Linux: `bash "<skill-dir>/scripts/init.sh" --skip <comma list>`

Leave out the skip argument if nothing is skipped. Installs take several minutes.

The script:

1. creates `.agents/skills/` and links `.claude/skills` to it (a junction on Windows);
2. installs every skill into `.agents/skills/` only;
3. copies `AGENTS.md`, `docs/agents/*.md` and `scripts/{link,update}-skills.*` from `<skill-dir>/templates/`;
4. appends the init-repo and impeccable blocks to `.gitignore`;
5. writes `.impeccable/config.json` with `buildPath: "code"` and `telemetry: false`.

It ends with a `REPORT`.

## 4. Fix what the report flags

- **A step `failed`:** re-run just that install command (it's in the script) and read the error. Retry once.
- **`missing-skills` is not `none`:** install those with `npx -y skills@latest add <source> --skill <name> -a codex -y`.
- **`link` is `BLOCKED`:** tell the user. Do not delete their files.
- **The `impeccable` install prompted, failed, or `impeccable-claude-hook`/`impeccable-codex-hook` is false:** run `npx impeccable install --help`, find the non-interactive flags for hooks, and re-run with `--providers=codex,claude --scope=project`.
- **`stray-design-folders` is not `none`:** an installer created a second design or skills location. Move any skill folders into `.agents/skills/`, delete the stray folder, and note it in the summary.

Do not run `/impeccable init` now. The frontend workflow runs it before the first frontend task.

## 5. Matt Pocock setup

Load the `setup-matt-pocock-skills` skill and run it with the user. Do not pre-fill or suggest answers: the repo may not use GitHub.

## 6. Commit

```
git add -A
git commit -m "chore: initialise agent setup"
```

Never push. Check that `.claude/skills` is not in the commit; it is gitignored.

## 7. Summary to the user

Keep it short:

- what was installed (group counts, not every skill name);
- what was skipped and why;
- anything you fixed or could not fix in step 4;
- manual steps:
  - **Restart Claude Code and Antigravity** so they load the new skills. Claude Code does not read AGENTS.md in the first session after an install or upgrade.
  - **Codex:** open `/hooks` and approve the impeccable hook.
  - **After cloning on another machine:** run `scripts/link-skills.ps1` (or `.sh`) once.
  - **To update skills:** run `scripts/update-skills.ps1` (or `.sh`) and review the diff.
