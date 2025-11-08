# PowerShell script to find and verify Android keystore files
# This script searches for .jks and .keystore files and checks their SHA1 fingerprints

Write-Host "Searching for keystore files..." -ForegroundColor Cyan

# Expected SHA1 fingerprint
$expectedSHA1 = "03:F9:44:6A:9F:3F:3B:CF:83:01:E7:D3:B3:C0:39:CE:A2:72:E6:0A"
$expectedSHA1Clean = $expectedSHA1.Replace(":", "").ToLower()

Write-Host "`nExpected SHA1: $expectedSHA1" -ForegroundColor Yellow
Write-Host "Searching in common locations...`n" -ForegroundColor Cyan

# Search in common locations
$searchPaths = @(
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\AndroidStudioProjects",
    "E:\Projects\Flutter",
    "E:\Projects\Android"
)

$foundKeystores = @()

foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        Write-Host "Searching in: $path" -ForegroundColor Gray
        $jksFiles = Get-ChildItem -Path $path -Filter "*.jks" -Recurse -ErrorAction SilentlyContinue
        $keystoreFiles = Get-ChildItem -Path $path -Filter "*.keystore" -Recurse -ErrorAction SilentlyContinue
        
        $foundKeystores += $jksFiles
        $foundKeystores += $keystoreFiles
    }
}

if ($foundKeystores.Count -eq 0) {
    Write-Host "`nNo keystore files found in common locations." -ForegroundColor Red
    Write-Host "Please manually locate your keystore file or check Google Play Console for backup instructions." -ForegroundColor Yellow
    exit
}

Write-Host "`nFound $($foundKeystores.Count) keystore file(s):" -ForegroundColor Green
Write-Host "=" * 80

foreach ($keystore in $foundKeystores) {
    Write-Host "`nChecking: $($keystore.FullName)" -ForegroundColor Cyan
    
    # Try to get SHA1 using keytool
    try {
        # You'll need to manually enter the password
        Write-Host "Checking fingerprint..." -ForegroundColor Gray
        $keytoolOutput = & keytool -list -v -keystore $keystore.FullName -storepass "123456" -alias "upload" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            # Extract SHA1 from output
            $sha1Line = $keytoolOutput | Select-String -Pattern "SHA1:\s*([0-9A-F:]+)"
            if ($sha1Line) {
                $sha1 = $sha1Line.Matches[0].Groups[1].Value
                $sha1Clean = $sha1.Replace(":", "").ToLower()
                
                Write-Host "SHA1: $sha1" -ForegroundColor $(if ($sha1 -eq $expectedSHA1) { "Green" } else { "Red" })
                
                if ($sha1 -eq $expectedSHA1) {
                    Write-Host "`n✓ MATCH FOUND! This is the correct keystore!" -ForegroundColor Green -BackgroundColor Black
                    Write-Host "Copy this file to: android/app/upload-keystore.jks" -ForegroundColor Yellow
                }
            }
        } else {
            Write-Host "Could not verify (wrong password or alias). Try with different password." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error checking keystore: $_" -ForegroundColor Red
    }
}

Write-Host "`n" + ("=" * 80)
Write-Host "`nIf no matching keystore was found:" -ForegroundColor Yellow
Write-Host "1. Check Google Play Console > Setup > App Signing for key download" -ForegroundColor White
Write-Host "2. Check backup locations (USB drives, cloud storage, etc.)" -ForegroundColor White
Write-Host "3. If you used App Signing by Google Play, you may need to request key reset" -ForegroundColor White

