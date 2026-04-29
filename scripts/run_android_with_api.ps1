# Forwards device 127.0.0.1:8001 -> this PC's localhost:8001 so the app can use
# default API_BASE_URL http://127.0.0.1:8001 on a physical phone.
# Usage (from repo root): .\scripts\run_android_with_api.ps1
# Extra args pass through: .\scripts\run_android_with_api.ps1 -d DEVICE_ID

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent

$adbExe = $null
foreach ($candidate in @(
        "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
        "$env:ANDROID_HOME\platform-tools\adb.exe"
    )) {
    if ($candidate -and (Test-Path $candidate)) {
        $adbExe = $candidate
        break
    }
}
if (-not $adbExe) {
    $adbExe = "adb"
}

Write-Host "Using: $adbExe"
& $adbExe reverse tcp:8001 tcp:8001
Write-Host "adb reverse tcp:8001 tcp:8001 (device localhost:8001 -> PC :8001)"

Set-Location $ProjectRoot
Write-Host "Run backend in another terminal: backend\run_backend.ps1"
& flutter run @args
