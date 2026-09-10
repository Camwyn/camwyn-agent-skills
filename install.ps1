# Master installer for Camwyn Agent Skills
# Recursively links all skill packages into your agent skills directory via NTFS Directory Junctions
param (
    [string]$TargetDir = "$HOME\.agents\skills",
    [string]$RulesDir = "$HOME\.agents\rules",
    [string]$BinDir = "$HOME\.agents\bin",
    [string]$ScriptsDir = "$HOME\.agents\scripts",
    [string]$HooksDir = "$HOME\.agents\hooks",
    [switch]$Copy = $false
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Camwyn Agent Skills Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Target Directory : $TargetDir" -ForegroundColor Gray
Write-Host "Rules Directory  : $RulesDir" -ForegroundColor Gray
Write-Host "Bin Directory    : $BinDir`n" -ForegroundColor Gray

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}
if (-not (Test-Path $BinDir)) {
    New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
}

# Find all directories that directly contain a SKILL.md file
$skillFiles = Get-ChildItem -Path "$PSScriptRoot\skills" -Filter "SKILL.md" -Recurse
$installedSkills = @()

foreach ($skillFile in $skillFiles) {
    $skillFolder = $skillFile.Directory
    $skillName = $skillFolder.Name
    $dest = Join-Path $TargetDir $skillName
    
    if (Test-Path $dest) {
        Remove-Item -Path $dest -Recurse -Force
    }

    if ($Copy) {
        Write-Host "  [COPY]   $skillName -> $dest" -ForegroundColor Green
        Copy-Item -Path $skillFolder.FullName -Destination $TargetDir -Recurse -Force
    } else {
        Write-Host "  [LINK]   $skillName -> $($skillFolder.FullName)" -ForegroundColor Green
        New-Item -ItemType Junction -Path $dest -Target $skillFolder.FullName | Out-Null
    }
    $installedSkills += $skillName
}

# Link or copy behavioral rules into .agents/rules
$installedRules = @()
if (Test-Path "$PSScriptRoot\rules") {
    if (-not (Test-Path $RulesDir)) {
        New-Item -ItemType Directory -Path $RulesDir -Force | Out-Null
    }
    $ruleFiles = Get-ChildItem -Path "$PSScriptRoot\rules" -Filter "*.md"
    foreach ($rule in $ruleFiles) {
        $dest = Join-Path $RulesDir $rule.Name
        if (Test-Path $dest) {
            Remove-Item -Path $dest -Force
        }
        if ($Copy) {
            Copy-Item -Path $rule.FullName -Destination $dest -Force
            Write-Host "  [COPY]   Rule: $($rule.Name)" -ForegroundColor Green
        } else {
            try {
                New-Item -ItemType HardLink -Path $dest -Target $rule.FullName -ErrorAction Stop | Out-Null
                Write-Host "  [LINK]   Rule: $($rule.Name)" -ForegroundColor Green
            } catch {
                Copy-Item -Path $rule.FullName -Destination $dest -Force
                Write-Host "  [COPY]   Rule: $($rule.Name)" -ForegroundColor Yellow
            }
        }
        $installedRules += $rule.Name
    }
}

# Install git post-commit hook if in a git repository
$gitHooksDir = Join-Path $PSScriptRoot ".git\hooks"
if ((Test-Path $gitHooksDir) -and (Test-Path "$PSScriptRoot\scripts\post-commit")) {
    $hookDest = Join-Path $gitHooksDir "post-commit"
    Copy-Item -Path "$PSScriptRoot\scripts\post-commit" -Destination $hookDest -Force
    Write-Host "  [HOOK]   post-commit -> $hookDest" -ForegroundColor Green
}

# Install CLI tools into BinDir
$installedBin = @()
if (Test-Path "$PSScriptRoot\bin") {
    $binFiles = Get-ChildItem -Path "$PSScriptRoot\bin" -File
    foreach ($bin in $binFiles) {
        $dest = Join-Path $BinDir $bin.Name
        Copy-Item -Path $bin.FullName -Destination $dest -Force
        Write-Host "  [CLI]    $($bin.Name) -> $dest" -ForegroundColor Green
        $installedBin += $bin.Name
    }
}

# Install supporting scripts into ScriptsDir
if (Test-Path "$PSScriptRoot\scripts") {
    if (-not (Test-Path $ScriptsDir)) {
        New-Item -ItemType Directory -Path $ScriptsDir -Force | Out-Null
    }
    $scriptFiles = Get-ChildItem -Path "$PSScriptRoot\scripts" -File
    foreach ($sf in $scriptFiles) {
        $dest = Join-Path $ScriptsDir $sf.Name
        Copy-Item -Path $sf.FullName -Destination $dest -Force
        Write-Host "  [SCRIPT] $($sf.Name) -> $dest" -ForegroundColor Green
    }
}

# Install Claude Code hook adapters into HooksDir
$installedHooks = @()
if (Test-Path "$PSScriptRoot\hooks") {
    if (-not (Test-Path $HooksDir)) {
        New-Item -ItemType Directory -Path $HooksDir -Force | Out-Null
    }
    foreach ($hk in (Get-ChildItem -Path "$PSScriptRoot\hooks" -File)) {
        $dest = Join-Path $HooksDir $hk.Name
        Copy-Item -Path $hk.FullName -Destination $dest -Force
        Write-Host "  [HOOK]   $($hk.Name) -> $dest" -ForegroundColor Green
        $installedHooks += $hk.Name
    }
}

# Install obsidian-config.json if not present
$configTarget = "$HOME\.agents\obsidian-config.json"
$configExample = "$PSScriptRoot\skills\obsidian-rag\obsidian-config.json.example"
if (-not (Test-Path $configTarget) -and (Test-Path $configExample)) {
    Write-Host "`n  [CONFIG] Creating default config at $configTarget" -ForegroundColor Yellow
    Copy-Item -Path $configExample -Destination $configTarget
}

$pathEnv = [System.Environment]::GetEnvironmentVariable("PATH", "User")
$inPath = $pathEnv -split ';' -contains $BinDir

Write-Host "`nAll skills, rules, and CLI tools installed!" -ForegroundColor Cyan
if (-not $inPath) {
    Write-Host "NOTE: To run 'obsidian-sync' from any terminal, add $BinDir to your User PATH:" -ForegroundColor Yellow
    Write-Host "  [System.Environment]::SetEnvironmentVariable('PATH', `"`$env:PATH;$BinDir`", 'User')`n" -ForegroundColor DarkGray
}
Write-Host "Available skills ($($installedSkills.Count)):"
foreach ($s in ($installedSkills | Sort-Object)) {
    Write-Host "  - /$s" -ForegroundColor White
}

if ($installedRules.Count -gt 0) {
    Write-Host "Active rules ($($installedRules.Count)):"
    foreach ($r in ($installedRules | Sort-Object)) {
        Write-Host "  - $r" -ForegroundColor White
    }
}

if ($installedHooks.Count -gt 0) {
    Write-Host "Hook adapters ($($installedHooks.Count)) installed to ${HooksDir}:"
    foreach ($h in ($installedHooks | Sort-Object)) {
        Write-Host "  - $h" -ForegroundColor White
    }
    Write-Host "  Add these to ~/.claude/settings.json to activate them:" -ForegroundColor Yellow
    Write-Host "    SessionStart      -> $HooksDir\cc-session-start.ps1" -ForegroundColor DarkGray
    Write-Host "    PostToolUse:Bash  -> $HooksDir\cc-post-bash.ps1" -ForegroundColor DarkGray
    Write-Host "  (each as a `"type`":`"command`" hook: powershell -NoProfile -ExecutionPolicy Bypass -File `"<path>`")" -ForegroundColor DarkGray
}

Write-Host "`nNext Step:" -ForegroundColor Cyan
Write-Host "  Run '/obsidian-setup' in chat to configure your vault (set 'vault_path'), or customize '$configTarget'`n" -ForegroundColor Gray
