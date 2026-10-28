#!/usr/bin/env bash
# Links .claude/skills to .agents/skills so Claude Code sees the same skills
# as Codex and Antigravity. On Windows, use link-skills.ps1 instead.
set -euo pipefail

root="$(git rev-parse --show-toplevel 2>/dev/null || (cd "$(dirname "$0")/.." && pwd))"
cd "$root"

mkdir -p .agents/skills .claude

if [ -L .claude/skills ]; then
  echo "OK: .claude/skills is already a link to $(readlink .claude/skills)"
  exit 0
fi

if [ -d .claude/skills ]; then
  if [ -n "$(ls -A .claude/skills)" ]; then
    echo "Error: .claude/skills is a real folder with content. Move anything you need into .agents/skills, delete .claude/skills, then run this again." >&2
    exit 1
  fi
  rmdir .claude/skills
fi

ln -s ../.agents/skills .claude/skills
echo "Linked .claude/skills -> .agents/skills"
