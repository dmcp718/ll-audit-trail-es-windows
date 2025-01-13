@echo off
setlocal enabledelayedexpansion

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo Docker is not running. Please start Docker and try again.
    exit /b 1
)

REM Create docker network if it doesn't exist
docker network ls | findstr "elastic" >nul
if errorlevel 1 (
    echo Creating elastic network...
    docker network create elastic
)

REM Set environment variables
set "ELASTIC_VERSION=8.11.1"
set "ELASTIC_PASSWORD=changeme"
set "KIBANA_PASSWORD=changeme"
set "STACK_VERSION=%ELASTIC_VERSION%"
set "CLUSTER_NAME=docker-cluster"
set "LICENSE=basic"
set "ES_PORT=9200"
set "KIBANA_PORT=5601"
set "MEM_LIMIT=1073741824"

REM Start the stack with Docker Compose
echo Starting the Elastic stack...
docker-compose -f docker-compose.yml up -d

REM Wait for Elasticsearch to be ready
:wait_loop
echo Waiting for Elasticsearch...
timeout /t 5 /nobreak >nul
curl -s -u elastic:%ELASTIC_PASSWORD% http://localhost:%ES_PORT%/_cat/health >nul 2>&1
if errorlevel 1 (
    goto wait_loop
)

echo Elastic Stack is ready
REM Import saved objects
timeout /t 10 /nobreak >nul
call import-saved-objects.cmd
echo Access Kibana at: http://localhost:%KIBANA_PORT%
echo Username: elastic
echo Password: %ELASTIC_PASSWORD%
