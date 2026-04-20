[CmdletBinding()]
param(
    [string]$Path = ".",
    [switch]$AllowHigh,
    [switch]$SkipDependencyAudit,
    [string]$ReportPath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-WarnLine {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
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
    $segments = $RelativePath.Replace("/", "\").Split("\") | Where-Object { $_ -ne "" }
    foreach ($segment in $segments) {
        if ($ExcludedSegments -contains $segment.ToLowerInvariant()) {
            return $true
        }
    }
    return $false
}

function Test-LikelyTextFile {
    param([string]$FilePath)
    $name = [System.IO.Path]::GetFileName($FilePath).ToLowerInvariant()
    $extension = [System.IO.Path]::GetExtension($FilePath).ToLowerInvariant()
    $textExtensions = @(
        ".cs", ".vb", ".fs", ".xaml", ".json", ".xml", ".yaml", ".yml", ".config", ".ini",
        ".ps1", ".psm1", ".sh", ".cmd", ".bat", ".js", ".jsx", ".ts", ".tsx", ".py",
        ".java", ".kt", ".go", ".rb", ".php", ".sql", ".txt", ".md", ".csproj",
        ".props", ".targets", ".sln", ".toml", ".lock"
    )

    if ($name -like ".env*" -or $name -like "appsettings*.json" -or $name -eq "dockerfile") {
        return $true
    }

    return $textExtensions -contains $extension
}

function Test-RuleAppliesToFile {
    param(
        [object]$Rule,
        [string]$FilePath
    )
    if (-not $Rule.extensions -or $Rule.extensions.Count -eq 0) {
        return $true
    }
    $ext = [System.IO.Path]::GetExtension($FilePath).ToLowerInvariant()
    return $Rule.extensions -contains "*" -or $Rule.extensions -contains $ext
}

function Normalize-Severity {
    param([string]$Severity)
    switch -Regex ($Severity.ToLowerInvariant()) {
        "^critical$" { return "critical" }
        "^high$" { return "high" }
        "^(moderate|medium)$" { return "medium" }
        "^low$" { return "low" }
        default { return "medium" }
    }
}

function Get-SeverityRank {
    param([string]$Severity)
    switch ($Severity.ToLowerInvariant()) {
        "critical" { return 4 }
        "high" { return 3 }
        "medium" { return 2 }
        "low" { return 1 }
        default { return 0 }
    }
}

$repoRoot = Get-RepoRoot -StartPath $Path
Write-Info "Running OWASP Top 10 audit under: $repoRoot"

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

$rules = @(
    [PSCustomObject]@{
        id = "A01-anonymous-endpoint"
        category = "A01 Broken Access Control"
        severity = "high"
        pattern = '\[AllowAnonymous\]'
        note = "Anonymous endpoint found. Ensure this exposure is intentional and minimal."
        extensions = @(".cs")
    },
    [PSCustomObject]@{
        id = "A02-weak-hash"
        category = "A02 Cryptographic Failures"
        severity = "high"
        pattern = '\b(MD5|SHA1)\b'
        note = "Weak cryptographic hash detected. Prefer modern algorithms."
        extensions = @(".cs", ".js", ".ts", ".py", ".java")
    },
    [PSCustomObject]@{
        id = "A02-ecb-mode"
        category = "A02 Cryptographic Failures"
        severity = "high"
        pattern = 'CipherMode\.ECB'
        note = "ECB cipher mode detected. Prefer authenticated encryption (for example AES-GCM)."
        extensions = @(".cs")
    },
    [PSCustomObject]@{
        id = "A03-raw-sql"
        category = "A03 Injection"
        severity = "medium"
        pattern = '\b(FromSqlRaw|ExecuteSqlRaw|ExecuteSqlInterpolated)\s*\('
        note = "Raw SQL execution found. Validate all inputs and use parameterization."
        extensions = @(".cs")
    },
    [PSCustomObject]@{
        id = "A03-string-built-sql"
        category = "A03 Injection"
        severity = "high"
        pattern = '(?i)\b(select|insert|update|delete)\b.{0,80}\+\s*[A-Za-z_]'
        note = "Potential SQL string concatenation detected."
        extensions = @(".cs", ".js", ".ts", ".py", ".java", ".php")
    },
    [PSCustomObject]@{
        id = "A03-eval"
        category = "A03 Injection"
        severity = "high"
        pattern = '\beval\s*\('
        note = "Dynamic code evaluation detected."
        extensions = @(".js", ".ts", ".py", ".php")
    },
    [PSCustomObject]@{
        id = "A05-open-cors-with-credentials"
        category = "A05 Security Misconfiguration"
        severity = "high"
        pattern = 'AllowAnyOrigin\s*\(\s*\)\s*\.\s*AllowCredentials'
        note = "CORS allows any origin with credentials."
        extensions = @(".cs")
    },
    [PSCustomObject]@{
        id = "A05-trust-server-certificate"
        category = "A05 Security Misconfiguration"
        severity = "medium"
        pattern = '(?i)TrustServerCertificate\s*=\s*true'
        note = "Database connection trusts server certificate without validation."
        extensions = @(".json", ".config", ".xml", ".cs")
    },
    [PSCustomObject]@{
        id = "A07-password-compare"
        category = "A07 Identification and Authentication Failures"
        severity = "high"
        pattern = '(?i)\b(password|passwd|pwd)\b\s*==\s*'
        note = "Direct password comparison detected."
        extensions = @(".cs", ".js", ".ts", ".py", ".java", ".php")
    },
    [PSCustomObject]@{
        id = "A08-binaryformatter"
        category = "A08 Software and Data Integrity Failures"
        severity = "high"
        pattern = '\bBinaryFormatter\b'
        note = "BinaryFormatter usage is unsafe."
        extensions = @(".cs")
    },
    [PSCustomObject]@{
        id = "A08-typenamehandling-all"
        category = "A08 Software and Data Integrity Failures"
        severity = "high"
        pattern = 'TypeNameHandling\.All'
        note = "TypeNameHandling.All can open unsafe polymorphic deserialization paths."
        extensions = @(".cs")
    },
    [PSCustomObject]@{
        id = "A09-empty-catch"
        category = "A09 Security Logging and Monitoring Failures"
        severity = "medium"
        pattern = 'catch\s*\(\s*Exception[^\)]*\)\s*\{\s*\}'
        note = "Empty catch block can hide security relevant failures."
        extensions = @(".cs", ".js", ".ts", ".java")
    },
    [PSCustomObject]@{
        id = "A10-user-driven-url-request"
        category = "A10 Server-Side Request Forgery"
        severity = "medium"
        pattern = '(?i)(GetAsync|PostAsync|SendAsync)\s*\(\s*(request|input|url|uri)'
        note = "HTTP request built from user-driven input. Validate allowed destinations."
        extensions = @(".cs", ".js", ".ts", ".py")
    }
)

$findings = New-Object System.Collections.Generic.List[object]
$warnings = New-Object System.Collections.Generic.List[string]

foreach ($file in $files) {
    try {
        $lines = Get-Content -LiteralPath $file -ErrorAction Stop
    } catch {
        continue
    }

    $relative = Convert-ToRelativePath -BasePath $repoRoot -TargetPath $file
    for ($index = 0; $index -lt $lines.Count; $index++) {
        $line = $lines[$index]
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        foreach ($rule in $rules) {
            if (-not (Test-RuleAppliesToFile -Rule $rule -FilePath $file)) {
                continue
            }
            if ($line -match $rule.pattern) {
                $snippet = $line.Trim()
                if ($snippet.Length -gt 180) {
                    $snippet = $snippet.Substring(0, 180) + "..."
                }
                $findings.Add([PSCustomObject]@{
                    id = $rule.id
                    category = $rule.category
                    severity = $rule.severity
                    file = $relative
                    line = $index + 1
                    note = $rule.note
                    snippet = $snippet
                })
            }
        }
    }
}

if (-not $SkipDependencyAudit) {
    if (Test-Command -Name "dotnet") {
        $dotnetTargets = Get-ChildItem -Path $repoRoot -Filter *.sln -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 3
        if (-not $dotnetTargets -or $dotnetTargets.Count -eq 0) {
            $dotnetTargets = Get-ChildItem -Path $repoRoot -Filter *.csproj -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 5
        }

        foreach ($target in $dotnetTargets) {
            $relativeTarget = Convert-ToRelativePath -BasePath $repoRoot -TargetPath $target.FullName
            Write-Info "Dependency audit (.NET): $relativeTarget"
            $output = & dotnet list $target.FullName package --vulnerable --include-transitive 2>&1
            $outputText = ($output | Out-String)

            $matches = [regex]::Matches($outputText, '(?im)^\s*>\s*(?<pkg>[^\s]+)\s+[^\s]+\s+(?<sev>Low|Moderate|High|Critical)\s+')
            if ($matches.Count -gt 0) {
                foreach ($match in $matches) {
                    $severity = Normalize-Severity -Severity $match.Groups["sev"].Value
                    $findings.Add([PSCustomObject]@{
                        id = "A06-vulnerable-component-dotnet"
                        category = "A06 Vulnerable and Outdated Components"
                        severity = $severity
                        file = $relativeTarget
                        line = 1
                        note = "Vulnerable NuGet package: $($match.Groups["pkg"].Value)"
                        snippet = $match.Value.Trim()
                    })
                }
            } elseif ($LASTEXITCODE -ne 0) {
                $warnings.Add("dotnet audit failed for $relativeTarget. Output: $($outputText.Trim())")
            }
        }
    } else {
        $warnings.Add("dotnet CLI was not found. Skipped NuGet vulnerability scan.")
    }

    if (Test-Command -Name "npm") {
        $npmLocks = Get-ChildItem -Path $repoRoot -Filter package-lock.json -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 3
        foreach ($lock in $npmLocks) {
            $packageDir = Split-Path -Parent $lock.FullName
            $relativeTarget = Convert-ToRelativePath -BasePath $repoRoot -TargetPath $packageDir
            Write-Info "Dependency audit (npm): $relativeTarget"
            $output = & npm audit --audit-level=high --json --prefix $packageDir 2>&1
            $jsonText = $output | Out-String
            try {
                $parsed = $jsonText | ConvertFrom-Json -ErrorAction Stop
                $critical = 0
                $high = 0
                if ($parsed.metadata -and $parsed.metadata.vulnerabilities) {
                    $critical = [int]$parsed.metadata.vulnerabilities.critical
                    $high = [int]$parsed.metadata.vulnerabilities.high
                }
                if ($critical -gt 0 -or $high -gt 0) {
                    $severity = if ($critical -gt 0) { "critical" } else { "high" }
                    $findings.Add([PSCustomObject]@{
                        id = "A06-vulnerable-component-npm"
                        category = "A06 Vulnerable and Outdated Components"
                        severity = $severity
                        file = (Join-Path $relativeTarget "package-lock.json")
                        line = 1
                        note = "npm audit reported $critical critical and $high high vulnerabilities"
                        snippet = "npm audit --audit-level=high"
                    })
                }
            } catch {
                if ($LASTEXITCODE -ne 0) {
                    $warnings.Add("npm audit failed for $relativeTarget. Output: $($jsonText.Trim())")
                }
            }
        }
    }
}

$findings = $findings | Sort-Object file, line, id -Unique

if (-not $ReportPath) {
    $reportDir = Join-Path $repoRoot ".security-reports"
    New-Item -Path $reportDir -ItemType Directory -Force | Out-Null
    $ReportPath = Join-Path $reportDir "owasp-audit-report.json"
}

$summary = @{
    critical = 0
    high = 0
    medium = 0
    low = 0
}

foreach ($finding in $findings) {
    $sev = Normalize-Severity -Severity $finding.severity
    $summary[$sev] = [int]$summary[$sev] + 1
}

@{
    generated_at = (Get-Date).ToString("o")
    repository = $repoRoot
    summary = $summary
    warnings = @($warnings)
    findings = @($findings)
} | ConvertTo-Json -Depth 7 | Set-Content -LiteralPath $ReportPath -Encoding UTF8

if (@($warnings).Count -gt 0) {
    foreach ($warning in $warnings) {
        Write-WarnLine $warning
    }
}

if (@($findings).Count -eq 0) {
    Write-Pass "No OWASP Top 10 findings detected. Report: $ReportPath"
    exit 0
}

$blocking = $false
foreach ($finding in $findings) {
    if ((Get-SeverityRank -Severity $finding.severity) -ge (Get-SeverityRank -Severity "high")) {
        $blocking = $true
    }
}

Write-Host ("[INFO] Findings summary: critical={0}, high={1}, medium={2}, low={3}" -f $summary.critical, $summary.high, $summary.medium, $summary.low)
foreach ($finding in $findings) {
    Write-Host (" - [{0}] {1} | {2} | {3}:{4} :: {5}" -f $finding.severity.ToUpperInvariant(), $finding.category, $finding.id, $finding.file, $finding.line, $finding.note)
}
Write-Host "Report: $ReportPath"

if (-not $AllowHigh -and $blocking) {
    Write-Fail "Blocking findings present (high or critical)."
    exit 1
}

Write-WarnLine "Audit completed with non-blocking findings."
exit 0
