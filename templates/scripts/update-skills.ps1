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

Write-Host "== Skills installed with npx skills (unslop, Matt Pocock, ponytail, taste, imagegen, hyperframes)"
npx -y skills@latest update

Write-Host "== ui-ux-pro-max"
if (Get-Command uipro -ErrorAction SilentlyContinue) {
    npm install -g ui-ux-pro-max-cli@latest
    uipro update
    # uipro re-adds skills that overlap taste / impeccable; keep only ui-ux-pro-max.
    foreach ($x in @('banner-design', 'brand', 'design', 'design-system', 'slides', 'ui-styling')) {
        $p = Join-Path '.agents\skills' $x
        if (Test-Path $p) { Remove-Item -Recurse -Force $p }
    }
} else {
    Write-Warning "uipro is not installed; skipping. Install with: npm install -g ui-ux-pro-max-cli"
}

Write-Host "== impeccable"
cmd /c "echo y| npx -y impeccable@latest update"

Write-Host "== Link check"
& "$PSScriptRoot\link-skills.ps1"

Write-Host "Done. Review changes with: git diff --stat"
