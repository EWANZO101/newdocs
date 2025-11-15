@echo off
REM addLocale.bat with Auto Path Detection
REM This script performs the following:
REM 0. Automatically detects SnailyCAD v4 installation paths
REM 1. Runs existing SnailyCAD project setup commands.
REM 2. Clones the locale-manager repository.
REM 3. Runs the locale addition script.
REM 4. Replaces the i18n.config.mjs in snaily-cadv4/apps/client with the updated version.
REM 5. Checks for start.bat and downloads it if missing.
REM 6. Prompts the user to open start.bat.
REM 7. Cleans up temporary files.

SETLOCAL ENABLEDELAYEDEXPANSION
REM ================================
REM Existing Project Setup Section
REM ================================
echo.
echo ================================
echo Starting SnailyCAD Project Setup
echo ================================
echo.

REM Navigate to the detected snaily-cadv4 project directory
cd /D "!SNAILYCAD_PATH!"
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to navigate to SnailyCAD directory.
    PAUSE
    EXIT /B 1
)

echo Current directory: !SNAILYCAD_PATH!
echo.

REM Execute the copy-env script for client and API
echo Running copy-env.mjs for client and API...
node scripts/copy-env.mjs --client --api
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to run copy-env.mjs. Please ensure Node.js is installed and the script exists.
    PAUSE
    EXIT /B 1
)

REM Pull the latest changes from the main branch
echo Pulling latest changes from Git...
git pull origin main
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to pull from Git. Please check your network connection and repository status.
    PAUSE
    EXIT /B 1
)

REM Stash any local changes and pull again to ensure the latest updates
echo Stashing local changes and pulling latest updates...
git stash && git pull origin main
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to stash or pull from Git. Please resolve any Git conflicts manually.
    PAUSE
    EXIT /B 1
)

REM Install project dependencies using pnpm
echo Installing project dependencies with pnpm...
pnpm install
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to install dependencies. Please ensure pnpm is installed correctly.
    PAUSE
    EXIT /B 1
)

REM Build the project
echo Building the project...
pnpm run build
IF %ERRORLEVEL% NEQ 0 (
    echo Build process failed. Please check the build scripts and dependencies.
    PAUSE
    EXIT /B 1
)

echo.
echo [32m[✓] All processes are completed.[0m
echo.
PAUSE

REM ================================
REM Post-Setup: Checking for start.bat
REM ================================
echo.
echo ================================
echo Post-Setup: Checking for start.bat
echo ================================
echo.

REM Define the path to start.bat
SET "START_BAT_PATH=!SNAILYCAD_PATH!\start.bat"

REM Check if start.bat exists
IF NOT EXIST "!START_BAT_PATH!" (
    echo start.bat not found. Downloading from GitHub...
    REM Download start.bat using PowerShell
    powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/EWANZO101/newdocs/main/caddownloads/start.bat' -OutFile '!START_BAT_PATH!'"
    IF %ERRORLEVEL% NEQ 0 (
        echo Failed to download start.bat. Please check your internet connection and try again.
        PAUSE
        EXIT /B 1
    )
    echo [32m[✓] start.bat has been downloaded successfully.[0m
) ELSE (
    echo [32m[✓] start.bat already exists.[0m
)

REM Prompt the user to open start.bat
set /p user_input=Do you want to open start.bat? (y/n): 
if /i "%user_input%"=="y" (
    start "" "!START_BAT_PATH!"
) else if /i "%user_input%"=="n" (
    echo Updater closed.
) else (
    echo Invalid input. Updater closed.
)

echo Press Enter to close the prompt.
pause >nul

ENDLOCAL
exit
