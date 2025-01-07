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

REM ================================
REM Locale Manager Automation Section
REM ================================

echo.
echo ================================
echo Starting Locale Manager Automation
echo ================================
echo.

REM Configuration Section
REM ================================
REM Set the GitHub repository URL for locale-manager
SET "LOCALE_MANAGER_REPO=https://github.com/EWANZO101/newdocs.git"

REM Set the directory where the repository will be cloned
SET "CLONE_DIR=%TEMP%\locale-manager-temp"

REM Set the path to your target project's i18n.config.mjs
SET "TARGET_CONFIG_PATH=%CD%\apps\client\i18n.config.mjs"

REM Set the path to your target project's locales directory
SET "TARGET_LOCALES_DIR=%CD%\apps\client\locales"

REM Validate that TARGET_CONFIG_PATH exists
IF NOT EXIST "%TARGET_CONFIG_PATH%" (
    echo Error: The target i18n.config.mjs does not exist at "%TARGET_CONFIG_PATH%".
    PAUSE
    EXIT /B 1
)

REM Validate that TARGET_LOCALES_DIR exists
IF NOT EXIST "%TARGET_LOCALES_DIR%" (
    echo Error: The target locales directory does not exist at "%TARGET_LOCALES_DIR%".
    PAUSE
    EXIT /B 1
)

REM Script Execution Section
REM ================================
REM Step 1: Clone the locale-manager repository
echo Cloning locale-manager repository from %LOCALE_MANAGER_REPO% into %CLONE_DIR%...
git clone %LOCALE_MANAGER_REPO% "%CLONE_DIR%"
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to clone the repository. Please check the repository URL and your internet connection.
    PAUSE
    EXIT /B 1
)

REM Step 2: Navigate to the cloned repository's locale-manager folder
REM Assuming the locale-manager is in caddownloads/locale-manager in newdocs
cd /D "%CLONE_DIR%\caddownloads\locale-manager"
IF %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to navigate to locale-manager directory.
    PAUSE
    EXIT /B 1
)

REM Check if the locale-manager folder exists
IF NOT EXIST "%CLONE_DIR%\caddownloads\locale-manager" (
    echo Error: locale-manager directory does not exist in the cloned repository.
    PAUSE
    EXIT /B 1
)

REM Step 3: Install Node.js dependencies
echo Installing Node.js dependencies for locale-manager...
npm install
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to install dependencies. Ensure that Node.js and npm are installed correctly.
    PAUSE
    EXIT /B 1
)

REM Step 4: Set environment variables for the locale manager script
REM These variables are already set above; ensure they are accessible
REM No action needed as environment variables are inherited

REM Step 5: Run the add-locale script
echo Running the add-locale script...
npm run add-locale
IF %ERRORLEVEL% NEQ 0 (
    echo The add-locale script encountered an error.
    PAUSE
    EXIT /B 1
)

REM Step 6: Replace the target i18n.config.mjs with the updated version
echo Replacing the target i18n.config.mjs with the updated configuration...
COPY /Y "%CLONE_DIR%\caddownloads\locale-manager\apps\client\i18n.config.mjs" "%TARGET_CONFIG_PATH%"
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to copy the updated i18n.config.mjs. Please check the target path.
    PAUSE
    EXIT /B 1
)

REM Step 7: Clean up by deleting the cloned repository
echo Cleaning up temporary files...
rd /S /Q "%CLONE_DIR%"
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to delete the temporary directory "%CLONE_DIR%". Please delete it manually.
    PAUSE
    EXIT /B 1
)

echo.
echo Locale setup and configuration update complete.
echo.
PAUSE

REM ================================
REM Post-Setup Prompt Section
REM ================================

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
