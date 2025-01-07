@echo off
REM addLocale.bat
REM This script performs the following:
REM 1. Runs existing SnailyCAD project setup commands.
REM 2. Clones the locale-manager repository.
REM 3. Runs the locale addition script.
REM 4. Replaces the i18n.config.mjs in snaily-cadv4/apps/client with the updated version.
REM 5. Checks for start.bat and downloads it if missing.
REM 6. Prompts the user to open start.bat.
REM 7. Cleans up temporary files.

REM ================================
REM Existing Project Setup Section
REM ================================

echo.
echo ================================
echo Starting SnailyCAD Project Setup
echo ================================
echo.

REM Navigate to the snaily-cadv4 project directory
cd /D "%USERPROFILE%\Documents\snaily-cadv4"
IF %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to navigate to snaily-cadv4 directory.
    PAUSE
    EXIT /B 1
)

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
echo All processes are completed.
echo.
PAUSE



echo.
echo ================================
echo Post-Setup: Checking for start.bat
echo ================================
echo.

REM Define the path to start.bat
SET "START_BAT_PATH=%CD%\start.bat"

REM Check if start.bat exists
IF NOT EXIST "%START_BAT_PATH%" (
    echo start.bat not found. Downloading from GitHub...
    REM Download start.bat using PowerShell
    powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/EWANZO101/newdocs/main/caddownloads/start%282%29.bat' -OutFile '%START_BAT_PATH%'"
    IF %ERRORLEVEL% NEQ 0 (
        echo Failed to download start.bat. Please check your internet connection and try again.
        PAUSE
        EXIT /B 1
    )
    echo start.bat has been downloaded successfully.
) ELSE (
    echo start.bat already exists at "%START_BAT_PATH%".
)

REM Prompt the user to open start.bat
set /p user_input=Do you want to open start.bat? (y/n): 
if /i "%user_input%"=="y" (
    start "" "%START_BAT_PATH%"
) else if /i "%user_input%"=="n" (
    echo Updater closed.
) else (
    echo Invalid input. Updater closed.
)

echo Press Enter to close the prompt.
pause >nul
exit
