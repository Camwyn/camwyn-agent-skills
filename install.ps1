# Master installer for Camwyn Agent Skills
# Recursively links all skill packages into your agent skills directory via NTFS Directory Junctions
param (
    [string]$TargetDir = "$HOME\.agents\skills",
    [switch]$Copy = $false
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Camwyn Agent Skills Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Target Directory: $TargetDir`n" -ForegroundColor Gray

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
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

# Install obsidian-config.json if not present
$configTarget = "$HOME\.agents\obsidian-config.json"
$configExample = "$PSScriptRoot\skills\obsidian-rag\obsidian-config.json.example"
if (-not (Test-Path $configTarget) -and (Test-Path $configExample)) {
    Write-Host "`n  [CONFIG] Creating default config at $configTarget" -ForegroundColor Yellow
    Copy-Item -Path $configExample -Destination $configTarget
}

Write-Host "`nAll skills installed and active!" -ForegroundColor Cyan
Write-Host "Available skills ($($installedSkills.Count)):"
foreach ($s in ($installedSkills | Sort-Object)) {
    Write-Host "  - /$s" -ForegroundColor White
}
