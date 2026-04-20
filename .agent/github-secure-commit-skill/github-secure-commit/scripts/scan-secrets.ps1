[CmdletBinding()]
param(
    [string]$Path = ".",
    [switch]$NoFail,
    [string]$ReportPath = ""
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
    try {
        $gitRoot = git -C $resolved.Path rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0 -and $gitRoot) {
            return $gitRoot.Trim()
        }
    } catch {
    }
    return $resolved.Path
}

function Test-Command {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Convert-ToRelativePath {
    param(
        [string]$BasePath,
        [string]$TargetPath
    )
    $baseUri = [System.Uri]((Resolve-Path -LiteralPath $BasePath).Path.TrimEnd("\") + "\")
    $targetUri = [System.Uri]((Resolve-Path -LiteralPath $TargetPath).Path)
    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString()).Replace("/", "\")
}

function Test-PathHasExcludedSegment {
    param(
        [string]$RelativePath,
        [string[]]$ExcludedSegments
    )

    $normalized = $RelativePath.Replace("/", "\")
    $segments = $normalized.Split("\") | Where-Object { $_ -ne "" }
    foreach ($segment in $segments) {
        if ($ExcludedSegments -contains $segment.ToLowerInvariant()) {
            return $true
        }
    }
    return $false
}

$repoRoot = Get-RepoRoot -StartPath $Path
Write-Info "Scanning for leaked secrets under: $repoRoot"

$excludedDirs = @(
    ".git",
    "bin",
    "obj",
    "node_modules",
    "dist",
    "build",
    ".vs",
    ".idea",
    ".vscode"
)

$textExtensions = @(
    ".cs", ".vb", ".fs", ".xaml", ".json", ".xml", ".yaml", ".yml", ".config", ".ini",
    ".ps1", ".psm1", ".sh", ".cmd", ".bat", ".js", ".jsx", ".ts", ".tsx", ".py", ".java",
    ".kt", ".go", ".rb", ".php", ".sql", ".txt", ".md", ".csproj", ".props", ".targets", ".sln",
    ".env", ".toml", ".lock", ".editorconfig", ".gitattributes", ".gitignore"
)

function Test-LikelyTextFile {
    param([string]$FilePath)
    $name = [System.IO.Path]::GetFileName($FilePath).ToLowerInvariant()
    $extension = [System.IO.Path]::GetExtension($FilePath).ToLowerInvariant()

    if ($name -like ".env*") {
        return $true
    }

    if ($name -like "appsettings*.json") {
        return $true
    }

    if ($name -eq "dockerfile") {
        return $true
    }

    return $textExtensions -contains $extension
}

$files = New-Object System.Collections.Generic.List[string]

$isGitRepo = $false
if (Test-Command -Name "git") {
    try {
        git -C $repoRoot rev-parse --is-inside-work-tree *> $null
        if ($LASTEXITCODE -eq 0) {
            $isGitRepo = $true
        }
    } catch {
    }
}

if ($isGitRepo) {
    $tracked = git -C $repoRoot ls-files
    foreach ($relative in $tracked) {
        if ([string]::IsNullOrWhiteSpace($relative)) {
            continue
        }
        if (Test-PathHasExcludedSegment -RelativePath $relative -ExcludedSegments $excludedDirs) {
            continue
        }
        $fullPath = Join-Path $repoRoot $relative
        if ((Test-Path -LiteralPath $fullPath -PathType Leaf) -and (Test-LikelyTextFile -FilePath $fullPath)) {
            $files.Add($fullPath)
        }
    }
} else {
    $candidates = Get-ChildItem -Path $repoRoot -Recurse -File -ErrorAction SilentlyContinue
    foreach ($item in $candidates) {
        $relative = Convert-ToRelativePath -BasePath $repoRoot -TargetPath $item.FullName
        if (Test-PathHasExcludedSegment -RelativePath $relative -ExcludedSegments $excludedDirs) {
            continue
        }
        if (Test-LikelyTextFile -FilePath $item.FullName) {
            $files.Add($item.FullName)
        }
    }
}

$files = $files | Sort-Object -Unique
Write-Info "Text files considered: $($files.Count)"

$placeholderPattern = '(?i)(your[_-]?(api[_-]?key|token|secret|password)|example|sample|dummy|changeme|replace[_-]?me|todo|<[^>]+>|xxx+)'

$secretRules = @(
    [PSCustomObject]@{ Id = "openai-api-key"; Severity = "critical"; Pattern = '(?i)\bsk-(proj|live|test)?-[A-Za-z0-9]{20,}\b'; Note = "Potential OpenAI key" },
    [PSCustomObject]@{ Id = "github-token"; Severity = "critical"; Pattern = '\bgh[pousr]_[A-Za-z0-9]{36,255}\b'; Note = "Potential GitHub token" },
    [PSCustomObject]@{ Id = "aws-access-key"; Severity = "critical"; Pattern = '\bAKIA[0-9A-Z]{16}\b'; Note = "Potential AWS access key id" },
    [PSCustomObject]@{ Id = "slack-token"; Severity = "high"; Pattern = '\bxox[baprs]-[A-Za-z0-9-]{10,}\b'; Note = "Potential Slack token" },
    [PSCustomObject]@{ Id = "private-key-block"; Severity = "critical"; Pattern = '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----'; Note = "Private key block detected" },
    [PSCustomObject]@{ Id = "hardcoded-secret-assignment"; Severity = "high"; Pattern = '(?i)\b(api[_-]?key|access[_-]?key|client[_-]?secret|secret|token|connectionstring|openai)\b\s*[:=]\s*["''][^"'']{8,}["'']'; Note = "Hardcoded secret-style assignment" },
    [PSCustomObject]@{ Id = "connection-string-with-password"; Severity = "high"; Pattern = '(?i)(server|host)=.+;(user id|uid|username)=.+;(password|pwd)=.+;'; Note = "Connection string with embedded password" },
    [PSCustomObject]@{ Id = "env-export-secret"; Severity = "high"; Pattern = '(?i)\b(export|setx?)\s+[A-Z0-9_]*(KEY|TOKEN|SECRET|PASSWORD)[A-Z0-9_]*\s*='; Note = "Shell command exports secret-like environment variable" }
)

$findings = New-Object System.Collections.Generic.List[object]

foreach ($file in $files) {
    $relative = Convert-ToRelativePath -BasePath $repoRoot -TargetPath $file
    $fileName = [System.IO.Path]::GetFileName($file).ToLowerInvariant()

    if ($fileName -match '^\.env($|\.)' -and $fileName -notmatch '^\.env\.(example|sample|template)$') {
        $findings.Add([PSCustomObject]@{
            rule = "tracked-dotenv-file"
            severity = "high"
            file = $relative
            line = 1
            message = "Tracked .env file can leak runtime secrets"
            snippet = $fileName
        })
    }

    try {
        $lines = Get-Content -LiteralPath $file -ErrorAction Stop
    } catch {
        continue
    }

    for ($index = 0; $index -lt $lines.Count; $index++) {
        $line = $lines[$index]
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        foreach ($rule in $secretRules) {
            if ($line -match $rule.Pattern) {
                if ($line -match $placeholderPattern) {
                    continue
                }

                $snippet = $line.Trim()
                if ($snippet.Length -gt 180) {
                    $snippet = $snippet.Substring(0, 180) + "..."
                }

                $findings.Add([PSCustomObject]@{
                    rule = $rule.Id
                    severity = $rule.Severity
                    file = $relative
                    line = $index + 1
                    message = $rule.Note
                    snippet = $snippet
                })
            }
        }
    }
}

$findings = $findings | Sort-Object file, line, rule -Unique

if (-not $ReportPath) {
    $reportDir = Join-Path $repoRoot ".security-reports"
    New-Item -Path $reportDir -ItemType Directory -Force | Out-Null
    $ReportPath = Join-Path $reportDir "secrets-report.json"
}

@{
    generated_at = (Get-Date).ToString("o")
    repository = $repoRoot
    total_findings = @($findings).Count
    findings = @($findings)
} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $ReportPath -Encoding UTF8

if (@($findings).Count -eq 0) {
    Write-Pass "No leaked secrets detected. Report: $ReportPath"
    exit 0
}

Write-Fail "Potential secret leakage detected: $(@($findings).Count) finding(s)."
foreach ($finding in $findings) {
    Write-Host (" - [{0}] {1} {2}:{3} :: {4}" -f $finding.severity.ToUpperInvariant(), $finding.rule, $finding.file, $finding.line, $finding.message)
}
Write-Host "Report: $ReportPath"

if (-not $NoFail) {
    exit 1
}

exit 0
