# ============================================================
# AgentHire AI — One-Click Startup Script
# Run from project root: .\start.ps1
# ============================================================

$ProjectDir = $PSScriptRoot

Write-Host "`n=================================================" -ForegroundColor Cyan
Write-Host "  AgentHire AI - Starting All Services" -ForegroundColor Cyan
Write-Host "=================================================`n" -ForegroundColor Cyan

# Step 1: Start Docker Desktop if not running
Write-Host "[1/4] Checking Docker..." -ForegroundColor Yellow
$dockerOk = $false
try {
    $info = docker info 2>&1
    if ($LASTEXITCODE -eq 0) { $dockerOk = $true }
} catch {}

if (-not $dockerOk) {
    Write-Host "     Starting Docker Desktop..." -ForegroundColor Gray
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    Write-Host "     Waiting for Docker to initialize (up to 120s)..." -ForegroundColor Gray
    for ($i = 1; $i -le 24; $i++) {
        Start-Sleep -Seconds 5
        $info = docker info 2>&1
        if ($LASTEXITCODE -eq 0) { $dockerOk = $true; break }
        Write-Host "     Still waiting... $($i*5)s" -ForegroundColor DarkGray
    }
}

if (-not $dockerOk) {
    Write-Host "ERROR: Docker not ready after 120s. Please start Docker Desktop manually." -ForegroundColor Red
    exit 1
}
Write-Host "     Docker OK!" -ForegroundColor Green

# Step 2: Start infrastructure
Write-Host "`n[2/4] Starting infrastructure (MySQL, Redis, Kafka, Prometheus, Grafana, Zipkin)..." -ForegroundColor Yellow
Set-Location $ProjectDir
docker compose up -d mysql redis zookeeper kafka zipkin prometheus grafana kafka-ui
Write-Host "     Infrastructure containers started." -ForegroundColor Green

# Step 3: Wait for MySQL and Kafka to be healthy
Write-Host "`n[3/4] Waiting for MySQL and Kafka to be healthy (up to 60s)..." -ForegroundColor Yellow
$healthy = $false
for ($i = 1; $i -le 12; $i++) {
    Start-Sleep -Seconds 5
    $mysqlHealth = docker inspect --format "{{.State.Health.Status}}" agenthire-mysql 2>&1
    $kafkaHealth = docker inspect --format "{{.State.Health.Status}}" agenthire-kafka 2>&1
    Write-Host "     MySQL: $mysqlHealth | Kafka: $kafkaHealth" -ForegroundColor DarkGray
    if ($mysqlHealth -eq "healthy" -and $kafkaHealth -eq "healthy") {
        $healthy = $true; break
    }
}
if (-not $healthy) {
    Write-Host "     Warning: Services may not be fully healthy yet, starting apps anyway..." -ForegroundColor Yellow
}

# Step 4: Start microservices
Write-Host "`n[4/4] Starting all microservices..." -ForegroundColor Yellow
docker compose up -d eureka-server config-server
Write-Host "     Waiting 20s for Eureka+Config..." -ForegroundColor Gray
Start-Sleep -Seconds 20

docker compose up -d api-gateway auth-service candidate-service recruiter-service interview-service live-coding-service agent-service notification-service analytics-service webapp
Write-Host "     All microservices started!" -ForegroundColor Green

# Summary
Write-Host "`n=================================================" -ForegroundColor Cyan
Write-Host "  AgentHire AI is starting up!" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Web App:      http://localhost:8090" -ForegroundColor White
Write-Host "  API Gateway:  http://localhost:8080" -ForegroundColor White
Write-Host "  Eureka:       http://localhost:8761" -ForegroundColor White
Write-Host "  Grafana:      http://localhost:3000  (admin/admin123)" -ForegroundColor White
Write-Host "  Zipkin:       http://localhost:9411" -ForegroundColor White
Write-Host "  Prometheus:   http://localhost:9090" -ForegroundColor White
Write-Host "  Kafka UI:     http://localhost:8089" -ForegroundColor White
Write-Host ""
Write-Host "  Run 'docker compose logs -f' to see live logs" -ForegroundColor DarkGray
Write-Host "  Run 'docker compose ps' to check container status" -ForegroundColor DarkGray
Write-Host "  Run '.\stop.ps1' to stop all services" -ForegroundColor DarkGray
Write-Host ""
