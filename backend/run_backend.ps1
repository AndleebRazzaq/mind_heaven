param(
  [int]$Port = 8001,
  [string]$BindHost = "0.0.0.0",
  [switch]$OpenDocs
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$pythonExe = Join-Path $projectRoot ".venv\Scripts\python.exe"

if (-not (Test-Path $pythonExe)) {
  Write-Error "Python venv not found at $pythonExe. Create it first in backend/.venv."
}

# Free the port if an old server process still owns it.
$pids = @(
  netstat -ano |
    Select-String ":$Port" |
    ForEach-Object { ($_ -split "\s+")[-1] } |
    Where-Object { $_ -match "^\d+$" } |
    Select-Object -Unique
)

foreach ($procId in $pids) {
  try {
    taskkill /PID $procId /F | Out-Null
  } catch {
    # Ignore taskkill failures and continue.
  }
}

if ($OpenDocs) {
  Start-Process "http://127.0.0.1:$Port/docs" | Out-Null
}

Set-Location $projectRoot
Write-Host "Starting FastAPI on http://$BindHost`:$Port"
Write-Host "Swagger: http://127.0.0.1:$Port/docs"
& $pythonExe -m uvicorn app.main:app --host $BindHost --port $Port
