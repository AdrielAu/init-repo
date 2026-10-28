# Checks the tools init-repo needs. Prints one JSON object per tool and never
# installs anything. The agent reads the output and asks the user about each
# missing tool.
$ErrorActionPreference = 'SilentlyContinue'

function Get-Version([string]$cmd, [string[]]$argList) {
    $c = Get-Command $cmd -ErrorAction SilentlyContinue
    if (-not $c) { return $null }
    $out = & $cmd @argList 2>&1 | Select-Object -First 1
    # The Windows "python3" Store stub exits 9009 with a "not found" message.
    if ($LASTEXITCODE -ne 0) { return $null }
    return "$out".Trim()
}

$results = @()

# git
$v = Get-Version 'git' @('--version')
$results += [ordered]@{ tool='git'; found=[bool]$v; ok=[bool]$v; version=$v; winget='Git.Git'; neededBy='everything' }

# node >= 22.20
$v = Get-Version 'node' @('--version')
$ok = $false
if ($v -match 'v(\d+)\.(\d+)') { $ok = ([int]$Matches[1] -gt 22) -or ([int]$Matches[1] -eq 22 -and [int]$Matches[2] -ge 20) }
$results += [ordered]@{ tool='node'; found=[bool]$v; ok=$ok; version=$v; required='>=22.20'; winget='OpenJS.NodeJS.LTS'; neededBy='all skill installers (npx skills, uipro, impeccable, hyperframes)' }

# python 3
$v = $null
foreach ($p in @(@('python3', @('--version')), @('python', @('--version')), @('py', @('-3', '--version')))) {
    $v = Get-Version $p[0] $p[1]
    if ($v -match 'Python 3') { $pyCmd = $p[0]; break } else { $v = $null }
}
$results += [ordered]@{ tool='python3'; found=[bool]$v; ok=[bool]$v; version=$v; command=$pyCmd; winget='Python.Python.3.12'; neededBy='ui-ux-pro-max search scripts' }

# ffmpeg
$v = Get-Version 'ffmpeg' @('-version')
$results += [ordered]@{ tool='ffmpeg'; found=[bool]$v; ok=[bool]$v; version=$v; winget='Gyan.FFmpeg'; neededBy='hyperframes rendering' }

# Chrome / Edge / Chromium
$browserPaths = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
)
$browser = $browserPaths | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
$results += [ordered]@{ tool='chrome'; found=[bool]$browser; ok=[bool]$browser; version=$browser; winget='Google.Chrome'; neededBy='taste browser checks, impeccable URL scans, hyperframes rendering' }

foreach ($r in $results) { $r | ConvertTo-Json -Compress }
