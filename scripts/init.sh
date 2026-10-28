#!/usr/bin/env bash
# init-repo: mechanical setup (macOS/Linux). Run from the root of the target repo.
# On Windows, use init.ps1. The agent decides what to skip and handles
# everything interactive; this script only does fixed, repeatable steps.
#
#   bash <skill-dir>/scripts/init.sh [--skip taste,hyperframes]
#
# Skip names: unslop, matt, ponytail, taste, imagegen, uipro, impeccable, hyperframes, templates
set -uo pipefail

SKIP=","
if [ "${1:-}" = "--skip" ] && [ -n "${2:-}" ]; then SKIP=",$2,"; fi
skipped() { case "$SKIP" in *",$1,"*) return 0;; *) return 1;; esac; }

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATES="$SKILL_DIR/templates"

root="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "Not inside a git repository. Run this from the root of the cloned repo." >&2; exit 1; }
cd "$root"

export DISABLE_TELEMETRY=1 DO_NOT_TRACK=1 IMPECCABLE_NO_TELEMETRY=1
export npm_config_loglevel=warn npm_config_update_notifier=false

# Extra skills bundled by `uipro init`. They duplicate taste / ui-ux-pro-max /
# impeccable and write their own design-system and brand files, so they go.
UIPRO_EXTRAS="banner-design brand design design-system slides ui-styling"

REPORT=""
note() { REPORT="$REPORT$1: $2"$'\n'; }
step() { # name, command...
  local name="$1"; shift
  if skipped "$name"; then note "$name" "skipped"; echo "-- $name: skipped"; return; fi
  echo "== $name"
  if "$@"; then note "$name" "ok"; else note "$name" "failed (exit $?)"; fi
}

# 1. Folders and the .claude/skills link, before any installer runs.
mkdir -p .agents/skills .claude
if [ -L .claude/skills ]; then note link "already linked"
elif [ -e .claude/skills ]; then note link "BLOCKED: .claude/skills is a real folder; move its contents into .agents/skills, delete it, run scripts/link-skills.sh"
else ln -s ../.agents/skills .claude/skills && note link "created"; fi

# 2. Skills, all into .agents/skills only.
sk() { npx -y skills@latest add "$@" -a codex -y; }
step unslop      sk https://github.com/cursor/plugins --skill unslop
step matt        sk mattpocock/skills
step ponytail    sk dietrichgebert/ponytail
step taste       sk https://github.com/Leonxlnx/taste-skill --skill design-taste-frontend
step imagegen    sk https://github.com/Leonxlnx/imagegen-skills --skill imagegen-frontend-web
step hyperframes sk heygen-com/hyperframes --skill hyperframes --skill hyperframes-cli --skill hyperframes-registry --skill media-use
uipro_install() {
  command -v uipro >/dev/null 2>&1 || npm install -g ui-ux-pro-max-cli
  uipro init --ai universal || return $?
  local removed="" x
  for x in $UIPRO_EXTRAS; do
    if [ -d ".agents/skills/$x" ]; then rm -rf ".agents/skills/$x"; removed="$removed $x"; fi
  done
  [ -n "$removed" ] && note uipro-extras-removed "$removed"
  return 0
}
step uipro       uipro_install
# "y" answers the "Install the design hook?" prompt.
impeccable_install() { echo y | npx -y impeccable@latest install --providers=codex,claude --scope=project; }
step impeccable  impeccable_install

# 3. Project files from templates. Never overwrite an existing file.
copy_templates() {
  local kept="" f
  for f in AGENTS.md docs/agents/coding-standards.md docs/agents/frontend-workflow.md \
           scripts/link-skills.ps1 scripts/link-skills.sh scripts/update-skills.ps1 scripts/update-skills.sh; do
    if [ -e "$f" ]; then kept="$kept $f"; continue; fi
    mkdir -p "$(dirname "$f")"
    cp "$TEMPLATES/$f" "$f"
  done
  chmod +x scripts/link-skills.sh scripts/update-skills.sh 2>/dev/null || true
  [ -n "$kept" ] && note templates-kept-existing "$kept"
  return 0
}
step templates copy_templates

# 4. .gitignore: append each block only if its start marker is missing.
touch .gitignore
added=""
for marker in init-repo impeccable-ignore; do
  if ! grep -q "# $marker-start" .gitignore; then
    [ -s .gitignore ] && [ -n "$(tail -c1 .gitignore)" ] && echo >> .gitignore
    [ -s .gitignore ] && echo >> .gitignore
    sed -n "/# $marker-start/,/# $marker-end/p" "$TEMPLATES/gitignore-block.txt" >> .gitignore
    added="$added $marker"
  fi
done
note gitignore "${added:+added:}${added:-already present}"

# 5. .impeccable/config.json: buildPath=code, telemetry=false (merge, keep other keys).
mkdir -p .impeccable
node -e '
const fs=require("fs"),p=".impeccable/config.json";
let c={}; try{c=JSON.parse(fs.readFileSync(p,"utf8"))}catch{}
c.buildPath="code"; c.telemetry=false;
fs.writeFileSync(p, JSON.stringify(c,null,2)+"\n");
' && note impeccable-config "buildPath=code, telemetry=false"

# 6. Verify the expected skills are present.
missing=""
check() { local group="$1"; shift; skipped "$group" && return; for s in "$@"; do [ -f ".agents/skills/$s/SKILL.md" ] || missing="$missing $s"; done; }
check unslop unslop
check matt setup-matt-pocock-skills grill-me tdd
check ponytail ponytail
check taste design-taste-frontend
check imagegen imagegen-frontend-web
check uipro ui-ux-pro-max
check impeccable impeccable
check hyperframes hyperframes hyperframes-cli hyperframes-registry media-use
note missing-skills "${missing:-none}"
[ -n "$(ls -A .claude/skills 2>/dev/null)" ] && note claude-sees-skills true || note claude-sees-skills false
grep -qs impeccable .claude/settings.local.json && note impeccable-claude-hook true || note impeccable-claude-hook false
[ -f .codex/hooks.json ] && note impeccable-codex-hook true || note impeccable-codex-hook false
stray=""; for d in design-system .agent/skills; do [ -e "$d" ] && stray="$stray $d"; done
note stray-design-folders "${stray:-none}"

echo
echo "== REPORT"
printf '%s' "$REPORT"
