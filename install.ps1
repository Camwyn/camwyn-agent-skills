# Master installer for Camwyn Agent Skills
# Links all skills in this repo into your agent skills directory via NTFS Directory Junctions
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

$skills = Get-ChildItem -Path "$PSScriptRoot\skills" -Directory

foreach ($skill in $skills) {
    $dest = Join-Path $TargetDir $skill.Name
    
    if (Test-Path $dest) {
        Remove-Item -Path $dest -Recurse -Force
    }

    if ($Copy) {
        Write-Host "  [COPY]   $($skill.Name) -> $dest" -ForegroundColor Green
        Copy-Item -Path $skill.FullName -Destination $TargetDir -Recurse -Force
    } else {
        Write-Host "  [LINK]   $($skill.Name) -> $($skill.FullName)" -ForegroundColor Green
        New-Item -ItemType Junction -Path $dest -Target $skill.FullName | Out-Null
    }
}

$configTarget = "$HOME\.agents\obsidian-config.json"
if (-not (Test-Path $configTarget) -and (Test-Path "$PSScriptRoot\obsidian-config.json.example")) {
    Write-Host "`n  [CONFIG] Creating default config at $configTarget" -ForegroundColor Yellow
    Copy-Item -Path "$PSScriptRoot\obsidian-config.json.example" -Destination $configTarget
}

Write-Host "`nAll skills installed and active!" -ForegroundColor Cyan
Write-Host "Available skills:"
foreach ($skill in $skills) {
    Write-Host "  - /$($skill.Name)" -ForegroundColor White
}
