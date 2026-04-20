[CmdletBinding()]
param(
    [string]$Path = "."
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Pass {
    param([string]$Message)
    Write-Host "[PASS] $Message" -ForegroundColor Green
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git was not found in PATH."
}

$resolved = Resolve-Path -LiteralPath $Path
$repoRoot = git -C $resolved.Path rev-parse --show-toplevel 2>$null
if ($LASTEXITCODE -ne 0 -or -not $repoRoot) {
    throw "Path '$($resolved.Path)' is not inside a Git repository."
}
$repoRoot = $repoRoot.Trim()

$hooksDir = Join-Path $repoRoot ".git\hooks"
New-Item -Path $hooksDir -ItemType Directory -Force | Out-Null

$hookPath = Join-Path $hooksDir "pre-commit"
$skillScriptRelative = ".agent/github-secure-commit-skill/github-secure-commit/scripts/secure-commit.ps1"

$hookContent = @"
#!/usr/bin/env sh
REPO_ROOT="$(git rev-parse --show-toplevel)"
powershell -NoProfile -ExecutionPolicy Bypass -File "$REPO_ROOT/$skillScriptRelative" -Path "$REPO_ROOT" -HookMode
STATUS=$?
if [ $STATUS -ne 0 ]; then
  echo "Security gate failed. Commit aborted."
  exit $STATUS
fi
exit 0
"@

Set-Content -LiteralPath $hookPath -Value $hookContent -Encoding ascii -NoNewline

Write-Info "Installed hook: $hookPath"
Write-Pass "Pre-commit hook now enforces secret scan + OWASP security gate."
