#!/usr/bin/env bash
# Updates every skill in .agents/skills. Review the result with `git diff`
# before committing. On Windows, use update-skills.ps1 instead.
set -uo pipefail

root="$(git rev-parse --show-toplevel 2>/dev/null || (cd "$(dirname "$0")/.." && pwd))"
cd "$root"

export DISABLE_TELEMETRY=1 DO_NOT_TRACK=1 IMPECCABLE_NO_TELEMETRY=1
export npm_config_loglevel=warn npm_config_update_notifier=false

echo "== Skills installed with npx skills (unslop, Matt Pocock, ponytail, taste, imagegen, Emil Kowalski, hyperframes)"
npx -y skills@latest update

echo "== impeccable"
echo y | npx -y impeccable@latest update

echo "== Link check"
bash "$(dirname "$0")/link-skills.sh"

echo "Done. Review changes with: git diff --stat"
