# init-repo: mechanical setup. Run from the root of the target repo.
# The agent decides what to skip (from the preflight answers) and handles
# everything interactive; this script only does fixed, repeatable steps.
#
#   powershell -ExecutionPolicy Bypass -File <skill-dir>\scripts\init.ps1 [-Skip taste,hyperframes]
#
# Skip names: unslop, matt, ponytail, taste, imagegen, uipro, impeccable, hyperframes, templates
param(
    [string[]]$Skip = @()
)
$ErrorActionPreference = 'Continue'
# With `powershell -File`, "-Skip a,b" arrives as one string; split it.
$Skip = @($Skip | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$SkillDir = (Resolve-Path "$PSScriptRoot\..").Path
$Templates = Join-Path $SkillDir 'templates'

$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Write-Error "Not inside a git repository. Run this from the root of the cloned repo."; exit 1 }
$root = (Resolve-Path $root).Path
Set-Location $root

$env:DISABLE_TELEMETRY = '1'
$env:DO_NOT_TRACK = '1'
$env:IMPECCABLE_NO_TELEMETRY = '1'
$env:npm_config_loglevel = 'warn'          # hide "npm notice" lines (PowerShell shows them as errors)
$env:npm_config_update_notifier = 'false'

# Extra skills bundled by `uipro init`. They duplicate taste / ui-ux-pro-max /
# impeccable and write their own design-system and brand files, so they go.
$UiproExtras = @('banner-design', 'brand', 'design', 'design-system', 'slides', 'ui-styling')

$report = [ordered]@{}
function Step([string]$name, [scriptblock]$body) {
    if ($Skip -contains $name) { $report[$name] = 'skipped'; Write-Host "-- ${name}: skipped"; return }
    Write-Host "== $name"
    $global:LASTEXITCODE = 0
    try { & $body; if ($LASTEXITCODE -ne 0) { $report[$name] = "failed (exit $LASTEXITCODE)" } else { $report[$name] = 'ok' } }
    catch { $report[$name] = "failed: $($_.Exception.Message)" }
    Write-Host "   -> $($report[$name])"
}

# 1. Folders and the .claude/skills junction (before any installer runs, so
#    nothing creates a real .claude/skills folder first).
New-Item -ItemType Directory -Force -Path '.agents\skills' | Out-Null
New-Item -ItemType Directory -Force -Path '.claude' | Out-Null
$link = Get-Item -LiteralPath '.claude\skills' -Force -ErrorAction SilentlyContinue
if (-not $link) {
    New-Item -ItemType Junction -Path '.claude\skills' -Target (Resolve-Path '.agents\skills').Path | Out-Null
    $report['link'] = 'created'
} elseif ($link.LinkType) { $report['link'] = 'already linked' }
else { $report['link'] = 'BLOCKED: .claude\skills is a real folder; move its contents into .agents\skills, delete it, run scripts\link-skills.ps1' }
Write-Host "== link: $($report['link'])"

# 2. Skills. Everything targets Codex's project folder (.agents/skills) only;
#    Antigravity reads the same folder and Claude sees it through the junction.
$sk = @('-y', 'skills@latest', 'add')
Step 'unslop'      { npx @sk 'https://github.com/cursor/plugins' --skill unslop -a codex -y }
Step 'matt'        { npx @sk 'mattpocock/skills' -a codex -y }
Step 'ponytail'    { npx @sk 'dietrichgebert/ponytail' -a codex -y }
Step 'taste'       { npx @sk 'https://github.com/Leonxlnx/taste-skill' --skill design-taste-frontend -a codex -y }
Step 'imagegen'    { npx @sk 'https://github.com/Leonxlnx/imagegen-skills' --skill imagegen-frontend-web -a codex -y }
Step 'hyperframes' { npx @sk 'heygen-com/hyperframes' --skill hyperframes --skill hyperframes-cli --skill hyperframes-registry --skill media-use -a codex -y }
Step 'uipro' {
    if (-not (Get-Command uipro -ErrorAction SilentlyContinue)) { npm install -g ui-ux-pro-max-cli }
    uipro init --ai universal
    if ($LASTEXITCODE -eq 0) {
        $removed = @()
        foreach ($x in $UiproExtras) {
            $p = Join-Path '.agents\skills' $x
            if (Test-Path $p) { Remove-Item -Recurse -Force $p; $removed += $x }
        }
        if ($removed) { $script:report['uipro-extras-removed'] = ($removed -join ', ') }
    }
}
# "y" answers the "Install the design hook?" prompt.
Step 'impeccable'  { 'y' | npx -y impeccable@latest install --providers=codex,claude --scope=project }

# 3. Project files from templates. Never overwrite an existing file.
Step 'templates' {
    $files = @(
        'AGENTS.md',
        'docs\agents\coding-standards.md',
        'docs\agents\frontend-workflow.md',
        'scripts\link-skills.ps1', 'scripts\link-skills.sh',
        'scripts\update-skills.ps1', 'scripts\update-skills.sh'
    )
    $kept = @()
    foreach ($f in $files) {
        $dest = Join-Path $root $f
        if (Test-Path $dest) { $kept += $f; continue }
        New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
        Copy-Item (Join-Path $Templates $f) $dest
    }
    if ($kept) { $script:report['templates-kept-existing'] = ($kept -join ', ') }
    git update-index --add --chmod=+x scripts/link-skills.sh scripts/update-skills.sh 2>$null
    $global:LASTEXITCODE = 0
}

# 4. .gitignore: append each block only if its start marker is missing.
$gi = Join-Path $root '.gitignore'
$existing = if (Test-Path $gi) { Get-Content $gi -Raw } else { '' }
$blockText = Get-Content (Join-Path $Templates 'gitignore-block.txt') -Raw
$added = @()
foreach ($marker in @('init-repo', 'impeccable-ignore')) {
    if ($existing -notmatch "# $marker-start") {
        $m = [regex]::Match($blockText, "(?s)# $marker-start.*?# $marker-end")
        $sep = if ($existing -and -not $existing.EndsWith("`n")) { "`n`n" } elseif ($existing) { "`n" } else { '' }
        $existing = $existing + $sep + $m.Value + "`n"
        $added += $marker
    }
}
Set-Content -Path $gi -Value $existing -NoNewline
$report['gitignore'] = if ($added) { 'added: ' + ($added -join ', ') } else { 'already present' }

# 5. .impeccable/config.json: buildPath=code, telemetry=false (merge, keep other keys).
New-Item -ItemType Directory -Force -Path '.impeccable' | Out-Null
$cfgPath = '.impeccable\config.json'
$cfg = [ordered]@{}
if (Test-Path $cfgPath) {
    try { (Get-Content $cfgPath -Raw | ConvertFrom-Json).PSObject.Properties | ForEach-Object { $cfg[$_.Name] = $_.Value } } catch {}
}
$cfg['buildPath'] = 'code'
$cfg['telemetry'] = $false
$cfg | ConvertTo-Json -Depth 20 | Set-Content $cfgPath
$report['impeccable-config'] = 'buildPath=code, telemetry=false'

# 6. Verify the expected skills are present.
$expect = [ordered]@{
    unslop = @('unslop'); matt = @('setup-matt-pocock-skills', 'grill-me', 'tdd'); ponytail = @('ponytail')
    taste = @('design-taste-frontend'); imagegen = @('imagegen-frontend-web'); uipro = @('ui-ux-pro-max')
    impeccable = @('impeccable'); hyperframes = @('hyperframes', 'hyperframes-cli', 'hyperframes-registry', 'media-use')
}
$missing = @()
foreach ($k in $expect.Keys) {
    if ($Skip -contains $k) { continue }
    foreach ($s in $expect[$k]) { if (-not (Test-Path (Join-Path '.agents\skills' "$s\SKILL.md"))) { $missing += $s } }
}
$report['missing-skills'] = if ($missing) { $missing -join ', ' } else { 'none' }
$report['claude-sees-skills'] = [bool](Test-Path '.claude\skills\impeccable') -or [bool](Get-ChildItem '.claude\skills' -ErrorAction SilentlyContinue | Select-Object -First 1)
$report['impeccable-claude-hook'] = [bool]((Test-Path '.claude\settings.local.json') -and (Select-String -Path '.claude\settings.local.json' -Pattern 'impeccable' -Quiet))
$report['impeccable-codex-hook'] = [bool](Test-Path '.codex\hooks.json')
$stray = (@('design-system', '.agent\skills') | Where-Object { Test-Path $_ }) -join ', '
$report['stray-design-folders'] = if ($stray) { $stray } else { 'none' }

Write-Host ''
Write-Host '== REPORT'
$report | ConvertTo-Json
