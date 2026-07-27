@echo off
title AgentHire AI - Project Launcher
color 0A
echo.
echo  =====================================================
echo   AgentHire AI - Full Stack Microservices Launcher
echo  =====================================================
echo.

:: Check if Docker Desktop is running
echo [1/5] Checking Docker Desktop...
docker info >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo  Docker Desktop not running. Starting it now...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    echo  Waiting for Docker to initialize...
    :WAIT_DOCKER
    timeout /t 8 /nobreak >nul
    docker info >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo  Still waiting...
        goto WAIT_DOCKER
    )
)
echo  Docker Desktop is READY!
echo.

:: Navigate to project
cd /d "C:\Users\yashb\Desktop\interviewProject\agenthire-ai"

:: Rebuild webapp with latest code (CSS/JS/views changes)
echo [2/5] Rebuilding Web App with latest changes...
docker compose build webapp
if %ERRORLEVEL% neq 0 (
    echo  WARNING: Webapp rebuild failed, using cached image.
)
echo.

:: Start all services
echo [3/5] Starting all 20 services...
docker compose up -d
if %ERRORLEVEL% neq 0 (
    echo  ERROR: Failed to start services.
    pause
    exit /b 1
)
echo.

:: Wait for Spring Boot apps to boot
echo [4/5] Waiting 2 minutes for Spring Boot apps to start...
timeout /t 30 /nobreak >nul
echo  30s - Infrastructure up...
timeout /t 30 /nobreak >nul
echo  60s - Services connecting...
timeout /t 30 /nobreak >nul
echo  90s - Apps booting...
timeout /t 30 /nobreak >nul
echo  120s - Done!
echo.

:: Show status
echo [5/5] Final Status:
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
echo.

echo  =====================================================
echo   PROJECT IS RUNNING! Open in your browser:
echo  =====================================================
echo.
echo   [MAIN APP]     http://localhost:8090
echo   [API GATEWAY]  http://localhost:8080
echo   [EUREKA]       http://localhost:8761  (eureka/eureka123)
echo   [GRAFANA]      http://localhost:3000  (admin/admin123)
echo   [ZIPKIN]       http://localhost:9411
echo   [KAFKA UI]     http://localhost:8089
echo.
echo   LOGIN:  admin@agenthire.ai  /  Admin@123
echo  =====================================================
echo.

start "" "http://localhost:8090"
start "" "http://localhost:8761"

echo  Done! Browsers opened.
pause
