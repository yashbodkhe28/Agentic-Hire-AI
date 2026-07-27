# AgentHire AI - Smart Start Script
# Double-click or run: powershell -ExecutionPolicy Bypass -File START-PROJECT.ps1

Set-Location $PSScriptRoot
Write-Host "=== AgentHire AI Startup ===" -ForegroundColor Cyan

# Step 1: Start Docker Desktop ONLY if not already running
Write-Host "Checking Docker..." -ForegroundColor Yellow
docker info 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Starting Docker Desktop..." -ForegroundColor Yellow
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    Write-Host "Waiting for Docker to be ready (up to 120s)..." -ForegroundColor Yellow
    $ready = $false
    for ($i = 0; $i -lt 20; $i++) {
        Start-Sleep -Seconds 6
        docker info 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Docker ready!" -ForegroundColor Green
            $ready = $true
            break
        }
        Write-Host "  Waiting... ($($i * 6)s)" -ForegroundColor Gray
    }
    if (-not $ready) {
        Write-Host "ERROR: Docker Desktop did not start in time. Please open it manually." -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
} else {
    Write-Host "Docker already running!" -ForegroundColor Green
}

# Step 2: Bring up all services
Write-Host "`nStarting all services..." -ForegroundColor Yellow
docker compose up -d 2>&1 | ForEach-Object { Write-Host "  $_" }

Write-Host "`nWaiting 30 seconds for services to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Step 3: Show status
Write-Host "`n=== CONTAINER STATUS ===" -ForegroundColor Cyan
docker compose ps --format "table {{.Name}}`t{{.Status}}`t{{.Ports}}"

Write-Host "`n=== Service URLs ===" -ForegroundColor Cyan
Write-Host "Web App:        http://localhost:8090" -ForegroundColor Green
Write-Host "API Gateway:    http://localhost:8080" -ForegroundColor Green
Write-Host "Eureka:         http://localhost:8761" -ForegroundColor Green
Write-Host "Grafana:        http://localhost:3000  (admin/admin123)" -ForegroundColor Green
Write-Host "Zipkin:         http://localhost:9411" -ForegroundColor Green
Write-Host "Prometheus:     http://localhost:9090" -ForegroundColor Green
Write-Host "Kafka UI:       http://localhost:8089" -ForegroundColor Green

Write-Host "`nNOTE: Spring Boot apps take 90-120 seconds to fully start." -ForegroundColor Yellow
Write-Host "Wait 2 minutes then open the URLs above." -ForegroundColor Yellow

Read-Host "`nPress Enter to exit"
