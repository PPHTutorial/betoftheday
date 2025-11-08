# PowerShell script to download football team logos
# Usage: .\scripts\download_logos.ps1

$ErrorActionPreference = "Continue"

# Create teams directory
$teamsDir = "assets\teams"
if (-not (Test-Path $teamsDir)) {
    New-Item -ItemType Directory -Path $teamsDir -Force | Out-Null
    Write-Host "Created directory: $teamsDir" -ForegroundColor Green
}

# Pages to scrape
$pages = @(
    "https://1000logos.net/soccer/",
    "https://1000logos.net/soccer/page/2/"
)

Write-Host "`nStarting logo download from 1000logos.net..." -ForegroundColor Cyan
Write-Host "Note: This script requires manual execution or a web scraping tool." -ForegroundColor Yellow
Write-Host "`nFor best results, use:" -ForegroundColor Yellow
Write-Host "1. Python script: python scripts\download_logos.py" -ForegroundColor Cyan
Write-Host "2. Or use a browser extension like 'Image Downloader'" -ForegroundColor Cyan
Write-Host "3. Or manually download from the pages:" -ForegroundColor Cyan
foreach ($page in $pages) {
    Write-Host "   - $page" -ForegroundColor Gray
}

Write-Host "`nAlternatively, you can use wget or curl with proper parsing." -ForegroundColor Yellow

# Function to sanitize filename
function Sanitize-Filename {
    param([string]$name)
    $name = $name.ToLower()
    $name = $name -replace '[^a-z0-9_-]', '_'
    $name = $name -replace '_+', '_'
    return $name.Trim('_')
}

Write-Host "`nScript ready. Please use Python script for automated download." -ForegroundColor Green

