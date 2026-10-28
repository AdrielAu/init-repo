# Links .claude/skills to .agents/skills so Claude Code sees the same skills
# as Codex and Antigravity. Uses a directory junction (no admin rights needed).
# Run from anywhere inside the repo after a fresh clone.
$ErrorActionPreference = 'Stop'

$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { $root = (Resolve-Path "$PSScriptRoot\..").Path }
Set-Location $root

$target = Join-Path $root '.agents\skills'
$link   = Join-Path $root '.claude\skills'

if (-not (Test-Path $target)) { New-Item -ItemType Directory -Path $target | Out-Null }
if (-not (Test-Path (Join-Path $root '.claude'))) { New-Item -ItemType Directory -Path (Join-Path $root '.claude') | Out-Null }

$item = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue
if ($item) {
    if ($item.LinkType) {
        Write-Host "OK: .claude\skills is already a link to $($item.Target)"
        exit 0
    }
    $hasContent = Get-ChildItem -LiteralPath $link -Force -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($hasContent) {
        Write-Error ".claude\skills is a real folder with content. Move anything you need into .agents\skills, delete .claude\skills, then run this again."
    }
    Remove-Item -LiteralPath $link -Force
}

New-Item -ItemType Junction -Path $link -Target $target | Out-Null
Write-Host "Linked .claude\skills -> .agents\skills"
