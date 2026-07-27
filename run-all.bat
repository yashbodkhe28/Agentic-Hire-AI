@echo off
cd /d C:\Users\yashb\Desktop\interviewProject\agenthire-ai

echo === Checking Docker ===
docker info >nul 2>&1
if errorlevel 1 (
    echo Docker not ready, starting Docker Desktop...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    timeout /t 90 /nobreak >nul
)

echo === Starting Infrastructure ===
docker compose up -d mysql redis zookeeper kafka zipkin prometheus grafana kafka-ui
echo Infrastructure started. Exit: %ERRORLEVEL%

echo === Waiting 45s for MySQL and Kafka to be healthy ===
timeout /t 45 /nobreak >nul

echo === Starting Eureka + Config Server ===
docker compose up -d eureka-server config-server
echo Waiting 25s for Eureka...
timeout /t 25 /nobreak >nul

echo === Starting All Microservices ===
docker compose up -d api-gateway auth-service candidate-service recruiter-service interview-service live-coding-service agent-service notification-service analytics-service webapp
echo Done! Exit: %ERRORLEVEL%

echo.
echo ============================================
echo   AgentHire AI Services Status:
echo ============================================
docker compose ps
echo.
echo   Web App:    http://localhost:8090
echo   Eureka:     http://localhost:8761
echo   Grafana:    http://localhost:3000
echo   Zipkin:     http://localhost:9411
echo   Kafka UI:   http://localhost:8089
echo ============================================
