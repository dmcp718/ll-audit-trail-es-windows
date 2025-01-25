@echo off
setlocal enabledelayedexpansion

:: Parse command line arguments
set "FSMOUNT="
set "INSTALL_DIR=C:\fluent-bit"

:parse_args
if "%~1"=="" goto :after_args
if /i "%~1"=="--fsmount" (
    set "FSMOUNT=%~2"
    shift
)
shift
goto :parse_args

:after_args

:: Validate required arguments
if not defined FSMOUNT (
    echo Error: --fsmount parameter is required
    echo Usage: setup.cmd --fsmount ^<mount_path^>
    echo Example: setup.cmd --fsmount "D:\Volumes\production"
    exit /b 1
)

:: Save mount point to .env file for future reference
echo FSMOUNT=%FSMOUNT%> .env

:: Check if Fluent Bit is already installed
set "NEED_INSTALL=0"
if not exist "%INSTALL_DIR%\bin\fluent-bit.exe" (
    set "NEED_INSTALL=1"
)

:: Download and install Fluent Bit if needed
if "%NEED_INSTALL%"=="1" (
    echo Downloading Fluent Bit...
    powershell -Command "& { Invoke-WebRequest -Uri 'https://fluentbit.io/releases/2.2/fluent-bit-2.2.2-win64.zip' -OutFile 'fluent-bit.zip' }"
    
    echo Extracting Fluent Bit...
    powershell -Command "& { Expand-Archive -Path 'fluent-bit.zip' -DestinationPath 'C:\' -Force }"
    
    echo Cleaning up...
    del fluent-bit.zip
)

:: Create necessary directories
if not exist "%INSTALL_DIR%\conf" mkdir "%INSTALL_DIR%\conf"
if not exist "%INSTALL_DIR%\db" mkdir "%INSTALL_DIR%\db"

:: Generate Fluent Bit configuration from template
echo Generating Fluent Bit configuration...
(for /f "usebackq delims=" %%a in ("fs-audit-trail.conf.template") do (
    set "line=%%a"
    set "line=!line:${FSMOUNT}=%FSMOUNT%!"
    echo !line!
)) > "%INSTALL_DIR%\conf\fs-audit-trail.conf"

:: Copy parser configuration
copy /Y "json-parser.conf" "%INSTALL_DIR%\conf\"

:: Verify configuration files exist
if not exist "%INSTALL_DIR%\conf\fs-audit-trail.conf" (
    echo Error: Configuration file fs-audit-trail.conf not found
    exit /b 1
)
if not exist "%INSTALL_DIR%\conf\json-parser.conf" (
    echo Error: Configuration file json-parser.conf not found
    exit /b 1
)

:: Create Fluent Bit service
echo Setting up Fluent Bit service...

:: Stop and remove existing service if it exists
sc.exe query fluent-bit >nul 2>&1
if not errorlevel 1 (
    echo Removing existing Fluent Bit service...
    call stop-service.cmd
    sc.exe delete fluent-bit >nul 2>&1
    timeout /t 2 /nobreak >nul
) else (
    echo No existing Fluent Bit service found
)

echo Creating Fluent Bit service...
:: Note the escaped quotes around the paths and no spaces after '='
sc.exe create fluent-bit binpath= "\"%INSTALL_DIR%\bin\fluent-bit.exe\" -c \"%INSTALL_DIR%\conf\fs-audit-trail.conf\" -R \"%INSTALL_DIR%\conf\json-parser.conf\" -v" DisplayName= "Fluent Bit" start= auto || (
    echo Failed to create Fluent Bit service
    exit /b 1
)

echo Setup completed successfully
echo.
echo To start the service, run: start-service.cmd
echo To stop the service, run: stop-service.cmd
