# ============================================================
# AgentHire AI — Stop All Services
# ============================================================
$ProjectDir = $PSScriptRoot
Set-Location $ProjectDir

Write-Host "`nStopping all AgentHire AI services..." -ForegroundColor Yellow
docker compose down
Write-Host "All services stopped." -ForegroundColor Green
