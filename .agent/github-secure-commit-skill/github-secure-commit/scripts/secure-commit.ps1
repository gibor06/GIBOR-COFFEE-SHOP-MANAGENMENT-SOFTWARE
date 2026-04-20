[CmdletBinding()]
param(
    [string]$Path = ".",
    [string]$CommitMessage = "",
    [switch]$Push,
    [string]$Remote = "origin",
    [string]$Branch = "",
    [switch]$HookMode,
    [switch]$SkipDependencyAudit
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

function Write-Fail {
    param([string]$Message)
    Write-Host "[FAIL] $Message" -ForegroundColor Red
}

function Get-RepoRoot {
    param([string]$StartPath)
    $resolved = Resolve-Path -LiteralPath $StartPath
    $gitRoot = git -C $resolved.Path rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $gitRoot) {
        throw "Path '$($resolved.Path)' is not inside a Git repository."
    }
    return $gitRoot.Trim()
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git was not found in PATH."
}

$repoRoot = Get-RepoRoot -StartPath $Path
$scriptsRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$secretScript = Join-Path $scriptsRoot "scan-secrets.ps1"
$auditScript = Join-Path $scriptsRoot "owasp-audit.ps1"

if (-not (Test-Path -LiteralPath $secretScript -PathType Leaf)) {
    throw "Missing script: $secretScript"
}
if (-not (Test-Path -LiteralPath $auditScript -PathType Leaf)) {
    throw "Missing script: $auditScript"
}

Write-Info "Repository root: $repoRoot"
Write-Info "Step 1/2: Secret leak scan"
& powershell -NoProfile -ExecutionPolicy Bypass -File $secretScript -Path $repoRoot
if ($LASTEXITCODE -ne 0) {
    Write-Fail "Secret leak gate failed. Commit blocked."
    exit 1
}

Write-Info "Step 2/2: OWASP Top 10 audit"
$auditArgs = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", $auditScript,
    "-Path", $repoRoot
)
if ($SkipDependencyAudit) {
    $auditArgs += "-SkipDependencyAudit"
}
& powershell @auditArgs
if ($LASTEXITCODE -ne 0) {
    Write-Fail "OWASP security gate failed. Commit blocked."
    exit 1
}

Write-Pass "All security gates passed."

if ($HookMode) {
    Write-Info "Hook mode enabled. Exiting after gate checks."
    exit 0
}

if ([string]::IsNullOrWhiteSpace($CommitMessage)) {
    Write-Info "No commit message supplied. Gate checks finished without creating a commit."
    exit 0
}

Write-Info "Staging all changes for commit."
git -C $repoRoot add -A
if ($LASTEXITCODE -ne 0) {
    Write-Fail "Failed to stage changes."
    exit 1
}

Write-Info "Creating commit."
git -C $repoRoot commit -m $CommitMessage
if ($LASTEXITCODE -ne 0) {
    Write-Fail "Commit command failed."
    exit 1
}

Write-Pass "Commit created successfully."

if ($Push) {
    if ([string]::IsNullOrWhiteSpace($Branch)) {
        $Branch = (git -C $repoRoot rev-parse --abbrev-ref HEAD).Trim()
    }
    Write-Info "Pushing to $Remote/$Branch"
    git -C $repoRoot push $Remote $Branch
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Push failed."
        exit 1
    }
    Write-Pass "Push completed successfully."
}

exit 0
