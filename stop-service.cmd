@echo off
setlocal enabledelayedexpansion

:: Check if service exists
sc.exe query fluent-bit >nul 2>&1
if errorlevel 1 (
    echo Fluent Bit service is not installed
    exit /b 0
)

echo Stopping Fluent Bit service...
sc.exe stop fluent-bit >nul 2>&1
timeout /t 2 /nobreak >nul

:: Verify service is stopped
sc.exe query fluent-bit | find "STOPPED" >nul
if errorlevel 1 (
    echo Warning: Failed to stop Fluent Bit service
    echo Current service status:
    sc.exe query fluent-bit
    exit /b 1
) else (
    echo Fluent Bit service stopped successfully
)
