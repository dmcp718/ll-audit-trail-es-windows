@echo off
setlocal enabledelayedexpansion

set "INSTALL_DIR=C:\fluent-bit"

:: Check if service exists
sc.exe query fluent-bit >nul 2>&1
if errorlevel 1 (
    echo Error: Fluent Bit service is not installed
    echo Please run setup.cmd first
    exit /b 1
)

echo Starting Fluent Bit service...
sc.exe start fluent-bit || (
    echo Failed to start Fluent Bit service
    echo Checking service status:
    sc.exe query fluent-bit
    echo.
    echo Checking Fluent Bit configuration:
    "%INSTALL_DIR%\bin\fluent-bit.exe" -c "%INSTALL_DIR%\conf\fs-audit-trail.conf" -R "%INSTALL_DIR%\conf\json-parser.conf" -v
    echo.
    echo Checking Application Event Log:
    powershell -Command "& { Get-WinEvent -LogName Application -MaxEvents 10 | Where-Object { $_.Message -like '*fluent*' -or $_.Message -like '*bit*' } | Format-List TimeCreated, Message }"
    exit /b 1
)

:: Verify service is running
sc.exe query fluent-bit | find "RUNNING" >nul
if errorlevel 1 (
    echo Error: Fluent Bit service is not running
    echo Checking service status:
    sc.exe query fluent-bit
    exit /b 1
) else (
    echo Fluent Bit service started successfully
)
