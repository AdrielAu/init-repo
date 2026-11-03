# Updates every skill in .agents/skills. Review the result with `git diff`
# before committing.
$ErrorActionPreference = 'Continue'

$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { $root = (Resolve-Path "$PSScriptRoot\..").Path }
Set-Location $root

$env:DISABLE_TELEMETRY = '1'
$env:DO_NOT_TRACK = '1'
$env:IMPECCABLE_NO_TELEMETRY = '1'
$env:npm_config_loglevel = 'warn'
$env:npm_config_update_notifier = 'false'

Write-Host "== Skills installed with npx skills (unslop, Matt Pocock, ponytail, taste, imagegen, Emil Kowalski, hyperframes)"
npx -y skills@latest update

Write-Host "== impeccable"
cmd /c "echo y| npx -y impeccable@latest update"

Write-Host "== Link check"
& "$PSScriptRoot\link-skills.ps1"

Write-Host "Done. Review changes with: git diff --stat"
