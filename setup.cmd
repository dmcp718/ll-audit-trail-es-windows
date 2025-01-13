@echo off
setlocal enabledelayedexpansion

:: Default values
set "DEFAULT_FSMOUNTPOINT="
set "FSMOUNTPOINT="

:: Parse command line arguments
:parse_args
if "%1"=="" goto check_args
if "%1"=="--fsmount" (
    set "FSMOUNTPOINT=%2"
    shift
    shift
    goto parse_args
)
if "%1"=="-h" goto show_usage
if "%1"=="--help" goto show_usage
echo Unknown parameter: %1
goto show_usage

:check_args
:: Check if required arguments are provided
if "%FSMOUNTPOINT%"=="" (
    echo.
    echo Error: --fsmount is required
    goto show_usage
)

:: Create .env file
echo FSMOUNTPOINT=%FSMOUNTPOINT%> .env

echo Configuration saved to .env file
echo You can now run start_docker_compose.cmd to start the services
goto :eof

:: Function to display usage
:show_usage
echo.
echo Usage: %~nx0 [options]
echo Options:
echo   --fsmount PATH    Set the LucidLink filespace mount point
echo.
echo Example:
echo   %~nx0 --fsmount D:\LucidLink
echo.
exit /b 1
